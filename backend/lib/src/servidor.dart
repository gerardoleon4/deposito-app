import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:sqlite3/sqlite3.dart';

import 'comun/bitacora.dart';
import 'comun/errores.dart';
import 'comun/fechas.dart';
import 'comun/middleware.dart';
import 'comun/seguridad.dart';
import 'comun/sesion.dart';
import 'db/base_datos.dart';
import 'db/migraciones.dart';
import 'db/repositorio_ajustes.dart';
import 'db/repositorio_productos.dart';
import 'db/repositorio_terminales.dart';
import 'rutas/rutas_productos.dart';
import 'rutas/rutas_terminales.dart';
import 'seed/datos_ejemplo.dart';
import 'servicios/servicio_productos.dart';
import 'servicios/servicio_terminales.dart';
import 'ws/hub.dart';

/// Versión del servidor; se manda en `conexion.lista`.
const versionServidor = '0.1.0';

/// El servidor de Anaquel. La app lo arranca dentro de sí misma en modo Caja;
/// en desarrollo lo arranca `bin/server.dart`.
///
/// ```dart
/// final servidor = DepositoServer(rutaBaseDatos: '${docs.path}/anaquel.db');
/// await servidor.iniciar();
/// // La app de la caja usa servidor.claveCaja en X-Clave-Terminal.
/// await servidor.detener();
/// ```
class DepositoServer {
  DepositoServer({
    required this.rutaBaseDatos,
    this.puerto = 8080,
    InternetAddress? direccion,
    String? claveCaja,
    this.datosEjemplo = false,
    Bitacora? bitacora,
    this._reloj = relojSistema,
  }) : direccion = direccion ?? InternetAddress.anyIPv4,
       claveCaja = claveCaja ?? generarClave(),
       bitacora = bitacora ?? Bitacora();

  /// Archivo SQLite, o [enMemoria].
  final String rutaBaseDatos;

  /// `0` elige un puerto libre (pruebas); el real queda en [puertoActual].
  final int puerto;
  final InternetAddress direccion;

  /// Clave con la que la app de la caja se identifica. Nunca sale del iPad.
  final String claveCaja;

  /// Carga los productos del prototipo si la base está vacía.
  final bool datosEjemplo;
  final Bitacora bitacora;
  final Reloj _reloj;

  HttpServer? _http;
  Database? _db;
  Hub? _hub;

  bool get iniciado => _http != null;

  int get puertoActual =>
      _http?.port ?? (throw StateError('El servidor no está iniciado'));

  /// Abre la base, aplica migraciones (con respaldo previo) y empieza a escuchar.
  Future<void> iniciar() async {
    if (iniciado) return;
    final db = abrirBaseDatos(rutaBaseDatos);
    try {
      final aplicadas = aplicarMigraciones(
        db,
        rutaRespaldo: _rutaRespaldoMigracion,
        reloj: _reloj,
      );
      if (aplicadas.isNotEmpty) {
        bitacora.info('Migraciones aplicadas: ${aplicadas.join(', ')}');
      }

      final hub = Hub(
        version: versionServidor,
        bitacora: bitacora,
        reloj: _reloj,
      );
      final ajustes = RepositorioAjustes(db);
      final repoProductos = RepositorioProductos(db);
      final productos = ServicioProductos(
        db: db,
        repositorio: repoProductos,
        hub: hub,
        reloj: _reloj,
      );
      final terminales = ServicioTerminales(
        repositorio: RepositorioTerminales(db),
        hub: hub,
        reloj: _reloj,
      );

      if (datosEjemplo && repoProductos.contar() == 0) {
        cargarDatosEjemplo(
          productos,
          zonaHoraria: ajustes.zonaHoraria,
          reloj: _reloj,
        );
        bitacora.info('Datos de ejemplo cargados');
      }

      final router =
          Router(
              notFoundHandler: (_) => throw ErrorApi.noEncontrado('esa ruta'),
            )
            ..get('/salud', (Request _) => Response.ok('ok'))
            ..get('/api/v1/ws', (Request peticion) {
              final sesion = sesionDe(peticion);
              return webSocketHandler(
                (canal, _) => hub.conectar(canal, sesion),
                pingInterval: const Duration(seconds: 20),
              )(peticion);
            });
      montarRutasTerminales(router, terminales);
      montarRutasProductos(router, productos);

      final manejador = const Pipeline()
          .addMiddleware(registrarPeticiones(bitacora))
          .addMiddleware(manejarErrores(bitacora))
          .addMiddleware(
            autenticar(claveCaja: claveCaja, terminales: terminales),
          )
          .addHandler(router.call);

      _http = await io.serve(manejador, direccion, puerto);
      _db = db;
      _hub = hub;
      bitacora.info(
        'Servidor $versionServidor en ${direccion.address}:${_http!.port}',
      );
    } catch (e, pila) {
      db.close();
      bitacora.error('No se pudo iniciar el servidor', e, pila);
      rethrow;
    }
  }

  /// Cierra conexiones y la base. Se puede volver a [iniciar] después.
  Future<void> detener() async {
    await _hub?.cerrar();
    await _http?.close(force: true);
    _db?.close();
    _http = null;
    _db = null;
    _hub = null;
    bitacora.info('Servidor detenido');
  }

  String? _rutaRespaldoMigracion(int versionActual) {
    if (rutaBaseDatos == enMemoria) return null;
    final marca = instanteIso(_reloj()).replaceAll(RegExp('[-:]'), '');
    final carpeta = p.join(p.dirname(rutaBaseDatos), 'respaldos');
    Directory(carpeta).createSync(recursive: true);
    return p.join(carpeta, 'antes-de-migrar-v$versionActual-$marca.db');
  }
}
