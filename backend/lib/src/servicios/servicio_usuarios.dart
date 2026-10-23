import 'package:sqlite3/sqlite3.dart';

import '../comun/errores.dart';
import '../comun/fechas.dart';
import '../comun/json.dart';
import '../comun/seguridad.dart';
import '../db/base_datos.dart';
import '../db/repositorio_usuarios.dart';
import '../modelos/usuario.dart';

/// PIN de 4 a 6 dígitos.
final _patronPin = RegExp(r'^\d{4,6}$');

/// Fallos seguidos que bloquean la verificación de PIN.
const maxIntentosPin = 5;
const bloqueoPin = Duration(minutes: 1);

/// Personal con PIN y autorización de acciones sensibles.
class ServicioUsuarios {
  ServicioUsuarios({
    required this._db,
    required this._repo,
    this._reloj = relojSistema,
  });

  final Database _db;
  final RepositorioUsuarios _repo;
  final Reloj _reloj;

  var _fallos = 0;
  DateTime? _bloqueadoHasta;

  List<Usuario> listar() => _repo.listar();

  /// Usuario activo con ese id, para guardar quién cobró o abrió la caja.
  /// `null` si [id] es `null`; `datos_invalidos` en [campo] si no existe.
  Usuario? activo(String? id, {String campo = 'usuarioId'}) {
    if (id == null) return null;
    final u = _repo.porId(id);
    if (u == null || !u.activo) {
      throw ErrorApi.datosInvalidos({
        campo: 'No hay un usuario activo con ese id',
      });
    }
    return u;
  }

  Usuario crear(Map<String, Object?> datos) {
    final v = Validador(datos);
    final nombre = v.texto('nombre', max: 80);
    final rol = v.opcion('rol', rolesUsuario);
    final pin = _leerPin(v, 'pin');
    final pinAutoriza = v.texto('pinAutoriza', requerido: false, max: 6);
    v.comprobar();

    final id = generarId('u');
    return transaccion(_db, () {
      if (_repo.contar() == 0) {
        if (rol != 'dueno') {
          throw ErrorApi.datosInvalidos({
            'rol': 'El primer usuario es la cuenta maestra: debe ser dueno',
          });
        }
      } else {
        final quien = _autorizador(pinAutoriza);
        if (rol == 'dueno' && quien.rol != 'dueno') throw ErrorApi.sinPermiso();
      }
      final hash = _hash(pin!);
      _pinLibre(hash);
      _repo.insertar(
        id: id,
        nombre: nombre!,
        rol: rol!,
        pinHash: hash,
        creado: instanteIso(_reloj()),
      );
      return _repo.porId(id)!;
    });
  }

  Usuario editar(String id, Map<String, Object?> datos) {
    final v = Validador(datos);
    final nombre = v.texto('nombre', requerido: false, max: 80);
    final rol = v.opcion('rol', rolesUsuario, requerido: false);
    final activo = datos['activo'];
    if (activo != null && activo is! bool) {
      v.error('activo', 'Debe ser true o false');
    }
    final pin = datos['pin'] == null ? null : _leerPin(v, 'pin');
    final pinAutoriza = v.texto('pinAutoriza', requerido: false, max: 6);
    v.comprobar();

    return transaccion(_db, () {
      final actual = _repo.porId(id);
      if (actual == null) throw ErrorApi.noEncontrado('el usuario');
      final quien = _autorizador(pinAutoriza);
      if ((actual.rol == 'dueno' || rol == 'dueno') && quien.rol != 'dueno') {
        throw ErrorApi.sinPermiso();
      }

      final nuevoRol = rol ?? actual.rol;
      final nuevoActivo = activo as bool? ?? actual.activo;
      String? hash;
      if (pin != null) {
        hash = _hash(pin);
        _pinLibre(hash, excepto: id);
      } else if (nuevoActivo && !actual.activo) {
        // Al reactivar, su PIN anterior no puede chocar con uno activo.
        final r = _db.select('SELECT pin_hash FROM usuarios WHERE id = ?', [
          id,
        ]);
        _pinLibre(r.first['pin_hash'] as String, excepto: id);
      }
      _repo.actualizar(
        id,
        nombre: nombre ?? actual.nombre,
        rol: nuevoRol,
        activo: nuevoActivo,
        pinHash: hash,
      );
      if (_repo.contarActivos(roles: {'dueno'}) == 0) {
        throw ErrorApi.datosInvalidos({
          actual.rol == 'dueno' && nuevoRol != 'dueno' ? 'rol' : 'activo':
              'El depósito necesita al menos un dueño activo',
        });
      }
      return _repo.porId(id)!;
    });
  }

  /// `POST /usuarios/verificar`: de quién es el PIN.
  Usuario verificar(Map<String, Object?> datos) {
    final v = Validador(datos);
    final pin = v.texto('pin', max: 6);
    final usuarioId = v.texto('usuarioId', requerido: false, max: 40);
    v.comprobar();
    final u = _porPin(pin!);
    if (usuarioId != null && u.id != usuarioId) {
      _fallo();
      throw ErrorApi.pinInvalido();
    }
    return u;
  }

  /// Autorización de una acción sensible (cancelar, devolver).
  ///
  /// Si no hay ningún dueño ni gerente activo, no se pide y regresa `null`.
  /// Si hay, [pin] debe ser de uno de ellos.
  Usuario? autorizar(String? pin) {
    if (_repo.contarActivos(roles: {'dueno', 'gerente'}) == 0) return null;
    return _autorizador(pin);
  }

  Usuario _autorizador(String? pin) {
    if (pin == null) throw ErrorApi.pinInvalido();
    final u = _porPin(pin);
    if (!u.autoriza) throw ErrorApi.sinPermiso();
    return u;
  }

  Usuario _porPin(String pin) {
    final ahora = _reloj();
    final hasta = _bloqueadoHasta;
    if (hasta != null && ahora.isBefore(hasta)) {
      throw ErrorApi.demasiadosIntentos();
    }
    final u = _patronPin.hasMatch(pin) ? _repo.activoPorPin(_hash(pin)) : null;
    if (u == null) {
      _fallo();
      throw ErrorApi.pinInvalido();
    }
    _fallos = 0;
    return u;
  }

  void _fallo() {
    if (++_fallos >= maxIntentosPin) {
      _fallos = 0;
      _bloqueadoHasta = _reloj().add(bloqueoPin);
    }
  }

  String? _leerPin(Validador v, String campo) => v.texto(
    campo,
    min: 4,
    max: 6,
    patron: _patronPin,
    mensajePatron: 'Debe tener de 4 a 6 dígitos',
  );

  void _pinLibre(String hash, {String? excepto}) {
    final otro = _repo.activoPorPin(hash);
    if (otro != null && otro.id != excepto) {
      throw ErrorApi.datosInvalidos({'pin': 'Ese PIN ya lo usa otra persona'});
    }
  }

  String _hash(String pin) => hashClave('${_repo.sal}:$pin');
}
