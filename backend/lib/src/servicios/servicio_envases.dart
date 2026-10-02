import 'package:sqlite3/sqlite3.dart';
import '../comun/errores.dart';
import '../comun/fechas.dart';
import '../comun/json.dart';
import '../comun/seguridad.dart';
import '../db/base_datos.dart';
import '../db/repositorio_envases.dart';
import '../modelos/evento.dart';
import '../ws/hub.dart';

class ServicioEnvases {
  ServicioEnvases({
    required Database db,
    required RepositorioEnvases repositorio,
    required Hub hub,
    Reloj reloj = relojSistema,
  }) : _db = db,
       _repo = repositorio,
       _hub = hub,
       _reloj = reloj;

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
      'fecha': fecha,
    };
  }

  void devolver(String prestamoId) {
    transaccion(_db, () {
      final p = _repo.obtenerPrestamo(prestamoId);
      if (p == null || p['devuelto'] == 1) {
        throw ErrorApi.noEncontrado('el préstamo');
      }
      final formato = p['formato'] as String;
      final cantidad = p['cantidad'] as int;

      _repo.devolverPrestamo(prestamoId);
      _repo.actualizarPrestados(formato, -cantidad);
      _repo.actualizarBodega(formato, cantidad);
    });

    _emitirBalance();
  }

  void _emitirBalance() {
    _hub.emitir(TiposEvento.balanceEnvasesActualizado, {'balance': balance()});
  }
}
