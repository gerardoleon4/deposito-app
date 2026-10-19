import 'package:sqlite3/sqlite3.dart';

import '../comun/errores.dart';
import '../comun/fechas.dart';
import '../comun/json.dart';
import '../comun/seguridad.dart';
import '../db/base_datos.dart';
import '../db/repositorio_envases.dart';
import '../modelos/evento.dart';
import '../modelos/producto.dart';
import '../ws/hub.dart';

class ServicioEnvases {
  ServicioEnvases({
    required this._db,
    required RepositorioEnvases repositorio,
    required this._hub,
    this._reloj = relojSistema,
  }) : _repo = repositorio;

  final Database _db;
  final RepositorioEnvases _repo;
  final Hub _hub;
  final Reloj _reloj;

  Map<String, Map<String, int>> balance() => _repo.obtenerBalance();

  List<Map<String, Object?>> prestamos() => _repo.listarPrestamosActivos();

  Map<String, Object?> registrarPrestamo(Map<String, Object?> datos) {
    final v = Validador(datos);
    final cliente = v.texto('cliente', max: 80);
    final formato = v.opcion('formato', {'mega', 'media', 'cuarto'});
    final cantidad = v.entero('cantidad', min: 1);
    v.comprobar();

    final id = generarId('pre');
    final fecha = instanteIso(_reloj());

    transaccion(_db, () {
      _repo.actualizarPrestados(formato!, cantidad!);
      _repo.registrarPrestamo(
        id: id,
        cliente: cliente!,
        formato: formato,
        cantidad: cantidad,
        fecha: fecha,
      );
    });

    _emitirBalance();
    return {
      'id': id,
      'cliente': cliente,
      'formato': formato,
      'cantidad': cantidad,
      'devueltos': 0,
      'fecha': fecha,
    };
  }

  /// Devolución total o, con `cantidad`, parcial. Los envases van a bodega.
  void devolver(String prestamoId, Map<String, Object?> datos) {
    final v = Validador(datos);
    final pedida = v.entero('cantidad', requerido: false, min: 1);
    v.comprobar();

    transaccion(_db, () {
      final p = _repo.obtenerPrestamo(prestamoId);
      if (p == null || p['devuelto'] == 1) {
        throw ErrorApi.noEncontrado('el préstamo');
      }
      final formato = p['formato'] as String;
      final pendiente = p['cantidad'] as int;
      final cantidad = pedida ?? pendiente;
      if (cantidad > pendiente) {
        throw ErrorApi.datosInvalidos({
          'cantidad': 'Solo faltan $pendiente envases por devolver',
        });
      }

      _repo.devolverPrestamo(
        prestamoId,
        cantidad,
        completo: cantidad == pendiente,
      );
      _repo.actualizarPrestados(formato, -cantidad);
      _repo.actualizarBodega(formato, cantidad);
    });

    _emitirBalance();
  }

  /// Vacíos que entran a bodega sin una venta (los deja el proveedor).
  Map<String, Map<String, int>> registrarEntrada(Map<String, Object?> datos) {
    final v = Validador(datos);
    final formato = v.opcion('formato', formatosEnvase);
    final cantidad = v.entero('cantidad', min: 1);
    v.comprobar();

    transaccion(_db, () => _repo.actualizarBodega(formato!, cantidad!));

    _emitirBalance();
    return balance();
  }

  void _emitirBalance() {
    _hub.emitir(TiposEvento.balanceEnvasesActualizado, {'balance': balance()});
  }
}
