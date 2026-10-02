import '../comun/errores.dart';
import '../comun/fechas.dart';
import '../comun/json.dart';
import '../comun/seguridad.dart';
import '../db/repositorio_terminales.dart';
import '../modelos/terminal.dart';
import '../ws/hub.dart';

/// Emparejamiento, registro y autenticación de terminales.
class ServicioTerminales {
  ServicioTerminales({
    required RepositorioTerminales repositorio,
    required Hub hub,
    Reloj reloj = relojSistema,
  }) : _repo = repositorio,
       _hub = hub,
       _reloj = reloj;

  static const vigenciaCodigo = Duration(minutes: 10);
  static const intentosPorCodigo = 5;

  /// No se escribe `ultima_conexion` en cada petición, solo si pasó este tiempo.
  static const intervaloConexion = Duration(minutes: 1);

  final RepositorioTerminales _repo;
  final Hub _hub;
  final Reloj _reloj;

  ({String codigo, DateTime expira})? _codigo;
  var _intentosFallidos = 0;
  final _ultimaMarca = <String, DateTime>{};

  /// Un código nuevo invalida el anterior.
  CodigoEmparejamiento crearCodigo() {
    final expira = _reloj().add(vigenciaCodigo);
    _codigo = (codigo: generarCodigoNumerico(6), expira: expira);
    _intentosFallidos = 0;
    return CodigoEmparejamiento(
      codigo: _codigo!.codigo,
      expira: instanteIso(expira),
    );
  }

  /// Regresa la terminal y su clave. La clave no se vuelve a mostrar.
  ({Terminal terminal, String clave}) registrar(Map<String, Object?> datos) {
    final v = Validador(datos);
    final nombre = v.texto('nombre', max: 40);
    final codigo = v.texto('codigo', min: 6, max: 6);
    v.comprobar();

    final vigente = _codigo;
    if (vigente == null || !_reloj().isBefore(vigente.expira)) {
      throw ErrorApi.codigoInvalido();
    }
    if (!igualesSeguro(codigo!, vigente.codigo)) {
      // Con 5 intentos sobre 1 000 000 de códigos, adivinar es inviable.
      if (++_intentosFallidos >= intentosPorCodigo) _codigo = null;
      throw ErrorApi.codigoInvalido();
    }
    _codigo = null; // Un código sirve para una sola terminal.

    final ahora = instanteIso(_reloj());
    final clave = generarClave();
    final terminal = Terminal(
      id: generarId('t'),
      nombre: nombre!,
      registrada: ahora,
      ultimaConexion: ahora,
    );
    _repo.insertar(terminal, claveHash: hashClave(clave));
    return (terminal: terminal, clave: clave);
  }

  /// Terminal dueña de [clave], o `null` si no existe o fue revocada.
  Terminal? autenticar(String clave) {
    final terminal = _repo.activaPorHash(hashClave(clave));
    if (terminal == null) return null;
    final ahora = _reloj();
    final ultima = _ultimaMarca[terminal.id];
    if (ultima == null || ahora.difference(ultima) >= intervaloConexion) {
      _repo.marcarConexion(terminal.id, instanteIso(ahora));
      _ultimaMarca[terminal.id] = ahora;
    }
    return terminal;
  }

  List<Terminal> listar() {
    final conectadas = _hub.terminalesConectadas;
    return [
      for (final t in _repo.listarActivas())
        t.conConexion(conectadas.contains(t.id)),
    ];
  }

  Future<void> revocar(String id) async {
    if (!_repo.revocar(id)) throw ErrorApi.noEncontrado('la terminal');
    _ultimaMarca.remove(id);
    await _hub.desconectarTerminal(id);
  }
}
