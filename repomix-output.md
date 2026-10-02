This file is a merged representation of a subset of the codebase, containing specifically included files and files not matching ignore patterns, combined into a single document by Repomix.
The content has been processed where line numbers have been added.

# File Summary

## Purpose
This file contains a packed representation of a subset of the repository's contents that is considered the most important context.
It is designed to be easily consumable by AI systems for analysis, code review,
or other automated processes.

## File Format
The content is organized as follows:
1. This summary section
2. Repository information
3. Directory structure
4. Repository files (if enabled)
5. Multiple file entries, each consisting of:
  a. A header with the file path (## File: path/to/file)
  b. The full contents of the file in a code block

## Usage Guidelines
- This file should be treated as read-only. Any changes should be made to the
  original repository files, not this packed version.
- When processing this file, use the file path to distinguish
  between different files in the repository.
- Be aware that this file may contain sensitive information. Handle it with
  the same level of security as you would the original repository.
- Pay special attention to the Repository Description. These contain important context and guidelines specific to this project.

## Notes
- Some files may have been excluded based on .gitignore rules and Repomix's configuration
- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files
- Only files matching these patterns are included: AGENTS.md, README.md, CHANGELOG.md, .gitignore, .gitattributes, .github/**, docs/**, backend/**/*.dart, backend/pubspec.yaml, backend/analysis_options.yaml, app/lib/**/*.dart, app/test/**/*.dart, app/pubspec.yaml, app/analysis_options.yaml, app/android/app/src/main/AndroidManifest.xml, app/ios/Runner/Info.plist
- Files matching these patterns are excluded: repomix-output.md
- Files matching patterns in .gitignore are excluded
- Files matching default ignore patterns are excluded
- Line numbers have been added to the beginning of each line
- Long base64 data strings (e.g., data:image/png;base64,...) have been truncated to reduce token count
- Files are sorted by Git change count (files with more changes are at the bottom)

# User Provided Header
Paquete de contexto del repositorio Anaquel (deposito-app). Anaquel es un punto de venta e inventario local para un depósito: una app Flutter en modo Caja aloja un backend Dart con API REST, WebSocket y SQLite; los teléfonos en modo Terminal se conectan por la red local. El contrato está en docs/API.md y los estándares obligatorios en docs/ESTANDARES.md. El proyecto todavía está en desarrollo: ventas, cortes, envases y otras funciones están pendientes; consulta README.md y docs/PLAN_DE_TRABAJO.md antes de asumir que algo está implementado. La app y el backend requieren Dart 3.13.4 / Flutter 3.47.5.

# Directory Structure
````
.github/
  workflows/
    ci.yml
  pull_request_template.md
app/
  android/
    app/
      src/
        main/
          AndroidManifest.xml
  ios/
    Runner/
      Info.plist
  lib/
    app/
      tema/
        colores.dart
        tema.dart
      app.dart
      router.dart
    core/
      api/
        api_falsa.dart
        api.dart
        fallo_api.dart
        proveedores.dart
      config/
        configuracion.dart
      formato/
        formato.dart
      servidor/
        servidor_embebido.dart
      tiempo_real/
        tiempo_real.dart
      widgets/
        estados.dart
        ilustracion_producto.dart
        indicador_conexion.dart
        marca.dart
        tarjeta_producto.dart
    features/
      ajustes/
        ajustes.dart
      caja/
        estado/
          terminales.dart
        pantallas/
          conectar_terminal.dart
          inicio_caja.dart
          secciones_caja.dart
          shell_caja.dart
      catalogo/
        estado/
          productos.dart
        pantallas/
          detalle_producto.dart
          formulario_producto.dart
          pantalla_catalogo.dart
          vista_catalogo.dart
      inicio/
        elegir_modo.dart
      proximamente/
        proximamente.dart
      terminal/
        pantallas/
          escanear.dart
          escaner.dart
          shell_terminal.dart
          vincular_terminal.dart
    main.dart
  test/
    ayudantes.dart
    capturas_test.dart
    flujos_test.dart
    formato_test.dart
    integracion_backend_test.dart
  analysis_options.yaml
  pubspec.yaml
backend/
  bin/
    server.dart
  lib/
    src/
      comun/
        bitacora.dart
        errores.dart
        fechas.dart
        json.dart
        middleware.dart
        seguridad.dart
        sesion.dart
        texto.dart
      db/
        migraciones/
          m001_inicial.dart
          m002_ventas_pedidos_envases.dart
        base_datos.dart
        migraciones.dart
        repositorio_ajustes.dart
        repositorio_envases.dart
        repositorio_productos.dart
        repositorio_terminales.dart
        repositorio_ventas.dart
      modelos/
        evento.dart
        producto.dart
        terminal.dart
      rutas/
        rutas_envases.dart
        rutas_pedidos.dart
        rutas_productos.dart
        rutas_terminales.dart
        rutas_ventas.dart
      seed/
        datos_ejemplo.dart
      servicios/
        servicio_envases.dart
        servicio_pedidos.dart
        servicio_productos.dart
        servicio_terminales.dart
        servicio_ventas.dart
      ws/
        hub.dart
      servidor.dart
    deposito_backend.dart
  test/
    ayudantes/
      servidor_prueba.dart
    api_test.dart
    fechas_test.dart
    migraciones_test.dart
    servicio_productos_test.dart
    ventas_test.dart
  analysis_options.yaml
  pubspec.yaml
docs/
  prototipo/
    index.html
  API.md
  ESTANDARES.md
  PLAN_DE_TRABAJO.md
  SETUP.md
.gitattributes
.gitignore
AGENTS.md
CHANGELOG.md
README.md
````

# Files

## File: backend/lib/src/db/migraciones/m002_ventas_pedidos_envases.dart
````dart
 1: import '../migraciones.dart';
 2: 
 3: const m002VentasPedidosEnvases = Migracion(2, 'ventas_pedidos_envases', '''
 4: -- Balance y seguimiento de envases retornables
 5: CREATE TABLE balance_envases (
 6:   formato       TEXT PRIMARY KEY CHECK (formato IN ('mega', 'media', 'cuarto')),
 7:   bodega        INTEGER NOT NULL DEFAULT 0 CHECK (bodega >= 0),
 8:   prestados     INTEGER NOT NULL DEFAULT 0 CHECK (prestados >= 0),
 9:   precio        INTEGER NOT NULL CHECK (precio > 0)
10: );
11: 
12: INSERT INTO balance_envases (formato, bodega, prestados, precio) VALUES
13:   ('mega', 84, 36, 800),
14:   ('media', 240, 48, 300),
15:   ('cuarto', 168, 24, 300);
16: 
17: CREATE TABLE prestamos_envases (
18:   id        TEXT PRIMARY KEY,
19:   cliente   TEXT NOT NULL,
20:   formato   TEXT NOT NULL CHECK (formato IN ('mega', 'media', 'cuarto')),
21:   cantidad  INTEGER NOT NULL CHECK (cantidad > 0),
22:   fecha     TEXT NOT NULL,
23:   devuelto  INTEGER NOT NULL DEFAULT 0
24: );
25: CREATE INDEX idx_prestamos_cliente ON prestamos_envases (cliente, devuelto);
26: 
27: -- Ventas y Tickets
28: CREATE TABLE ventas (
29:   id          TEXT PRIMARY KEY,
30:   folio       INTEGER NOT NULL UNIQUE,
31:   fecha       TEXT NOT NULL,
32:   dia_negocio TEXT NOT NULL,
33:   total       INTEGER NOT NULL CHECK (total >= 0),
34:   metodo      TEXT NOT NULL CHECK (metodo IN ('efectivo', 'tarjeta')),
35:   tarjeta     TEXT,
36:   recibido    INTEGER NOT NULL DEFAULT 0 CHECK (recibido >= 0),
37:   cambio      INTEGER NOT NULL DEFAULT 0 CHECK (cambio >= 0),
38:   env_modo    TEXT NOT NULL DEFAULT 'na' CHECK (env_modo IN ('na', 'cobrar', 'trae', 'prestamo')),
39:   env_n       INTEGER NOT NULL DEFAULT 0 CHECK (env_n >= 0),
40:   env_monto   INTEGER NOT NULL DEFAULT 0 CHECK (env_monto >= 0),
41:   env_cliente TEXT,
42:   origen      TEXT NOT NULL,
43:   cancelada   INTEGER NOT NULL DEFAULT 0
44: );
45: CREATE INDEX idx_ventas_dia ON ventas (dia_negocio, cancelada);
46: 
47: CREATE TABLE venta_lineas (
48:   id          INTEGER PRIMARY KEY AUTOINCREMENT,
49:   venta_id    TEXT NOT NULL REFERENCES ventas (id),
50:   producto_id TEXT NOT NULL REFERENCES productos (id),
51:   nombre      TEXT NOT NULL,
52:   unidad      TEXT NOT NULL CHECK (unidad IN ('pieza', 'caja')),
53:   cantidad    INTEGER NOT NULL CHECK (cantidad > 0),
54:   piezas      INTEGER NOT NULL CHECK (piezas > 0),
55:   precio_unit INTEGER NOT NULL CHECK (precio_unit > 0),
56:   subtotal    INTEGER NOT NULL CHECK (subtotal > 0)
57: );
58: CREATE INDEX idx_lineas_venta ON venta_lineas (venta_id);
59: 
60: -- Pedidos levantados por Terminales
61: CREATE TABLE pedidos (
62:   id        TEXT PRIMARY KEY,
63:   origen    TEXT NOT NULL,
64:   fecha     TEXT NOT NULL,
65:   nota      TEXT,
66:   atendido  INTEGER NOT NULL DEFAULT 0
67: );
68: 
69: CREATE TABLE pedido_lineas (
70:   id          INTEGER PRIMARY KEY AUTOINCREMENT,
71:   pedido_id   TEXT NOT NULL REFERENCES pedidos (id),
72:   producto_id TEXT NOT NULL REFERENCES productos (id),
73:   unidad      TEXT NOT NULL CHECK (unidad IN ('pieza', 'caja')),
74:   cantidad    INTEGER NOT NULL CHECK (cantidad > 0)
75: );
76: ''');
````

## File: backend/lib/src/db/repositorio_envases.dart
````dart
 1: import 'package:sqlite3/sqlite3.dart';
 2: 
 3: class RepositorioEnvases {
 4:   RepositorioEnvases(this._db);
 5:   final Database _db;
 6: 
 7:   Map<String, Map<String, int>> obtenerBalance() {
 8:     final filas = _db.select(
 9:       'SELECT formato, bodega, prestados, precio FROM balance_envases',
10:     );
11:     return {
12:       for (final f in filas)
13:         f['formato'] as String: {
14:           'bodega': f['bodega'] as int,
15:           'prestados': f['prestados'] as int,
16:           'precio': f['precio'] as int,
17:         },
18:     };
19:   }
20: 
21:   void actualizarBodega(String formato, int delta) {
22:     _db.execute(
23:       'UPDATE balance_envases SET bodega = bodega + ? WHERE formato = ?',
24:       [delta, formato],
25:     );
26:   }
27: 
28:   void actualizarPrestados(String formato, int delta) {
29:     _db.execute(
30:       'UPDATE balance_envases SET prestados = prestados + ? WHERE formato = ?',
31:       [delta, formato],
32:     );
33:   }
34: 
35:   void registrarPrestamo({
36:     required String id,
37:     required String cliente,
38:     required String formato,
39:     required int cantidad,
40:     required String fecha,
41:   }) {
42:     _db.execute(
43:       'INSERT INTO prestamos_envases (id, cliente, formato, cantidad, fecha) VALUES (?, ?, ?, ?, ?)',
44:       [id, cliente, formato, cantidad, fecha],
45:     );
46:   }
47: 
48:   List<Map<String, Object?>> listarPrestamosActivos() {
49:     return _db
50:         .select(
51:           'SELECT * FROM prestamos_envases WHERE devuelto = 0 ORDER BY fecha DESC',
52:         )
53:         .map(
54:           (f) => {
55:             'id': f['id'],
56:             'cliente': f['cliente'],
57:             'formato': f['formato'],
58:             'cantidad': f['cantidad'],
59:             'fecha': f['fecha'],
60:           },
61:         )
62:         .toList();
63:   }
64: 
65:   bool devolverPrestamo(String id) {
66:     _db.execute(
67:       'UPDATE prestamos_envases SET devuelto = 1 WHERE id = ? AND devuelto = 0',
68:       [id],
69:     );
70:     return _db.updatedRows > 0;
71:   }
72: 
73:   Row? obtenerPrestamo(String id) {
74:     final f = _db.select('SELECT * FROM prestamos_envases WHERE id = ?', [id]);
75:     return f.isEmpty ? null : f.first;
76:   }
77: }
````

## File: backend/lib/src/db/repositorio_ventas.dart
````dart
  1: import 'package:sqlite3/sqlite3.dart';
  2: 
  3: class RepositorioVentas {
  4:   RepositorioVentas(this._db);
  5:   final Database _db;
  6: 
  7:   int siguienteFolio() {
  8:     final r = _db.select(
  9:       'SELECT COALESCE(MAX(folio), 1000) + 1 AS f FROM ventas',
 10:     );
 11:     return r.first['f'] as int;
 12:   }
 13: 
 14:   void insertarVenta({
 15:     required String id,
 16:     required int folio,
 17:     required String fecha,
 18:     required String diaNegocio,
 19:     required int total,
 20:     required String metodo,
 21:     String? tarjeta,
 22:     required int recibido,
 23:     required int cambio,
 24:     required String envModo,
 25:     required int envN,
 26:     required int envMonto,
 27:     String? envCliente,
 28:     required String origen,
 29:   }) {
 30:     _db.execute(
 31:       '''
 32:       INSERT INTO ventas (id, folio, fecha, dia_negocio, total, metodo, tarjeta, recibido,
 33:         cambio, env_modo, env_n, env_monto, env_cliente, origen)
 34:       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
 35:     ''',
 36:       [
 37:         id,
 38:         folio,
 39:         fecha,
 40:         diaNegocio,
 41:         total,
 42:         metodo,
 43:         tarjeta,
 44:         recibido,
 45:         cambio,
 46:         envModo,
 47:         envN,
 48:         envMonto,
 49:         envCliente,
 50:         origen,
 51:       ],
 52:     );
 53:   }
 54: 
 55:   void insertarLinea({
 56:     required String ventaId,
 57:     required String productoId,
 58:     required String nombre,
 59:     required String unidad,
 60:     required int cantidad,
 61:     required int piezas,
 62:     required int precioUnit,
 63:     required int subtotal,
 64:   }) {
 65:     _db.execute(
 66:       '''
 67:       INSERT INTO venta_lineas (venta_id, producto_id, nombre, unidad, cantidad, piezas, precio_unit, subtotal)
 68:       VALUES (?, ?, ?, ?, ?, ?, ?, ?)
 69:     ''',
 70:       [
 71:         ventaId,
 72:         productoId,
 73:         nombre,
 74:         unidad,
 75:         cantidad,
 76:         piezas,
 77:         precioUnit,
 78:         subtotal,
 79:       ],
 80:     );
 81:   }
 82: 
 83:   Row? obtenerPorId(String id) {
 84:     final r = _db.select('SELECT * FROM ventas WHERE id = ?', [id]);
 85:     return r.isEmpty ? null : r.first;
 86:   }
 87: 
 88:   List<Row> obtenerLineas(String ventaId) {
 89:     return _db.select('SELECT * FROM venta_lineas WHERE venta_id = ?', [
 90:       ventaId,
 91:     ]);
 92:   }
 93: 
 94:   List<Row> listar({String? diaNegocio}) {
 95:     if (diaNegocio != null) {
 96:       return _db.select(
 97:         'SELECT * FROM ventas WHERE dia_negocio = ? ORDER BY folio DESC',
 98:         [diaNegocio],
 99:       );
100:     }
101:     return _db.select('SELECT * FROM ventas ORDER BY folio DESC LIMIT 100');
102:   }
103: 
104:   void anularVenta(String id) {
105:     _db.execute('UPDATE ventas SET cancelada = 1 WHERE id = ?', [id]);
106:   }
107: }
````

## File: backend/lib/src/rutas/rutas_envases.dart
````dart
 1: import 'package:shelf/shelf.dart';
 2: import 'package:shelf_router/shelf_router.dart';
 3: import '../comun/json.dart';
 4: import '../servicios/servicio_envases.dart';
 5: 
 6: void montarRutasEnvases(Router r, ServicioEnvases envases) {
 7:   r.get('/api/v1/envases', (Request _) {
 8:     return respuestaJson({'balance': envases.balance()});
 9:   });
10: 
11:   r.get('/api/v1/envases/prestamos', (Request _) {
12:     return respuestaJson({'prestamos': envases.prestamos()});
13:   });
14: 
15:   r.post('/api/v1/envases/prestamos', (Request p) async {
16:     final res = envases.registrarPrestamo(await leerObjetoJson(p));
17:     return respuestaJson(res, estado: 201);
18:   });
19: 
20:   r.post('/api/v1/envases/prestamos/<id>/devolver', (Request _, String id) {
21:     envases.devolver(id);
22:     return Response(204);
23:   });
24: }
````

## File: backend/lib/src/rutas/rutas_pedidos.dart
````dart
 1: import 'package:shelf/shelf.dart';
 2: import 'package:shelf_router/shelf_router.dart';
 3: import '../comun/json.dart';
 4: import '../comun/sesion.dart';
 5: import '../servicios/servicio_pedidos.dart';
 6: 
 7: void montarRutasPedidos(Router r, ServicioPedidos pedidos) {
 8:   r.get('/api/v1/pedidos', (Request _) {
 9:     return respuestaJson({'pedidos': pedidos.listarPendientes()});
10:   });
11: 
12:   r.post('/api/v1/pedidos', (Request p) async {
13:     final sesion = sesionDe(p);
14:     final res = pedidos.crear(await leerObjetoJson(p), origen: sesion.nombre);
15:     return respuestaJson(res, estado: 201);
16:   });
17: 
18:   r.delete('/api/v1/pedidos/<id>', (Request p, String id) {
19:     exigirCaja(p);
20:     pedidos.descartar(id);
21:     return Response(204);
22:   });
23: }
````

## File: backend/lib/src/rutas/rutas_ventas.dart
````dart
 1: import 'package:shelf/shelf.dart';
 2: import 'package:shelf_router/shelf_router.dart';
 3: import '../comun/json.dart';
 4: import '../comun/sesion.dart';
 5: import '../servicios/servicio_ventas.dart';
 6: 
 7: void montarRutasVentas(Router r, ServicioVentas ventas) {
 8:   r.get('/api/v1/ventas', (Request p) {
 9:     final q = p.url.queryParameters['dia'];
10:     return respuestaJson({'ventas': ventas.listar(diaNegocio: q)});
11:   });
12: 
13:   r.get('/api/v1/ventas/<id>', (Request _, String id) {
14:     return respuestaJson(ventas.detalle(id));
15:   });
16: 
17:   r.post('/api/v1/ventas', (Request p) async {
18:     final sesion = exigirCaja(p);
19:     final venta = ventas.registrar(
20:       await leerObjetoJson(p),
21:       origen: sesion.nombre,
22:     );
23:     return respuestaJson(venta, estado: 201);
24:   });
25: 
26:   r.post('/api/v1/ventas/<id>/cancelar', (Request p, String id) {
27:     final sesion = exigirCaja(p);
28:     ventas.cancelar(id, origen: sesion.nombre);
29:     return Response(204);
30:   });
31: }
````

## File: backend/lib/src/servicios/servicio_envases.dart
````dart
 1: import 'package:sqlite3/sqlite3.dart';
 2: import '../comun/errores.dart';
 3: import '../comun/fechas.dart';
 4: import '../comun/json.dart';
 5: import '../comun/seguridad.dart';
 6: import '../db/base_datos.dart';
 7: import '../db/repositorio_envases.dart';
 8: import '../modelos/evento.dart';
 9: import '../ws/hub.dart';
10: 
11: class ServicioEnvases {
12:   ServicioEnvases({
13:     required Database db,
14:     required RepositorioEnvases repositorio,
15:     required Hub hub,
16:     Reloj reloj = relojSistema,
17:   }) : _db = db,
18:        _repo = repositorio,
19:        _hub = hub,
20:        _reloj = reloj;
21: 
22:   final Database _db;
23:   final RepositorioEnvases _repo;
24:   final Hub _hub;
25:   final Reloj _reloj;
26: 
27:   Map<String, Map<String, int>> balance() => _repo.obtenerBalance();
28: 
29:   List<Map<String, Object?>> prestamos() => _repo.listarPrestamosActivos();
30: 
31:   Map<String, Object?> registrarPrestamo(Map<String, Object?> datos) {
32:     final v = Validador(datos);
33:     final cliente = v.texto('cliente', max: 80);
34:     final formato = v.opcion('formato', {'mega', 'media', 'cuarto'});
35:     final cantidad = v.entero('cantidad', min: 1);
36:     v.comprobar();
37: 
38:     final id = generarId('pre');
39:     final fecha = instanteIso(_reloj());
40: 
41:     transaccion(_db, () {
42:       _repo.actualizarPrestados(formato!, cantidad!);
43:       _repo.registrarPrestamo(
44:         id: id,
45:         cliente: cliente!,
46:         formato: formato,
47:         cantidad: cantidad,
48:         fecha: fecha,
49:       );
50:     });
51: 
52:     _emitirBalance();
53:     return {
54:       'id': id,
55:       'cliente': cliente,
56:       'formato': formato,
57:       'cantidad': cantidad,
58:       'fecha': fecha,
59:     };
60:   }
61: 
62:   void devolver(String prestamoId) {
63:     transaccion(_db, () {
64:       final p = _repo.obtenerPrestamo(prestamoId);
65:       if (p == null || p['devuelto'] == 1) {
66:         throw ErrorApi.noEncontrado('el préstamo');
67:       }
68:       final formato = p['formato'] as String;
69:       final cantidad = p['cantidad'] as int;
70: 
71:       _repo.devolverPrestamo(prestamoId);
72:       _repo.actualizarPrestados(formato, -cantidad);
73:       _repo.actualizarBodega(formato, cantidad);
74:     });
75: 
76:     _emitirBalance();
77:   }
78: 
79:   void _emitirBalance() {
80:     _hub.emitir(TiposEvento.balanceEnvasesActualizado, {'balance': balance()});
81:   }
82: }
````

## File: backend/lib/src/servicios/servicio_pedidos.dart
````dart
 1: import 'package:sqlite3/sqlite3.dart';
 2: import '../comun/fechas.dart';
 3: import '../comun/json.dart';
 4: import '../comun/seguridad.dart';
 5: import '../db/base_datos.dart';
 6: import '../modelos/evento.dart';
 7: import '../ws/hub.dart';
 8: 
 9: class ServicioPedidos {
10:   ServicioPedidos({
11:     required Database db,
12:     required Hub hub,
13:     Reloj reloj = relojSistema,
14:   }) : _db = db,
15:        _hub = hub,
16:        _reloj = reloj;
17: 
18:   final Database _db;
19:   final Hub _hub;
20:   final Reloj _reloj;
21: 
22:   Map<String, Object?> crear(
23:     Map<String, Object?> datos, {
24:     required String origen,
25:   }) {
26:     final v = Validador(datos);
27:     final nota = v.texto('nota', requerido: false, max: 120);
28:     final lineas = datos['lineas'];
29:     if (lineas is! List || lineas.isEmpty) {
30:       v.error('lineas', 'Debe contener productos');
31:     }
32:     v.comprobar();
33: 
34:     final pedidoId = generarId('ped');
35:     final fecha = instanteIso(_reloj());
36: 
37:     transaccion(_db, () {
38:       _db.execute(
39:         'INSERT INTO pedidos (id, origen, fecha, nota) VALUES (?, ?, ?, ?)',
40:         [pedidoId, origen, fecha, nota],
41:       );
42: 
43:       for (final l in (lineas as List)) {
44:         if (l is! Map) continue;
45:         _db.execute(
46:           'INSERT INTO pedido_lineas (pedido_id, producto_id, unidad, cantidad) VALUES (?, ?, ?, ?)',
47:           [pedidoId, l['productoId'], l['unidad'], l['cantidad']],
48:         );
49:       }
50:     });
51: 
52:     final payload = {
53:       'id': pedidoId,
54:       'origen': origen,
55:       'fecha': fecha,
56:       'nota': nota,
57:       'lineas': lineas,
58:     };
59: 
60:     _hub.emitir(TiposEvento.pedidoCreado, {'pedido': payload});
61:     return payload;
62:   }
63: 
64:   List<Map<String, Object?>> listarPendientes() {
65:     final filas = _db.select(
66:       'SELECT * FROM pedidos WHERE atendido = 0 ORDER BY fecha ASC',
67:     );
68:     return [
69:       for (final f in filas)
70:         {
71:           'id': f['id'],
72:           'origen': f['origen'],
73:           'fecha': f['fecha'],
74:           'nota': f['nota'],
75:           'lineas': _db
76:               .select(
77:                 'SELECT producto_id, unidad, cantidad FROM pedido_lineas WHERE pedido_id = ?',
78:                 [f['id']],
79:               )
80:               .map(
81:                 (l) => {
82:                   'productoId': l['producto_id'],
83:                   'unidad': l['unidad'],
84:                   'cantidad': l['cantidad'],
85:                 },
86:               )
87:               .toList(),
88:         },
89:     ];
90:   }
91: 
92:   void descartar(String id) {
93:     _db.execute('UPDATE pedidos SET atendido = 1 WHERE id = ?', [id]);
94:     _hub.emitir(TiposEvento.pedidoAtendido, {'id': id});
95:   }
96: }
````

## File: backend/lib/src/servicios/servicio_ventas.dart
````dart
  1: import 'package:sqlite3/sqlite3.dart';
  2: import '../comun/errores.dart';
  3: import '../comun/fechas.dart';
  4: import '../comun/json.dart';
  5: import '../comun/seguridad.dart';
  6: import '../db/base_datos.dart';
  7: import '../db/repositorio_ajustes.dart';
  8: import '../db/repositorio_envases.dart';
  9: import '../db/repositorio_productos.dart';
 10: import '../db/repositorio_ventas.dart';
 11: import '../modelos/evento.dart';
 12: import '../modelos/producto.dart';
 13: import '../ws/hub.dart';
 14: 
 15: class ServicioVentas {
 16:   ServicioVentas({
 17:     required Database db,
 18:     required RepositorioVentas repoVentas,
 19:     required RepositorioProductos repoProductos,
 20:     required RepositorioEnvases repoEnvases,
 21:     required RepositorioAjustes repoAjustes,
 22:     required Hub hub,
 23:     Reloj reloj = relojSistema,
 24:   }) : _db = db,
 25:        _repoVentas = repoVentas,
 26:        _repoProductos = repoProductos,
 27:        _repoEnvases = repoEnvases,
 28:        _repoAjustes = repoAjustes,
 29:        _hub = hub,
 30:        _reloj = reloj;
 31: 
 32:   final Database _db;
 33:   final RepositorioVentas _repoVentas;
 34:   final RepositorioProductos _repoProductos;
 35:   final RepositorioEnvases _repoEnvases;
 36:   final RepositorioAjustes _repoAjustes;
 37:   final Hub _hub;
 38:   final Reloj _reloj;
 39: 
 40:   // backend/lib/src/servicios/servicio_ventas.dart
 41: 
 42:   Map<String, Object?> registrar(
 43:     Map<String, Object?> datos, {
 44:     required String origen,
 45:   }) {
 46:     final v = Validador(datos);
 47:     final metodo = v.opcion('metodo', {'efectivo', 'tarjeta'});
 48:     final tarjeta = v.texto('tarjeta', requerido: false, max: 20);
 49:     final envModo =
 50:         v.opcion('envModo', {
 51:           'na',
 52:           'cobrar',
 53:           'trae',
 54:           'prestamo',
 55:         }, requerido: false) ??
 56:         'na';
 57:     final envCliente = v.texto('envCliente', requerido: false, max: 80);
 58:     final lineasRaw = datos['lineas'];
 59:     if (lineasRaw is! List || lineasRaw.isEmpty) {
 60:       v.error('lineas', 'Debe incluir al menos un producto');
 61:     }
 62:     v.comprobar();
 63: 
 64:     final ahora = _reloj();
 65:     final fecha = instanteIso(ahora);
 66:     final dia = diaNegocio(ahora, _repoAjustes.zonaHoraria);
 67:     final ventaId = generarId('v');
 68: 
 69:     final productosActualizados = <Producto>[];
 70:     var total = 0;
 71:     var envN = 0;
 72:     var envMonto = 0;
 73:     final envPorFormato = <String, int>{};
 74: 
 75:     final resultado = transaccion(_db, () {
 76:       final folio = _repoVentas.siguienteFolio();
 77:       final lineasProcesadas = <Map<String, Object?>>[];
 78: 
 79:       // PASO 1: Validar inventario y calcular totales (sin insertar líneas aún)
 80:       for (final item in (lineasRaw as List)) {
 81:         if (item is! Map) {
 82:           throw ErrorApi.datosInvalidos({'lineas': 'Estructura inválida'});
 83:         }
 84:         final pid = item['productoId'] as String?;
 85:         final unidad = item['unidad'] as String?;
 86:         final cantidad = item['cantidad'] as int?;
 87: 
 88:         if (pid == null ||
 89:             unidad == null ||
 90:             cantidad == null ||
 91:             cantidad <= 0) {
 92:           throw ErrorApi.datosInvalidos({
 93:             'lineas': 'Faltan datos obligatorios en línea',
 94:           });
 95:         }
 96: 
 97:         final p = _repoProductos.porId(pid);
 98:         if (p == null) throw ErrorApi.noEncontrado('el producto $pid');
 99: 
100:         final piezas = unidad == 'caja'
101:             ? (cantidad * (p.piezasPorCaja ?? 1))
102:             : cantidad;
103:         if (p.existenciaPiezas < piezas) {
104:           throw ErrorApi.datosInvalidos({
105:             'existencias':
106:                 'Existencias insuficientes para ${p.nombre}. Disponibles: ${p.existenciaPiezas}',
107:           });
108:         }
109: 
110:         final precioUnit = unidad == 'caja'
111:             ? (p.precioCaja ??
112:                   (throw ErrorApi.datosInvalidos({
113:                     'unidad': 'El producto no se vende por caja',
114:                   })))
115:             : p.precio;
116: 
117:         final subtotal = precioUnit * cantidad;
118:         total += subtotal;
119: 
120:         if (p.envase != null) {
121:           envN += piezas;
122:           envPorFormato[p.envase!] = (envPorFormato[p.envase!] ?? 0) + piezas;
123:         }
124: 
125:         lineasProcesadas.add({
126:           'p': p,
127:           'unidad': unidad,
128:           'cantidad': cantidad,
129:           'piezas': piezas,
130:           'precioUnit': precioUnit,
131:           'subtotal': subtotal,
132:         });
133:       }
134: 
135:       // PASO 2: Cálculo final de envases y validación de cobro
136:       final balance = _repoEnvases.obtenerBalance();
137:       if (envModo == 'cobrar') {
138:         for (final entry in envPorFormato.entries) {
139:           final precioEnv = balance[entry.key]?['precio'] ?? 0;
140:           envMonto += entry.value * precioEnv;
141:         }
142:         total += envMonto;
143:       }
144: 
145:       final recibido = (datos['recibido'] is int)
146:           ? (datos['recibido'] as int)
147:           : total;
148:       if (metodo == 'efectivo' && recibido < total) {
149:         throw ErrorApi.datosInvalidos({
150:           'recibido':
151:               'El monto recibido ($recibido) es menor al total ($total)',
152:         });
153:       }
154:       final cambio = (metodo == 'efectivo') ? (recibido - total) : 0;
155: 
156:       // PASO 3: Insertar el registro maestro (ventas) PRIMERO
157:       _repoVentas.insertarVenta(
158:         id: ventaId,
159:         folio: folio,
160:         fecha: fecha,
161:         diaNegocio: dia,
162:         total: total,
163:         metodo: metodo!,
164:         tarjeta: tarjeta,
165:         recibido: recibido,
166:         cambio: cambio,
167:         envModo: envModo,
168:         envN: envN,
169:         envMonto: envMonto,
170:         envCliente: envCliente,
171:         origen: origen,
172:       );
173: 
174:       // PASO 4: Insertar líneas, actualizar inventario y registrar movimientos
175:       for (final lp in lineasProcesadas) {
176:         final p = lp['p'] as Producto;
177:         final piezas = lp['piezas'] as int;
178: 
179:         _repoVentas.insertarLinea(
180:           ventaId: ventaId,
181:           productoId: p.id,
182:           nombre: p.nombre,
183:           unidad: lp['unidad'] as String,
184:           cantidad: lp['cantidad'] as int,
185:           piezas: piezas,
186:           precioUnit: lp['precioUnit'] as int,
187:           subtotal: lp['subtotal'] as int,
188:         );
189: 
190:         final nuevaExistencia = p.existenciaPiezas - piezas;
191:         _db.execute(
192:           'UPDATE productos SET existencia_piezas = ?, actualizado = ? WHERE id = ?',
193:           [nuevaExistencia, fecha, p.id],
194:         );
195: 
196:         _repoProductos.registrarMovimiento(
197:           productoId: p.id,
198:           tipo: 'venta',
199:           piezas: -piezas,
200:           existenciaResultante: nuevaExistencia,
201:           referencia: 'Folio $folio',
202:           origen: origen,
203:           fecha: fecha,
204:         );
205: 
206:         final actualizado = _repoProductos.porId(p.id);
207:         if (actualizado != null) {
208:           productosActualizados.add(actualizado);
209:         }
210:       }
211: 
212:       // PASO 5: Actualizar bodega o préstamos de envases
213:       if (envModo == 'trae') {
214:         for (final entry in envPorFormato.entries) {
215:           _repoEnvases.actualizarBodega(entry.key, entry.value);
216:         }
217:       } else if (envModo == 'prestamo') {
218:         for (final entry in envPorFormato.entries) {
219:           _repoEnvases.actualizarPrestados(entry.key, entry.value);
220:           _repoEnvases.registrarPrestamo(
221:             id: generarId('pre'),
222:             cliente: envCliente ?? 'Cliente Mostrador',
223:             formato: entry.key,
224:             cantidad: entry.value,
225:             fecha: fecha,
226:           );
227:         }
228:       }
229: 
230:       return {
231:         'id': ventaId,
232:         'folio': folio,
233:         'fecha': fecha,
234:         'diaNegocio': dia,
235:         'total': total,
236:         'metodo': metodo,
237:         'cambio': cambio,
238:       };
239:     });
240: 
241:     // Notificar por WebSocket fuera de la transacción para no enviar eventos si falla la BD
242:     for (final prod in productosActualizados) {
243:       _hub.emitir(TiposEvento.productoActualizado, {'producto': prod.toJson()});
244:     }
245:     if (envPorFormato.isNotEmpty) {
246:       _hub.emitir(TiposEvento.balanceEnvasesActualizado, {
247:         'balance': _repoEnvases.obtenerBalance(),
248:       });
249:     }
250: 
251:     return resultado;
252:   }
253: 
254:   void cancelar(String id, {required String origen}) {
255:     final prods = <Producto>[];
256:     transaccion(_db, () {
257:       final v = _repoVentas.obtenerPorId(id);
258:       if (v == null) throw ErrorApi.noEncontrado('la venta');
259:       if ((v['cancelada'] as int) == 1) {
260:         throw ErrorApi.datosInvalidos({
261:           'cancelada': 'La venta ya fue cancelada',
262:         });
263:       }
264: 
265:       final lineas = _repoVentas.obtenerLineas(id);
266:       final fecha = instanteIso(_reloj());
267:       final folio = v['folio'] as int;
268: 
269:       // Reversar existencias
270:       for (final l in lineas) {
271:         final pid = l['producto_id'] as String;
272:         final piezas = l['piezas'] as int;
273:         final p = _repoProductos.porId(pid);
274:         if (p != null) {
275:           final restock = p.existenciaPiezas + piezas;
276:           _db.execute(
277:             'UPDATE productos SET existencia_piezas = ?, actualizado = ? WHERE id = ?',
278:             [restock, fecha, p.id],
279:           );
280:           _repoProductos.registrarMovimiento(
281:             productoId: p.id,
282:             tipo: 'cancelacion',
283:             piezas: piezas,
284:             existenciaResultante: restock,
285:             referencia: 'Cancelación Folio $folio',
286:             origen: origen,
287:             fecha: fecha,
288:           );
289:           prods.add(_repoProductos.porId(p.id)!);
290:         }
291:       }
292: 
293:       // Reversar envases si se ingresaron a bodega
294:       final modo = v['env_modo'] as String;
295:       if (modo == 'trae') {
296:         // Descontar los que se habían sumado
297:         for (final l in lineas) {
298:           final p = _repoProductos.porId(l['producto_id'] as String);
299:           if (p?.envase != null) {
300:             _repoEnvases.actualizarBodega(p!.envase!, -(l['piezas'] as int));
301:           }
302:         }
303:       }
304: 
305:       _repoVentas.anularVenta(id);
306:     });
307: 
308:     for (final prod in prods) {
309:       _hub.emitir(TiposEvento.productoActualizado, {'producto': prod.toJson()});
310:     }
311:     _hub.emitir(TiposEvento.balanceEnvasesActualizado, {
312:       'balance': _repoEnvases.obtenerBalance(),
313:     });
314:   }
315: 
316:   Map<String, Object?> detalle(String id) {
317:     final v = _repoVentas.obtenerPorId(id);
318:     if (v == null) throw ErrorApi.noEncontrado('la venta');
319:     final lineas = _repoVentas.obtenerLineas(id);
320:     return {
321:       'id': v['id'],
322:       'folio': v['folio'],
323:       'fecha': v['fecha'],
324:       'diaNegocio': v['dia_negocio'],
325:       'total': v['total'],
326:       'metodo': v['metodo'],
327:       'tarjeta': v['tarjeta'],
328:       'recibido': v['recibido'],
329:       'cambio': v['cambio'],
330:       'envModo': v['env_modo'],
331:       'envN': v['env_n'],
332:       'envMonto': v['env_monto'],
333:       'origen': v['origen'],
334:       'cancelada': (v['cancelada'] as int) == 1,
335:       'lineas': [
336:         for (final l in lineas)
337:           {
338:             'productoId': l['producto_id'],
339:             'nombre': l['nombre'],
340:             'unidad': l['unidad'],
341:             'cantidad': l['cantidad'],
342:             'piezas': l['piezas'],
343:             'precioUnit': l['precio_unit'],
344:             'subtotal': l['subtotal'],
345:           },
346:       ],
347:     };
348:   }
349: 
350:   List<Map<String, Object?>> listar({String? diaNegocio}) {
351:     return _repoVentas
352:         .listar(diaNegocio: diaNegocio)
353:         .map(
354:           (v) => {
355:             'id': v['id'],
356:             'folio': v['folio'],
357:             'fecha': v['fecha'],
358:             'total': v['total'],
359:             'metodo': v['metodo'],
360:             'origen': v['origen'],
361:             'cancelada': (v['cancelada'] as int) == 1,
362:           },
363:         )
364:         .toList();
365:   }
366: }
````

## File: backend/test/ventas_test.dart
````dart
  1: import 'package:test/test.dart';
  2: import 'ayudantes/servidor_prueba.dart';
  3: 
  4: void main() {
  5:   late ServidorPrueba s;
  6: 
  7:   setUp(() async => s = await crearServidorDePrueba());
  8:   tearDown(() => s.cerrar());
  9: 
 10:   group('Ventas y envases', () {
 11:     test(
 12:       'la caja registra una venta en efectivo y descuenta inventario',
 13:       () async {
 14:         // 1. Crear producto con 10 piezas
 15:         final prodRes = await s.post(
 16:           '/api/v1/productos',
 17:           productoValido({
 18:             'existenciaPiezas': 10,
 19:             'precio': 4200,
 20:             'precioCaja': 48000,
 21:             'piezasPorCaja': 12,
 22:           }),
 23:         );
 24:         final pid = json(prodRes)['id'] as String;
 25: 
 26:         // 2. Registrar cobro
 27:         final ventaRes = await s.post('/api/v1/ventas', {
 28:           'metodo': 'efectivo',
 29:           'recibido': 5000,
 30:           'envModo': 'trae',
 31:           'lineas': [
 32:             {'productoId': pid, 'unidad': 'pieza', 'cantidad': 1},
 33:           ],
 34:         });
 35: 
 36:         expect(ventaRes.statusCode, 201);
 37:         final venta = json(ventaRes);
 38:         expect(venta['folio'], 1001);
 39:         expect(venta['total'], 4200);
 40:         expect(venta['cambio'], 800);
 41: 
 42:         // 3. Verificar que descontó stock
 43:         final detalle = json(await s.get('/api/v1/productos/$pid'));
 44:         expect(detalle['existenciaPiezas'], 9);
 45:       },
 46:     );
 47: 
 48:     test('falla si no hay existencias suficientes', () async {
 49:       final prodRes = await s.post(
 50:         '/api/v1/productos',
 51:         productoValido({'existenciaPiezas': 2}),
 52:       );
 53:       final pid = json(prodRes)['id'] as String;
 54: 
 55:       final ventaRes = await s.post('/api/v1/ventas', {
 56:         'metodo': 'efectivo',
 57:         'recibido': 50000,
 58:         'lineas': [
 59:           {'productoId': pid, 'unidad': 'pieza', 'cantidad': 5},
 60:         ],
 61:       });
 62: 
 63:       expect(ventaRes.statusCode, 400);
 64:       expect(codigoError(ventaRes), 'datos_invalidos');
 65:     });
 66: 
 67:     test('una terminal no puede cobrar ventas directo (solo caja)', () async {
 68:       final claveTerminal = await s.registrarTerminal();
 69:       final ventaRes = await s.post('/api/v1/ventas', {
 70:         'metodo': 'efectivo',
 71:         'lineas': [],
 72:       }, clave: claveTerminal);
 73: 
 74:       expect(ventaRes.statusCode, 403);
 75:       expect(codigoError(ventaRes), 'solo_caja');
 76:     });
 77: 
 78:     test(
 79:       'una terminal puede levantar pedidos y la caja descartarlos',
 80:       () async {
 81:         final claveTerminal = await s.registrarTerminal();
 82:         final prodRes = await s.post('/api/v1/productos', productoValido());
 83:         final pid = json(prodRes)['id'] as String;
 84: 
 85:         // Terminal crea pedido
 86:         final pedRes = await s.post('/api/v1/pedidos', {
 87:           'nota': 'Mesa 3',
 88:           'lineas': [
 89:             {'productoId': pid, 'unidad': 'pieza', 'cantidad': 2},
 90:           ],
 91:         }, clave: claveTerminal);
 92:         expect(pedRes.statusCode, 201);
 93:         final idPedido = json(pedRes)['id'] as String;
 94: 
 95:         // Caja lista pedidos
 96:         final lista = json(await s.get('/api/v1/pedidos'))['pedidos'] as List;
 97:         expect(lista.any((p) => p['id'] == idPedido), isTrue);
 98: 
 99:         // Caja descarta pedido
100:         final deleteRes = await s.delete('/api/v1/pedidos/$idPedido');
101:         expect(deleteRes.statusCode, 204);
102:       },
103:     );
104: 
105:     test('balance de envases se consulta y actualiza con préstamos', () async {
106:       final balRes = await s.get('/api/v1/envases');
107:       expect(balRes.statusCode, 200);
108:       expect(json(balRes)['balance'], contains('mega'));
109: 
110:       final prestamoRes = await s.post('/api/v1/envases/prestamos', {
111:         'cliente': 'Don Pedro',
112:         'formato': 'mega',
113:         'cantidad': 10,
114:       });
115:       expect(prestamoRes.statusCode, 201);
116:       final idPrestamo = json(prestamoRes)['id'] as String;
117: 
118:       final devRes = await s.post(
119:         '/api/v1/envases/prestamos/$idPrestamo/devolver',
120:         null,
121:       );
122:       expect(devRes.statusCode, 204);
123:     });
124:   });
125: }
````

## File: .github/pull_request_template.md
````markdown
 1: ## Qué cambia
 2: 
 3: <!-- Una o dos frases. Liga la tarjeta de Trello: ANQ-12 -->
 4: 
 5: ## Cómo probarlo
 6: 
 7: 1.
 8: 
 9: ## Capturas
10: 
11: <!-- Obligatorias si toca pantallas de la app. Borra esta sección si no aplica. -->
12: 
13: ## Checklist
14: 
15: - [ ] Sigue `docs/ESTANDARES.md` (centavos, UTC y `diaNegocio()`, transacciones, movimientos).
16: - [ ] Tiene pruebas. Si toca dinero o existencias, hay una prueba e2e del flujo.
17: - [ ] Si toca la API, `docs/API.md` está actualizado y el PR lleva la etiqueta `contrato`.
18: - [ ] Si agrega una migración, es un archivo nuevo con el siguiente número.
19: - [ ] `CHANGELOG.md` actualizado en "Sin publicar".
20: - [ ] Front: probado en un dispositivo real, con estados de carga, error y vacío.
````

## File: app/lib/app/tema/colores.dart
````dart
  1: import 'package:flutter/material.dart';
  2: 
  3: /// Paleta de Anaquel, tomada del prototipo (docs/prototipo).
  4: ///
  5: /// - vidrio: café de botella, para la barra lateral y encabezados.
  6: /// - lager: ámbar de cerveza, el acento de acciones principales.
  7: /// - verde / alerta / azul: estados.
  8: ///
  9: /// Se lee con `context.colores` (ver [ColoresContexto]).
 10: @immutable
 11: class ColoresAnaquel extends ThemeExtension<ColoresAnaquel> {
 12:   const ColoresAnaquel({
 13:     required this.fondo,
 14:     required this.superficie,
 15:     required this.superficie2,
 16:     required this.superficie3,
 17:     required this.tinta,
 18:     required this.tinta2,
 19:     required this.linea,
 20:     required this.vidrio,
 21:     required this.vidrio2,
 22:     required this.vidrioTinta,
 23:     required this.vidrioTinta2,
 24:     required this.lager,
 25:     required this.lagerTinta,
 26:     required this.lagerSuave,
 27:     required this.verde,
 28:     required this.verdeSuave,
 29:     required this.alerta,
 30:     required this.alertaSuave,
 31:     required this.azul,
 32:     required this.seleccion,
 33:     required this.seleccionTinta,
 34:     required this.fondoCerveza,
 35:     required this.fondoRefresco,
 36:     required this.fondoBotana,
 37:     required this.fondoHielo,
 38:     required this.fondoOtro,
 39:     required this.sombra,
 40:   });
 41: 
 42:   final Color fondo;
 43:   final Color superficie;
 44:   final Color superficie2;
 45:   final Color superficie3;
 46:   final Color tinta;
 47:   final Color tinta2;
 48:   final Color linea;
 49:   final Color vidrio;
 50:   final Color vidrio2;
 51:   final Color vidrioTinta;
 52:   final Color vidrioTinta2;
 53:   final Color lager;
 54:   final Color lagerTinta;
 55:   final Color lagerSuave;
 56:   final Color verde;
 57:   final Color verdeSuave;
 58:   final Color alerta;
 59:   final Color alertaSuave;
 60:   final Color azul;
 61:   final Color seleccion;
 62:   final Color seleccionTinta;
 63:   final Color fondoCerveza;
 64:   final Color fondoRefresco;
 65:   final Color fondoBotana;
 66:   final Color fondoHielo;
 67:   final Color fondoOtro;
 68:   final List<BoxShadow> sombra;
 69: 
 70:   static const claro = ColoresAnaquel(
 71:     fondo: Color(0xFFE4ECEE),
 72:     superficie: Color(0xFFFFFFFF),
 73:     superficie2: Color(0xFFF1F5F6),
 74:     superficie3: Color(0xFFE7EEF0),
 75:     tinta: Color(0xFF1B2226),
 76:     tinta2: Color(0xFF56646B),
 77:     linea: Color(0xFFCFDADE),
 78:     vidrio: Color(0xFF3A2518),
 79:     vidrio2: Color(0xFF4E3322),
 80:     vidrioTinta: Color(0xFFF6E7D2),
 81:     vidrioTinta2: Color(0xFFC9AE8E),
 82:     lager: Color(0xFFF0A500),
 83:     lagerTinta: Color(0xFF2A1A00),
 84:     lagerSuave: Color(0xFFFFF1CC),
 85:     verde: Color(0xFF2E6B4E),
 86:     verdeSuave: Color(0xFFDDEFE5),
 87:     alerta: Color(0xFFB8322A),
 88:     alertaSuave: Color(0xFFF9E0DD),
 89:     azul: Color(0xFF2F6690),
 90:     seleccion: Color(0xFF3A2518),
 91:     seleccionTinta: Color(0xFFF6E7D2),
 92:     fondoCerveza: Color(0xFFF5E3C3),
 93:     fondoRefresco: Color(0xFFF4DEDC),
 94:     fondoBotana: Color(0xFFF7E6C8),
 95:     fondoHielo: Color(0xFFD9ECF4),
 96:     fondoOtro: Color(0xFFE5E9EA),
 97:     sombra: [
 98:       BoxShadow(color: Color(0x0F142328), blurRadius: 2, offset: Offset(0, 1)),
 99:       BoxShadow(
100:         color: Color(0x2E142328),
101:         blurRadius: 24,
102:         spreadRadius: -12,
103:         offset: Offset(0, 8),
104:       ),
105:     ],
106:   );
107: 
108:   static const oscuro = ColoresAnaquel(
109:     fondo: Color(0xFF0F171A),
110:     superficie: Color(0xFF172226),
111:     superficie2: Color(0xFF1F2C31),
112:     superficie3: Color(0xFF26353B),
113:     tinta: Color(0xFFE7EEF0),
114:     tinta2: Color(0xFF9AAAB0),
115:     linea: Color(0xFF2E3E44),
116:     vidrio: Color(0xFF24160D),
117:     vidrio2: Color(0xFF352216),
118:     vidrioTinta: Color(0xFFF3E1C7),
119:     vidrioTinta2: Color(0xFFB89A78),
120:     lager: Color(0xFFF4B324),
121:     lagerTinta: Color(0xFF2A1A00),
122:     lagerSuave: Color(0xFF3A2C0C),
123:     verde: Color(0xFF5BB287),
124:     verdeSuave: Color(0xFF193428),
125:     alerta: Color(0xFFE8645B),
126:     alertaSuave: Color(0xFF3A1A18),
127:     azul: Color(0xFF6FA8D6),
128:     seleccion: Color(0xFFF4B324),
129:     seleccionTinta: Color(0xFF2A1A00),
130:     fondoCerveza: Color(0xFF3A2E1C),
131:     fondoRefresco: Color(0xFF3A2322),
132:     fondoBotana: Color(0xFF3B301E),
133:     fondoHielo: Color(0xFF1D3440),
134:     fondoOtro: Color(0xFF2A3336),
135:     sombra: [
136:       BoxShadow(color: Color(0x4D000000), blurRadius: 2, offset: Offset(0, 1)),
137:       BoxShadow(
138:         color: Color(0x99000000),
139:         blurRadius: 28,
140:         spreadRadius: -14,
141:         offset: Offset(0, 10),
142:       ),
143:     ],
144:   );
145: 
146:   /// Fondo de la ilustración de un producto según su categoría.
147:   Color fondoCategoria(String categoria) => switch (categoria) {
148:     'cerveza' => fondoCerveza,
149:     'refresco' => fondoRefresco,
150:     'botana' => fondoBotana,
151:     'hielo' => fondoHielo,
152:     _ => fondoOtro,
153:   };
154: 
155:   @override
156:   ColoresAnaquel copyWith() => this;
157: 
158:   @override
159:   ColoresAnaquel lerp(ColoresAnaquel? other, double t) =>
160:       t < 0.5 ? this : (other ?? this);
161: }
162: 
163: extension ColoresContexto on BuildContext {
164:   ColoresAnaquel get colores => Theme.of(this).extension<ColoresAnaquel>()!;
165: }
````

## File: app/lib/app/tema/tema.dart
````dart
  1: import 'package:flutter/material.dart';
  2: 
  3: import 'colores.dart';
  4: 
  5: const fuenteTexto = 'Barlow';
  6: const fuenteTitulos = 'Barlow Condensed';
  7: 
  8: /// Radios del sistema, iguales al prototipo.
  9: abstract final class Radios {
 10:   static const control = 10.0;
 11:   static const tarjeta = 16.0;
 12:   static const imagen = 12.0;
 13: }
 14: 
 15: ThemeData temaClaro() => _tema(ColoresAnaquel.claro, Brightness.light);
 16: 
 17: ThemeData temaOscuro() => _tema(ColoresAnaquel.oscuro, Brightness.dark);
 18: 
 19: ThemeData _tema(ColoresAnaquel c, Brightness brillo) {
 20:   final esquema = ColorScheme(
 21:     brightness: brillo,
 22:     primary: c.lager,
 23:     onPrimary: c.lagerTinta,
 24:     primaryContainer: c.lagerSuave,
 25:     onPrimaryContainer: c.tinta,
 26:     secondary: c.vidrio,
 27:     onSecondary: c.vidrioTinta,
 28:     tertiary: c.verde,
 29:     onTertiary: c.superficie,
 30:     error: c.alerta,
 31:     onError: Colors.white,
 32:     errorContainer: c.alertaSuave,
 33:     onErrorContainer: c.alerta,
 34:     surface: c.superficie,
 35:     onSurface: c.tinta,
 36:     onSurfaceVariant: c.tinta2,
 37:     surfaceContainerLowest: c.superficie,
 38:     surfaceContainerLow: c.superficie2,
 39:     surfaceContainer: c.superficie2,
 40:     surfaceContainerHigh: c.superficie3,
 41:     surfaceContainerHighest: c.superficie3,
 42:     outline: c.linea,
 43:     outlineVariant: c.linea,
 44:     shadow: Colors.black,
 45:     inverseSurface: c.tinta,
 46:     onInverseSurface: c.fondo,
 47:   );
 48: 
 49:   TextStyle titulo(double tamano, {FontWeight peso = FontWeight.w700}) =>
 50:       TextStyle(
 51:         fontFamily: fuenteTitulos,
 52:         fontSize: tamano,
 53:         fontWeight: peso,
 54:         height: 1.05,
 55:         color: c.tinta,
 56:       );
 57: 
 58:   TextStyle cuerpo(
 59:     double tamano, {
 60:     FontWeight peso = FontWeight.w400,
 61:     Color? color,
 62:   }) => TextStyle(
 63:     fontFamily: fuenteTexto,
 64:     fontSize: tamano,
 65:     fontWeight: peso,
 66:     height: 1.4,
 67:     color: color ?? c.tinta,
 68:   );
 69: 
 70:   final textos = TextTheme(
 71:     displayLarge: titulo(56),
 72:     displayMedium: titulo(46),
 73:     displaySmall: titulo(40),
 74:     headlineLarge: titulo(34),
 75:     headlineMedium: titulo(30),
 76:     headlineSmall: titulo(26),
 77:     titleLarge: titulo(24),
 78:     titleMedium: cuerpo(17, peso: FontWeight.w600),
 79:     titleSmall: cuerpo(15, peso: FontWeight.w600),
 80:     bodyLarge: cuerpo(17),
 81:     bodyMedium: cuerpo(15),
 82:     bodySmall: cuerpo(14, color: c.tinta2),
 83:     labelLarge: cuerpo(16, peso: FontWeight.w600),
 84:     labelMedium: cuerpo(14, peso: FontWeight.w500),
 85:     labelSmall: cuerpo(12, peso: FontWeight.w500, color: c.tinta2),
 86:   );
 87: 
 88:   final forma = RoundedRectangleBorder(
 89:     borderRadius: BorderRadius.circular(Radios.control),
 90:   );
 91:   const tamanoMinimo = Size(46, 46);
 92:   const relleno = EdgeInsets.symmetric(horizontal: 16, vertical: 10);
 93: 
 94:   return ThemeData(
 95:     useMaterial3: true,
 96:     brightness: brillo,
 97:     colorScheme: esquema,
 98:     fontFamily: fuenteTexto,
 99:     textTheme: textos,
100:     scaffoldBackgroundColor: c.fondo,
101:     canvasColor: c.fondo,
102:     dividerColor: c.linea,
103:     splashFactory: InkSparkle.splashFactory,
104:     extensions: [c],
105:     dividerTheme: DividerThemeData(color: c.linea, thickness: 1, space: 1),
106:     appBarTheme: AppBarTheme(
107:       backgroundColor: c.superficie,
108:       foregroundColor: c.tinta,
109:       surfaceTintColor: Colors.transparent,
110:       elevation: 0,
111:       scrolledUnderElevation: 0,
112:       titleTextStyle: titulo(30),
113:       shape: Border(bottom: BorderSide(color: c.linea)),
114:     ),
115:     filledButtonTheme: FilledButtonThemeData(
116:       style: FilledButton.styleFrom(
117:         backgroundColor: c.lager,
118:         foregroundColor: c.lagerTinta,
119:         disabledBackgroundColor: c.superficie3,
120:         minimumSize: tamanoMinimo,
121:         padding: relleno,
122:         shape: forma,
123:         textStyle: textos.labelLarge,
124:       ),
125:     ),
126:     outlinedButtonTheme: OutlinedButtonThemeData(
127:       style: OutlinedButton.styleFrom(
128:         backgroundColor: c.superficie,
129:         foregroundColor: c.tinta,
130:         side: BorderSide(color: c.linea),
131:         minimumSize: tamanoMinimo,
132:         padding: relleno,
133:         shape: forma,
134:         textStyle: textos.labelLarge,
135:       ),
136:     ),
137:     textButtonTheme: TextButtonThemeData(
138:       style: TextButton.styleFrom(
139:         foregroundColor: c.tinta,
140:         minimumSize: tamanoMinimo,
141:         shape: forma,
142:         textStyle: textos.labelLarge,
143:       ),
144:     ),
145:     iconButtonTheme: IconButtonThemeData(
146:       style: IconButton.styleFrom(
147:         foregroundColor: c.tinta,
148:         minimumSize: tamanoMinimo,
149:         shape: forma,
150:       ),
151:     ),
152:     inputDecorationTheme: InputDecorationTheme(
153:       filled: true,
154:       fillColor: c.superficie,
155:       hintStyle: cuerpo(16, color: c.tinta2),
156:       labelStyle: cuerpo(16, color: c.tinta2),
157:       contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
158:       border: OutlineInputBorder(
159:         borderRadius: BorderRadius.circular(Radios.control),
160:         borderSide: BorderSide(color: c.linea),
161:       ),
162:       enabledBorder: OutlineInputBorder(
163:         borderRadius: BorderRadius.circular(Radios.control),
164:         borderSide: BorderSide(color: c.linea),
165:       ),
166:       focusedBorder: OutlineInputBorder(
167:         borderRadius: BorderRadius.circular(Radios.control),
168:         borderSide: BorderSide(color: c.lager, width: 2),
169:       ),
170:       errorBorder: OutlineInputBorder(
171:         borderRadius: BorderRadius.circular(Radios.control),
172:         borderSide: BorderSide(color: c.alerta),
173:       ),
174:     ),
175:     chipTheme: ChipThemeData(
176:       backgroundColor: c.superficie,
177:       selectedColor: c.seleccion,
178:       side: BorderSide(color: c.linea),
179:       shape: const StadiumBorder(),
180:       labelStyle: cuerpo(15, peso: FontWeight.w500),
181:       secondaryLabelStyle: cuerpo(
182:         15,
183:         peso: FontWeight.w600,
184:         color: c.seleccionTinta,
185:       ),
186:       checkmarkColor: c.seleccionTinta,
187:       showCheckmark: false,
188:       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
189:     ),
190:     cardTheme: CardThemeData(
191:       color: c.superficie,
192:       surfaceTintColor: Colors.transparent,
193:       elevation: 0,
194:       margin: EdgeInsets.zero,
195:       shape: RoundedRectangleBorder(
196:         borderRadius: BorderRadius.circular(Radios.tarjeta),
197:         side: BorderSide(color: c.linea),
198:       ),
199:     ),
200:     dialogTheme: DialogThemeData(
201:       backgroundColor: c.superficie,
202:       surfaceTintColor: Colors.transparent,
203:       shape: RoundedRectangleBorder(
204:         borderRadius: BorderRadius.circular(Radios.tarjeta),
205:       ),
206:       titleTextStyle: titulo(28),
207:       contentTextStyle: cuerpo(16, color: c.tinta2),
208:     ),
209:     bottomSheetTheme: BottomSheetThemeData(
210:       backgroundColor: c.superficie,
211:       surfaceTintColor: Colors.transparent,
212:       showDragHandle: true,
213:       dragHandleColor: c.linea,
214:       shape: const RoundedRectangleBorder(
215:         borderRadius: BorderRadius.vertical(
216:           top: Radius.circular(Radios.tarjeta),
217:         ),
218:       ),
219:     ),
220:     snackBarTheme: SnackBarThemeData(
221:       behavior: SnackBarBehavior.floating,
222:       backgroundColor: c.tinta,
223:       contentTextStyle: cuerpo(15, color: c.fondo),
224:       shape: RoundedRectangleBorder(
225:         borderRadius: BorderRadius.circular(Radios.control),
226:       ),
227:     ),
228:     navigationBarTheme: NavigationBarThemeData(
229:       backgroundColor: c.superficie,
230:       surfaceTintColor: Colors.transparent,
231:       indicatorColor: c.lagerSuave,
232:       height: 70,
233:       labelTextStyle: WidgetStateProperty.resolveWith(
234:         (s) => cuerpo(
235:           13,
236:           peso: s.contains(WidgetState.selected)
237:               ? FontWeight.w700
238:               : FontWeight.w600,
239:           color: s.contains(WidgetState.selected) ? c.tinta : c.tinta2,
240:         ),
241:       ),
242:       iconTheme: WidgetStateProperty.resolveWith(
243:         (s) => IconThemeData(
244:           color: s.contains(WidgetState.selected) ? c.tinta : c.tinta2,
245:         ),
246:       ),
247:     ),
248:     progressIndicatorTheme: ProgressIndicatorThemeData(color: c.lager),
249:     textSelectionTheme: TextSelectionThemeData(
250:       cursorColor: c.lager,
251:       selectionColor: c.lager.withValues(alpha: 0.35),
252:       selectionHandleColor: c.lager,
253:     ),
254:   );
255: }
````

## File: app/lib/app/app.dart
````dart
 1: import 'package:flutter/material.dart';
 2: import 'package:flutter_localizations/flutter_localizations.dart';
 3: import 'package:flutter_riverpod/flutter_riverpod.dart';
 4: 
 5: import '../core/config/configuracion.dart';
 6: import 'router.dart';
 7: import 'tema/tema.dart';
 8: 
 9: class AnaquelApp extends ConsumerWidget {
10:   const AnaquelApp({super.key});
11: 
12:   @override
13:   Widget build(BuildContext context, WidgetRef ref) {
14:     return MaterialApp.router(
15:       title: 'Anaquel',
16:       debugShowCheckedModeBanner: false,
17:       theme: temaClaro(),
18:       darkTheme: temaOscuro(),
19:       themeMode: ref.watch(configuracionProvider.select((c) => c.tema)),
20:       routerConfig: ref.watch(routerProvider),
21:       locale: const Locale('es', 'MX'),
22:       supportedLocales: const [Locale('es', 'MX'), Locale('es')],
23:       localizationsDelegates: GlobalMaterialLocalizations.delegates,
24:     );
25:   }
26: }
````

## File: app/lib/app/router.dart
````dart
  1: import 'package:flutter/material.dart';
  2: import 'package:flutter_riverpod/flutter_riverpod.dart';
  3: import 'package:go_router/go_router.dart';
  4: 
  5: import '../core/config/configuracion.dart';
  6: import '../features/ajustes/ajustes.dart';
  7: import '../features/caja/pantallas/secciones_caja.dart';
  8: import '../features/caja/pantallas/shell_caja.dart';
  9: import '../features/catalogo/pantallas/vista_catalogo.dart';
 10: import '../features/inicio/elegir_modo.dart';
 11: import '../features/proximamente/proximamente.dart';
 12: import '../features/terminal/pantallas/escanear.dart';
 13: import '../features/terminal/pantallas/shell_terminal.dart';
 14: import '../features/terminal/pantallas/vincular_terminal.dart';
 15: 
 16: /// Rutas:
 17: /// - `/inicio`: elegir modo.
 18: /// - `/caja/<sección>`: secciones de la caja (secciones_caja.dart).
 19: /// - `/terminal/vincular` y `/terminal/<pestaña>`.
 20: ///
 21: /// La configuración decide a dónde se puede ir: sin modo → `/inicio`;
 22: /// terminal sin vincular → `/terminal/vincular`.
 23: final routerProvider = Provider<GoRouter>((ref) {
 24:   final cambios = ValueNotifier(0);
 25:   ref.listen(configuracionProvider, (_, _) => cambios.value++);
 26:   ref.onDispose(cambios.dispose);
 27: 
 28:   final router = GoRouter(
 29:     initialLocation: '/inicio',
 30:     refreshListenable: cambios,
 31:     redirect: (context, estado) =>
 32:         _redirigir(ref.read(configuracionProvider), estado.uri.path),
 33:     routes: [
 34:       GoRoute(path: '/inicio', builder: (_, _) => const ElegirModo()),
 35:       ShellRoute(
 36:         builder: (_, estado, hijo) => ShellCaja(
 37:           seccion: estado.pathParameters['seccion'] ?? 'inicio',
 38:           child: hijo,
 39:         ),
 40:         routes: [
 41:           GoRoute(
 42:             path: '/caja/:seccion',
 43:             pageBuilder: (_, estado) {
 44:               final s = seccionCaja(estado.pathParameters['seccion']!);
 45:               return NoTransitionPage(
 46:                 key: ValueKey(s.ruta),
 47:                 child: s.construir(),
 48:               );
 49:             },
 50:           ),
 51:         ],
 52:       ),
 53:       GoRoute(
 54:         path: '/terminal/vincular',
 55:         builder: (_, _) => const VincularTerminal(),
 56:       ),
 57:       ShellRoute(
 58:         builder: (_, estado, hijo) => ShellTerminal(
 59:           seccion: estado.pathParameters['seccion'] ?? 'escanear',
 60:           child: hijo,
 61:         ),
 62:         routes: [
 63:           GoRoute(
 64:             path: '/terminal/:seccion',
 65:             pageBuilder: (_, estado) {
 66:               final seccion = estado.pathParameters['seccion']!;
 67:               return NoTransitionPage(
 68:                 key: ValueKey(seccion),
 69:                 child: _pestanaTerminal(seccion),
 70:               );
 71:             },
 72:           ),
 73:         ],
 74:       ),
 75:     ],
 76:   );
 77:   ref.onDispose(router.dispose);
 78:   return router;
 79: });
 80: 
 81: String? _redirigir(Configuracion config, String ruta) {
 82:   switch (config.modo) {
 83:     case null:
 84:       return ruta == '/inicio' ? null : '/inicio';
 85:     case ModoDispositivo.caja:
 86:       return ruta.startsWith('/caja/') ? null : '/caja/inicio';
 87:     case ModoDispositivo.terminal:
 88:       if (config.conexion == null) {
 89:         return ruta == '/terminal/vincular' ? null : '/terminal/vincular';
 90:       }
 91:       return ruta.startsWith('/terminal/') && ruta != '/terminal/vincular'
 92:           ? null
 93:           : '/terminal/escanear';
 94:   }
 95: }
 96: 
 97: Widget _pestanaTerminal(String seccion) => switch (seccion) {
 98:   'productos' => const VistaCatalogo(
 99:     relleno: EdgeInsets.fromLTRB(16, 16, 16, 0),
100:   ),
101:   'pedido' => const Proximamente(
102:     icono: Icons.receipt_outlined,
103:     titulo: 'Pedido',
104:     descripcion:
105:         'Arma el pedido del cliente aquí y mándalo a la caja para cobrarlo.',
106:     sprint: 3,
107:     responsable: 'Luis',
108:   ),
109:   'ajustes' => const PantallaAjustes(),
110:   _ => const PantallaEscanear(),
111: };
````

## File: app/lib/core/api/api_falsa.dart
````dart
  1: import 'package:deposito_backend/deposito_backend.dart';
  2: 
  3: import 'api.dart';
  4: 
  5: /// Datos de prueba con la forma exacta del contrato. Sirve para pruebas de
  6: /// widgets y para programar pantallas antes de que exista su endpoint.
  7: class ApiFalsa implements Api {
  8:   ApiFalsa({List<Producto>? productos, List<Terminal>? terminales})
  9:     : productos = productos ?? productosDePrueba(),
 10:       terminales = terminales ?? [];
 11: 
 12:   final List<Producto> productos;
 13:   final List<Terminal> terminales;
 14: 
 15:   @override
 16:   Uri get base => Uri.parse('http://127.0.0.1:8080');
 17: 
 18:   @override
 19:   String get clave => 'clave-falsa';
 20: 
 21:   @override
 22:   Future<List<Producto>> listarProductos() async => List.of(productos);
 23: 
 24:   @override
 25:   Future<Producto> crearProducto(Map<String, Object?> datos) async {
 26:     final p = Producto.fromJson({
 27:       'id': 'p_${productos.length + 1}',
 28:       'existenciaPiezas': 0,
 29:       'minimo': 0,
 30:       'creado': '2026-10-02T18:30:00Z',
 31:       'actualizado': '2026-10-02T18:30:00Z',
 32:       ...datos,
 33:     });
 34:     productos.add(p);
 35:     return p;
 36:   }
 37: 
 38:   @override
 39:   Future<CodigoEmparejamiento> crearCodigoEmparejamiento() async =>
 40:       CodigoEmparejamiento(
 41:         codigo: '482913',
 42:         expira: instanteIso(DateTime.now().add(const Duration(minutes: 10))),
 43:       );
 44: 
 45:   @override
 46:   Future<List<Terminal>> listarTerminales() async => List.of(terminales);
 47: 
 48:   @override
 49:   Future<void> revocarTerminal(String id) async =>
 50:       terminales.removeWhere((t) => t.id == id);
 51: }
 52: 
 53: List<Producto> productosDePrueba() {
 54:   Producto p(
 55:     String id,
 56:     String codigo,
 57:     String nombre,
 58:     String categoria,
 59:     String presentacion,
 60:     int precio,
 61:     int existencia,
 62:     int minimo, {
 63:     int? precioCaja,
 64:     int? piezasPorCaja,
 65:     String? envase,
 66:     String? caducidad,
 67:   }) => Producto(
 68:     id: id,
 69:     codigo: codigo,
 70:     nombre: nombre,
 71:     categoria: categoria,
 72:     presentacion: presentacion,
 73:     precio: precio,
 74:     precioCaja: precioCaja,
 75:     piezasPorCaja: piezasPorCaja,
 76:     existenciaPiezas: existencia,
 77:     minimo: minimo,
 78:     envase: envase,
 79:     caducidad: caducidad,
 80:     creado: '2026-10-02T18:30:00Z',
 81:     actualizado: '2026-10-02T18:30:00Z',
 82:   );
 83: 
 84:   return [
 85:     p(
 86:       'p_1',
 87:       '7501064191015',
 88:       'Victoria Mega',
 89:       'cerveza',
 90:       'Mega 1.2 L',
 91:       4200,
 92:       66,
 93:       36,
 94:       precioCaja: 48000,
 95:       piezasPorCaja: 12,
 96:       envase: 'mega',
 97:       caducidad: '2027-01-29',
 98:     ),
 99:     p(
100:       'p_2',
101:       '7501064191022',
102:       'Corona Mega',
103:       'cerveza',
104:       'Mega 1.2 L',
105:       4400,
106:       30,
107:       36,
108:       precioCaja: 50000,
109:       piezasPorCaja: 12,
110:       envase: 'mega',
111:       caducidad: '2027-01-04',
112:     ),
113:     p(
114:       'p_3',
115:       '7501064191046',
116:       'Corona Cuarto',
117:       'cerveza',
118:       'Cuarto 210 ml',
119:       1700,
120:       200,
121:       48,
122:       precioCaja: 38000,
123:       piezasPorCaja: 24,
124:       envase: 'cuarto',
125:       caducidad: '2026-10-21',
126:     ),
127:     p(
128:       'p_4',
129:       '7502000000017',
130:       'Hielo en bolsa',
131:       'hielo',
132:       'Bolsa 5 kg',
133:       3500,
134:       18,
135:       10,
136:     ),
137:     p(
138:       'p_5',
139:       '7502000000024',
140:       'Coca-Cola',
141:       'refresco',
142:       'Botella 600 ml',
143:       2200,
144:       40,
145:       24,
146:       caducidad: '2027-02-28',
147:     ),
148:     p(
149:       'p_6',
150:       '7502000000048',
151:       'Papas adobadas',
152:       'botana',
153:       'Bolsa 45 g',
154:       2000,
155:       25,
156:       20,
157:       caducidad: '2026-10-13',
158:     ),
159:   ];
160: }
````

## File: app/lib/core/api/api.dart
````dart
  1: import 'package:deposito_backend/deposito_backend.dart';
  2: import 'package:dio/dio.dart';
  3: 
  4: import 'fallo_api.dart';
  5: 
  6: /// Lo que la app le puede pedir al servidor (docs/API.md).
  7: ///
  8: /// Las pantallas solo conocen esta interfaz. [ApiHttp] habla con el servidor
  9: /// real; `ApiFalsa` regresa datos de prueba para pruebas de widgets y para
 10: /// avanzar antes de que exista un endpoint.
 11: abstract interface class Api {
 12:   /// `http://host:puerto`, para armar la URL del WebSocket.
 13:   Uri get base;
 14: 
 15:   String get clave;
 16: 
 17:   Future<List<Producto>> listarProductos();
 18: 
 19:   Future<Producto> crearProducto(Map<String, Object?> datos);
 20: 
 21:   Future<CodigoEmparejamiento> crearCodigoEmparejamiento();
 22: 
 23:   Future<List<Terminal>> listarTerminales();
 24: 
 25:   Future<void> revocarTerminal(String id);
 26: }
 27: 
 28: class ApiHttp implements Api {
 29:   ApiHttp({required this.base, required this.clave, Dio? dio})
 30:     : _dio =
 31:           dio ??
 32:           Dio(
 33:             BaseOptions(
 34:               baseUrl: base.toString(),
 35:               connectTimeout: const Duration(seconds: 5),
 36:               receiveTimeout: const Duration(seconds: 10),
 37:               headers: {cabeceraClave: clave},
 38:             ),
 39:           );
 40: 
 41:   @override
 42:   final Uri base;
 43:   @override
 44:   final String clave;
 45:   final Dio _dio;
 46: 
 47:   /// Registro de una terminal: es público, todavía no hay clave.
 48:   static Future<({Terminal terminal, String clave})> registrarTerminal({
 49:     required Uri base,
 50:     required String nombre,
 51:     required String codigo,
 52:   }) async {
 53:     final dio = Dio(
 54:       BaseOptions(
 55:         baseUrl: base.toString(),
 56:         connectTimeout: const Duration(seconds: 5),
 57:         receiveTimeout: const Duration(seconds: 10),
 58:       ),
 59:     );
 60:     try {
 61:       final r = await dio.post<Map<String, Object?>>(
 62:         '/api/v1/terminales/registro',
 63:         data: {'nombre': nombre, 'codigo': codigo},
 64:       );
 65:       return (
 66:         terminal: Terminal.fromJson((r.data!['terminal'] as Map).cast()),
 67:         clave: r.data!['clave'] as String,
 68:       );
 69:     } on DioException catch (e) {
 70:       throw FalloApi.desdeDio(e);
 71:     } finally {
 72:       dio.close();
 73:     }
 74:   }
 75: 
 76:   @override
 77:   Future<List<Producto>> listarProductos() => _pedir(() async {
 78:     final r = await _dio.get<Map<String, Object?>>('/api/v1/productos');
 79:     return [
 80:       for (final p in r.data!['productos'] as List)
 81:         Producto.fromJson((p as Map).cast()),
 82:     ];
 83:   });
 84: 
 85:   @override
 86:   Future<Producto> crearProducto(Map<String, Object?> datos) =>
 87:       _pedir(() async {
 88:         final r = await _dio.post<Map<String, Object?>>(
 89:           '/api/v1/productos',
 90:           data: datos,
 91:         );
 92:         return Producto.fromJson(r.data!);
 93:       });
 94: 
 95:   @override
 96:   Future<CodigoEmparejamiento> crearCodigoEmparejamiento() => _pedir(() async {
 97:     final r = await _dio.post<Map<String, Object?>>(
 98:       '/api/v1/terminales/codigo',
 99:     );
100:     return CodigoEmparejamiento.fromJson(r.data!);
101:   });
102: 
103:   @override
104:   Future<List<Terminal>> listarTerminales() => _pedir(() async {
105:     final r = await _dio.get<Map<String, Object?>>('/api/v1/terminales');
106:     return [
107:       for (final t in r.data!['terminales'] as List)
108:         Terminal.fromJson((t as Map).cast()),
109:     ];
110:   });
111: 
112:   @override
113:   Future<void> revocarTerminal(String id) =>
114:       _pedir(() => _dio.delete<void>('/api/v1/terminales/$id'));
115: 
116:   Future<T> _pedir<T>(Future<T> Function() accion) async {
117:     try {
118:       return await accion();
119:     } on DioException catch (e) {
120:       throw FalloApi.desdeDio(e);
121:     }
122:   }
123: }
````

## File: app/lib/core/api/fallo_api.dart
````dart
 1: import 'package:dio/dio.dart';
 2: 
 3: /// Error de la API ya traducido para mostrarlo en pantalla.
 4: ///
 5: /// [codigo] es el del contrato (`datos_invalidos`, `no_autorizado`...) o
 6: /// `sin_conexion` cuando no se pudo llegar al servidor.
 7: class FalloApi implements Exception {
 8:   const FalloApi(
 9:     this.codigo,
10:     this.mensaje, {
11:     this.campos = const {},
12:     this.estado,
13:   });
14: 
15:   final String codigo;
16:   final String mensaje;
17:   final Map<String, String> campos;
18:   final int? estado;
19: 
20:   bool get sinConexion => codigo == 'sin_conexion';
21: 
22:   bool get noAutorizado => estado == 401;
23: 
24:   factory FalloApi.desdeDio(DioException e) {
25:     final datos = e.response?.data;
26:     if (datos is Map && datos['error'] is Map) {
27:       final error = datos['error'] as Map;
28:       return FalloApi(
29:         error['codigo'] as String? ?? 'error',
30:         error['mensaje'] as String? ?? 'Ocurrió un error',
31:         campos: (error['campos'] as Map?)?.cast<String, String>() ?? const {},
32:         estado: e.response?.statusCode,
33:       );
34:     }
35:     return switch (e.type) {
36:       DioExceptionType.connectionError ||
37:       DioExceptionType.connectionTimeout ||
38:       DioExceptionType.receiveTimeout ||
39:       DioExceptionType.sendTimeout => const FalloApi(
40:         'sin_conexion',
41:         'No hay conexión con la caja. Revisa que estén en la misma Wi-Fi.',
42:       ),
43:       _ => FalloApi(
44:         'error',
45:         'Respuesta inesperada del servidor (${e.response?.statusCode ?? 'sin código'})',
46:         estado: e.response?.statusCode,
47:       ),
48:     };
49:   }
50: 
51:   @override
52:   String toString() => 'FalloApi($codigo: $mensaje)';
53: }
54: 
55: /// Mensaje legible para cualquier error que llegue a una pantalla.
56: String mensajeDeError(Object error) =>
57:     error is FalloApi ? error.mensaje : 'Ocurrió un error inesperado.';
````

## File: app/lib/core/api/proveedores.dart
````dart
 1: import 'package:flutter_riverpod/flutter_riverpod.dart';
 2: 
 3: import '../config/configuracion.dart';
 4: import '../servidor/servidor_embebido.dart';
 5: import 'api.dart';
 6: import 'fallo_api.dart';
 7: 
 8: /// La [Api] según el modo del dispositivo:
 9: /// - Caja: el servidor embebido, en `localhost`, con la clave de caja.
10: /// - Terminal: la IP de la caja, con la clave que recibió al registrarse.
11: ///
12: /// En pruebas se sobrescribe con `ApiFalsa`.
13: final apiProvider = FutureProvider<Api>((ref) async {
14:   final config = ref.watch(configuracionProvider);
15:   switch (config.modo) {
16:     case ModoDispositivo.caja:
17:       final servidor = await ref.watch(servidorEmbebidoProvider.future);
18:       return ApiHttp(
19:         base: Uri.parse('http://127.0.0.1:${servidor.puertoActual}'),
20:         clave: servidor.claveCaja,
21:       );
22:     case ModoDispositivo.terminal:
23:       final c = config.conexion;
24:       if (c == null) {
25:         throw const FalloApi(
26:           'sin_conexion',
27:           'Esta terminal no está vinculada a una caja.',
28:         );
29:       }
30:       return ApiHttp(
31:         base: Uri(scheme: 'http', host: c.host, port: c.puerto),
32:         clave: c.clave,
33:       );
34:     case null:
35:       throw StateError('Elige un modo antes de usar la API');
36:   }
37: }, retry: (_, _) => null);
````

## File: app/lib/core/config/configuracion.dart
````dart
  1: import 'package:flutter/material.dart';
  2: import 'package:flutter_riverpod/flutter_riverpod.dart';
  3: import 'package:shared_preferences/shared_preferences.dart';
  4: 
  5: enum ModoDispositivo { caja, terminal }
  6: 
  7: /// Datos con los que una terminal habla con la caja. La [clave] la entrega
  8: /// el servidor una sola vez, al registrarse.
  9: @immutable
 10: class ConexionTerminal {
 11:   const ConexionTerminal({
 12:     required this.host,
 13:     required this.puerto,
 14:     required this.clave,
 15:     required this.nombre,
 16:   });
 17: 
 18:   final String host;
 19:   final int puerto;
 20:   final String clave;
 21:   final String nombre;
 22: }
 23: 
 24: /// Configuración local de este dispositivo.
 25: @immutable
 26: class Configuracion {
 27:   const Configuracion({this.modo, this.conexion, this.tema = ThemeMode.system});
 28: 
 29:   final ModoDispositivo? modo;
 30:   final ConexionTerminal? conexion;
 31:   final ThemeMode tema;
 32: 
 33:   Configuracion copiar({
 34:     ModoDispositivo? Function()? modo,
 35:     ConexionTerminal? Function()? conexion,
 36:     ThemeMode? tema,
 37:   }) => Configuracion(
 38:     modo: modo == null ? this.modo : modo(),
 39:     conexion: conexion == null ? this.conexion : conexion(),
 40:     tema: tema ?? this.tema,
 41:   );
 42: }
 43: 
 44: /// Se sobrescribe en `main()` con la instancia ya cargada.
 45: final preferenciasProvider = Provider<SharedPreferences>(
 46:   (ref) => throw UnimplementedError('preferenciasProvider sin inicializar'),
 47: );
 48: 
 49: final configuracionProvider =
 50:     NotifierProvider<ConfiguracionNotifier, Configuracion>(
 51:       ConfiguracionNotifier.new,
 52:     );
 53: 
 54: class ConfiguracionNotifier extends Notifier<Configuracion> {
 55:   static const _modo = 'modo';
 56:   static const _tema = 'tema';
 57:   static const _host = 'conexion.host';
 58:   static const _puerto = 'conexion.puerto';
 59:   static const _clave = 'conexion.clave';
 60:   static const _nombre = 'conexion.nombre';
 61: 
 62:   SharedPreferences get _prefs => ref.read(preferenciasProvider);
 63: 
 64:   @override
 65:   Configuracion build() {
 66:     final p = ref.watch(preferenciasProvider);
 67:     final host = p.getString(_host);
 68:     final clave = p.getString(_clave);
 69:     return Configuracion(
 70:       modo: ModoDispositivo.values.asNameMap()[p.getString(_modo)],
 71:       tema:
 72:           ThemeMode.values.asNameMap()[p.getString(_tema)] ?? ThemeMode.system,
 73:       conexion: host == null || clave == null
 74:           ? null
 75:           : ConexionTerminal(
 76:               host: host,
 77:               puerto: p.getInt(_puerto) ?? 8080,
 78:               clave: clave,
 79:               nombre: p.getString(_nombre) ?? 'Terminal',
 80:             ),
 81:     );
 82:   }
 83: 
 84:   Future<void> elegirModo(ModoDispositivo? modo) async {
 85:     if (modo == null) {
 86:       await _prefs.remove(_modo);
 87:     } else {
 88:       await _prefs.setString(_modo, modo.name);
 89:     }
 90:     state = state.copiar(modo: () => modo);
 91:   }
 92: 
 93:   Future<void> guardarConexion(ConexionTerminal c) async {
 94:     await _prefs.setString(_host, c.host);
 95:     await _prefs.setInt(_puerto, c.puerto);
 96:     await _prefs.setString(_clave, c.clave);
 97:     await _prefs.setString(_nombre, c.nombre);
 98:     state = state.copiar(conexion: () => c);
 99:   }
100: 
101:   Future<void> olvidarConexion() async {
102:     for (final k in [_host, _puerto, _clave, _nombre]) {
103:       await _prefs.remove(k);
104:     }
105:     state = state.copiar(conexion: () => null);
106:   }
107: 
108:   Future<void> cambiarTema(ThemeMode tema) async {
109:     await _prefs.setString(_tema, tema.name);
110:     state = state.copiar(tema: tema);
111:   }
112: }
````

## File: app/lib/core/formato/formato.dart
````dart
 1: import 'package:deposito_backend/deposito_backend.dart';
 2: 
 3: /// El formateador de dinero de la app (docs/ESTANDARES.md). Ninguna pantalla
 4: /// formatea dinero por su cuenta.
 5: ///
 6: /// `4200` → `$42`, `4250` → `$42.50`, `123456` → `$1,234.56`.
 7: String dinero(int centavos) {
 8:   final negativo = centavos < 0;
 9:   final abs = centavos.abs();
10:   final pesos = abs ~/ 100;
11:   final resto = abs % 100;
12:   final miles = pesos.toString().replaceAllMapped(
13:     RegExp(r'(\d)(?=(\d{3})+$)'),
14:     (m) => '${m[1]},',
15:   );
16:   final texto = resto == 0
17:       ? '\$$miles'
18:       : '\$$miles.${resto.toString().padLeft(2, '0')}';
19:   return negativo ? '-$texto' : texto;
20: }
21: 
22: /// Existencia legible: `66` piezas en cajas de 12 → `5 cajas + 6 pz`.
23: String existenciaLegible(Producto p) {
24:   final piezas = p.existenciaPiezas;
25:   final porCaja = p.piezasPorCaja;
26:   if (porCaja == null || piezas < porCaja) return '$piezas pz';
27:   final cajas = piezas ~/ porCaja;
28:   final sueltas = piezas % porCaja;
29:   final textoCajas = cajas == 1 ? '1 caja' : '$cajas cajas';
30:   return sueltas == 0 ? textoCajas : '$textoCajas + $sueltas pz';
31: }
32: 
33: const _meses = [
34:   'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', //
35:   'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
36: ];
37: const _dias = [
38:   'lunes',
39:   'martes',
40:   'miércoles',
41:   'jueves',
42:   'viernes',
43:   'sábado',
44:   'domingo',
45: ];
46: 
47: /// `Jueves, 1 de octubre`.
48: String fechaLarga(DateTime f) {
49:   final dia = _dias[f.weekday - 1];
50:   return '${dia[0].toUpperCase()}${dia.substring(1)}, ${f.day} de ${_meses[f.month - 1]}';
51: }
52: 
53: /// `3 oct` a partir de `AAAA-MM-DD`.
54: String fechaCorta(String iso) {
55:   final f = DateTime.parse(iso);
56:   return '${f.day} ${_meses[f.month - 1].substring(0, 3)}';
57: }
58: 
59: /// Días de hoy a [iso] (`AAAA-MM-DD`); negativo si ya pasó.
60: int diasHasta(String iso, DateTime hoy) {
61:   final f = DateTime.parse(iso);
62:   return DateTime(
63:     f.year,
64:     f.month,
65:     f.day,
66:   ).difference(DateTime(hoy.year, hoy.month, hoy.day)).inDays;
67: }
68: 
69: /// Primera letra en mayúscula: `cerveza` → `Cerveza`.
70: String capitalizar(String t) =>
71:     t.isEmpty ? t : '${t[0].toUpperCase()}${t.substring(1)}';
72: 
73: /// Lee pesos escritos por una persona (`42`, `42.5`, `$1,234.50`) y los
74: /// regresa en centavos exactos, sin pasar por `double`. `null` si no es válido.
75: int? centavosDesdeTexto(String texto) {
76:   final limpio = texto.replaceAll(RegExp(r'[\s$,]'), '');
77:   final m = RegExp(r'^(\d{1,7})(?:\.(\d{1,2}))?$').firstMatch(limpio);
78:   if (m == null) return null;
79:   final pesos = int.parse(m[1]!);
80:   final cent = m[2] == null ? 0 : int.parse(m[2]!.padRight(2, '0'));
81:   return pesos * 100 + cent;
82: }
````

## File: app/lib/core/servidor/servidor_embebido.dart
````dart
 1: import 'dart:io';
 2: 
 3: import 'package:deposito_backend/deposito_backend.dart';
 4: import 'package:flutter_riverpod/flutter_riverpod.dart';
 5: import 'package:path_provider/path_provider.dart';
 6: 
 7: /// Carga los productos del prototipo la primera vez. Se apaga antes de la
 8: /// entrega al cliente (Sprint 5), cuando se cargue su inventario real.
 9: const cargarDatosEjemplo = true;
10: 
11: const puertoServidor = 8080;
12: 
13: /// El servidor que corre dentro de la app en modo Caja.
14: ///
15: /// Arranca la primera vez que alguien lo lee y se detiene si el provider se
16: /// descarta (por ejemplo, al cambiar a modo Terminal).
17: final servidorEmbebidoProvider = FutureProvider<DepositoServer>((ref) async {
18:   final documentos = await getApplicationDocumentsDirectory();
19:   final carpeta = Directory('${documentos.path}/anaquel')
20:     ..createSync(recursive: true);
21:   final servidor = DepositoServer(
22:     rutaBaseDatos: '${carpeta.path}/anaquel.db',
23:     puerto: puertoServidor,
24:     datosEjemplo: cargarDatosEjemplo,
25:     bitacora: Bitacora(rutaArchivo: '${carpeta.path}/anaquel.log'),
26:   );
27:   await servidor.iniciar();
28:   ref.onDispose(servidor.detener);
29:   return servidor;
30: }, retry: (_, _) => null);
31: 
32: /// IP de este dispositivo en la Wi-Fi, para el QR de emparejamiento.
33: final direccionLocalProvider = FutureProvider<String?>(
34:   (ref) => direccionLocal(),
35: );
36: 
37: Future<String?> direccionLocal() async {
38:   final interfaces = await NetworkInterface.list(
39:     type: InternetAddressType.IPv4,
40:   );
41:   final candidatas = [
42:     for (final i in interfaces)
43:       for (final d in i.addresses)
44:         if (!d.isLoopback && !d.isLinkLocal) (interfaz: i.name, ip: d.address),
45:   ];
46:   if (candidatas.isEmpty) return null;
47:   // Preferir la Wi-Fi (wlan0 en Android, en0 en iOS) y redes privadas.
48:   int puntaje(({String interfaz, String ip}) c) =>
49:       (c.interfaz.startsWith('wlan') || c.interfaz == 'en0' ? 2 : 0) +
50:       (c.ip.startsWith('192.168.') || c.ip.startsWith('10.') ? 1 : 0);
51:   candidatas.sort((a, b) => puntaje(b).compareTo(puntaje(a)));
52:   return candidatas.first.ip;
53: }
````

## File: app/lib/core/tiempo_real/tiempo_real.dart
````dart
  1: import 'dart:async';
  2: import 'dart:convert';
  3: import 'dart:math';
  4: 
  5: import 'package:deposito_backend/deposito_backend.dart';
  6: import 'package:flutter_riverpod/flutter_riverpod.dart';
  7: import 'package:web_socket_channel/io.dart';
  8: import 'package:web_socket_channel/web_socket_channel.dart';
  9: 
 10: import '../api/api.dart';
 11: import '../api/proveedores.dart';
 12: 
 13: enum EstadoConexion { conectando, enLinea, sinConexion }
 14: 
 15: /// Evento que la app genera al reconectarse: quien lo escuche debe volver a
 16: /// pedir sus datos completos (regla del contrato).
 17: const eventoReconectado = 'app.reconectado';
 18: 
 19: /// WebSocket con la caja. Se reconecta solo, con espera creciente de 1 a 10 s.
 20: class TiempoReal {
 21:   TiempoReal(this._api) {
 22:     _conectar();
 23:   }
 24: 
 25:   final Api _api;
 26:   final _eventos = StreamController<Evento>.broadcast();
 27:   final _estado = StreamController<EstadoConexion>.broadcast();
 28:   WebSocketChannel? _canal;
 29:   Timer? _reintento;
 30:   var _intentos = 0;
 31:   var _yaConecto = false;
 32:   var _cerrado = false;
 33:   EstadoConexion _actual = EstadoConexion.conectando;
 34: 
 35:   Stream<Evento> get eventos => _eventos.stream;
 36: 
 37:   Stream<EstadoConexion> get estados => _estado.stream;
 38: 
 39:   EstadoConexion get estado => _actual;
 40: 
 41:   Future<void> _conectar() async {
 42:     if (_cerrado) return;
 43:     _cambiar(EstadoConexion.conectando);
 44:     final uri = _api.base.replace(
 45:       scheme: _api.base.scheme == 'https' ? 'wss' : 'ws',
 46:       path: '/api/v1/ws',
 47:     );
 48:     try {
 49:       final canal = IOWebSocketChannel.connect(
 50:         uri,
 51:         headers: {cabeceraClave: _api.clave},
 52:         pingInterval: const Duration(seconds: 20),
 53:         connectTimeout: const Duration(seconds: 5),
 54:       );
 55:       _canal = canal;
 56:       await canal.ready;
 57:       if (_cerrado) return;
 58:       _intentos = 0;
 59:       _cambiar(EstadoConexion.enLinea);
 60:       if (_yaConecto) {
 61:         _eventos.add(
 62:           Evento(
 63:             tipo: eventoReconectado,
 64:             datos: const {},
 65:             fecha: instanteIso(DateTime.now()),
 66:           ),
 67:         );
 68:       }
 69:       _yaConecto = true;
 70:       canal.stream.listen(
 71:         (mensaje) {
 72:           try {
 73:             _eventos.add(
 74:               Evento.fromJson((jsonDecode(mensaje as String) as Map).cast()),
 75:             );
 76:           } on Object {
 77:             // Un mensaje que no entendemos no debe tumbar la conexión.
 78:           }
 79:         },
 80:         onDone: _programarReintento,
 81:         onError: (_) => _programarReintento(),
 82:         cancelOnError: true,
 83:       );
 84:     } on Object {
 85:       _programarReintento();
 86:     }
 87:   }
 88: 
 89:   void _programarReintento() {
 90:     if (_cerrado) return;
 91:     _canal = null;
 92:     _cambiar(EstadoConexion.sinConexion);
 93:     _reintento?.cancel();
 94:     final segundos = min(10, pow(2, _intentos++).toInt());
 95:     _reintento = Timer(Duration(seconds: segundos), _conectar);
 96:   }
 97: 
 98:   /// Reintenta ya, sin esperar (botón "Reintentar").
 99:   void reconectar() {
100:     if (_actual == EstadoConexion.enLinea) return;
101:     _reintento?.cancel();
102:     _intentos = 0;
103:     _conectar();
104:   }
105: 
106:   void _cambiar(EstadoConexion e) {
107:     if (_actual == e) return;
108:     _actual = e;
109:     _estado.add(e);
110:   }
111: 
112:   Future<void> cerrar() async {
113:     _cerrado = true;
114:     _reintento?.cancel();
115:     await _canal?.sink.close();
116:     await _eventos.close();
117:     await _estado.close();
118:   }
119: }
120: 
121: final tiempoRealProvider = FutureProvider<TiempoReal>((ref) async {
122:   final api = await ref.watch(apiProvider.future);
123:   final tr = TiempoReal(api);
124:   ref.onDispose(tr.cerrar);
125:   return tr;
126: });
127: 
128: final estadoConexionProvider = StreamProvider<EstadoConexion>((ref) async* {
129:   final tr = await ref.watch(tiempoRealProvider.future);
130:   yield tr.estado;
131:   yield* tr.estados;
132: });
133: 
134: final eventosProvider = StreamProvider<Evento>((ref) async* {
135:   final tr = await ref.watch(tiempoRealProvider.future);
136:   yield* tr.eventos;
137: });
````

## File: app/lib/core/widgets/estados.dart
````dart
  1: import 'package:flutter/material.dart';
  2: 
  3: import '../../app/tema/colores.dart';
  4: import '../api/fallo_api.dart';
  5: 
  6: /// Estado vacío con ícono, título, explicación y una acción opcional.
  7: /// Toda pantalla con datos lo usa en lugar de dejar el espacio en blanco.
  8: class EstadoVacio extends StatelessWidget {
  9:   const EstadoVacio({
 10:     super.key,
 11:     required this.icono,
 12:     required this.titulo,
 13:     this.mensaje,
 14:     this.accion,
 15:   });
 16: 
 17:   final IconData icono;
 18:   final String titulo;
 19:   final String? mensaje;
 20:   final Widget? accion;
 21: 
 22:   @override
 23:   Widget build(BuildContext context) {
 24:     final c = context.colores;
 25:     final textos = Theme.of(context).textTheme;
 26:     return Center(
 27:       child: Padding(
 28:         padding: const EdgeInsets.all(32),
 29:         child: ConstrainedBox(
 30:           constraints: const BoxConstraints(maxWidth: 380),
 31:           child: Column(
 32:             mainAxisSize: MainAxisSize.min,
 33:             children: [
 34:               Container(
 35:                 width: 72,
 36:                 height: 72,
 37:                 decoration: BoxDecoration(
 38:                   color: c.superficie3,
 39:                   borderRadius: BorderRadius.circular(20),
 40:                 ),
 41:                 child: Icon(icono, size: 34, color: c.tinta2),
 42:               ),
 43:               const SizedBox(height: 18),
 44:               Text(
 45:                 titulo,
 46:                 style: textos.titleLarge,
 47:                 textAlign: TextAlign.center,
 48:               ),
 49:               if (mensaje != null) ...[
 50:                 const SizedBox(height: 6),
 51:                 Text(
 52:                   mensaje!,
 53:                   style: textos.bodyMedium?.copyWith(color: c.tinta2),
 54:                   textAlign: TextAlign.center,
 55:                 ),
 56:               ],
 57:               if (accion != null) ...[const SizedBox(height: 20), accion!],
 58:             ],
 59:           ),
 60:         ),
 61:       ),
 62:     );
 63:   }
 64: }
 65: 
 66: /// Error con mensaje legible y botón para reintentar.
 67: class EstadoError extends StatelessWidget {
 68:   const EstadoError({super.key, required this.error, this.alReintentar});
 69: 
 70:   final Object error;
 71:   final VoidCallback? alReintentar;
 72: 
 73:   @override
 74:   Widget build(BuildContext context) {
 75:     final sinConexion = error is FalloApi && (error as FalloApi).sinConexion;
 76:     return EstadoVacio(
 77:       icono: sinConexion ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
 78:       titulo: sinConexion ? 'Sin conexión con la caja' : 'Algo salió mal',
 79:       mensaje: mensajeDeError(error),
 80:       accion: alReintentar == null
 81:           ? null
 82:           : OutlinedButton.icon(
 83:               onPressed: alReintentar,
 84:               icon: const Icon(Icons.refresh_rounded),
 85:               label: const Text('Reintentar'),
 86:             ),
 87:     );
 88:   }
 89: }
 90: 
 91: class Cargando extends StatelessWidget {
 92:   const Cargando({super.key, this.mensaje});
 93: 
 94:   final String? mensaje;
 95: 
 96:   @override
 97:   Widget build(BuildContext context) => Center(
 98:     child: Column(
 99:       mainAxisSize: MainAxisSize.min,
100:       children: [
101:         const SizedBox(
102:           width: 32,
103:           height: 32,
104:           child: CircularProgressIndicator(strokeWidth: 3),
105:         ),
106:         if (mensaje != null) ...[
107:           const SizedBox(height: 14),
108:           Text(mensaje!, style: TextStyle(color: context.colores.tinta2)),
109:         ],
110:       ],
111:     ),
112:   );
113: }
114: 
115: /// Diálogo de confirmación compartido (docs/ESTANDARES.md: no se crea uno por pantalla).
116: Future<bool> confirmar(
117:   BuildContext context, {
118:   required String titulo,
119:   required String mensaje,
120:   required String accion,
121:   bool peligrosa = false,
122: }) async {
123:   final c = context.colores;
124:   final r = await showDialog<bool>(
125:     context: context,
126:     builder: (context) => AlertDialog(
127:       title: Text(titulo),
128:       content: Text(mensaje),
129:       actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
130:       actions: [
131:         OutlinedButton(
132:           onPressed: () => Navigator.pop(context, false),
133:           child: const Text('Cancelar'),
134:         ),
135:         FilledButton(
136:           style: peligrosa
137:               ? FilledButton.styleFrom(
138:                   backgroundColor: c.alerta,
139:                   foregroundColor: Colors.white,
140:                 )
141:               : null,
142:           onPressed: () => Navigator.pop(context, true),
143:           child: Text(accion),
144:         ),
145:       ],
146:     ),
147:   );
148:   return r ?? false;
149: }
150: 
151: void avisar(BuildContext context, String mensaje) {
152:   ScaffoldMessenger.of(context)
153:     ..hideCurrentSnackBar()
154:     ..showSnackBar(SnackBar(content: Text(mensaje)));
155: }
````

## File: app/lib/core/widgets/ilustracion_producto.dart
````dart
  1: import 'package:deposito_backend/deposito_backend.dart';
  2: import 'package:flutter/material.dart';
  3: 
  4: import '../../app/tema/colores.dart';
  5: import '../../app/tema/tema.dart';
  6: 
  7: /// Ilustración del producto mientras no tenga foto (Sprint 2): una botella,
  8: /// lata, bolsa o bolsa de hielo según su envase y categoría, sobre el color
  9: /// de su categoría. Se dibuja en código: no pesa ni necesita internet.
 10: class IlustracionProducto extends StatelessWidget {
 11:   const IlustracionProducto({
 12:     super.key,
 13:     required this.producto,
 14:     this.radio = Radios.imagen,
 15:   });
 16: 
 17:   final Producto producto;
 18:   final double radio;
 19: 
 20:   @override
 21:   Widget build(BuildContext context) {
 22:     final c = context.colores;
 23:     return ClipRRect(
 24:       borderRadius: BorderRadius.circular(radio),
 25:       child: ColoredBox(
 26:         color: c.fondoCategoria(producto.categoria),
 27:         child: CustomPaint(
 28:           painter: _Pintor(
 29:             forma: _formaDe(producto),
 30:             acento: _acentoDe(producto),
 31:             oscuro: Theme.of(context).brightness == Brightness.dark,
 32:           ),
 33:           child: const SizedBox.expand(),
 34:         ),
 35:       ),
 36:     );
 37:   }
 38: }
 39: 
 40: enum _Forma { mega, media, cuarto, pet, bolsa, hielo, caja }
 41: 
 42: _Forma _formaDe(Producto p) => switch ((p.envase, p.categoria)) {
 43:   ('mega', _) => _Forma.mega,
 44:   ('media', _) => _Forma.media,
 45:   ('cuarto', _) => _Forma.cuarto,
 46:   (_, 'cerveza') => _Forma.media,
 47:   (_, 'refresco') => _Forma.pet,
 48:   (_, 'botana') => _Forma.bolsa,
 49:   (_, 'hielo') => _Forma.hielo,
 50:   _ => _Forma.caja,
 51: };
 52: 
 53: /// Color de la etiqueta, estable por producto para que cada uno se reconozca.
 54: Color _acentoDe(Producto p) {
 55:   const acentos = [
 56:     Color(0xFFE0B04A),
 57:     Color(0xFF2F5DA8),
 58:     Color(0xFFD9722E),
 59:     Color(0xFFC62828),
 60:     Color(0xFF2E8B57),
 61:     Color(0xFFF2C230),
 62:   ];
 63:   final h = p.codigo.codeUnits.fold<int>(
 64:     7,
 65:     (a, b) => (a * 31 + b) & 0x7fffffff,
 66:   );
 67:   return acentos[h % acentos.length];
 68: }
 69: 
 70: class _Pintor extends CustomPainter {
 71:   _Pintor({required this.forma, required this.acento, required this.oscuro});
 72: 
 73:   final _Forma forma;
 74:   final Color acento;
 75:   final bool oscuro;
 76: 
 77:   static const _vidrio = Color(0xFF7A3E12);
 78:   static const _vidrioClaro = Color(0xFFB7892B);
 79:   static const _tapa = Color(0xFFC9A44C);
 80: 
 81:   @override
 82:   void paint(Canvas canvas, Size s) {
 83:     final sombra = Paint()
 84:       ..color = Colors.black.withValues(alpha: oscuro ? 0.35 : 0.12);
 85:     final base = s.height * 0.88;
 86:     canvas.drawOval(
 87:       Rect.fromCenter(
 88:         center: Offset(s.width / 2, base + 2),
 89:         width: s.shortestSide * 0.42,
 90:         height: 6,
 91:       ),
 92:       sombra,
 93:     );
 94:     switch (forma) {
 95:       case _Forma.mega:
 96:         _botella(canvas, s, alto: 0.80, ancho: 0.30);
 97:       case _Forma.media:
 98:         _botella(canvas, s, alto: 0.66, ancho: 0.26);
 99:       case _Forma.cuarto:
100:         _botella(canvas, s, alto: 0.52, ancho: 0.24);
101:       case _Forma.pet:
102:         _pet(canvas, s);
103:       case _Forma.bolsa:
104:         _bolsa(canvas, s);
105:       case _Forma.hielo:
106:         _hielo(canvas, s);
107:       case _Forma.caja:
108:         _caja(canvas, s);
109:     }
110:   }
111: 
112:   void _botella(
113:     Canvas canvas,
114:     Size s, {
115:     required double alto,
116:     required double ancho,
117:   }) {
118:     final cx = s.width / 2;
119:     final base = s.height * 0.88;
120:     final h = s.height * alto;
121:     final bw = s.shortestSide * ancho;
122:     final nw = bw * 0.38;
123:     final arriba = base - h;
124:     final hombro = arriba + h * 0.42;
125:     final cuello = arriba + h * 0.10;
126: 
127:     final cuerpo = Path()
128:       ..moveTo(cx - nw / 2, cuello)
129:       ..lineTo(cx - nw / 2, hombro - h * 0.10)
130:       ..quadraticBezierTo(
131:         cx - bw / 2,
132:         hombro - h * 0.02,
133:         cx - bw / 2,
134:         hombro + h * 0.10,
135:       )
136:       ..lineTo(cx - bw / 2, base - 6)
137:       ..quadraticBezierTo(cx - bw / 2, base, cx - bw / 2 + 6, base)
138:       ..lineTo(cx + bw / 2 - 6, base)
139:       ..quadraticBezierTo(cx + bw / 2, base, cx + bw / 2, base - 6)
140:       ..lineTo(cx + bw / 2, hombro + h * 0.10)
141:       ..quadraticBezierTo(
142:         cx + bw / 2,
143:         hombro - h * 0.02,
144:         cx + nw / 2,
145:         hombro - h * 0.10,
146:       )
147:       ..lineTo(cx + nw / 2, cuello)
148:       ..close();
149:     canvas.drawPath(
150:       cuerpo,
151:       Paint()
152:         ..shader = const LinearGradient(
153:           colors: [_vidrioClaro, _vidrio, Color(0xFF4A2408)],
154:           stops: [0, 0.45, 1],
155:         ).createShader(Rect.fromLTRB(cx - bw / 2, arriba, cx + bw / 2, base)),
156:     );
157: 
158:     // Tapa corona.
159:     canvas.drawRRect(
160:       RRect.fromRectAndRadius(
161:         Rect.fromLTRB(cx - nw / 2 - 1.5, arriba, cx + nw / 2 + 1.5, cuello + 1),
162:         const Radius.circular(2),
163:       ),
164:       Paint()..color = _tapa,
165:     );
166: 
167:     // Etiqueta.
168:     final etiqueta = Rect.fromLTRB(
169:       cx - bw / 2,
170:       hombro + h * 0.16,
171:       cx + bw / 2,
172:       hombro + h * 0.44,
173:     );
174:     canvas.drawRect(etiqueta, Paint()..color = acento);
175:     canvas.drawRect(
176:       Rect.fromLTRB(
177:         etiqueta.left,
178:         etiqueta.center.dy - 2,
179:         etiqueta.right,
180:         etiqueta.center.dy + 2,
181:       ),
182:       Paint()..color = Colors.white.withValues(alpha: 0.55),
183:     );
184:     // Cuello con etiqueta pequeña.
185:     canvas.drawRect(
186:       Rect.fromLTRB(
187:         cx - nw / 2,
188:         cuello + h * 0.10,
189:         cx + nw / 2,
190:         cuello + h * 0.17,
191:       ),
192:       Paint()..color = acento,
193:     );
194:     // Brillo del vidrio.
195:     canvas.drawRRect(
196:       RRect.fromRectAndRadius(
197:         Rect.fromLTWH(
198:           cx - bw / 2 + bw * 0.16,
199:           hombro + h * 0.06,
200:           bw * 0.08,
201:           h * 0.44,
202:         ),
203:         const Radius.circular(4),
204:       ),
205:       Paint()..color = Colors.white.withValues(alpha: 0.22),
206:     );
207:   }
208: 
209:   void _pet(Canvas canvas, Size s) {
210:     final cx = s.width / 2;
211:     final base = s.height * 0.88;
212:     final h = s.height * 0.72;
213:     final bw = s.shortestSide * 0.28;
214:     final arriba = base - h;
215:     final cuerpo = Path()
216:       ..moveTo(cx - bw * 0.2, arriba + h * 0.08)
217:       ..quadraticBezierTo(
218:         cx - bw / 2,
219:         arriba + h * 0.18,
220:         cx - bw / 2,
221:         arriba + h * 0.32,
222:       )
223:       ..lineTo(cx - bw / 2, base - 8)
224:       ..quadraticBezierTo(cx - bw / 2, base, cx - bw / 2 + 8, base)
225:       ..lineTo(cx + bw / 2 - 8, base)
226:       ..quadraticBezierTo(cx + bw / 2, base, cx + bw / 2, base - 8)
227:       ..lineTo(cx + bw / 2, arriba + h * 0.32)
228:       ..quadraticBezierTo(
229:         cx + bw / 2,
230:         arriba + h * 0.18,
231:         cx + bw * 0.2,
232:         arriba + h * 0.08,
233:       )
234:       ..close();
235:     canvas.drawPath(cuerpo, Paint()..color = const Color(0xFF3A1C10));
236:     canvas.drawRRect(
237:       RRect.fromRectAndRadius(
238:         Rect.fromLTRB(
239:           cx - bw * 0.22,
240:           arriba,
241:           cx + bw * 0.22,
242:           arriba + h * 0.09,
243:         ),
244:         const Radius.circular(3),
245:       ),
246:       Paint()..color = acento,
247:     );
248:     canvas.drawRect(
249:       Rect.fromLTRB(
250:         cx - bw / 2,
251:         arriba + h * 0.42,
252:         cx + bw / 2,
253:         arriba + h * 0.66,
254:       ),
255:       Paint()..color = acento,
256:     );
257:     canvas.drawRect(
258:       Rect.fromLTRB(
259:         cx - bw / 2,
260:         arriba + h * 0.52,
261:         cx + bw / 2,
262:         arriba + h * 0.56,
263:       ),
264:       Paint()..color = Colors.white.withValues(alpha: 0.7),
265:     );
266:   }
267: 
268:   void _bolsa(Canvas canvas, Size s) {
269:     final cx = s.width / 2;
270:     final base = s.height * 0.88;
271:     final w = s.shortestSide * 0.48;
272:     final h = s.height * 0.66;
273:     final r = Rect.fromLTRB(cx - w / 2, base - h, cx + w / 2, base);
274:     final bolsa = Path()..moveTo(r.left, r.top);
275:     const dientes = 7;
276:     for (var i = 0; i < dientes; i++) {
277:       final x0 = r.left + r.width * i / dientes;
278:       bolsa
279:         ..lineTo(x0 + r.width / dientes / 2, r.top + 5)
280:         ..lineTo(x0 + r.width / dientes, r.top);
281:     }
282:     bolsa
283:       ..quadraticBezierTo(r.right + 4, r.center.dy, r.right, r.bottom)
284:       ..lineTo(r.left, r.bottom)
285:       ..quadraticBezierTo(r.left - 4, r.center.dy, r.left, r.top)
286:       ..close();
287:     canvas.drawPath(bolsa, Paint()..color = acento);
288:     canvas.drawCircle(
289:       r.center.translate(0, h * 0.06),
290:       w * 0.22,
291:       Paint()..color = Colors.white.withValues(alpha: 0.85),
292:     );
293:     canvas.drawCircle(
294:       r.center.translate(0, h * 0.06),
295:       w * 0.14,
296:       Paint()..color = const Color(0xFFE3B23C),
297:     );
298:     canvas.drawRect(
299:       Rect.fromLTRB(
300:         r.left + 6,
301:         r.top + h * 0.14,
302:         r.right - 6,
303:         r.top + h * 0.22,
304:       ),
305:       Paint()..color = Colors.white.withValues(alpha: 0.6),
306:     );
307:   }
308: 
309:   void _hielo(Canvas canvas, Size s) {
310:     final cx = s.width / 2;
311:     final base = s.height * 0.88;
312:     final w = s.shortestSide * 0.52;
313:     final h = s.height * 0.62;
314:     final r = RRect.fromRectAndCorners(
315:       Rect.fromLTRB(cx - w / 2, base - h, cx + w / 2, base),
316:       topLeft: const Radius.circular(6),
317:       topRight: const Radius.circular(6),
318:       bottomLeft: const Radius.circular(14),
319:       bottomRight: const Radius.circular(14),
320:     );
321:     canvas.drawRRect(
322:       r,
323:       Paint()..color = const Color(0xFF6FB3D2).withValues(alpha: 0.55),
324:     );
325:     canvas.drawRRect(
326:       r,
327:       Paint()
328:         ..style = PaintingStyle.stroke
329:         ..strokeWidth = 2
330:         ..color = const Color(0xFF3E86A8),
331:     );
332:     final cubo = Paint()..color = Colors.white.withValues(alpha: 0.75);
333:     final lado = w * 0.2;
334:     for (final (dx, dy) in [
335:       (-0.22, 0.30),
336:       (0.08, 0.36),
337:       (-0.08, 0.6),
338:       (0.2, 0.62),
339:       (-0.26, 0.74),
340:     ]) {
341:       canvas.drawRRect(
342:         RRect.fromRectAndRadius(
343:           Rect.fromLTWH(cx + w * dx, r.top + h * dy, lado, lado),
344:           const Radius.circular(3),
345:         ),
346:         cubo,
347:       );
348:     }
349:     canvas.drawRect(
350:       Rect.fromLTRB(r.left, r.top + h * 0.08, r.right, r.top + h * 0.16),
351:       Paint()..color = const Color(0xFF3E86A8),
352:     );
353:   }
354: 
355:   void _caja(Canvas canvas, Size s) {
356:     final cx = s.width / 2;
357:     final base = s.height * 0.88;
358:     final w = s.shortestSide * 0.5;
359:     final h = s.height * 0.5;
360:     final r = Rect.fromLTRB(cx - w / 2, base - h, cx + w / 2, base);
361:     canvas.drawRRect(
362:       RRect.fromRectAndRadius(r, const Radius.circular(6)),
363:       Paint()..color = const Color(0xFFB98B55),
364:     );
365:     canvas.drawRect(
366:       Rect.fromLTRB(cx - 5, r.top, cx + 5, r.bottom),
367:       Paint()..color = const Color(0xFFE3C08F),
368:     );
369:     canvas.drawRect(
370:       Rect.fromLTRB(r.left, r.top + h * 0.14, r.right, r.top + h * 0.18),
371:       Paint()..color = const Color(0xFF8C5A2B),
372:     );
373:   }
374: 
375:   @override
376:   bool shouldRepaint(_Pintor old) =>
377:       old.forma != forma || old.acento != acento || old.oscuro != oscuro;
378: }
````

## File: app/lib/core/widgets/indicador_conexion.dart
````dart
 1: import 'package:flutter/material.dart';
 2: import 'package:flutter_riverpod/flutter_riverpod.dart';
 3: 
 4: import '../tiempo_real/tiempo_real.dart';
 5: 
 6: /// Punto verde "en línea" / ámbar "conectando" / gris "sin conexión".
 7: ///
 8: /// Se ve siempre en la terminal y en la caja: si la Wi-Fi falla, el
 9: /// personal lo nota antes de cobrar (plan, riesgo "Wi-Fi inestable").
10: class IndicadorConexion extends ConsumerWidget {
11:   const IndicadorConexion({
12:     super.key,
13:     this.colorTexto,
14:     this.etiquetaEnLinea = 'En línea',
15:   });
16: 
17:   final Color? colorTexto;
18:   final String etiquetaEnLinea;
19: 
20:   @override
21:   Widget build(BuildContext context, WidgetRef ref) {
22:     final estado =
23:         ref.watch(estadoConexionProvider).value ?? EstadoConexion.conectando;
24:     final (color, texto) = switch (estado) {
25:       EstadoConexion.enLinea => (const Color(0xFF46C281), etiquetaEnLinea),
26:       EstadoConexion.conectando => (const Color(0xFFF4B324), 'Conectando…'),
27:       EstadoConexion.sinConexion => (
28:         const Color(0xFF9A8B7A),
29:         'Sin conexión, reintentando',
30:       ),
31:     };
32:     return Row(
33:       mainAxisSize: MainAxisSize.min,
34:       children: [
35:         AnimatedContainer(
36:           duration: const Duration(milliseconds: 250),
37:           width: 9,
38:           height: 9,
39:           decoration: BoxDecoration(color: color, shape: BoxShape.circle),
40:         ),
41:         const SizedBox(width: 7),
42:         Flexible(
43:           child: Text(
44:             texto,
45:             overflow: TextOverflow.ellipsis,
46:             style: TextStyle(
47:               fontSize: 14,
48:               fontWeight: FontWeight.w500,
49:               color: colorTexto,
50:             ),
51:           ),
52:         ),
53:       ],
54:     );
55:   }
56: }
````

## File: app/lib/core/widgets/marca.dart
````dart
 1: import 'package:flutter/material.dart';
 2: 
 3: import '../../app/tema/colores.dart';
 4: 
 5: /// Logo de Anaquel: botella sobre un cuadro ámbar.
 6: class LogoAnaquel extends StatelessWidget {
 7:   const LogoAnaquel({super.key, this.tamano = 42});
 8: 
 9:   final double tamano;
10: 
11:   @override
12:   Widget build(BuildContext context) {
13:     final c = context.colores;
14:     return Container(
15:       width: tamano,
16:       height: tamano,
17:       decoration: BoxDecoration(
18:         color: c.lager,
19:         borderRadius: BorderRadius.circular(tamano * 0.29),
20:       ),
21:       child: CustomPaint(painter: _Botella(c.lagerTinta)),
22:     );
23:   }
24: }
25: 
26: class _Botella extends CustomPainter {
27:   _Botella(this.color);
28: 
29:   final Color color;
30: 
31:   @override
32:   void paint(Canvas canvas, Size s) {
33:     final w = s.width;
34:     final p = Paint()..color = color;
35:     final cuerpo = Path()
36:       ..moveTo(w * 0.44, w * 0.18)
37:       ..lineTo(w * 0.56, w * 0.18)
38:       ..lineTo(w * 0.56, w * 0.36)
39:       ..quadraticBezierTo(w * 0.66, w * 0.42, w * 0.66, w * 0.52)
40:       ..lineTo(w * 0.66, w * 0.80)
41:       ..quadraticBezierTo(w * 0.66, w * 0.84, w * 0.62, w * 0.84)
42:       ..lineTo(w * 0.38, w * 0.84)
43:       ..quadraticBezierTo(w * 0.34, w * 0.84, w * 0.34, w * 0.80)
44:       ..lineTo(w * 0.34, w * 0.52)
45:       ..quadraticBezierTo(w * 0.34, w * 0.42, w * 0.44, w * 0.36)
46:       ..close();
47:     canvas.drawPath(cuerpo, p);
48:     canvas.drawRect(
49:       Rect.fromLTRB(w * 0.34, w * 0.56, w * 0.66, w * 0.68),
50:       Paint()..color = const Color(0xFFF0A500),
51:     );
52:   }
53: 
54:   @override
55:   bool shouldRepaint(_Botella old) => old.color != color;
56: }
57: 
58: /// Píldora gris con texto secundario (fecha, IP, versión).
59: class Pildora extends StatelessWidget {
60:   const Pildora({super.key, required this.texto, this.icono});
61: 
62:   final String texto;
63:   final IconData? icono;
64: 
65:   @override
66:   Widget build(BuildContext context) {
67:     final c = context.colores;
68:     return Container(
69:       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
70:       decoration: BoxDecoration(
71:         color: c.superficie2,
72:         border: Border.all(color: c.linea),
73:         borderRadius: BorderRadius.circular(999),
74:       ),
75:       child: Row(
76:         mainAxisSize: MainAxisSize.min,
77:         children: [
78:           if (icono != null) ...[
79:             Icon(icono, size: 16, color: c.tinta2),
80:             const SizedBox(width: 6),
81:           ],
82:           Text(
83:             texto,
84:             style: TextStyle(
85:               fontSize: 14,
86:               fontWeight: FontWeight.w500,
87:               color: c.tinta2,
88:             ),
89:           ),
90:         ],
91:       ),
92:     );
93:   }
94: }
````

## File: app/lib/core/widgets/tarjeta_producto.dart
````dart
  1: import 'package:deposito_backend/deposito_backend.dart';
  2: import 'package:flutter/material.dart';
  3: 
  4: import '../../app/tema/colores.dart';
  5: import '../../app/tema/tema.dart';
  6: import '../formato/formato.dart';
  7: import 'ilustracion_producto.dart';
  8: 
  9: /// Mosaico de producto para cuadrículas (catálogo, vender, terminal).
 10: class TarjetaProducto extends StatelessWidget {
 11:   const TarjetaProducto({super.key, required this.producto, this.alTocar});
 12: 
 13:   final Producto producto;
 14:   final VoidCallback? alTocar;
 15: 
 16:   @override
 17:   Widget build(BuildContext context) {
 18:     final c = context.colores;
 19:     final textos = Theme.of(context).textTheme;
 20:     final p = producto;
 21:     return DecoratedBox(
 22:       decoration: BoxDecoration(
 23:         color: c.superficie,
 24:         borderRadius: BorderRadius.circular(14),
 25:         border: Border.all(color: c.linea),
 26:         boxShadow: c.sombra,
 27:       ),
 28:       child: Material(
 29:         type: MaterialType.transparency,
 30:         child: InkWell(
 31:           borderRadius: BorderRadius.circular(14),
 32:           onTap: alTocar,
 33:           child: Padding(
 34:             padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
 35:             child: Column(
 36:               crossAxisAlignment: CrossAxisAlignment.start,
 37:               children: [
 38:                 Expanded(
 39:                   child: Stack(
 40:                     children: [
 41:                       Positioned.fill(child: IlustracionProducto(producto: p)),
 42:                       Positioned(
 43:                         top: 8,
 44:                         right: 8,
 45:                         child: InsigniaExistencia(producto: p),
 46:                       ),
 47:                     ],
 48:                   ),
 49:                 ),
 50:                 const SizedBox(height: 10),
 51:                 Text(
 52:                   p.nombre,
 53:                   style: textos.titleMedium?.copyWith(height: 1.15),
 54:                   maxLines: 1,
 55:                   overflow: TextOverflow.ellipsis,
 56:                 ),
 57:                 Text(
 58:                   p.presentacion ?? capitalizar(p.categoria),
 59:                   style: textos.bodySmall,
 60:                   maxLines: 1,
 61:                   overflow: TextOverflow.ellipsis,
 62:                 ),
 63:                 const SizedBox(height: 6),
 64:                 Row(
 65:                   crossAxisAlignment: CrossAxisAlignment.baseline,
 66:                   textBaseline: TextBaseline.alphabetic,
 67:                   children: [
 68:                     Text(dinero(p.precio), style: textos.headlineSmall),
 69:                     const SizedBox(width: 6),
 70:                     Expanded(
 71:                       child: Text(
 72:                         p.precioCaja == null
 73:                             ? 'pieza'
 74:                             : 'caja ${dinero(p.precioCaja!)}',
 75:                         style: textos.bodySmall,
 76:                         maxLines: 1,
 77:                         overflow: TextOverflow.ellipsis,
 78:                         textAlign: TextAlign.right,
 79:                       ),
 80:                     ),
 81:                   ],
 82:                 ),
 83:               ],
 84:             ),
 85:           ),
 86:         ),
 87:       ),
 88:     );
 89:   }
 90: }
 91: 
 92: /// Píldora con la existencia; en rojo si está bajo el mínimo.
 93: class InsigniaExistencia extends StatelessWidget {
 94:   const InsigniaExistencia({super.key, required this.producto});
 95: 
 96:   final Producto producto;
 97: 
 98:   @override
 99:   Widget build(BuildContext context) {
100:     final c = context.colores;
101:     final bajo = producto.bajoMinimo;
102:     return Container(
103:       padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
104:       decoration: BoxDecoration(
105:         color: bajo ? c.alerta : c.superficie.withValues(alpha: 0.92),
106:         borderRadius: BorderRadius.circular(999),
107:       ),
108:       child: Text(
109:         '${producto.existenciaPiezas} pz',
110:         style: TextStyle(
111:           fontFamily: fuenteTexto,
112:           fontSize: 13,
113:           fontWeight: FontWeight.w700,
114:           color: bajo ? Colors.white : c.tinta,
115:         ),
116:       ),
117:     );
118:   }
119: }
````

## File: app/lib/features/ajustes/ajustes.dart
````dart
  1: import 'package:deposito_backend/deposito_backend.dart';
  2: import 'package:flutter/material.dart';
  3: import 'package:flutter_riverpod/flutter_riverpod.dart';
  4: 
  5: import '../../app/tema/colores.dart';
  6: import '../../core/config/configuracion.dart';
  7: import '../../core/servidor/servidor_embebido.dart';
  8: import '../../core/widgets/estados.dart';
  9: 
 10: /// Ajustes de este dispositivo. Los del negocio (nombre, días de alerta,
 11: /// respaldo, PIN) llegan en el Sprint 4.
 12: class PantallaAjustes extends ConsumerWidget {
 13:   const PantallaAjustes({super.key});
 14: 
 15:   @override
 16:   Widget build(BuildContext context, WidgetRef ref) {
 17:     final config = ref.watch(configuracionProvider);
 18:     final notificador = ref.read(configuracionProvider.notifier);
 19:     final c = context.colores;
 20:     final esCaja = config.modo == ModoDispositivo.caja;
 21: 
 22:     return ListView(
 23:       padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
 24:       children: [
 25:         Center(
 26:           child: ConstrainedBox(
 27:             constraints: const BoxConstraints(maxWidth: 720),
 28:             child: Column(
 29:               crossAxisAlignment: CrossAxisAlignment.stretch,
 30:               spacing: 18,
 31:               children: [
 32:                 _Grupo(
 33:                   titulo: 'Apariencia',
 34:                   children: [
 35:                     SegmentedButton<ThemeMode>(
 36:                       showSelectedIcon: false,
 37:                       segments: const [
 38:                         ButtonSegment(
 39:                           value: ThemeMode.system,
 40:                           icon: Icon(Icons.brightness_auto_outlined),
 41:                           label: Text('Automático'),
 42:                         ),
 43:                         ButtonSegment(
 44:                           value: ThemeMode.light,
 45:                           icon: Icon(Icons.light_mode_outlined),
 46:                           label: Text('Claro'),
 47:                         ),
 48:                         ButtonSegment(
 49:                           value: ThemeMode.dark,
 50:                           icon: Icon(Icons.dark_mode_outlined),
 51:                           label: Text('Oscuro'),
 52:                         ),
 53:                       ],
 54:                       selected: {config.tema},
 55:                       onSelectionChanged: (s) =>
 56:                           notificador.cambiarTema(s.first),
 57:                       style: SegmentedButton.styleFrom(
 58:                         selectedBackgroundColor: c.seleccion,
 59:                         selectedForegroundColor: c.seleccionTinta,
 60:                         side: BorderSide(color: c.linea),
 61:                       ),
 62:                     ),
 63:                   ],
 64:                 ),
 65:                 _Grupo(
 66:                   titulo: 'Este dispositivo',
 67:                   children: [
 68:                     _Dato('Modo', esCaja ? 'Caja (servidor)' : 'Terminal'),
 69:                     if (esCaja) ...[
 70:                       _Dato(
 71:                         'Dirección en la Wi-Fi',
 72:                         '${ref.watch(direccionLocalProvider).value ?? 'sin Wi-Fi'}:$puertoServidor',
 73:                       ),
 74:                       _Dato('Versión del servidor', versionServidor),
 75:                     ] else if (config.conexion case final cx?) ...[
 76:                       _Dato('Nombre', cx.nombre),
 77:                       _Dato('Caja', '${cx.host}:${cx.puerto}'),
 78:                     ],
 79:                     const SizedBox(height: 8),
 80:                     Wrap(
 81:                       spacing: 10,
 82:                       runSpacing: 10,
 83:                       children: [
 84:                         if (!esCaja)
 85:                           OutlinedButton.icon(
 86:                             onPressed: () async {
 87:                               final ok = await confirmar(
 88:                                 context,
 89:                                 titulo: '¿Desvincular de la caja?',
 90:                                 mensaje: 'Para volver a usar esta terminal hay que escanear un código nuevo en la caja.',
 91:                                 accion: 'Desvincular',
 92:                                 peligrosa: true,
 93:                               );
 94:                               if (ok) await notificador.olvidarConexion();
 95:                             },
 96:                             icon: const Icon(Icons.link_off_rounded),
 97:                             label: const Text('Desvincular de la caja'),
 98:                           ),
 99:                         OutlinedButton.icon(
100:                           onPressed: () async {
101:                             final ok = await confirmar(
102:                               context,
103:                               titulo: 'Cambiar el modo',
104:                               mensaje: esCaja
105:                                   ? 'La caja dejará de atender a las terminales. Los datos se conservan en este iPad.'
106:                                   : 'Esta terminal se desvinculará de la caja.',
107:                               accion: 'Cambiar modo',
108:                               peligrosa: esCaja,
109:                             );
110:                             if (!ok) return;
111:                             if (!esCaja) await notificador.olvidarConexion();
112:                             await notificador.elegirModo(null);
113:                           },
114:                           icon: const Icon(Icons.swap_horiz_rounded),
115:                           label: const Text('Cambiar modo'),
116:                         ),
117:                       ],
118:                     ),
119:                   ],
120:                 ),
121:                 _Grupo(
122:                   titulo: 'Próximamente',
123:                   children: [
124:                     Text(
125:                       'Nombre del negocio, días de alerta de caducidad, PIN del dueño, respaldo y restauración (Sprint 4).',
126:                       style: TextStyle(color: c.tinta2),
127:                     ),
128:                   ],
129:                 ),
130:               ],
131:             ),
132:           ),
133:         ),
134:       ],
135:     );
136:   }
137: }
138: 
139: class _Grupo extends StatelessWidget {
140:   const _Grupo({required this.titulo, required this.children});
141: 
142:   final String titulo;
143:   final List<Widget> children;
144: 
145:   @override
146:   Widget build(BuildContext context) {
147:     final c = context.colores;
148:     return Container(
149:       padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
150:       decoration: BoxDecoration(
151:         color: c.superficie,
152:         borderRadius: BorderRadius.circular(16),
153:         border: Border.all(color: c.linea),
154:         boxShadow: c.sombra,
155:       ),
156:       child: Column(
157:         crossAxisAlignment: CrossAxisAlignment.stretch,
158:         spacing: 10,
159:         children: [
160:           Text(titulo, style: Theme.of(context).textTheme.titleLarge),
161:           ...children,
162:         ],
163:       ),
164:     );
165:   }
166: }
167: 
168: class _Dato extends StatelessWidget {
169:   const _Dato(this.etiqueta, this.valor);
170: 
171:   final String etiqueta;
172:   final String valor;
173: 
174:   @override
175:   Widget build(BuildContext context) => Row(
176:     children: [
177:       Expanded(
178:         child: Text(etiqueta, style: TextStyle(color: context.colores.tinta2)),
179:       ),
180:       Flexible(
181:         child: Text(
182:           valor,
183:           style: const TextStyle(fontWeight: FontWeight.w600),
184:           textAlign: TextAlign.right,
185:         ),
186:       ),
187:     ],
188:   );
189: }
````

## File: app/lib/features/caja/estado/terminales.dart
````dart
 1: import 'dart:async';
 2: 
 3: import 'package:deposito_backend/deposito_backend.dart';
 4: import 'package:flutter_riverpod/flutter_riverpod.dart';
 5: 
 6: import '../../../core/api/proveedores.dart';
 7: 
 8: /// Terminales vinculadas. El servidor no avisa por WebSocket cuando una se
 9: /// conecta, así que se vuelve a pedir cada 10 s mientras alguien la vea.
10: final terminalesProvider = FutureProvider.autoDispose<List<Terminal>>((
11:   ref,
12: ) async {
13:   final api = await ref.watch(apiProvider.future);
14:   final reintento = Timer(const Duration(seconds: 10), ref.invalidateSelf);
15:   ref.onDispose(reintento.cancel);
16:   return api.listarTerminales();
17: }, retry: (_, _) => null);
````

## File: app/lib/features/caja/pantallas/conectar_terminal.dart
````dart
  1: import 'dart:async';
  2: import 'dart:convert';
  3: 
  4: import 'package:deposito_backend/deposito_backend.dart';
  5: import 'package:flutter/material.dart';
  6: import 'package:flutter_riverpod/flutter_riverpod.dart';
  7: import 'package:qr_flutter/qr_flutter.dart';
  8: 
  9: import '../../../app/tema/colores.dart';
 10: import '../../../core/api/fallo_api.dart';
 11: import '../../../core/api/proveedores.dart';
 12: import '../../../core/servidor/servidor_embebido.dart';
 13: import '../../../core/widgets/estados.dart';
 14: import '../estado/terminales.dart';
 15: 
 16: Future<void> mostrarConectarTerminal(BuildContext context) => showDialog<void>(
 17:   context: context,
 18:   builder: (_) => const ConectarTerminal(),
 19: );
 20: 
 21: /// QR de emparejamiento (docs/API.md, Terminales): IP, puerto y un código de
 22: /// 6 dígitos que vence en 10 minutos y sirve para una sola terminal.
 23: class ConectarTerminal extends ConsumerStatefulWidget {
 24:   const ConectarTerminal({super.key});
 25: 
 26:   @override
 27:   ConsumerState<ConectarTerminal> createState() => _ConectarTerminalState();
 28: }
 29: 
 30: class _ConectarTerminalState extends ConsumerState<ConectarTerminal> {
 31:   CodigoEmparejamiento? _codigo;
 32:   Object? _error;
 33:   Timer? _reloj;
 34:   Timer? _sondeo;
 35:   var _restante = Duration.zero;
 36:   var _terminalesAlAbrir = -1;
 37: 
 38:   @override
 39:   void initState() {
 40:     super.initState();
 41:     _generar();
 42:     // Mientras el diálogo está abierto se revisa seguido si ya se vinculó una.
 43:     _sondeo = Timer.periodic(
 44:       const Duration(seconds: 2),
 45:       (_) => ref.invalidate(terminalesProvider),
 46:     );
 47:   }
 48: 
 49:   @override
 50:   void dispose() {
 51:     _reloj?.cancel();
 52:     _sondeo?.cancel();
 53:     super.dispose();
 54:   }
 55: 
 56:   Future<void> _generar() async {
 57:     setState(() {
 58:       _codigo = null;
 59:       _error = null;
 60:     });
 61:     try {
 62:       final api = await ref.read(apiProvider.future);
 63:       final codigo = await api.crearCodigoEmparejamiento();
 64:       if (!mounted) return;
 65:       setState(() => _codigo = codigo);
 66:       _reloj?.cancel();
 67:       _actualizarRestante();
 68:       _reloj = Timer.periodic(
 69:         const Duration(seconds: 1),
 70:         (_) => _actualizarRestante(),
 71:       );
 72:     } on Object catch (e) {
 73:       if (mounted) setState(() => _error = e);
 74:     }
 75:   }
 76: 
 77:   void _actualizarRestante() {
 78:     final codigo = _codigo;
 79:     if (codigo == null) return;
 80:     final r = DateTime.parse(codigo.expira).difference(DateTime.now());
 81:     setState(() => _restante = r.isNegative ? Duration.zero : r);
 82:   }
 83: 
 84:   @override
 85:   Widget build(BuildContext context) {
 86:     final c = context.colores;
 87:     final textos = Theme.of(context).textTheme;
 88:     final ip = ref.watch(direccionLocalProvider).value;
 89:     final terminales = ref.watch(terminalesProvider);
 90: 
 91:     // Si aparece una terminal nueva mientras está abierto, el código ya se usó.
 92:     final total = terminales.value?.length;
 93:     if (total != null) {
 94:       if (_terminalesAlAbrir < 0) {
 95:         _terminalesAlAbrir = total;
 96:       } else if (total > _terminalesAlAbrir) {
 97:         _terminalesAlAbrir = total;
 98:         WidgetsBinding.instance.addPostFrameCallback((_) {
 99:           if (!mounted) return;
100:           avisar(
101:             context,
102:             '${terminales.value!.last.nombre} se conectó a la caja',
103:           );
104:           _generar();
105:         });
106:       }
107:     }
108: 
109:     final vencido = _codigo != null && _restante == Duration.zero;
110:     final qr = _codigo == null || ip == null
111:         ? null
112:         : jsonEncode({
113:             'v': 1,
114:             'host': ip,
115:             'puerto': puertoServidor,
116:             'codigo': _codigo!.codigo,
117:           });
118: 
119:     return Dialog(
120:       insetPadding: const EdgeInsets.all(24),
121:       child: ConstrainedBox(
122:         constraints: const BoxConstraints(maxWidth: 760),
123:         child: SingleChildScrollView(
124:           padding: const EdgeInsets.all(28),
125:           child: Column(
126:             mainAxisSize: MainAxisSize.min,
127:             crossAxisAlignment: CrossAxisAlignment.stretch,
128:             children: [
129:               Row(
130:                 children: [
131:                   Expanded(
132:                     child: Text(
133:                       'Conectar una terminal',
134:                       style: textos.headlineMedium,
135:                     ),
136:                   ),
137:                   IconButton(
138:                     onPressed: () => Navigator.pop(context),
139:                     icon: const Icon(Icons.close_rounded),
140:                     tooltip: 'Cerrar',
141:                   ),
142:                 ],
143:               ),
144:               const SizedBox(height: 4),
145:               Text(
146:                 'En el teléfono abre Anaquel, elige Terminal y escanea este código. Los dos deben estar en la misma Wi-Fi.',
147:                 style: textos.bodyMedium?.copyWith(color: c.tinta2),
148:               ),
149:               const SizedBox(height: 22),
150:               Wrap(
151:                 spacing: 28,
152:                 runSpacing: 20,
153:                 crossAxisAlignment: WrapCrossAlignment.center,
154:                 children: [
155:                   Container(
156:                     width: 240,
157:                     height: 240,
158:                     padding: const EdgeInsets.all(14),
159:                     decoration: BoxDecoration(
160:                       color: Colors.white,
161:                       borderRadius: BorderRadius.circular(18),
162:                       border: Border.all(color: c.linea),
163:                     ),
164:                     child: switch ((qr, _error)) {
165:                       (_, final Object e) => Center(
166:                         child: Text(
167:                           mensajeDeError(e),
168:                           textAlign: TextAlign.center,
169:                         ),
170:                       ),
171:                       (null, _) when ip == null && _codigo != null =>
172:                         const Center(
173:                           child: Text(
174:                             'Conecta el iPad a la Wi-Fi del local',
175:                             textAlign: TextAlign.center,
176:                           ),
177:                         ),
178:                       (null, _) => const Center(
179:                         child: CircularProgressIndicator(),
180:                       ),
181:                       (final String datos, _) => Opacity(
182:                         opacity: vencido ? 0.15 : 1,
183:                         child: QrImageView(
184:                           data: datos,
185:                           padding: EdgeInsets.zero,
186:                           eyeStyle: const QrEyeStyle(
187:                             eyeShape: QrEyeShape.square,
188:                             color: Color(0xFF1B2226),
189:                           ),
190:                           dataModuleStyle: const QrDataModuleStyle(
191:                             dataModuleShape: QrDataModuleShape.square,
192:                             color: Color(0xFF1B2226),
193:                           ),
194:                         ),
195:                       ),
196:                     },
197:                   ),
198:                   ConstrainedBox(
199:                     constraints: const BoxConstraints(maxWidth: 400),
200:                     child: Column(
201:                       crossAxisAlignment: CrossAxisAlignment.start,
202:                       children: [
203:                         Text('O escríbelo a mano', style: textos.bodySmall),
204:                         const SizedBox(height: 6),
205:                         Text(
206:                           _codigo == null
207:                               ? '··· ···'
208:                               : '${_codigo!.codigo.substring(0, 3)} ${_codigo!.codigo.substring(3)}',
209:                           style: textos.displayLarge?.copyWith(
210:                             letterSpacing: 4,
211:                             color: vencido ? c.tinta2 : c.tinta,
212:                           ),
213:                         ),
214:                         const SizedBox(height: 4),
215:                         Text(
216:                           ip == null
217:                               ? 'Sin Wi-Fi'
218:                               : 'Caja: $ip · puerto $puertoServidor',
219:                           style: textos.titleSmall?.copyWith(color: c.tinta2),
220:                         ),
221:                         const SizedBox(height: 16),
222:                         Row(
223:                           children: [
224:                             Icon(
225:                               vencido
226:                                   ? Icons.timer_off_outlined
227:                                   : Icons.timer_outlined,
228:                               size: 18,
229:                               color: vencido ? c.alerta : c.tinta2,
230:                             ),
231:                             const SizedBox(width: 6),
232:                             Text(
233:                               vencido
234:                                   ? 'El código venció'
235:                                   : 'Vence en ${_restante.inMinutes}:${(_restante.inSeconds % 60).toString().padLeft(2, '0')}',
236:                               style: TextStyle(
237:                                 color: vencido ? c.alerta : c.tinta2,
238:                                 fontWeight: FontWeight.w500,
239:                               ),
240:                             ),
241:                             const SizedBox(width: 12),
242:                             TextButton.icon(
243:                               onPressed: _generar,
244:                               icon: const Icon(Icons.refresh_rounded, size: 20),
245:                               label: const Text('Generar otro'),
246:                             ),
247:                           ],
248:                         ),
249:                       ],
250:                     ),
251:                   ),
252:                 ],
253:               ),
254:               const SizedBox(height: 26),
255:               Text('Terminales vinculadas', style: textos.titleLarge),
256:               const SizedBox(height: 8),
257:               switch (terminales) {
258:                 AsyncData(:final value) when value.isEmpty => Padding(
259:                   padding: const EdgeInsets.symmetric(vertical: 12),
260:                   child: Text(
261:                     'Todavía no hay terminales.',
262:                     style: TextStyle(color: c.tinta2),
263:                   ),
264:                 ),
265:                 AsyncData(:final value) => Column(
266:                   children: [for (final t in value) _FilaTerminal(terminal: t)],
267:                 ),
268:                 AsyncError(:final error) => Text(
269:                   mensajeDeError(error),
270:                   style: TextStyle(color: c.alerta),
271:                 ),
272:                 _ => const Padding(
273:                   padding: EdgeInsets.all(12),
274:                   child: LinearProgressIndicator(),
275:                 ),
276:               },
277:             ],
278:           ),
279:         ),
280:       ),
281:     );
282:   }
283: }
284: 
285: class _FilaTerminal extends ConsumerWidget {
286:   const _FilaTerminal({required this.terminal});
287: 
288:   final Terminal terminal;
289: 
290:   @override
291:   Widget build(BuildContext context, WidgetRef ref) {
292:     final c = context.colores;
293:     return Container(
294:       padding: const EdgeInsets.symmetric(vertical: 10),
295:       decoration: BoxDecoration(
296:         border: Border(top: BorderSide(color: c.linea)),
297:       ),
298:       child: Row(
299:         children: [
300:           Container(
301:             width: 42,
302:             height: 42,
303:             decoration: BoxDecoration(
304:               color: c.superficie3,
305:               borderRadius: BorderRadius.circular(12),
306:             ),
307:             child: Icon(Icons.smartphone_rounded, color: c.tinta2),
308:           ),
309:           const SizedBox(width: 12),
310:           Expanded(
311:             child: Column(
312:               crossAxisAlignment: CrossAxisAlignment.start,
313:               children: [
314:                 Text(
315:                   terminal.nombre,
316:                   style: const TextStyle(fontWeight: FontWeight.w600),
317:                 ),
318:                 Row(
319:                   children: [
320:                     Container(
321:                       width: 8,
322:                       height: 8,
323:                       decoration: BoxDecoration(
324:                         shape: BoxShape.circle,
325:                         color: terminal.conectada
326:                             ? const Color(0xFF46C281)
327:                             : c.tinta2,
328:                       ),
329:                     ),
330:                     const SizedBox(width: 6),
331:                     Text(
332:                       terminal.conectada ? 'Conectada ahora' : 'Desconectada',
333:                       style: TextStyle(fontSize: 14, color: c.tinta2),
334:                     ),
335:                   ],
336:                 ),
337:               ],
338:             ),
339:           ),
340:           TextButton(
341:             style: TextButton.styleFrom(foregroundColor: c.alerta),
342:             onPressed: () async {
343:               final ok = await confirmar(
344:                 context,
345:                 titulo: '¿Desvincular ${terminal.nombre}?',
346:                 mensaje: 'Dejará de ver productos y mandar pedidos hasta que se vuelva a conectar con un código nuevo.',
347:                 accion: 'Desvincular',
348:                 peligrosa: true,
349:               );
350:               if (!ok) return;
351:               try {
352:                 final api = await ref.read(apiProvider.future);
353:                 await api.revocarTerminal(terminal.id);
354:                 ref.invalidate(terminalesProvider);
355:               } on FalloApi catch (e) {
356:                 if (context.mounted) avisar(context, e.mensaje);
357:               }
358:             },
359:             child: const Text('Desvincular'),
360:           ),
361:         ],
362:       ),
363:     );
364:   }
365: }
````

## File: app/lib/features/caja/pantallas/secciones_caja.dart
````dart
  1: import 'package:flutter/material.dart';
  2: 
  3: import '../../ajustes/ajustes.dart';
  4: import '../../catalogo/pantallas/pantalla_catalogo.dart';
  5: import '../../proximamente/proximamente.dart';
  6: import 'inicio_caja.dart';
  7: 
  8: /// Secciones de la caja, en el orden del menú. Las que no están construidas
  9: /// muestran en qué sprint llegan y quién las hace (docs/PLAN_DE_TRABAJO.md).
 10: class SeccionCaja {
 11:   const SeccionCaja(
 12:     this.ruta,
 13:     this.titulo,
 14:     this.icono,
 15:     this.iconoActivo,
 16:     this.construir,
 17:   );
 18: 
 19:   final String ruta;
 20:   final String titulo;
 21:   final IconData icono;
 22:   final IconData iconoActivo;
 23:   final Widget Function() construir;
 24: }
 25: 
 26: final seccionesCaja = <SeccionCaja>[
 27:   SeccionCaja(
 28:     'inicio',
 29:     'Inicio',
 30:     Icons.home_outlined,
 31:     Icons.home_rounded,
 32:     InicioCaja.new,
 33:   ),
 34:   SeccionCaja(
 35:     'vender',
 36:     'Vender',
 37:     Icons.shopping_cart_outlined,
 38:     Icons.shopping_cart_rounded,
 39:     () => const Proximamente(
 40:       icono: Icons.shopping_cart_outlined,
 41:       titulo: 'Vender',
 42:       descripcion:
 43:           'Carrito por pieza o caja, envases y cobro en efectivo o tarjeta.',
 44:       sprint: 3,
 45:       responsable: 'Daniel',
 46:     ),
 47:   ),
 48:   SeccionCaja(
 49:     'ventas',
 50:     'Ventas',
 51:     Icons.receipt_long_outlined,
 52:     Icons.receipt_long_rounded,
 53:     () => const Proximamente(
 54:       icono: Icons.receipt_long_outlined,
 55:       titulo: 'Ventas',
 56:       descripcion: 'Historial del turno, tickets en PDF y cancelaciones.',
 57:       sprint: 3,
 58:       responsable: 'Daniel',
 59:     ),
 60:   ),
 61:   SeccionCaja(
 62:     'catalogo',
 63:     'Catálogo',
 64:     Icons.grid_view_outlined,
 65:     Icons.grid_view_rounded,
 66:     PantallaCatalogo.new,
 67:   ),
 68:   SeccionCaja(
 69:     'envases',
 70:     'Envases',
 71:     Icons.liquor_outlined,
 72:     Icons.liquor_rounded,
 73:     () => const Proximamente(
 74:       icono: Icons.liquor_outlined,
 75:       titulo: 'Envases',
 76:       descripcion:
 77:           'Existencias por formato, préstamos a clientes y devoluciones.',
 78:       sprint: 2,
 79:       responsable: 'Luis',
 80:     ),
 81:   ),
 82:   SeccionCaja(
 83:     'corte',
 84:     'Corte de caja',
 85:     Icons.point_of_sale_outlined,
 86:     Icons.point_of_sale_rounded,
 87:     () => const Proximamente(
 88:       icono: Icons.point_of_sale_outlined,
 89:       titulo: 'Corte de caja',
 90:       descripcion: 'Apertura con fondo, arqueo y cierre del turno con respaldo automático.',
 91:       sprint: 3,
 92:       responsable: 'Daniel',
 93:     ),
 94:   ),
 95:   SeccionCaja(
 96:     'alertas',
 97:     'Alertas',
 98:     Icons.notifications_none_rounded,
 99:     Icons.notifications_rounded,
100:     () => const Proximamente(
101:       icono: Icons.notifications_none_rounded,
102:       titulo: 'Alertas',
103:       descripcion: 'Productos bajo su mínimo y próximos a caducar. Mientras tanto, el Inicio ya los muestra.',
104:       sprint: 4,
105:       responsable: 'Luis',
106:     ),
107:   ),
108:   SeccionCaja(
109:     'resurtido',
110:     'Resurtido',
111:     Icons.local_shipping_outlined,
112:     Icons.local_shipping_rounded,
113:     () => const Proximamente(
114:       icono: Icons.local_shipping_outlined,
115:       titulo: 'Resurtido',
116:       descripcion: 'Cuánto comprar según lo vendido, con pedido al proveedor por WhatsApp.',
117:       sprint: 4,
118:       responsable: 'Luis',
119:     ),
120:   ),
121:   SeccionCaja(
122:     'ajustes',
123:     'Ajustes',
124:     Icons.settings_outlined,
125:     Icons.settings_rounded,
126:     PantallaAjustes.new,
127:   ),
128: ];
129: 
130: SeccionCaja seccionCaja(String ruta) => seccionesCaja.firstWhere(
131:   (s) => s.ruta == ruta,
132:   orElse: () => seccionesCaja.first,
133: );
````

## File: app/lib/features/caja/pantallas/shell_caja.dart
````dart
  1: import 'package:deposito_backend/deposito_backend.dart';
  2: import 'package:flutter/material.dart';
  3: import 'package:flutter_riverpod/flutter_riverpod.dart';
  4: import 'package:go_router/go_router.dart';
  5: 
  6: import '../../../app/tema/colores.dart';
  7: import '../../../core/config/configuracion.dart';
  8: import '../../../core/formato/formato.dart';
  9: import '../../../core/servidor/servidor_embebido.dart';
 10: import '../../../core/widgets/estados.dart';
 11: import '../../../core/widgets/indicador_conexion.dart';
 12: import '../../../core/widgets/marca.dart';
 13: import '../../catalogo/estado/productos.dart';
 14: import 'conectar_terminal.dart';
 15: import 'secciones_caja.dart';
 16: 
 17: /// Marco de la caja: menú lateral café, barra superior y la sección activa.
 18: ///
 19: /// - 1000 px o más (iPad horizontal): menú completo.
 20: /// - 640 a 1000 px (iPad vertical): menú de íconos.
 21: /// - Menos: menú en cajón (para probar en teléfono).
 22: class ShellCaja extends ConsumerWidget {
 23:   const ShellCaja({super.key, required this.seccion, required this.child});
 24: 
 25:   final String seccion;
 26:   final Widget child;
 27: 
 28:   @override
 29:   Widget build(BuildContext context, WidgetRef ref) {
 30:     final servidor = ref.watch(servidorEmbebidoProvider);
 31:     return switch (servidor) {
 32:       AsyncData() => _Marco(seccion: seccion, child: child),
 33:       AsyncError(:final error) => Scaffold(
 34:         body: EstadoVacio(
 35:           icono: Icons.dns_outlined,
 36:           titulo: 'No se pudo iniciar la caja',
 37:           mensaje:
 38:               '$error\n\nCierra otras apps que usen el puerto $puertoServidor y reintenta.',
 39:           accion: FilledButton.icon(
 40:             onPressed: () => ref.invalidate(servidorEmbebidoProvider),
 41:             icon: const Icon(Icons.refresh_rounded),
 42:             label: const Text('Reintentar'),
 43:           ),
 44:         ),
 45:       ),
 46:       _ => const _Arrancando(),
 47:     };
 48:   }
 49: }
 50: 
 51: class _Arrancando extends StatelessWidget {
 52:   const _Arrancando();
 53: 
 54:   @override
 55:   Widget build(BuildContext context) {
 56:     final c = context.colores;
 57:     return Scaffold(
 58:       backgroundColor: c.vidrio,
 59:       body: Center(
 60:         child: Column(
 61:           mainAxisSize: MainAxisSize.min,
 62:           children: [
 63:             const LogoAnaquel(tamano: 72),
 64:             const SizedBox(height: 20),
 65:             Text(
 66:               'Abriendo la caja…',
 67:               style: Theme.of(context).textTheme.headlineSmall
 68:                   ?.copyWith(color: c.vidrioTinta),
 69:             ),
 70:             const SizedBox(height: 16),
 71:             SizedBox(
 72:               width: 160,
 73:               child: LinearProgressIndicator(
 74:                 color: c.lager,
 75:                 backgroundColor: c.vidrio2,
 76:               ),
 77:             ),
 78:           ],
 79:         ),
 80:       ),
 81:     );
 82:   }
 83: }
 84: 
 85: class _Marco extends StatelessWidget {
 86:   const _Marco({required this.seccion, required this.child});
 87: 
 88:   final String seccion;
 89:   final Widget child;
 90: 
 91:   @override
 92:   Widget build(BuildContext context) {
 93:     return LayoutBuilder(
 94:       builder: (context, medidas) {
 95:         final ancho = medidas.maxWidth;
 96:         final actual = seccionCaja(seccion);
 97:         if (ancho < 640) {
 98:           return Scaffold(
 99:             appBar: AppBar(
100:               title: Text(actual.titulo),
101:               actions: const [
102:                 _BotonConectar(compacto: true),
103:                 SizedBox(width: 8),
104:               ],
105:             ),
106:             drawer: Drawer(
107:               backgroundColor: context.colores.vidrio,
108:               child: _MenuLateral(
109:                 seccion: seccion,
110:                 compacto: false,
111:                 alNavegar: () => Navigator.pop(context),
112:               ),
113:             ),
114:             body: child,
115:           );
116:         }
117:         final compacto = ancho < 1000;
118:         return Scaffold(
119:           body: Row(
120:             children: [
121:               _MenuLateral(seccion: seccion, compacto: compacto),
122:               Expanded(
123:                 child: Column(
124:                   children: [
125:                     _BarraSuperior(
126:                       titulo: actual.titulo,
127:                       compacta: ancho < 820,
128:                     ),
129:                     Expanded(child: child),
130:                   ],
131:                 ),
132:               ),
133:             ],
134:           ),
135:         );
136:       },
137:     );
138:   }
139: }
140: 
141: class _MenuLateral extends ConsumerWidget {
142:   const _MenuLateral({
143:     required this.seccion,
144:     required this.compacto,
145:     this.alNavegar,
146:   });
147: 
148:   final String seccion;
149:   final bool compacto;
150:   final VoidCallback? alNavegar;
151: 
152:   @override
153:   Widget build(BuildContext context, WidgetRef ref) {
154:     final c = context.colores;
155:     final textos = Theme.of(context).textTheme;
156:     final ip = ref.watch(direccionLocalProvider).value;
157:     final productos = ref.watch(productosProvider).value ?? const <Producto>[];
158:     final hoy = DateTime.now();
159:     final alertas = productos
160:         .where(
161:           (p) =>
162:               p.bajoMinimo ||
163:               (p.caducidad != null && diasHasta(p.caducidad!, hoy) <= 15),
164:         )
165:         .length;
166: 
167:     return Container(
168:       width: compacto ? 92 : 240,
169:       color: c.vidrio,
170:       child: SafeArea(
171:         right: false,
172:         child: Padding(
173:           padding: EdgeInsets.symmetric(
174:             horizontal: compacto ? 12 : 14,
175:             vertical: 20,
176:           ),
177:           child: Column(
178:             crossAxisAlignment: compacto
179:                 ? CrossAxisAlignment.center
180:                 : CrossAxisAlignment.stretch,
181:             children: [
182:               Padding(
183:                 padding: EdgeInsets.fromLTRB(compacto ? 0 : 8, 0, 0, 22),
184:                 child: Row(
185:                   mainAxisAlignment: compacto
186:                       ? MainAxisAlignment.center
187:                       : MainAxisAlignment.start,
188:                   children: [
189:                     const LogoAnaquel(),
190:                     if (!compacto) ...[
191:                       const SizedBox(width: 12),
192:                       Expanded(
193:                         child: Column(
194:                           crossAxisAlignment: CrossAxisAlignment.start,
195:                           children: [
196:                             Text(
197:                               'Anaquel',
198:                               maxLines: 1,
199:                               overflow: TextOverflow.ellipsis,
200:                               style: textos.headlineSmall?.copyWith(
201:                                 color: c.vidrioTinta,
202:                                 height: 1,
203:                               ),
204:                             ),
205:                             Text(
206:                               'Caja principal',
207:                               maxLines: 1,
208:                               overflow: TextOverflow.ellipsis,
209:                               style: TextStyle(
210:                                 color: c.vidrioTinta2,
211:                                 fontSize: 14,
212:                                 fontWeight: FontWeight.w500,
213:                               ),
214:                             ),
215:                           ],
216:                         ),
217:                       ),
218:                     ],
219:                   ],
220:                 ),
221:               ),
222:               Expanded(
223:                 child: ListView(
224:                   children: [
225:                     for (final s in seccionesCaja)
226:                       _ElementoMenu(
227:                         seccion: s,
228:                         activo: s.ruta == seccion,
229:                         compacto: compacto,
230:                         insignia: s.ruta == 'alertas' && alertas > 0
231:                             ? alertas
232:                             : null,
233:                         alTocar: () {
234:                           alNavegar?.call();
235:                           context.go('/caja/${s.ruta}');
236:                         },
237:                       ),
238:                   ],
239:                 ),
240:               ),
241:               if (!compacto)
242:                 Padding(
243:                   padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
244:                   child: Column(
245:                     crossAxisAlignment: CrossAxisAlignment.start,
246:                     spacing: 6,
247:                     children: [
248:                       IndicadorConexion(
249:                         colorTexto: c.vidrioTinta,
250:                         etiquetaEnLinea: 'Servidor activo',
251:                       ),
252:                       Row(
253:                         children: [
254:                           Icon(
255:                             Icons.wifi_rounded,
256:                             size: 16,
257:                             color: c.vidrioTinta2,
258:                           ),
259:                           const SizedBox(width: 8),
260:                           Flexible(
261:                             child: Text(
262:                               ip == null ? 'Sin Wi-Fi' : '$ip:$puertoServidor',
263:                               maxLines: 1,
264:                               overflow: TextOverflow.ellipsis,
265:                               style: TextStyle(
266:                                 color: c.vidrioTinta2,
267:                                 fontSize: 14,
268:                               ),
269:                             ),
270:                           ),
271:                         ],
272:                       ),
273:                     ],
274:                   ),
275:                 ),
276:             ],
277:           ),
278:         ),
279:       ),
280:     );
281:   }
282: }
283: 
284: class _ElementoMenu extends StatelessWidget {
285:   const _ElementoMenu({
286:     required this.seccion,
287:     required this.activo,
288:     required this.compacto,
289:     required this.alTocar,
290:     this.insignia,
291:   });
292: 
293:   final SeccionCaja seccion;
294:   final bool activo;
295:   final bool compacto;
296:   final VoidCallback alTocar;
297:   final int? insignia;
298: 
299:   @override
300:   Widget build(BuildContext context) {
301:     final c = context.colores;
302:     final color = activo ? c.lagerTinta : c.vidrioTinta;
303:     final icono = Icon(
304:       activo ? seccion.iconoActivo : seccion.icono,
305:       color: color,
306:       size: 23,
307:     );
308:     final contenido = compacto
309:         ? Badge(
310:             isLabelVisible: insignia != null,
311:             label: Text('${insignia ?? ''}'),
312:             backgroundColor: c.alerta,
313:             child: icono,
314:           )
315:         : Row(
316:             children: [
317:               icono,
318:               const SizedBox(width: 14),
319:               Expanded(
320:                 child: Text(
321:                   seccion.titulo,
322:                   style: TextStyle(
323:                     fontSize: 17,
324:                     fontWeight: activo ? FontWeight.w600 : FontWeight.w500,
325:                     color: color,
326:                   ),
327:                 ),
328:               ),
329:               if (insignia != null)
330:                 Container(
331:                   padding: const EdgeInsets.symmetric(
332:                     horizontal: 8,
333:                     vertical: 2,
334:                   ),
335:                   decoration: BoxDecoration(
336:                     color: activo ? c.vidrio : c.alerta,
337:                     borderRadius: BorderRadius.circular(999),
338:                   ),
339:                   child: Text(
340:                     '$insignia',
341:                     style: TextStyle(
342:                       color: activo ? c.vidrioTinta : Colors.white,
343:                       fontSize: 13,
344:                       fontWeight: FontWeight.w700,
345:                     ),
346:                   ),
347:                 ),
348:             ],
349:           );
350: 
351:     return Padding(
352:       padding: const EdgeInsets.only(bottom: 3),
353:       child: Tooltip(
354:         message: compacto ? seccion.titulo : '',
355:         child: Material(
356:           color: activo ? c.lager : Colors.transparent,
357:           borderRadius: BorderRadius.circular(10),
358:           child: InkWell(
359:             borderRadius: BorderRadius.circular(10),
360:             hoverColor: c.vidrio2,
361:             onTap: alTocar,
362:             child: Container(
363:               height: 50,
364:               padding: EdgeInsets.symmetric(horizontal: compacto ? 0 : 12),
365:               alignment: compacto ? Alignment.center : Alignment.centerLeft,
366:               child: contenido,
367:             ),
368:           ),
369:         ),
370:       ),
371:     );
372:   }
373: }
374: 
375: class _BarraSuperior extends ConsumerWidget {
376:   const _BarraSuperior({required this.titulo, required this.compacta});
377: 
378:   final String titulo;
379:   final bool compacta;
380: 
381:   @override
382:   Widget build(BuildContext context, WidgetRef ref) {
383:     final c = context.colores;
384:     final tema = ref.watch(configuracionProvider).tema;
385:     final oscuro =
386:         tema == ThemeMode.dark ||
387:         (tema == ThemeMode.system &&
388:             Theme.of(context).brightness == Brightness.dark);
389:     return Container(
390:       padding: const EdgeInsets.fromLTRB(24, 12, 20, 12),
391:       decoration: BoxDecoration(
392:         color: c.superficie,
393:         border: Border(bottom: BorderSide(color: c.linea)),
394:       ),
395:       child: SafeArea(
396:         bottom: false,
397:         left: false,
398:         child: Row(
399:           spacing: 10,
400:           children: [
401:             Expanded(
402:               child: Text(
403:                 titulo,
404:                 style: Theme.of(context).textTheme.headlineLarge,
405:               ),
406:             ),
407:             if (!compacta)
408:               Pildora(
409:                 texto: fechaLarga(DateTime.now()),
410:                 icono: Icons.calendar_today_rounded,
411:               ),
412:             IconButton.outlined(
413:               tooltip: oscuro ? 'Tema claro' : 'Tema oscuro',
414:               style: IconButton.styleFrom(side: BorderSide(color: c.linea)),
415:               onPressed: () => ref
416:                   .read(configuracionProvider.notifier)
417:                   .cambiarTema(oscuro ? ThemeMode.light : ThemeMode.dark),
418:               icon: Icon(
419:                 oscuro ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
420:               ),
421:             ),
422:             _BotonConectar(compacto: compacta),
423:           ],
424:         ),
425:       ),
426:     );
427:   }
428: }
429: 
430: class _BotonConectar extends StatelessWidget {
431:   const _BotonConectar({required this.compacto});
432: 
433:   final bool compacto;
434: 
435:   @override
436:   Widget build(BuildContext context) => compacto
437:       ? IconButton.outlined(
438:           tooltip: 'Conectar terminal',
439:           onPressed: () => mostrarConectarTerminal(context),
440:           icon: const Icon(Icons.qr_code_2_rounded),
441:         )
442:       : OutlinedButton.icon(
443:           onPressed: () => mostrarConectarTerminal(context),
444:           icon: const Icon(Icons.qr_code_2_rounded),
445:           label: const Text('Conectar terminal'),
446:         );
447: }
````

## File: app/lib/features/catalogo/estado/productos.dart
````dart
 1: import 'package:deposito_backend/deposito_backend.dart';
 2: import 'package:flutter_riverpod/flutter_riverpod.dart';
 3: 
 4: import '../../../core/api/proveedores.dart';
 5: import '../../../core/tiempo_real/tiempo_real.dart';
 6: 
 7: /// Catálogo completo, al día con el WebSocket:
 8: /// - `producto.actualizado` lo agrega o reemplaza sin volver a pedir todo.
 9: /// - Al reconectarse vuelve a pedir la lista completa (regla del contrato).
10: final productosProvider =
11:     AsyncNotifierProvider<ProductosNotifier, List<Producto>>(
12:       ProductosNotifier.new,
13:       retry: (_, _) => null,
14:     );
15: 
16: class ProductosNotifier extends AsyncNotifier<List<Producto>> {
17:   @override
18:   Future<List<Producto>> build() async {
19:     final api = await ref.watch(apiProvider.future);
20:     ref.listen(eventosProvider, (_, siguiente) {
21:       final evento = siguiente.value;
22:       if (evento != null) _alEvento(evento);
23:     });
24:     return _ordenar(await api.listarProductos());
25:   }
26: 
27:   /// Vuelve a pedir la lista sin mostrar "cargando" (jalar para refrescar).
28:   Future<void> refrescar() async {
29:     final api = await ref.read(apiProvider.future);
30:     state = await AsyncValue.guard(
31:       () async => _ordenar(await api.listarProductos()),
32:     );
33:   }
34: 
35:   void _alEvento(Evento e) {
36:     switch (e.tipo) {
37:       case TiposEvento.productoActualizado:
38:         final p = Producto.fromJson((e.datos['producto'] as Map).cast());
39:         final actual = state.value;
40:         if (actual == null) return;
41:         state = AsyncData(_ordenar([...actual.where((x) => x.id != p.id), p]));
42:       case eventoReconectado:
43:         refrescar();
44:     }
45:   }
46: 
47:   static List<Producto> _ordenar(List<Producto> lista) => lista
48:     ..sort(
49:       (a, b) =>
50:           normalizarBusqueda(a.nombre).compareTo(normalizarBusqueda(b.nombre)),
51:     );
52: }
53: 
54: /// Filtro local: el catálogo de un depósito cabe completo en memoria.
55: List<Producto> filtrarProductos(
56:   List<Producto> lista, {
57:   String busqueda = '',
58:   String? categoria,
59: }) {
60:   final q = normalizarBusqueda(busqueda);
61:   return [
62:     for (final p in lista)
63:       if ((categoria == null || p.categoria == categoria) &&
64:           (q.isEmpty ||
65:               normalizarBusqueda(p.nombre).contains(q) ||
66:               p.codigo.contains(q)))
67:         p,
68:   ];
69: }
70: 
71: /// Categorías presentes, en orden alfabético.
72: List<String> categoriasDe(List<Producto> lista) =>
73:     {for (final p in lista) p.categoria}.toList()..sort();
74: 
75: /// Producto con ese código de barras, o `null`.
76: Producto? porCodigo(List<Producto> lista, String codigo) {
77:   final c = codigo.trim();
78:   for (final p in lista) {
79:     if (p.codigo == c) return p;
80:   }
81:   return null;
82: }
````

## File: app/lib/features/catalogo/pantallas/detalle_producto.dart
````dart
  1: import 'package:deposito_backend/deposito_backend.dart';
  2: import 'package:flutter/material.dart';
  3: 
  4: import '../../../app/tema/colores.dart';
  5: import '../../../core/formato/formato.dart';
  6: import '../../../core/widgets/ilustracion_producto.dart';
  7: 
  8: Future<void> mostrarDetalleProducto(BuildContext context, Producto p) =>
  9:     showModalBottomSheet<void>(
 10:       context: context,
 11:       isScrollControlled: true,
 12:       constraints: const BoxConstraints(maxWidth: 560),
 13:       builder: (_) => DetalleProducto(producto: p),
 14:     );
 15: 
 16: /// Ficha del producto: precio, existencia y datos del catálogo.
 17: class DetalleProducto extends StatelessWidget {
 18:   const DetalleProducto({super.key, required this.producto});
 19: 
 20:   final Producto producto;
 21: 
 22:   @override
 23:   Widget build(BuildContext context) {
 24:     final c = context.colores;
 25:     final textos = Theme.of(context).textTheme;
 26:     final p = producto;
 27:     final hoy = DateTime.now();
 28:     final diasCaducidad = p.caducidad == null
 29:         ? null
 30:         : diasHasta(p.caducidad!, hoy);
 31: 
 32:     return SafeArea(
 33:       child: Padding(
 34:         padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
 35:         child: Column(
 36:           mainAxisSize: MainAxisSize.min,
 37:           crossAxisAlignment: CrossAxisAlignment.stretch,
 38:           children: [
 39:             Row(
 40:               children: [
 41:                 SizedBox(
 42:                   width: 104,
 43:                   height: 120,
 44:                   child: IlustracionProducto(producto: p),
 45:                 ),
 46:                 const SizedBox(width: 18),
 47:                 Expanded(
 48:                   child: Column(
 49:                     crossAxisAlignment: CrossAxisAlignment.start,
 50:                     children: [
 51:                       Text(
 52:                         capitalizar(p.categoria).toUpperCase(),
 53:                         style: textos.labelSmall?.copyWith(letterSpacing: 1.2),
 54:                       ),
 55:                       const SizedBox(height: 2),
 56:                       Text(p.nombre, style: textos.headlineMedium),
 57:                       if (p.presentacion != null)
 58:                         Text(
 59:                           p.presentacion!,
 60:                           style: textos.bodyMedium?.copyWith(color: c.tinta2),
 61:                         ),
 62:                     ],
 63:                   ),
 64:                 ),
 65:               ],
 66:             ),
 67:             const SizedBox(height: 20),
 68:             Row(
 69:               children: [
 70:                 Expanded(
 71:                   child: _Cifra(
 72:                     etiqueta: 'Pieza',
 73:                     valor: dinero(p.precio),
 74:                     resaltada: true,
 75:                   ),
 76:                 ),
 77:                 const SizedBox(width: 12),
 78:                 Expanded(
 79:                   child: _Cifra(
 80:                     etiqueta: p.piezasPorCaja == null
 81:                         ? 'Caja'
 82:                         : 'Caja de ${p.piezasPorCaja}',
 83:                     valor: p.precioCaja == null ? '—' : dinero(p.precioCaja!),
 84:                   ),
 85:                 ),
 86:               ],
 87:             ),
 88:             const SizedBox(height: 12),
 89:             _Cifra(
 90:               etiqueta: 'Existencia',
 91:               valor: existenciaLegible(p),
 92:               detalle: p.bajoMinimo
 93:                   ? 'Bajo el mínimo de ${p.minimo} pz'
 94:                   : 'Mínimo ${p.minimo} pz',
 95:               alerta: p.bajoMinimo,
 96:             ),
 97:             const SizedBox(height: 16),
 98:             _Dato(
 99:               icono: Icons.qr_code_2_rounded,
100:               etiqueta: 'Código',
101:               valor: p.codigo,
102:             ),
103:             if (p.envase != null)
104:               _Dato(
105:                 icono: Icons.recycling_rounded,
106:                 etiqueta: 'Envase retornable',
107:                 valor: capitalizar(p.envase!),
108:               ),
109:             if (p.caducidad != null)
110:               _Dato(
111:                 icono: Icons.event_rounded,
112:                 etiqueta: 'Caducidad',
113:                 valor:
114:                     '${fechaCorta(p.caducidad!)} · ${_textoDias(diasCaducidad!)}',
115:                 alerta: diasCaducidad <= 15,
116:               ),
117:           ],
118:         ),
119:       ),
120:     );
121:   }
122: 
123:   static String _textoDias(int d) => switch (d) {
124:     < 0 => 'caducado',
125:     0 => 'caduca hoy',
126:     1 => 'mañana',
127:     _ => 'en $d días',
128:   };
129: }
130: 
131: class _Cifra extends StatelessWidget {
132:   const _Cifra({
133:     required this.etiqueta,
134:     required this.valor,
135:     this.detalle,
136:     this.resaltada = false,
137:     this.alerta = false,
138:   });
139: 
140:   final String etiqueta;
141:   final String valor;
142:   final String? detalle;
143:   final bool resaltada;
144:   final bool alerta;
145: 
146:   @override
147:   Widget build(BuildContext context) {
148:     final c = context.colores;
149:     final textos = Theme.of(context).textTheme;
150:     final fondo = alerta
151:         ? c.alertaSuave
152:         : (resaltada ? c.lagerSuave : c.superficie2);
153:     return Container(
154:       padding: const EdgeInsets.all(14),
155:       decoration: BoxDecoration(
156:         color: fondo,
157:         borderRadius: BorderRadius.circular(14),
158:       ),
159:       child: Column(
160:         crossAxisAlignment: CrossAxisAlignment.start,
161:         children: [
162:           Text(etiqueta, style: textos.bodySmall),
163:           Text(
164:             valor,
165:             style: textos.headlineLarge?.copyWith(
166:               color: alerta ? c.alerta : null,
167:             ),
168:           ),
169:           if (detalle != null)
170:             Text(
171:               detalle!,
172:               style: textos.bodySmall?.copyWith(
173:                 color: alerta ? c.alerta : null,
174:               ),
175:             ),
176:         ],
177:       ),
178:     );
179:   }
180: }
181: 
182: class _Dato extends StatelessWidget {
183:   const _Dato({
184:     required this.icono,
185:     required this.etiqueta,
186:     required this.valor,
187:     this.alerta = false,
188:   });
189: 
190:   final IconData icono;
191:   final String etiqueta;
192:   final String valor;
193:   final bool alerta;
194: 
195:   @override
196:   Widget build(BuildContext context) {
197:     final c = context.colores;
198:     return Container(
199:       padding: const EdgeInsets.symmetric(vertical: 11),
200:       decoration: BoxDecoration(
201:         border: Border(top: BorderSide(color: c.linea)),
202:       ),
203:       child: Row(
204:         children: [
205:           Icon(icono, size: 20, color: c.tinta2),
206:           const SizedBox(width: 12),
207:           Expanded(
208:             child: Text(etiqueta, style: TextStyle(color: c.tinta2)),
209:           ),
210:           Text(
211:             valor,
212:             style: TextStyle(
213:               fontWeight: FontWeight.w600,
214:               color: alerta ? c.alerta : c.tinta,
215:             ),
216:           ),
217:         ],
218:       ),
219:     );
220:   }
221: }
````

## File: app/lib/features/catalogo/pantallas/formulario_producto.dart
````dart
  1: import 'package:deposito_backend/deposito_backend.dart';
  2: import 'package:flutter/material.dart';
  3: import 'package:flutter/services.dart';
  4: import 'package:flutter_riverpod/flutter_riverpod.dart';
  5: 
  6: import '../../../app/tema/colores.dart';
  7: import '../../../core/api/fallo_api.dart';
  8: import '../../../core/api/proveedores.dart';
  9: import '../../../core/formato/formato.dart';
 10: import '../../../core/widgets/estados.dart';
 11: 
 12: Future<Producto?> abrirFormularioProducto(BuildContext context) =>
 13:     showDialog<Producto>(
 14:       context: context,
 15:       builder: (_) => const FormularioProducto(),
 16:     );
 17: 
 18: /// Alta de producto. Valida lo básico en pantalla; las reglas finales las
 19: /// pone el servidor y sus errores se muestran en el campo que corresponde.
 20: class FormularioProducto extends ConsumerStatefulWidget {
 21:   const FormularioProducto({super.key});
 22: 
 23:   @override
 24:   ConsumerState<FormularioProducto> createState() => _FormularioProductoState();
 25: }
 26: 
 27: class _FormularioProductoState extends ConsumerState<FormularioProducto> {
 28:   final _codigo = TextEditingController();
 29:   final _nombre = TextEditingController();
 30:   final _categoria = TextEditingController(text: 'cerveza');
 31:   final _presentacion = TextEditingController();
 32:   final _precio = TextEditingController();
 33:   final _precioCaja = TextEditingController();
 34:   final _piezasPorCaja = TextEditingController();
 35:   final _existencia = TextEditingController(text: '0');
 36:   final _minimo = TextEditingController(text: '0');
 37:   var _porCaja = false;
 38:   String? _envase;
 39:   DateTime? _caducidad;
 40:   var _guardando = false;
 41:   Map<String, String> _errores = {};
 42: 
 43:   @override
 44:   void dispose() {
 45:     for (final c in [
 46:       _codigo,
 47:       _nombre,
 48:       _categoria,
 49:       _presentacion,
 50:       _precio,
 51:       _precioCaja,
 52:       _piezasPorCaja,
 53:       _existencia,
 54:       _minimo,
 55:     ]) {
 56:       c.dispose();
 57:     }
 58:     super.dispose();
 59:   }
 60: 
 61:   Future<void> _guardar() async {
 62:     final errores = <String, String>{};
 63:     final precio = centavosDesdeTexto(_precio.text);
 64:     if (precio == null || precio == 0) {
 65:       errores['precio'] = 'Escribe el precio, por ejemplo 42.50';
 66:     }
 67:     final precioCaja = _porCaja ? centavosDesdeTexto(_precioCaja.text) : null;
 68:     if (_porCaja && (precioCaja == null || precioCaja == 0)) {
 69:       errores['precioCaja'] = 'Escribe el precio de la caja';
 70:     }
 71:     setState(() => _errores = errores);
 72:     if (errores.isNotEmpty) return;
 73: 
 74:     final caducidad = _caducidad;
 75:     final datos = <String, Object?>{
 76:       'codigo': _codigo.text.trim(),
 77:       'nombre': _nombre.text.trim(),
 78:       'categoria': _categoria.text.trim().toLowerCase(),
 79:       if (_presentacion.text.trim().isNotEmpty)
 80:         'presentacion': _presentacion.text.trim(),
 81:       'precio': precio,
 82:       if (_porCaja) 'precioCaja': precioCaja,
 83:       if (_porCaja) 'piezasPorCaja': int.tryParse(_piezasPorCaja.text) ?? 0,
 84:       'existenciaPiezas': int.tryParse(_existencia.text) ?? 0,
 85:       'minimo': int.tryParse(_minimo.text) ?? 0,
 86:       'envase': _envase,
 87:       if (caducidad != null)
 88:         'caducidad':
 89:             '${caducidad.year}-${caducidad.month.toString().padLeft(2, '0')}-${caducidad.day.toString().padLeft(2, '0')}',
 90:     };
 91: 
 92:     setState(() => _guardando = true);
 93:     try {
 94:       final api = await ref.read(apiProvider.future);
 95:       final producto = await api.crearProducto(datos);
 96:       if (!mounted) return;
 97:       Navigator.pop(context, producto);
 98:       avisar(context, '${producto.nombre} quedó en el catálogo');
 99:     } on FalloApi catch (e) {
100:       setState(() {
101:         _guardando = false;
102:         _errores = e.campos.isNotEmpty ? e.campos : {'codigo': e.mensaje};
103:       });
104:     }
105:   }
106: 
107:   @override
108:   Widget build(BuildContext context) {
109:     final c = context.colores;
110:     final textos = Theme.of(context).textTheme;
111:     final soloNumeros = [FilteringTextInputFormatter.digitsOnly];
112:     final dinero = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,$]'))];
113: 
114:     Widget campo(
115:       String clave,
116:       String etiqueta,
117:       TextEditingController ctrl, {
118:       List<TextInputFormatter>? formato,
119:       TextInputType? teclado,
120:       String? ayuda,
121:       String? prefijo,
122:     }) => TextField(
123:       controller: ctrl,
124:       inputFormatters: formato,
125:       keyboardType: teclado,
126:       decoration: InputDecoration(
127:         labelText: etiqueta,
128:         helperText: ayuda,
129:         prefixText: prefijo,
130:         errorText: _errores[clave],
131:         errorMaxLines: 2,
132:       ),
133:     );
134: 
135:     Widget fila(List<Widget> hijos) => Row(
136:       crossAxisAlignment: CrossAxisAlignment.start,
137:       children: [
138:         for (var i = 0; i < hijos.length; i++) ...[
139:           if (i > 0) const SizedBox(width: 12),
140:           Expanded(child: hijos[i]),
141:         ],
142:       ],
143:     );
144: 
145:     return Dialog(
146:       insetPadding: const EdgeInsets.all(24),
147:       child: ConstrainedBox(
148:         constraints: const BoxConstraints(maxWidth: 620, maxHeight: 760),
149:         child: Column(
150:           mainAxisSize: MainAxisSize.min,
151:           crossAxisAlignment: CrossAxisAlignment.stretch,
152:           children: [
153:             Padding(
154:               padding: const EdgeInsets.fromLTRB(24, 22, 12, 8),
155:               child: Row(
156:                 children: [
157:                   Expanded(
158:                     child: Text('Nuevo producto', style: textos.headlineMedium),
159:                   ),
160:                   IconButton(
161:                     onPressed: () => Navigator.pop(context),
162:                     icon: const Icon(Icons.close_rounded),
163:                     tooltip: 'Cerrar',
164:                   ),
165:                 ],
166:               ),
167:             ),
168:             Flexible(
169:               child: SingleChildScrollView(
170:                 padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
171:                 child: Column(
172:                   crossAxisAlignment: CrossAxisAlignment.stretch,
173:                   spacing: 14,
174:                   children: [
175:                     campo(
176:                       'codigo',
177:                       'Código de barras',
178:                       _codigo,
179:                       teclado: TextInputType.number,
180:                     ),
181:                     campo('nombre', 'Nombre', _nombre),
182:                     fila([
183:                       campo(
184:                         'categoria',
185:                         'Categoría',
186:                         _categoria,
187:                         ayuda: 'cerveza, refresco, botana, hielo…',
188:                       ),
189:                       campo(
190:                         'presentacion',
191:                         'Presentación',
192:                         _presentacion,
193:                         ayuda: 'Mega 1.2 L',
194:                       ),
195:                     ]),
196:                     fila([
197:                       campo(
198:                         'precio',
199:                         'Precio por pieza',
200:                         _precio,
201:                         formato: dinero,
202:                         prefijo: '\$ ',
203:                         teclado: const TextInputType.numberWithOptions(
204:                           decimal: true,
205:                         ),
206:                       ),
207:                       campo(
208:                         'minimo',
209:                         'Mínimo (piezas)',
210:                         _minimo,
211:                         formato: soloNumeros,
212:                         teclado: TextInputType.number,
213:                       ),
214:                     ]),
215:                     SwitchListTile.adaptive(
216:                       value: _porCaja,
217:                       onChanged: (v) => setState(() => _porCaja = v),
218:                       title: const Text('También se vende por caja'),
219:                       contentPadding: EdgeInsets.zero,
220:                       activeTrackColor: c.lager,
221:                     ),
222:                     if (_porCaja)
223:                       fila([
224:                         campo(
225:                           'precioCaja',
226:                           'Precio por caja',
227:                           _precioCaja,
228:                           formato: dinero,
229:                           prefijo: '\$ ',
230:                           teclado: const TextInputType.numberWithOptions(
231:                             decimal: true,
232:                           ),
233:                         ),
234:                         campo(
235:                           'piezasPorCaja',
236:                           'Piezas por caja',
237:                           _piezasPorCaja,
238:                           formato: soloNumeros,
239:                           teclado: TextInputType.number,
240:                         ),
241:                       ]),
242:                     campo(
243:                       'existenciaPiezas',
244:                       'Existencia inicial (piezas)',
245:                       _existencia,
246:                       formato: soloNumeros,
247:                       teclado: TextInputType.number,
248:                       ayuda: 'Queda registrada como movimiento de inventario',
249:                     ),
250:                     Text(
251:                       'Envase retornable',
252:                       style: textos.labelMedium?.copyWith(color: c.tinta2),
253:                     ),
254:                     SegmentedButton<String?>(
255:                       showSelectedIcon: false,
256:                       segments: const [
257:                         ButtonSegment(value: null, label: Text('Ninguno')),
258:                         ButtonSegment(value: 'mega', label: Text('Mega')),
259:                         ButtonSegment(value: 'media', label: Text('Media')),
260:                         ButtonSegment(value: 'cuarto', label: Text('Cuarto')),
261:                       ],
262:                       selected: {_envase},
263:                       onSelectionChanged: (s) =>
264:                           setState(() => _envase = s.first),
265:                       style: SegmentedButton.styleFrom(
266:                         selectedBackgroundColor: c.seleccion,
267:                         selectedForegroundColor: c.seleccionTinta,
268:                         side: BorderSide(color: c.linea),
269:                       ),
270:                     ),
271:                     OutlinedButton.icon(
272:                       onPressed: () async {
273:                         final hoy = DateTime.now();
274:                         final f = await showDatePicker(
275:                           context: context,
276:                           firstDate: hoy,
277:                           lastDate: DateTime(hoy.year + 5),
278:                           initialDate:
279:                               _caducidad ?? hoy.add(const Duration(days: 90)),
280:                         );
281:                         if (f != null) setState(() => _caducidad = f);
282:                       },
283:                       icon: const Icon(Icons.event_rounded),
284:                       label: Text(
285:                         _caducidad == null
286:                             ? 'Agregar caducidad (opcional)'
287:                             : 'Caduca el ${fechaCorta(_caducidad!.toIso8601String().substring(0, 10))} ${_caducidad!.year}',
288:                       ),
289:                     ),
290:                     if (_errores['caducidad'] case final e?)
291:                       Text(e, style: TextStyle(color: c.alerta)),
292:                   ],
293:                 ),
294:               ),
295:             ),
296:             Padding(
297:               padding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
298:               child: Row(
299:                 mainAxisAlignment: MainAxisAlignment.end,
300:                 spacing: 10,
301:                 children: [
302:                   OutlinedButton(
303:                     onPressed: _guardando ? null : () => Navigator.pop(context),
304:                     child: const Text('Cancelar'),
305:                   ),
306:                   FilledButton.icon(
307:                     onPressed: _guardando ? null : _guardar,
308:                     icon: _guardando
309:                         ? const SizedBox(
310:                             width: 18,
311:                             height: 18,
312:                             child: CircularProgressIndicator(strokeWidth: 2),
313:                           )
314:                         : const Icon(Icons.check_rounded),
315:                     label: const Text('Guardar producto'),
316:                   ),
317:                 ],
318:               ),
319:             ),
320:           ],
321:         ),
322:       ),
323:     );
324:   }
325: }
````

## File: app/lib/features/catalogo/pantallas/pantalla_catalogo.dart
````dart
 1: import 'package:flutter/material.dart';
 2: 
 3: import 'formulario_producto.dart';
 4: import 'vista_catalogo.dart';
 5: 
 6: /// Catálogo de la caja: el mismo de la terminal, más el alta de productos.
 7: class PantallaCatalogo extends StatelessWidget {
 8:   const PantallaCatalogo({super.key});
 9: 
10:   @override
11:   Widget build(BuildContext context) => VistaCatalogo(
12:     acciones: [
13:       FilledButton.icon(
14:         onPressed: () => abrirFormularioProducto(context),
15:         icon: const Icon(Icons.add_rounded),
16:         label: const Text('Nuevo producto'),
17:         style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
18:       ),
19:     ],
20:   );
21: }
````

## File: app/lib/features/catalogo/pantallas/vista_catalogo.dart
````dart
  1: import 'package:deposito_backend/deposito_backend.dart';
  2: import 'package:flutter/material.dart';
  3: import 'package:flutter_riverpod/flutter_riverpod.dart';
  4: 
  5: import '../../../app/tema/colores.dart';
  6: import '../../../core/formato/formato.dart';
  7: import '../../../core/widgets/estados.dart';
  8: import '../../../core/widgets/tarjeta_producto.dart';
  9: import '../estado/productos.dart';
 10: import 'detalle_producto.dart';
 11: 
 12: /// Búsqueda, filtros por categoría y cuadrícula de productos.
 13: /// La usan el Catálogo de la caja y la pestaña Productos de la terminal.
 14: class VistaCatalogo extends ConsumerStatefulWidget {
 15:   const VistaCatalogo({
 16:     super.key,
 17:     this.acciones = const [],
 18:     this.relleno = const EdgeInsets.fromLTRB(24, 20, 24, 0),
 19:   });
 20: 
 21:   /// Botones a la derecha de la búsqueda (por ejemplo, "Nuevo producto").
 22:   final List<Widget> acciones;
 23:   final EdgeInsets relleno;
 24: 
 25:   @override
 26:   ConsumerState<VistaCatalogo> createState() => _VistaCatalogoState();
 27: }
 28: 
 29: class _VistaCatalogoState extends ConsumerState<VistaCatalogo> {
 30:   final _busqueda = TextEditingController();
 31:   String? _categoria;
 32: 
 33:   @override
 34:   void dispose() {
 35:     _busqueda.dispose();
 36:     super.dispose();
 37:   }
 38: 
 39:   @override
 40:   Widget build(BuildContext context) {
 41:     final productos = ref.watch(productosProvider);
 42:     final c = context.colores;
 43: 
 44:     return Padding(
 45:       padding: widget.relleno,
 46:       child: Column(
 47:         crossAxisAlignment: CrossAxisAlignment.stretch,
 48:         children: [
 49:           Row(
 50:             children: [
 51:               Expanded(
 52:                 child: TextField(
 53:                   controller: _busqueda,
 54:                   onChanged: (_) => setState(() {}),
 55:                   textInputAction: TextInputAction.search,
 56:                   decoration: InputDecoration(
 57:                     hintText: 'Buscar por nombre o código',
 58:                     prefixIcon: Icon(Icons.search_rounded, color: c.tinta2),
 59:                     suffixIcon: _busqueda.text.isEmpty
 60:                         ? null
 61:                         : IconButton(
 62:                             tooltip: 'Borrar',
 63:                             icon: const Icon(Icons.close_rounded),
 64:                             onPressed: () => setState(_busqueda.clear),
 65:                           ),
 66:                   ),
 67:                 ),
 68:               ),
 69:               for (final a in widget.acciones) ...[
 70:                 const SizedBox(width: 10),
 71:                 a,
 72:               ],
 73:             ],
 74:           ),
 75:           const SizedBox(height: 12),
 76:           if (productos.value case final lista? when lista.isNotEmpty)
 77:             _Categorias(
 78:               categorias: categoriasDe(lista),
 79:               seleccion: _categoria,
 80:               alElegir: (cat) => setState(() => _categoria = cat),
 81:             ),
 82:           const SizedBox(height: 14),
 83:           Expanded(
 84:             child: switch (productos) {
 85:               AsyncData(:final value) => _Cuadricula(
 86:                 productos: filtrarProductos(
 87:                   value,
 88:                   busqueda: _busqueda.text,
 89:                   categoria: _categoria,
 90:                 ),
 91:                 hayCatalogo: value.isNotEmpty,
 92:               ),
 93:               AsyncError(:final error) => EstadoError(
 94:                 error: error,
 95:                 alReintentar: () => ref.invalidate(productosProvider),
 96:               ),
 97:               _ => const Cargando(mensaje: 'Cargando catálogo'),
 98:             },
 99:           ),
100:         ],
101:       ),
102:     );
103:   }
104: }
105: 
106: class _Categorias extends StatelessWidget {
107:   const _Categorias({
108:     required this.categorias,
109:     required this.seleccion,
110:     required this.alElegir,
111:   });
112: 
113:   final List<String> categorias;
114:   final String? seleccion;
115:   final ValueChanged<String?> alElegir;
116: 
117:   @override
118:   Widget build(BuildContext context) {
119:     final c = context.colores;
120:     Widget chip(String texto, String? valor) {
121:       final activo = seleccion == valor;
122:       return Padding(
123:         padding: const EdgeInsets.only(right: 8),
124:         child: ChoiceChip(
125:           label: Text(texto),
126:           selected: activo,
127:           onSelected: (_) => alElegir(valor),
128:           labelStyle: TextStyle(
129:             fontWeight: activo ? FontWeight.w600 : FontWeight.w500,
130:             color: activo ? c.seleccionTinta : c.tinta,
131:           ),
132:         ),
133:       );
134:     }
135: 
136:     return SizedBox(
137:       height: 42,
138:       child: ListView(
139:         scrollDirection: Axis.horizontal,
140:         children: [
141:           chip('Todos', null),
142:           for (final cat in categorias) chip(capitalizar(cat), cat),
143:         ],
144:       ),
145:     );
146:   }
147: }
148: 
149: class _Cuadricula extends ConsumerWidget {
150:   const _Cuadricula({required this.productos, required this.hayCatalogo});
151: 
152:   final List<Producto> productos;
153:   final bool hayCatalogo;
154: 
155:   @override
156:   Widget build(BuildContext context, WidgetRef ref) {
157:     if (productos.isEmpty) {
158:       return hayCatalogo
159:           ? const EstadoVacio(
160:               icono: Icons.search_off_rounded,
161:               titulo: 'Sin resultados',
162:               mensaje: 'Ningún producto coincide con la búsqueda.',
163:             )
164:           : const EstadoVacio(
165:               icono: Icons.inventory_2_outlined,
166:               titulo: 'El catálogo está vacío',
167:               mensaje: 'Agrega el primer producto desde la caja.',
168:             );
169:     }
170:     return RefreshIndicator(
171:       onRefresh: () => ref.read(productosProvider.notifier).refrescar(),
172:       child: GridView.builder(
173:         padding: const EdgeInsets.only(bottom: 24),
174:         gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
175:           maxCrossAxisExtent: 200,
176:           mainAxisExtent: 250,
177:           crossAxisSpacing: 12,
178:           mainAxisSpacing: 12,
179:         ),
180:         itemCount: productos.length,
181:         itemBuilder: (context, i) => TarjetaProducto(
182:           key: ValueKey(productos[i].id),
183:           producto: productos[i],
184:           alTocar: () => mostrarDetalleProducto(context, productos[i]),
185:         ),
186:       ),
187:     );
188:   }
189: }
````

## File: app/lib/features/inicio/elegir_modo.dart
````dart
  1: import 'package:flutter/material.dart';
  2: import 'package:flutter_riverpod/flutter_riverpod.dart';
  3: 
  4: import '../../app/tema/colores.dart';
  5: import '../../core/config/configuracion.dart';
  6: import '../../core/widgets/marca.dart';
  7: 
  8: /// Primera pantalla: ¿este dispositivo es la caja o una terminal?
  9: class ElegirModo extends ConsumerWidget {
 10:   const ElegirModo({super.key});
 11: 
 12:   @override
 13:   Widget build(BuildContext context, WidgetRef ref) {
 14:     final c = context.colores;
 15:     final textos = Theme.of(context).textTheme;
 16:     final notificador = ref.read(configuracionProvider.notifier);
 17: 
 18:     return Scaffold(
 19:       body: SafeArea(
 20:         child: LayoutBuilder(
 21:           builder: (context, medidas) {
 22:             final ancho = medidas.maxWidth >= 760;
 23:             final opciones = [
 24:               _Opcion(
 25:                 icono: Icons.point_of_sale_rounded,
 26:                 titulo: 'Caja',
 27:                 texto: 'Guarda la base de datos, cobra y recibe a las terminales. Debe quedarse encendida con la app abierta.',
 28:                 alElegir: () => notificador.elegirModo(ModoDispositivo.caja),
 29:               ),
 30:               _Opcion(
 31:                 icono: Icons.smartphone_rounded,
 32:                 titulo: 'Terminal',
 33:                 texto: 'Escanea productos, arma pedidos y consulta existencias en los pasillos. Se conecta a la caja por Wi-Fi.',
 34:                 alElegir: () =>
 35:                     notificador.elegirModo(ModoDispositivo.terminal),
 36:               ),
 37:             ];
 38:             return SingleChildScrollView(
 39:               padding: EdgeInsets.symmetric(
 40:                 horizontal: ancho ? 48 : 22,
 41:                 vertical: 40,
 42:               ),
 43:               child: Center(
 44:                 child: ConstrainedBox(
 45:                   constraints: const BoxConstraints(maxWidth: 880),
 46:                   child: Column(
 47:                     crossAxisAlignment: CrossAxisAlignment.start,
 48:                     children: [
 49:                       Row(
 50:                         children: [
 51:                           const LogoAnaquel(tamano: 52),
 52:                           const SizedBox(width: 14),
 53:                           Text('Anaquel', style: textos.headlineLarge),
 54:                         ],
 55:                       ),
 56:                       const SizedBox(height: 36),
 57:                       Flex(
 58:                         direction: ancho ? Axis.horizontal : Axis.vertical,
 59:                         crossAxisAlignment: ancho
 60:                             ? CrossAxisAlignment.center
 61:                             : CrossAxisAlignment.start,
 62:                         children: [
 63:                           Flexible(
 64:                             fit: FlexFit.loose,
 65:                             child: Column(
 66:                               crossAxisAlignment: CrossAxisAlignment.start,
 67:                               children: [
 68:                                 Text(
 69:                                   'Punto de venta\ndel depósito',
 70:                                   style: ancho
 71:                                       ? textos.displayLarge
 72:                                       : textos.displayMedium,
 73:                                 ),
 74:                                 const SizedBox(height: 14),
 75:                                 Text(
 76:                                   'Ventas, inventario y envases en tiempo real entre la caja y los teléfonos del equipo. '
 77:                                   'Para empezar, dinos cómo se usará este dispositivo; puedes cambiarlo después en Ajustes.',
 78:                                   style: textos.bodyLarge?.copyWith(
 79:                                     color: c.tinta2,
 80:                                   ),
 81:                                 ),
 82:                               ],
 83:                             ),
 84:                           ),
 85:                           if (ancho) ...[
 86:                             const SizedBox(width: 40),
 87:                             const _Escena(),
 88:                           ],
 89:                         ],
 90:                       ),
 91:                       const SizedBox(height: 36),
 92:                       if (ancho)
 93:                         IntrinsicHeight(
 94:                           child: Row(
 95:                             crossAxisAlignment: CrossAxisAlignment.stretch,
 96:                             children: [
 97:                               Expanded(child: opciones[0]),
 98:                               const SizedBox(width: 18),
 99:                               Expanded(child: opciones[1]),
100:                             ],
101:                           ),
102:                         )
103:                       else
104:                         Column(spacing: 14, children: opciones),
105:                     ],
106:                   ),
107:                 ),
108:               ),
109:             );
110:           },
111:         ),
112:       ),
113:     );
114:   }
115: }
116: 
117: class _Opcion extends StatelessWidget {
118:   const _Opcion({
119:     required this.icono,
120:     required this.titulo,
121:     required this.texto,
122:     required this.alElegir,
123:   });
124: 
125:   final IconData icono;
126:   final String titulo;
127:   final String texto;
128:   final VoidCallback alElegir;
129: 
130:   @override
131:   Widget build(BuildContext context) {
132:     final c = context.colores;
133:     final textos = Theme.of(context).textTheme;
134:     return Material(
135:       type: MaterialType.transparency,
136:       child: Ink(
137:         decoration: BoxDecoration(
138:           color: c.superficie,
139:           borderRadius: BorderRadius.circular(18),
140:           border: Border.all(color: c.linea),
141:           boxShadow: c.sombra,
142:         ),
143:         child: InkWell(
144:           onTap: alElegir,
145:           borderRadius: BorderRadius.circular(18),
146:           child: Padding(
147:             padding: const EdgeInsets.all(22),
148:             child: Row(
149:               crossAxisAlignment: CrossAxisAlignment.start,
150:               children: [
151:                 Container(
152:                   width: 56,
153:                   height: 56,
154:                   decoration: BoxDecoration(
155:                     color: c.lager,
156:                     borderRadius: BorderRadius.circular(16),
157:                   ),
158:                   child: Icon(icono, color: c.lagerTinta, size: 28),
159:                 ),
160:                 const SizedBox(width: 16),
161:                 Expanded(
162:                   child: Column(
163:                     crossAxisAlignment: CrossAxisAlignment.start,
164:                     children: [
165:                       Row(
166:                         children: [
167:                           Expanded(
168:                             child: Text(titulo, style: textos.headlineMedium),
169:                           ),
170:                           Icon(Icons.arrow_forward_rounded, color: c.tinta2),
171:                         ],
172:                       ),
173:                       const SizedBox(height: 6),
174:                       Text(
175:                         texto,
176:                         style: textos.bodyMedium?.copyWith(color: c.tinta2),
177:                       ),
178:                     ],
179:                   ),
180:                 ),
181:               ],
182:             ),
183:           ),
184:         ),
185:       ),
186:     );
187:   }
188: }
189: 
190: /// Dibujo de un iPad y un teléfono conectados por Wi-Fi.
191: class _Escena extends StatelessWidget {
192:   const _Escena();
193: 
194:   @override
195:   Widget build(BuildContext context) {
196:     final c = context.colores;
197:     Widget celda() => Container(
198:       decoration: BoxDecoration(
199:         color: c.superficie2,
200:         borderRadius: BorderRadius.circular(5),
201:       ),
202:       child: Center(
203:         child: Container(
204:           width: 6,
205:           height: 16,
206:           decoration: BoxDecoration(
207:             color: c.lager,
208:             borderRadius: BorderRadius.circular(3),
209:           ),
210:         ),
211:       ),
212:     );
213:     return SizedBox(
214:       width: 300,
215:       height: 200,
216:       child: Stack(
217:         children: [
218:           Positioned(
219:             left: 0,
220:             top: 24,
221:             child: Container(
222:               width: 210,
223:               height: 150,
224:               padding: const EdgeInsets.all(7),
225:               decoration: BoxDecoration(
226:                 color: c.tinta,
227:                 borderRadius: BorderRadius.circular(16),
228:                 boxShadow: c.sombra,
229:               ),
230:               child: ClipRRect(
231:                 borderRadius: BorderRadius.circular(10),
232:                 child: Row(
233:                   children: [
234:                     Container(
235:                       width: 38,
236:                       color: c.vidrio,
237:                       padding: const EdgeInsets.all(6),
238:                       child: Column(
239:                         spacing: 6,
240:                         children: [
241:                           Container(
242:                             height: 6,
243:                             decoration: BoxDecoration(
244:                               color: c.lager,
245:                               borderRadius: BorderRadius.circular(3),
246:                             ),
247:                           ),
248:                           for (var i = 0; i < 4; i++)
249:                             Container(
250:                               height: 4,
251:                               decoration: BoxDecoration(
252:                                 color: c.vidrioTinta2,
253:                                 borderRadius: BorderRadius.circular(2),
254:                               ),
255:                             ),
256:                         ],
257:                       ),
258:                     ),
259:                     Expanded(
260:                       child: Container(
261:                         color: c.fondo,
262:                         padding: const EdgeInsets.all(7),
263:                         child: GridView.count(
264:                           crossAxisCount: 3,
265:                           mainAxisSpacing: 6,
266:                           crossAxisSpacing: 6,
267:                           physics: const NeverScrollableScrollPhysics(),
268:                           children: List.generate(6, (_) => celda()),
269:                         ),
270:                       ),
271:                     ),
272:                   ],
273:                 ),
274:               ),
275:             ),
276:           ),
277:           Positioned(
278:             right: 8,
279:             top: 60,
280:             child: Container(
281:               width: 72,
282:               height: 132,
283:               padding: const EdgeInsets.all(5),
284:               decoration: BoxDecoration(
285:                 color: c.tinta,
286:                 borderRadius: BorderRadius.circular(14),
287:                 boxShadow: c.sombra,
288:               ),
289:               child: ClipRRect(
290:                 borderRadius: BorderRadius.circular(10),
291:                 child: Column(
292:                   children: [
293:                     Container(height: 20, color: c.vidrio),
294:                     Expanded(
295:                       child: Container(
296:                         color: c.fondo,
297:                         padding: const EdgeInsets.all(8),
298:                         child: Column(
299:                           spacing: 6,
300:                           children: [
301:                             Expanded(child: celda()),
302:                             Container(
303:                               height: 7,
304:                               decoration: BoxDecoration(
305:                                 color: c.lager,
306:                                 borderRadius: BorderRadius.circular(3),
307:                               ),
308:                             ),
309:                             Container(
310:                               height: 5,
311:                               decoration: BoxDecoration(
312:                                 color: c.superficie3,
313:                                 borderRadius: BorderRadius.circular(3),
314:                               ),
315:                             ),
316:                           ],
317:                         ),
318:                       ),
319:                     ),
320:                   ],
321:                 ),
322:               ),
323:             ),
324:           ),
325:           Positioned(
326:             right: 26,
327:             top: 14,
328:             child: Icon(Icons.wifi_rounded, size: 40, color: c.verde),
329:           ),
330:         ],
331:       ),
332:     );
333:   }
334: }
````

## File: app/lib/features/proximamente/proximamente.dart
````dart
 1: import 'package:flutter/material.dart';
 2: 
 3: import '../../app/tema/colores.dart';
 4: 
 5: /// Sección planeada pero todavía no construida. Dice en qué sprint llega y
 6: /// quién la hace, según docs/PLAN_DE_TRABAJO.md.
 7: class Proximamente extends StatelessWidget {
 8:   const Proximamente({
 9:     super.key,
10:     required this.icono,
11:     required this.titulo,
12:     required this.descripcion,
13:     required this.sprint,
14:     required this.responsable,
15:   });
16: 
17:   final IconData icono;
18:   final String titulo;
19:   final String descripcion;
20:   final int sprint;
21:   final String responsable;
22: 
23:   @override
24:   Widget build(BuildContext context) {
25:     final c = context.colores;
26:     final textos = Theme.of(context).textTheme;
27:     return Center(
28:       child: Padding(
29:         padding: const EdgeInsets.all(32),
30:         child: ConstrainedBox(
31:           constraints: const BoxConstraints(maxWidth: 440),
32:           child: Column(
33:             mainAxisSize: MainAxisSize.min,
34:             children: [
35:               Container(
36:                 width: 84,
37:                 height: 84,
38:                 decoration: BoxDecoration(
39:                   color: c.lagerSuave,
40:                   borderRadius: BorderRadius.circular(24),
41:                 ),
42:                 child: Icon(icono, size: 40, color: c.tinta),
43:               ),
44:               const SizedBox(height: 20),
45:               Text(
46:                 titulo,
47:                 style: textos.displaySmall,
48:                 textAlign: TextAlign.center,
49:               ),
50:               const SizedBox(height: 8),
51:               Text(
52:                 descripcion,
53:                 style: textos.bodyLarge?.copyWith(color: c.tinta2),
54:                 textAlign: TextAlign.center,
55:               ),
56:               const SizedBox(height: 20),
57:               Container(
58:                 padding: const EdgeInsets.symmetric(
59:                   horizontal: 14,
60:                   vertical: 8,
61:                 ),
62:                 decoration: BoxDecoration(
63:                   color: c.superficie,
64:                   border: Border.all(color: c.linea),
65:                   borderRadius: BorderRadius.circular(999),
66:                 ),
67:                 child: Text(
68:                   'Llega en el Sprint $sprint · $responsable',
69:                   style: TextStyle(
70:                     fontWeight: FontWeight.w600,
71:                     color: c.tinta2,
72:                   ),
73:                 ),
74:               ),
75:             ],
76:           ),
77:         ),
78:       ),
79:     );
80:   }
81: }
````

## File: app/lib/features/terminal/pantallas/escanear.dart
````dart
  1: import 'package:deposito_backend/deposito_backend.dart';
  2: import 'package:flutter/material.dart';
  3: import 'package:flutter_riverpod/flutter_riverpod.dart';
  4: 
  5: import '../../../app/tema/colores.dart';
  6: import '../../../core/formato/formato.dart';
  7: import '../../../core/widgets/estados.dart';
  8: import '../../../core/widgets/ilustracion_producto.dart';
  9: import '../../catalogo/estado/productos.dart';
 10: import 'escaner.dart';
 11: 
 12: /// Escanear un producto para ver precio y existencia al momento.
 13: ///
 14: /// Busca en el catálogo que ya está en memoria (se mantiene al día por
 15: /// WebSocket). `GET /productos/codigo/{codigo}` llega en el Sprint 2.
 16: class PantallaEscanear extends ConsumerStatefulWidget {
 17:   const PantallaEscanear({super.key});
 18: 
 19:   @override
 20:   ConsumerState<PantallaEscanear> createState() => _PantallaEscanearState();
 21: }
 22: 
 23: class _PantallaEscanearState extends ConsumerState<PantallaEscanear> {
 24:   final _codigo = TextEditingController();
 25:   String? _buscado;
 26: 
 27:   @override
 28:   void dispose() {
 29:     _codigo.dispose();
 30:     super.dispose();
 31:   }
 32: 
 33:   Future<void> _abrirCamara() async {
 34:     final codigo = await escanearCodigo(context, titulo: 'Escanear producto');
 35:     if (codigo != null) _buscar(codigo);
 36:   }
 37: 
 38:   void _buscar(String codigo) {
 39:     _codigo.text = codigo.trim();
 40:     setState(() => _buscado = codigo.trim());
 41:     FocusScope.of(context).unfocus();
 42:   }
 43: 
 44:   @override
 45:   Widget build(BuildContext context) {
 46:     final c = context.colores;
 47:     final textos = Theme.of(context).textTheme;
 48:     final productos = ref.watch(productosProvider);
 49:     final buscado = _buscado;
 50: 
 51:     return ListView(
 52:       padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
 53:       children: [
 54:         Material(
 55:           color: c.superficie,
 56:           borderRadius: BorderRadius.circular(18),
 57:           child: InkWell(
 58:             borderRadius: BorderRadius.circular(18),
 59:             onTap: _abrirCamara,
 60:             child: CustomPaint(
 61:               painter: _BordePunteado(c.lager),
 62:               child: SizedBox(
 63:                 height: 140,
 64:                 child: Column(
 65:                   mainAxisAlignment: MainAxisAlignment.center,
 66:                   children: [
 67:                     Icon(
 68:                       Icons.qr_code_scanner_rounded,
 69:                       size: 40,
 70:                       color: c.tinta,
 71:                     ),
 72:                     const SizedBox(height: 10),
 73:                     Text(
 74:                       'Abrir cámara',
 75:                       style: textos.titleMedium?.copyWith(fontSize: 19),
 76:                     ),
 77:                   ],
 78:                 ),
 79:               ),
 80:             ),
 81:           ),
 82:         ),
 83:         const SizedBox(height: 14),
 84:         Row(
 85:           children: [
 86:             Expanded(
 87:               child: TextField(
 88:                 controller: _codigo,
 89:                 keyboardType: TextInputType.number,
 90:                 textInputAction: TextInputAction.search,
 91:                 onSubmitted: _buscar,
 92:                 decoration: const InputDecoration(
 93:                   hintText: 'O escribe el código',
 94:                 ),
 95:               ),
 96:             ),
 97:             const SizedBox(width: 10),
 98:             FilledButton(
 99:               onPressed: () => _buscar(_codigo.text),
100:               style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
101:               child: const Text('Buscar'),
102:             ),
103:           ],
104:         ),
105:         const SizedBox(height: 18),
106:         switch ((productos, buscado)) {
107:           (AsyncError(:final error), _) => EstadoError(
108:             error: error,
109:             alReintentar: () => ref.invalidate(productosProvider),
110:           ),
111:           (_, null) => const EstadoVacio(
112:             icono: Icons.inventory_2_outlined,
113:             titulo: 'Listo para escanear',
114:             mensaje: 'Escanea un producto para ver su precio y existencia en tiempo real.',
115:           ),
116:           (AsyncData(:final value), final String codigo) => switch (porCodigo(
117:             value,
118:             codigo,
119:           )) {
120:             final Producto p => _Resultado(producto: p),
121:             null => EstadoVacio(
122:               icono: Icons.search_off_rounded,
123:               titulo: 'Código no registrado',
124:               mensaje:
125:                   'El código $codigo no está en el catálogo. Pide en la caja que lo den de alta.',
126:             ),
127:           },
128:           _ => const Padding(padding: EdgeInsets.all(32), child: Cargando()),
129:         },
130:       ],
131:     );
132:   }
133: }
134: 
135: class _Resultado extends StatelessWidget {
136:   const _Resultado({required this.producto});
137: 
138:   final Producto producto;
139: 
140:   @override
141:   Widget build(BuildContext context) {
142:     final c = context.colores;
143:     final textos = Theme.of(context).textTheme;
144:     final p = producto;
145:     return Container(
146:       padding: const EdgeInsets.all(16),
147:       decoration: BoxDecoration(
148:         color: c.superficie,
149:         borderRadius: BorderRadius.circular(18),
150:         border: Border.all(color: c.linea),
151:         boxShadow: c.sombra,
152:       ),
153:       child: Column(
154:         crossAxisAlignment: CrossAxisAlignment.stretch,
155:         children: [
156:           Row(
157:             children: [
158:               SizedBox(
159:                 width: 92,
160:                 height: 104,
161:                 child: IlustracionProducto(producto: p),
162:               ),
163:               const SizedBox(width: 14),
164:               Expanded(
165:                 child: Column(
166:                   crossAxisAlignment: CrossAxisAlignment.start,
167:                   children: [
168:                     Text(p.nombre, style: textos.headlineSmall),
169:                     if (p.presentacion != null)
170:                       Text(p.presentacion!, style: textos.bodySmall),
171:                     const SizedBox(height: 6),
172:                     Text(dinero(p.precio), style: textos.displaySmall),
173:                     if (p.precioCaja != null)
174:                       Text(
175:                         'Caja de ${p.piezasPorCaja}: ${dinero(p.precioCaja!)}',
176:                         style: textos.bodyMedium?.copyWith(color: c.tinta2),
177:                       ),
178:                   ],
179:                 ),
180:               ),
181:             ],
182:           ),
183:           const SizedBox(height: 14),
184:           Container(
185:             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
186:             decoration: BoxDecoration(
187:               color: p.bajoMinimo ? c.alertaSuave : c.verdeSuave,
188:               borderRadius: BorderRadius.circular(12),
189:             ),
190:             child: Row(
191:               children: [
192:                 Icon(
193:                   p.bajoMinimo
194:                       ? Icons.warning_amber_rounded
195:                       : Icons.inventory_rounded,
196:                   color: p.bajoMinimo ? c.alerta : c.verde,
197:                 ),
198:                 const SizedBox(width: 10),
199:                 Expanded(
200:                   child: Text(
201:                     'Hay ${existenciaLegible(p)}',
202:                     style: TextStyle(
203:                       fontWeight: FontWeight.w600,
204:                       color: p.bajoMinimo ? c.alerta : c.verde,
205:                     ),
206:                   ),
207:                 ),
208:                 Text(
209:                   '${p.existenciaPiezas} pz',
210:                   style: textos.titleLarge?.copyWith(
211:                     color: p.bajoMinimo ? c.alerta : c.verde,
212:                   ),
213:                 ),
214:               ],
215:             ),
216:           ),
217:         ],
218:       ),
219:     );
220:   }
221: }
222: 
223: class _BordePunteado extends CustomPainter {
224:   _BordePunteado(this.color);
225: 
226:   final Color color;
227: 
228:   @override
229:   void paint(Canvas canvas, Size s) {
230:     final pincel = Paint()
231:       ..color = color
232:       ..style = PaintingStyle.stroke
233:       ..strokeWidth = 2;
234:     final ruta = Path()
235:       ..addRRect(
236:         RRect.fromRectAndRadius(Offset.zero & s, const Radius.circular(18)),
237:       );
238:     for (final m in ruta.computeMetrics()) {
239:       for (var d = 0.0; d < m.length; d += 14) {
240:         canvas.drawPath(m.extractPath(d, d + 8), pincel);
241:       }
242:     }
243:   }
244: 
245:   @override
246:   bool shouldRepaint(_BordePunteado old) => old.color != color;
247: }
````

## File: app/lib/features/terminal/pantallas/escaner.dart
````dart
  1: import 'package:flutter/material.dart';
  2: import 'package:mobile_scanner/mobile_scanner.dart';
  3: 
  4: import '../../../app/tema/colores.dart';
  5: 
  6: /// Abre la cámara a pantalla completa y regresa el primer código leído
  7: /// (código de barras o QR), o `null` si se cierra.
  8: Future<String?> escanearCodigo(
  9:   BuildContext context, {
 10:   required String titulo,
 11:   String? ayuda,
 12: }) => Navigator.of(context, rootNavigator: true).push<String>(
 13:   MaterialPageRoute(
 14:     fullscreenDialog: true,
 15:     builder: (_) => PantallaEscaner(titulo: titulo, ayuda: ayuda),
 16:   ),
 17: );
 18: 
 19: class PantallaEscaner extends StatefulWidget {
 20:   const PantallaEscaner({super.key, required this.titulo, this.ayuda});
 21: 
 22:   final String titulo;
 23:   final String? ayuda;
 24: 
 25:   @override
 26:   State<PantallaEscaner> createState() => _PantallaEscanerState();
 27: }
 28: 
 29: class _PantallaEscanerState extends State<PantallaEscaner> {
 30:   final _control = MobileScannerController(
 31:     detectionSpeed: DetectionSpeed.noDuplicates,
 32:   );
 33:   var _listo = false;
 34: 
 35:   @override
 36:   void dispose() {
 37:     _control.dispose();
 38:     super.dispose();
 39:   }
 40: 
 41:   @override
 42:   Widget build(BuildContext context) {
 43:     final c = context.colores;
 44:     return Scaffold(
 45:       backgroundColor: Colors.black,
 46:       body: Stack(
 47:         fit: StackFit.expand,
 48:         children: [
 49:           MobileScanner(
 50:             controller: _control,
 51:             onDetect: (captura) {
 52:               final valor = captura.barcodes.firstOrNull?.rawValue;
 53:               if (_listo || valor == null || valor.isEmpty) return;
 54:               _listo = true;
 55:               Navigator.pop(context, valor);
 56:             },
 57:             errorBuilder: (context, error) => Center(
 58:               child: Padding(
 59:                 padding: const EdgeInsets.all(32),
 60:                 child: Text(
 61:                   error.errorCode == MobileScannerErrorCode.permissionDenied
 62:                       ? 'Permite el uso de la cámara en los ajustes del teléfono para escanear.'
 63:                       : 'No se pudo abrir la cámara.',
 64:                   style: const TextStyle(color: Colors.white, fontSize: 17),
 65:                   textAlign: TextAlign.center,
 66:                 ),
 67:               ),
 68:             ),
 69:           ),
 70:           // Marco de enfoque.
 71:           Center(
 72:             child: Container(
 73:               width: 260,
 74:               height: 200,
 75:               decoration: BoxDecoration(
 76:                 border: Border.all(color: c.lager, width: 3),
 77:                 borderRadius: BorderRadius.circular(20),
 78:               ),
 79:             ),
 80:           ),
 81:           SafeArea(
 82:             child: Padding(
 83:               padding: const EdgeInsets.all(16),
 84:               child: Column(
 85:                 children: [
 86:                   Row(
 87:                     children: [
 88:                       IconButton.filled(
 89:                         style: IconButton.styleFrom(
 90:                           backgroundColor: Colors.black54,
 91:                           foregroundColor: Colors.white,
 92:                         ),
 93:                         onPressed: () => Navigator.pop(context),
 94:                         icon: const Icon(Icons.close_rounded),
 95:                         tooltip: 'Cerrar',
 96:                       ),
 97:                       const SizedBox(width: 12),
 98:                       Expanded(
 99:                         child: Text(
100:                           widget.titulo,
101:                           style: Theme.of(context).textTheme.headlineSmall
102:                               ?.copyWith(color: Colors.white),
103:                         ),
104:                       ),
105:                       IconButton.filled(
106:                         style: IconButton.styleFrom(
107:                           backgroundColor: Colors.black54,
108:                           foregroundColor: Colors.white,
109:                         ),
110:                         onPressed: _control.toggleTorch,
111:                         icon: const Icon(Icons.flashlight_on_rounded),
112:                         tooltip: 'Linterna',
113:                       ),
114:                     ],
115:                   ),
116:                   const Spacer(),
117:                   if (widget.ayuda != null)
118:                     Container(
119:                       padding: const EdgeInsets.symmetric(
120:                         horizontal: 16,
121:                         vertical: 10,
122:                       ),
123:                       decoration: BoxDecoration(
124:                         color: Colors.black54,
125:                         borderRadius: BorderRadius.circular(12),
126:                       ),
127:                       child: Text(
128:                         widget.ayuda!,
129:                         style: const TextStyle(color: Colors.white),
130:                         textAlign: TextAlign.center,
131:                       ),
132:                     ),
133:                 ],
134:               ),
135:             ),
136:           ),
137:         ],
138:       ),
139:     );
140:   }
141: }
````

## File: app/lib/features/terminal/pantallas/shell_terminal.dart
````dart
  1: import 'package:flutter/material.dart';
  2: import 'package:flutter_riverpod/flutter_riverpod.dart';
  3: import 'package:go_router/go_router.dart';
  4: 
  5: import '../../../app/tema/colores.dart';
  6: import '../../../core/api/fallo_api.dart';
  7: import '../../../core/config/configuracion.dart';
  8: import '../../../core/widgets/indicador_conexion.dart';
  9: import '../../catalogo/estado/productos.dart';
 10: 
 11: class _Pestana {
 12:   const _Pestana(this.ruta, this.titulo, this.icono, this.iconoActivo);
 13: 
 14:   final String ruta;
 15:   final String titulo;
 16:   final IconData icono;
 17:   final IconData iconoActivo;
 18: }
 19: 
 20: const _pestanas = [
 21:   _Pestana(
 22:     'escanear',
 23:     'Escanear',
 24:     Icons.qr_code_scanner_outlined,
 25:     Icons.qr_code_scanner_rounded,
 26:   ),
 27:   _Pestana(
 28:     'productos',
 29:     'Productos',
 30:     Icons.grid_view_outlined,
 31:     Icons.grid_view_rounded,
 32:   ),
 33:   _Pestana('pedido', 'Pedido', Icons.receipt_outlined, Icons.receipt_rounded),
 34:   _Pestana(
 35:     'ajustes',
 36:     'Ajustes',
 37:     Icons.settings_outlined,
 38:     Icons.settings_rounded,
 39:   ),
 40: ];
 41: 
 42: /// Marco de la terminal: encabezado café con el estado de la conexión y
 43: /// pestañas abajo, a la mano del pulgar.
 44: class ShellTerminal extends ConsumerWidget {
 45:   const ShellTerminal({super.key, required this.seccion, required this.child});
 46: 
 47:   final String seccion;
 48:   final Widget child;
 49: 
 50:   @override
 51:   Widget build(BuildContext context, WidgetRef ref) {
 52:     final c = context.colores;
 53:     final nombre =
 54:         ref.watch(configuracionProvider).conexion?.nombre ?? 'Terminal';
 55:     final indice = _pestanas
 56:         .indexWhere((p) => p.ruta == seccion)
 57:         .clamp(0, _pestanas.length - 1);
 58:     final error = ref.watch(productosProvider).error;
 59:     final revocada = error is FalloApi && error.noAutorizado;
 60: 
 61:     return Scaffold(
 62:       body: Column(
 63:         children: [
 64:           Container(
 65:             color: c.vidrio,
 66:             child: SafeArea(
 67:               bottom: false,
 68:               child: Padding(
 69:                 padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
 70:                 child: Row(
 71:                   children: [
 72:                     Expanded(
 73:                       child: Column(
 74:                         crossAxisAlignment: CrossAxisAlignment.start,
 75:                         children: [
 76:                           Text(
 77:                             _pestanas[indice].titulo,
 78:                             style: Theme.of(context).textTheme.headlineLarge
 79:                                 ?.copyWith(color: c.vidrioTinta),
 80:                           ),
 81:                           const SizedBox(height: 4),
 82:                           IndicadorConexion(
 83:                             colorTexto: c.vidrioTinta2,
 84:                             etiquetaEnLinea: '$nombre, conectada a la caja',
 85:                           ),
 86:                         ],
 87:                       ),
 88:                     ),
 89:                   ],
 90:                 ),
 91:               ),
 92:             ),
 93:           ),
 94:           if (revocada)
 95:             MaterialBanner(
 96:               backgroundColor: c.alertaSuave,
 97:               content: Text(
 98:                 'La caja desvinculó esta terminal. Vuelve a escanear el código de la caja.',
 99:                 style: TextStyle(color: c.alerta, fontWeight: FontWeight.w500),
100:               ),
101:               actions: [
102:                 TextButton(
103:                   onPressed: () => ref
104:                       .read(configuracionProvider.notifier)
105:                       .olvidarConexion(),
106:                   child: const Text('Vincular de nuevo'),
107:                 ),
108:               ],
109:             ),
110:           Expanded(child: child),
111:         ],
112:       ),
113:       bottomNavigationBar: NavigationBar(
114:         selectedIndex: indice,
115:         onDestinationSelected: (i) =>
116:             context.go('/terminal/${_pestanas[i].ruta}'),
117:         destinations: [
118:           for (final p in _pestanas)
119:             NavigationDestination(
120:               icon: Icon(p.icono),
121:               selectedIcon: Icon(p.iconoActivo),
122:               label: p.titulo,
123:             ),
124:         ],
125:       ),
126:     );
127:   }
128: }
````

## File: app/lib/features/terminal/pantallas/vincular_terminal.dart
````dart
  1: import 'dart:convert';
  2: import 'dart:io';
  3: 
  4: import 'package:flutter/material.dart';
  5: import 'package:flutter/services.dart';
  6: import 'package:flutter_riverpod/flutter_riverpod.dart';
  7: 
  8: import '../../../app/tema/colores.dart';
  9: import '../../../core/api/api.dart';
 10: import '../../../core/api/fallo_api.dart';
 11: import '../../../core/config/configuracion.dart';
 12: import '../../../core/widgets/marca.dart';
 13: import 'escaner.dart';
 14: 
 15: /// Vincula esta terminal con la caja: escaneando el QR que muestra la caja
 16: /// o escribiendo IP y código a mano (útil con el servidor de la laptop).
 17: class VincularTerminal extends ConsumerStatefulWidget {
 18:   const VincularTerminal({super.key});
 19: 
 20:   @override
 21:   ConsumerState<VincularTerminal> createState() => _VincularTerminalState();
 22: }
 23: 
 24: class _VincularTerminalState extends ConsumerState<VincularTerminal> {
 25:   final _nombre = TextEditingController(
 26:     text: Platform.isIOS ? 'iPhone' : 'Terminal S24',
 27:   );
 28:   final _host = TextEditingController();
 29:   final _puerto = TextEditingController(text: '8080');
 30:   final _codigo = TextEditingController();
 31:   var _manual = false;
 32:   var _conectando = false;
 33:   String? _error;
 34: 
 35:   @override
 36:   void dispose() {
 37:     for (final c in [_nombre, _host, _puerto, _codigo]) {
 38:       c.dispose();
 39:     }
 40:     super.dispose();
 41:   }
 42: 
 43:   Future<void> _escanearQr() async {
 44:     final texto = await escanearCodigo(
 45:       context,
 46:       titulo: 'Código de la caja',
 47:       ayuda: 'En la caja toca "Conectar terminal"',
 48:     );
 49:     if (texto == null) return;
 50:     try {
 51:       final datos = jsonDecode(texto) as Map<String, Object?>;
 52:       _host.text = datos['host'] as String;
 53:       _puerto.text = '${datos['puerto']}';
 54:       _codigo.text = datos['codigo'] as String;
 55:     } on Object {
 56:       setState(
 57:         () => _error = 'Ese no es el código de la caja. Escanea el QR de "Conectar terminal".',
 58:       );
 59:       return;
 60:     }
 61:     await _vincular();
 62:   }
 63: 
 64:   Future<void> _vincular() async {
 65:     final puerto = int.tryParse(_puerto.text);
 66:     if (_host.text.trim().isEmpty ||
 67:         puerto == null ||
 68:         _codigo.text.length != 6) {
 69:       setState(
 70:         () => _error =
 71:             'Escribe la IP de la caja, el puerto y el código de 6 dígitos.',
 72:       );
 73:       return;
 74:     }
 75:     setState(() {
 76:       _conectando = true;
 77:       _error = null;
 78:     });
 79:     try {
 80:       final host = _host.text.trim();
 81:       final registro = await ApiHttp.registrarTerminal(
 82:         base: Uri(scheme: 'http', host: host, port: puerto),
 83:         nombre: _nombre.text.trim().isEmpty ? 'Terminal' : _nombre.text.trim(),
 84:         codigo: _codigo.text,
 85:       );
 86:       await ref
 87:           .read(configuracionProvider.notifier)
 88:           .guardarConexion(
 89:             ConexionTerminal(
 90:               host: host,
 91:               puerto: puerto,
 92:               clave: registro.clave,
 93:               nombre: registro.terminal.nombre,
 94:             ),
 95:           );
 96:     } on FalloApi catch (e) {
 97:       if (mounted) {
 98:         setState(() {
 99:           _conectando = false;
100:           _error = e.codigo == 'codigo_invalido'
101:               ? 'El código es incorrecto o ya venció. Genera otro en la caja.'
102:               : e.mensaje;
103:         });
104:       }
105:     }
106:   }
107: 
108:   @override
109:   Widget build(BuildContext context) {
110:     final c = context.colores;
111:     final textos = Theme.of(context).textTheme;
112:     return Scaffold(
113:       body: SafeArea(
114:         child: Center(
115:           child: SingleChildScrollView(
116:             padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
117:             child: ConstrainedBox(
118:               constraints: const BoxConstraints(maxWidth: 460),
119:               child: Column(
120:                 crossAxisAlignment: CrossAxisAlignment.stretch,
121:                 children: [
122:                   Row(
123:                     children: [
124:                       IconButton(
125:                         onPressed: () => ref
126:                             .read(configuracionProvider.notifier)
127:                             .elegirModo(null),
128:                         icon: const Icon(Icons.arrow_back_rounded),
129:                         tooltip: 'Cambiar modo',
130:                       ),
131:                       const Spacer(),
132:                       const LogoAnaquel(tamano: 40),
133:                     ],
134:                   ),
135:                   const SizedBox(height: 24),
136:                   Text('Vincula esta terminal', style: textos.displaySmall),
137:                   const SizedBox(height: 8),
138:                   Text(
139:                     'En la caja toca "Conectar terminal" y escanea el código que aparece. '
140:                     'El teléfono y la caja deben estar en la misma Wi-Fi.',
141:                     style: textos.bodyLarge?.copyWith(color: c.tinta2),
142:                   ),
143:                   const SizedBox(height: 24),
144:                   TextField(
145:                     controller: _nombre,
146:                     decoration: const InputDecoration(
147:                       labelText: 'Nombre de esta terminal',
148:                       helperText: 'Así aparecerá en la caja y en los pedidos',
149:                     ),
150:                   ),
151:                   const SizedBox(height: 18),
152:                   FilledButton.icon(
153:                     onPressed: _conectando ? null : _escanearQr,
154:                     icon: const Icon(Icons.qr_code_scanner_rounded),
155:                     label: const Text('Escanear el código de la caja'),
156:                     style: FilledButton.styleFrom(
157:                       minimumSize: const Size.fromHeight(60),
158:                     ),
159:                   ),
160:                   const SizedBox(height: 10),
161:                   TextButton(
162:                     onPressed: () => setState(() => _manual = !_manual),
163:                     child: Text(
164:                       _manual ? 'Ocultar' : 'Escribir los datos a mano',
165:                     ),
166:                   ),
167:                   AnimatedSize(
168:                     duration: const Duration(milliseconds: 220),
169:                     curve: Curves.easeOut,
170:                     child: !_manual
171:                         ? const SizedBox(width: double.infinity)
172:                         : Padding(
173:                             padding: const EdgeInsets.only(top: 8),
174:                             child: Column(
175:                               crossAxisAlignment: CrossAxisAlignment.stretch,
176:                               spacing: 12,
177:                               children: [
178:                                 Row(
179:                                   spacing: 10,
180:                                   children: [
181:                                     Expanded(
182:                                       flex: 3,
183:                                       child: TextField(
184:                                         controller: _host,
185:                                         keyboardType:
186:                                             const TextInputType.numberWithOptions(
187:                                               decimal: true,
188:                                             ),
189:                                         decoration: const InputDecoration(
190:                                           labelText: 'IP de la caja',
191:                                           hintText: '192.168.1.20',
192:                                         ),
193:                                       ),
194:                                     ),
195:                                     Expanded(
196:                                       child: TextField(
197:                                         controller: _puerto,
198:                                         keyboardType: TextInputType.number,
199:                                         inputFormatters: [
200:                                           FilteringTextInputFormatter
201:                                               .digitsOnly,
202:                                         ],
203:                                         decoration: const InputDecoration(
204:                                           labelText: 'Puerto',
205:                                         ),
206:                                       ),
207:                                     ),
208:                                   ],
209:                                 ),
210:                                 TextField(
211:                                   controller: _codigo,
212:                                   keyboardType: TextInputType.number,
213:                                   maxLength: 6,
214:                                   inputFormatters: [
215:                                     FilteringTextInputFormatter.digitsOnly,
216:                                   ],
217:                                   style: textos.headlineMedium?.copyWith(
218:                                     letterSpacing: 6,
219:                                   ),
220:                                   decoration: const InputDecoration(
221:                                     labelText: 'Código de 6 dígitos',
222:                                     counterText: '',
223:                                   ),
224:                                 ),
225:                                 OutlinedButton(
226:                                   onPressed: _conectando ? null : _vincular,
227:                                   child: const Text('Vincular'),
228:                                 ),
229:                               ],
230:                             ),
231:                           ),
232:                   ),
233:                   if (_conectando) ...[
234:                     const SizedBox(height: 18),
235:                     const LinearProgressIndicator(),
236:                   ],
237:                   if (_error != null) ...[
238:                     const SizedBox(height: 18),
239:                     Container(
240:                       padding: const EdgeInsets.all(14),
241:                       decoration: BoxDecoration(
242:                         color: c.alertaSuave,
243:                         borderRadius: BorderRadius.circular(12),
244:                       ),
245:                       child: Row(
246:                         crossAxisAlignment: CrossAxisAlignment.start,
247:                         children: [
248:                           Icon(Icons.error_outline_rounded, color: c.alerta),
249:                           const SizedBox(width: 10),
250:                           Expanded(
251:                             child: Text(
252:                               _error!,
253:                               style: TextStyle(
254:                                 color: c.alerta,
255:                                 fontWeight: FontWeight.w500,
256:                               ),
257:                             ),
258:                           ),
259:                         ],
260:                       ),
261:                     ),
262:                   ],
263:                 ],
264:               ),
265:             ),
266:           ),
267:         ),
268:       ),
269:     );
270:   }
271: }
````

## File: app/test/ayudantes.dart
````dart
 1: import 'dart:io';
 2: 
 3: import 'package:deposito_app/app/app.dart';
 4: import 'package:deposito_app/core/api/api.dart';
 5: import 'package:deposito_app/core/api/api_falsa.dart';
 6: import 'package:deposito_app/core/api/proveedores.dart';
 7: import 'package:deposito_app/core/config/configuracion.dart';
 8: import 'package:deposito_app/core/servidor/servidor_embebido.dart';
 9: import 'package:deposito_app/core/tiempo_real/tiempo_real.dart';
10: import 'package:deposito_backend/deposito_backend.dart';
11: import 'package:flutter/material.dart';
12: import 'package:flutter/services.dart';
13: import 'package:flutter_riverpod/flutter_riverpod.dart';
14: import 'package:flutter_test/flutter_test.dart';
15: import 'package:shared_preferences/shared_preferences.dart';
16: 
17: const prefsCaja = {'modo': 'caja'};
18: const prefsTerminal = {
19:   'modo': 'terminal',
20:   'conexion.host': '192.168.1.50',
21:   'conexion.puerto': 8080,
22:   'conexion.clave': 'clave',
23:   'conexion.nombre': 'Terminal S24',
24: };
25: 
26: /// Monta la app completa con [ApiFalsa], sin servidor ni WebSocket reales.
27: Future<void> montarApp(
28:   WidgetTester tester, {
29:   Map<String, Object> preferencias = const {},
30:   Api? api,
31:   Size tamano = const Size(1366, 1024),
32:   ThemeMode? tema,
33: }) async {
34:   tester.view.physicalSize = tamano;
35:   tester.view.devicePixelRatio = 1;
36:   addTearDown(tester.view.reset);
37: 
38:   SharedPreferences.setMockInitialValues({
39:     if (tema != null) 'tema': tema.name,
40:     ...preferencias,
41:   });
42:   final prefs = await SharedPreferences.getInstance();
43: 
44:   await tester.pumpWidget(
45:     ProviderScope(
46:       overrides: [
47:         preferenciasProvider.overrideWithValue(prefs),
48:         apiProvider.overrideWith((ref) async => api ?? ApiFalsa()),
49:         // Sin arrancar: las pantallas solo leen su puerto y su clave.
50:         servidorEmbebidoProvider.overrideWith(
51:           (ref) async => DepositoServer(rutaBaseDatos: enMemoria),
52:         ),
53:         direccionLocalProvider.overrideWith((ref) async => '192.168.1.50'),
54:         estadoConexionProvider.overrideWith(
55:           (ref) => Stream.value(EstadoConexion.enLinea),
56:         ),
57:         eventosProvider.overrideWith((ref) => const Stream.empty()),
58:       ],
59:       child: const AnaquelApp(),
60:     ),
61:   );
62:   await tester.pumpAndSettle();
63: }
64: 
65: /// Carga Barlow e íconos para que las capturas se vean como en el dispositivo
66: /// (flutter_test usa una fuente de cuadros por omisión).
67: Future<void> cargarFuentes() async {
68:   Future<void> cargar(String familia, List<String> rutas) async {
69:     final cargador = FontLoader(familia);
70:     for (final r in rutas) {
71:       cargador.addFont(
72:         Future.value(ByteData.sublistView(File(r).readAsBytesSync())),
73:       );
74:     }
75:     await cargador.load();
76:   }
77: 
78:   await cargar('Barlow', [
79:     for (final p in ['Regular', 'Medium', 'SemiBold', 'Bold'])
80:       'assets/fonts/Barlow-$p.ttf',
81:   ]);
82:   await cargar('Barlow Condensed', [
83:     for (final p in ['SemiBold', 'Bold']) 'assets/fonts/BarlowCondensed-$p.ttf',
84:   ]);
85:   final flutterRaiz = File(Platform.resolvedExecutable)
86:       .parent
87:       .parent
88:       .parent
89:       .parent
90:       .parent
91:       .parent
92:       .path;
93:   final iconos = File(
94:     '$flutterRaiz/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
95:   );
96:   if (iconos.existsSync()) await cargar('MaterialIcons', [iconos.path]);
97: }
````

## File: app/test/capturas_test.dart
````dart
  1: // Genera capturas PNG de las pantallas principales para revisar el diseño.
  2: // No corre en el CI: solo cuando se define CAPTURAS con la carpeta de salida.
  3: //
  4: //   CAPTURAS=/tmp/capturas flutter test test/capturas_test.dart
  5: import 'dart:io';
  6: import 'dart:ui' show ImageByteFormat;
  7: 
  8: import 'package:flutter/material.dart';
  9: import 'package:flutter/rendering.dart';
 10: import 'package:flutter_test/flutter_test.dart';
 11: 
 12: import 'ayudantes.dart';
 13: 
 14: final _salida = Platform.environment['CAPTURAS'];
 15: 
 16: void main() {
 17:   const ipad = Size(1366, 1024);
 18:   const telefono = Size(412, 915);
 19: 
 20:   setUpAll(cargarFuentes);
 21: 
 22:   Future<void> capturar(
 23:     WidgetTester tester,
 24:     String nombre, {
 25:     bool esperar = true,
 26:   }) async {
 27:     if (esperar) await tester.pumpAndSettle();
 28:     final vista = tester.binding.renderViews.first;
 29:     final capa = vista.debugLayer! as OffsetLayer;
 30:     await tester.runAsync(() async {
 31:       final imagen = await capa.toImage(Offset.zero & vista.size);
 32:       final png = await imagen.toByteData(format: ImageByteFormat.png);
 33:       File('$_salida/$nombre.png')
 34:         ..createSync(recursive: true)
 35:         ..writeAsBytesSync(png!.buffer.asUint8List());
 36:     });
 37:   }
 38: 
 39:   final omitir = _salida == null
 40:       ? 'Define CAPTURAS para generar capturas'
 41:       : null;
 42: 
 43:   testWidgets('bienvenida', skip: omitir != null, (tester) async {
 44:     await montarApp(tester, tamano: ipad, tema: ThemeMode.dark);
 45:     await capturar(tester, '01_bienvenida_oscuro');
 46:   });
 47: 
 48:   testWidgets('caja inicio', skip: omitir != null, (tester) async {
 49:     await montarApp(
 50:       tester,
 51:       preferencias: prefsCaja,
 52:       tamano: ipad,
 53:       tema: ThemeMode.light,
 54:     );
 55:     await capturar(tester, '02_caja_inicio_claro');
 56:   });
 57: 
 58:   testWidgets('caja inicio oscuro', skip: omitir != null, (tester) async {
 59:     await montarApp(
 60:       tester,
 61:       preferencias: prefsCaja,
 62:       tamano: ipad,
 63:       tema: ThemeMode.dark,
 64:     );
 65:     await capturar(tester, '03_caja_inicio_oscuro');
 66:   });
 67: 
 68:   testWidgets('caja catálogo', skip: omitir != null, (tester) async {
 69:     await montarApp(
 70:       tester,
 71:       preferencias: prefsCaja,
 72:       tamano: ipad,
 73:       tema: ThemeMode.light,
 74:     );
 75:     await tester.tap(find.text('Catálogo').first);
 76:     await capturar(tester, '04_caja_catalogo');
 77:   });
 78: 
 79:   testWidgets('caja nuevo producto', skip: omitir != null, (tester) async {
 80:     await montarApp(
 81:       tester,
 82:       preferencias: prefsCaja,
 83:       tamano: ipad,
 84:       tema: ThemeMode.light,
 85:     );
 86:     await tester.tap(find.text('Catálogo').first);
 87:     await tester.pumpAndSettle();
 88:     await tester.tap(find.text('Nuevo producto'));
 89:     await capturar(tester, '05_caja_nuevo_producto');
 90:   });
 91: 
 92:   testWidgets('caja conectar terminal', skip: omitir != null, (tester) async {
 93:     await montarApp(
 94:       tester,
 95:       preferencias: prefsCaja,
 96:       tamano: ipad,
 97:       tema: ThemeMode.light,
 98:     );
 99:     await tester.tap(find.text('Conectar terminal').first);
100:     await tester.pump(const Duration(milliseconds: 500));
101:     await tester.pump(const Duration(milliseconds: 500));
102:     // Sin pumpAndSettle: el diálogo tiene un reloj que nunca se detiene.
103:     await capturar(tester, '06_caja_conectar_terminal', esperar: false);
104:     // Cierra el diálogo para cancelar sus temporizadores.
105:     await tester.tap(find.byTooltip('Cerrar'));
106:     await tester.pumpAndSettle();
107:   });
108: 
109:   testWidgets('caja vertical', skip: omitir != null, (tester) async {
110:     await montarApp(
111:       tester,
112:       preferencias: prefsCaja,
113:       tamano: const Size(820, 1180),
114:       tema: ThemeMode.light,
115:     );
116:     await tester.tap(find.byTooltip('Catálogo'));
117:     await capturar(tester, '07_caja_ipad_vertical');
118:   });
119: 
120:   testWidgets('terminal escanear', skip: omitir != null, (tester) async {
121:     await montarApp(
122:       tester,
123:       preferencias: prefsTerminal,
124:       tamano: telefono,
125:       tema: ThemeMode.dark,
126:     );
127:     await tester.enterText(find.byType(TextField), '7501064191022');
128:     await tester.tap(find.text('Buscar'));
129:     await capturar(tester, '08_terminal_escanear');
130:   });
131: 
132:   testWidgets('terminal productos', skip: omitir != null, (tester) async {
133:     await montarApp(
134:       tester,
135:       preferencias: prefsTerminal,
136:       tamano: telefono,
137:       tema: ThemeMode.light,
138:     );
139:     await tester.tap(find.text('Productos'));
140:     await capturar(tester, '09_terminal_productos');
141:   });
142: 
143:   testWidgets('terminal vincular', skip: omitir != null, (tester) async {
144:     await montarApp(
145:       tester,
146:       preferencias: {'modo': 'terminal'},
147:       tamano: telefono,
148:       tema: ThemeMode.light,
149:     );
150:     await tester.tap(find.text('Escribir los datos a mano'));
151:     await capturar(tester, '10_terminal_vincular');
152:   });
153: }
````

## File: app/test/flujos_test.dart
````dart
  1: import 'package:deposito_app/core/api/api_falsa.dart';
  2: import 'package:flutter/material.dart';
  3: import 'package:flutter_test/flutter_test.dart';
  4: 
  5: import 'ayudantes.dart';
  6: 
  7: void main() {
  8:   testWidgets(
  9:     'sin modo elegido muestra la bienvenida y al elegir Caja abre el tablero',
 10:     (tester) async {
 11:       await montarApp(tester);
 12:       expect(find.text('Punto de venta\ndel depósito'), findsOneWidget);
 13: 
 14:       await tester.tap(find.text('Caja'));
 15:       await tester.pumpAndSettle();
 16: 
 17:       expect(find.text('Anaquel'), findsOneWidget); // menú lateral
 18:       expect(find.text('Necesita atención'), findsOneWidget);
 19:       // Corona Mega tiene 30 piezas con mínimo 36.
 20:       expect(find.text('Corona Mega'), findsWidgets);
 21:     },
 22:   );
 23: 
 24:   testWidgets('el catálogo filtra por búsqueda sin acentos y por categoría', (
 25:     tester,
 26:   ) async {
 27:     await montarApp(tester, preferencias: prefsCaja);
 28:     await tester.tap(find.text('Catálogo').first);
 29:     await tester.pumpAndSettle();
 30: 
 31:     expect(find.text('Victoria Mega'), findsOneWidget);
 32:     await tester.enterText(find.byType(TextField), 'CORONA');
 33:     await tester.pumpAndSettle();
 34:     expect(find.text('Victoria Mega'), findsNothing);
 35:     expect(find.text('Corona Mega'), findsOneWidget);
 36:     expect(find.text('Corona Cuarto'), findsOneWidget);
 37: 
 38:     await tester.enterText(find.byType(TextField), '');
 39:     await tester.tap(find.widgetWithText(ChoiceChip, 'Botana'));
 40:     await tester.pumpAndSettle();
 41:     expect(find.text('Papas adobadas'), findsOneWidget);
 42:     expect(find.text('Corona Mega'), findsNothing);
 43:   });
 44: 
 45:   testWidgets('crear un producto valida el precio en pantalla y lo guarda', (
 46:     tester,
 47:   ) async {
 48:     final api = ApiFalsa();
 49:     await montarApp(tester, preferencias: prefsCaja, api: api);
 50:     await tester.tap(find.text('Catálogo').first);
 51:     await tester.pumpAndSettle();
 52:     await tester.tap(find.text('Nuevo producto'));
 53:     await tester.pumpAndSettle();
 54: 
 55:     Finder campo(String etiqueta) => find.widgetWithText(TextField, etiqueta);
 56:     await tester.enterText(campo('Código de barras'), '750999');
 57:     await tester.enterText(campo('Nombre'), 'Tecate Light');
 58:     await tester.tap(find.text('Guardar producto'));
 59:     await tester.pumpAndSettle();
 60:     expect(find.text('Escribe el precio, por ejemplo 42.50'), findsOneWidget);
 61:     expect(api.productos.where((p) => p.nombre == 'Tecate Light'), isEmpty);
 62: 
 63:     await tester.enterText(campo('Precio por pieza'), '23.50');
 64:     await tester.tap(find.text('Guardar producto'));
 65:     await tester.pumpAndSettle();
 66:     final creado = api.productos.singleWhere((p) => p.nombre == 'Tecate Light');
 67:     expect(creado.precio, 2350);
 68:     expect(find.text('Tecate Light quedó en el catálogo'), findsOneWidget);
 69:   });
 70: 
 71:   testWidgets('la terminal escanea un código y muestra precio y existencia', (
 72:     tester,
 73:   ) async {
 74:     await montarApp(
 75:       tester,
 76:       preferencias: prefsTerminal,
 77:       tamano: const Size(412, 915),
 78:     );
 79:     expect(find.text('Listo para escanear'), findsOneWidget);
 80: 
 81:     await tester.enterText(find.byType(TextField), '7501064191015');
 82:     await tester.tap(find.text('Buscar'));
 83:     await tester.pumpAndSettle();
 84: 
 85:     expect(find.text('Victoria Mega'), findsOneWidget);
 86:     expect(find.text(r'$42'), findsOneWidget);
 87:     expect(find.text('Hay 5 cajas + 6 pz'), findsOneWidget);
 88:   });
 89: 
 90:   testWidgets('un código que no existe lo dice claramente', (tester) async {
 91:     await montarApp(
 92:       tester,
 93:       preferencias: prefsTerminal,
 94:       tamano: const Size(412, 915),
 95:     );
 96:     await tester.enterText(find.byType(TextField), '000');
 97:     await tester.tap(find.text('Buscar'));
 98:     await tester.pumpAndSettle();
 99:     expect(find.text('Código no registrado'), findsOneWidget);
100:   });
101: 
102:   testWidgets('una terminal sin vincular va a la pantalla de vinculación', (
103:     tester,
104:   ) async {
105:     await montarApp(
106:       tester,
107:       preferencias: {'modo': 'terminal'},
108:       tamano: const Size(412, 915),
109:     );
110:     expect(find.text('Vincula esta terminal'), findsOneWidget);
111:   });
112: }
````

## File: app/test/formato_test.dart
````dart
 1: import 'package:deposito_app/core/api/api_falsa.dart';
 2: import 'package:deposito_app/core/formato/formato.dart';
 3: import 'package:flutter_test/flutter_test.dart';
 4: 
 5: void main() {
 6:   group('dinero', () {
 7:     test('pesos enteros sin decimales', () => expect(dinero(4200), r'$42'));
 8:     test('con centavos', () => expect(dinero(4250), r'$42.50'));
 9:     test('un centavo', () => expect(dinero(1), r'$0.01'));
10:     test('miles con coma', () => expect(dinero(123456), r'$1,234.56'));
11:     test('millones', () => expect(dinero(123456700), r'$1,234,567'));
12:     test('negativos', () => expect(dinero(-4250), r'-$42.50'));
13:   });
14: 
15:   group('centavosDesdeTexto', () {
16:     test('lee pesos exactos sin pasar por double', () {
17:       expect(centavosDesdeTexto('42'), 4200);
18:       expect(centavosDesdeTexto('42.5'), 4250);
19:       expect(centavosDesdeTexto('42.50'), 4250);
20:       expect(centavosDesdeTexto(r'$1,234.56'), 123456);
21:       // 0.29 * 100 en double da 28.999999999999996.
22:       expect(centavosDesdeTexto('0.29'), 29);
23:     });
24: 
25:     test('rechaza lo que no es dinero', () {
26:       expect(centavosDesdeTexto(''), isNull);
27:       expect(centavosDesdeTexto('42.505'), isNull);
28:       expect(centavosDesdeTexto('abc'), isNull);
29:       expect(centavosDesdeTexto('-5'), isNull);
30:     });
31:   });
32: 
33:   group('existenciaLegible', () {
34:     final victoria = productosDePrueba().first; // 66 piezas, cajas de 12.
35: 
36:     test(
37:       'cajas y piezas sueltas',
38:       () => expect(existenciaLegible(victoria), '5 cajas + 6 pz'),
39:     );
40: 
41:     test('producto sin caja', () {
42:       final hielo = productosDePrueba().firstWhere(
43:         (p) => p.piezasPorCaja == null,
44:       );
45:       expect(existenciaLegible(hielo), '18 pz');
46:     });
47:   });
48: 
49:   test('diasHasta cuenta días de calendario', () {
50:     final hoy = DateTime(2026, 10, 2, 23, 59);
51:     expect(diasHasta('2026-10-02', hoy), 0);
52:     expect(diasHasta('2026-10-03', hoy), 1);
53:     expect(diasHasta('2026-09-30', hoy), -2);
54:   });
55: }
````

## File: app/analysis_options.yaml
````yaml
 1: # This file configures the analyzer, which statically analyzes Dart code to
 2: # check for errors, warnings, and lints.
 3: #
 4: # The issues identified by the analyzer are surfaced in the UI of Dart-enabled
 5: # IDEs (https://dart.dev/tools#ides-and-editors). The analyzer can also be
 6: # invoked from the command line by running `flutter analyze`.
 7: 
 8: # The following line activates a set of recommended lints for Flutter apps,
 9: # packages, and plugins designed to encourage good coding practices.
10: include: package:flutter_lints/flutter.yaml
11: 
12: analyzer:
13:   exclude:
14:     - build/**
15:     - android/**
16:     - ios/**
17: 
18: linter:
19:   # The lint rules applied to this project can be customized in the
20:   # section below to disable rules from the `package:flutter_lints/flutter.yaml`
21:   # included above or to enable additional rules. A list of all available lints
22:   # and their documentation is published at https://dart.dev/lints.
23:   #
24:   # Instead of disabling a lint rule for the entire project in the
25:   # section below, it can also be suppressed for a single line of code
26:   # or a specific dart file by using the `// ignore: name_of_lint` and
27:   # `// ignore_for_file: name_of_lint` syntax on the line or in the file
28:   # producing the lint.
29:   rules:
30:     # avoid_print: false  # Uncomment to disable the `avoid_print` rule
31:     # prefer_single_quotes: true  # Uncomment to enable the `prefer_single_quotes` rule
32: 
33: # Additional information about this file can be found at
34: # https://dart.dev/guides/language/analysis-options
````

## File: backend/lib/src/comun/errores.dart
````dart
 1: /// Error que la API devuelve al cliente con el formato del contrato.
 2: ///
 3: /// Las rutas y servicios lanzan [ErrorApi]; el middleware de errores lo
 4: /// convierte en `{ "error": { "codigo", "mensaje", "campos"? } }`.
 5: class ErrorApi implements Exception {
 6:   ErrorApi(this.estado, this.codigo, this.mensaje, {this.campos});
 7: 
 8:   final int estado;
 9:   final String codigo;
10:   final String mensaje;
11: 
12:   /// Campo → explicación, solo en `datos_invalidos`.
13:   final Map<String, String>? campos;
14: 
15:   factory ErrorApi.datosInvalidos(Map<String, String> campos) => ErrorApi(
16:     400,
17:     'datos_invalidos',
18:     'Revisa los campos marcados',
19:     campos: campos,
20:   );
21: 
22:   factory ErrorApi.jsonInvalido() => ErrorApi(
23:     400,
24:     'json_invalido',
25:     'El cuerpo de la petición no es JSON válido',
26:   );
27: 
28:   factory ErrorApi.noAutorizado() => ErrorApi(
29:     401,
30:     'no_autorizado',
31:     'Falta la clave de terminal o ya no es válida',
32:   );
33: 
34:   factory ErrorApi.codigoInvalido() => ErrorApi(
35:     401,
36:     'codigo_invalido',
37:     'El código de emparejamiento es incorrecto o ya venció',
38:   );
39: 
40:   factory ErrorApi.soloCaja() => ErrorApi(
41:     403,
42:     'solo_caja',
43:     'Esta acción solo se puede hacer desde la caja',
44:   );
45: 
46:   factory ErrorApi.noEncontrado(String que) =>
47:       ErrorApi(404, 'no_encontrado', 'No existe $que');
48: 
49:   factory ErrorApi.codigoDuplicado(String codigo) => ErrorApi(
50:     409,
51:     'codigo_duplicado',
52:     'Ya existe un producto con el código $codigo',
53:   );
54: 
55:   factory ErrorApi.interno() => ErrorApi(
56:     500,
57:     'error_interno',
58:     'Ocurrió un error inesperado. Quedó registrado en el log',
59:   );
60: 
61:   Map<String, Object?> toJson() => {
62:     'error': {
63:       'codigo': codigo,
64:       'mensaje': mensaje,
65:       if (campos != null) 'campos': campos,
66:     },
67:   };
68: 
69:   @override
70:   String toString() => 'ErrorApi($estado $codigo: $mensaje)';
71: }
````

## File: backend/lib/src/comun/fechas.dart
````dart
 1: /// Reglas de fechas del proyecto (ver docs/ESTANDARES.md):
 2: /// - Los instantes se guardan y viajan en UTC.
 3: /// - El "día del negocio" se calcula SOLO con [diaNegocio], nunca con
 4: ///   `DateTime.now().day` ni con la zona del dispositivo.
 5: library;
 6: 
 7: /// Fuente de la hora actual. Se inyecta para poder probar con fechas fijas.
 8: typedef Reloj = DateTime Function();
 9: 
10: DateTime relojSistema() => DateTime.now().toUtc();
11: 
12: /// Instante en ISO 8601 UTC sin milisegundos: `2026-10-02T18:30:00Z`.
13: String instanteIso(DateTime instante) {
14:   final u = instante.toUtc();
15:   return '${_fecha(u.year, u.month, u.day)}T${_dos(u.hour)}:${_dos(u.minute)}:${_dos(u.second)}Z';
16: }
17: 
18: /// Día de calendario (`AAAA-MM-DD`) al que pertenece [instante] en la zona
19: /// del negocio, dada como desfase respecto a UTC (México centro: -6 h).
20: ///
21: /// Ejemplo: una venta a las 23:59 del 2 de octubre en el local es
22: /// `2026-10-03T05:59:00Z`, y su día de negocio es `2026-10-02`.
23: String diaNegocio(DateTime instante, Duration desfase) {
24:   final local = instante.toUtc().add(desfase);
25:   return _fecha(local.year, local.month, local.day);
26: }
27: 
28: /// Rango UTC `[inicio, fin)` que cubre el día de negocio [dia].
29: ({DateTime inicio, DateTime fin}) rangoDiaNegocio(
30:   String dia,
31:   Duration desfase,
32: ) {
33:   final f = parsearFecha(dia);
34:   if (f == null) throw ArgumentError.value(dia, 'dia', 'No es AAAA-MM-DD');
35:   final inicio = DateTime.utc(f.year, f.month, f.day).subtract(desfase);
36:   return (inicio: inicio, fin: inicio.add(const Duration(days: 1)));
37: }
38: 
39: /// Interpreta `AAAA-MM-DD` y comprueba que la fecha exista (no 2026-02-30).
40: DateTime? parsearFecha(String texto) {
41:   final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(texto);
42:   if (m == null) return null;
43:   final a = int.parse(m[1]!), mes = int.parse(m[2]!), d = int.parse(m[3]!);
44:   final f = DateTime.utc(a, mes, d);
45:   if (f.year != a || f.month != mes || f.day != d) return null;
46:   return f;
47: }
48: 
49: /// Interpreta un desfase `-06:00` / `+05:30`.
50: Duration? parsearDesfase(String texto) {
51:   final m = RegExp(r'^([+-])(\d{2}):(\d{2})$').firstMatch(texto);
52:   if (m == null) return null;
53:   final minutos = int.parse(m[2]!) * 60 + int.parse(m[3]!);
54:   return Duration(minutes: m[1] == '-' ? -minutos : minutos);
55: }
56: 
57: String _fecha(int a, int m, int d) =>
58:     '${a.toString().padLeft(4, '0')}-${_dos(m)}-${_dos(d)}';
59: 
60: String _dos(int n) => n.toString().padLeft(2, '0');
````

## File: backend/lib/src/comun/json.dart
````dart
  1: import 'dart:convert';
  2: 
  3: import 'package:shelf/shelf.dart';
  4: 
  5: import 'errores.dart';
  6: import 'fechas.dart';
  7: 
  8: const _cabecerasJson = {'content-type': 'application/json; charset=utf-8'};
  9: 
 10: Response respuestaJson(Object? cuerpo, {int estado = 200}) =>
 11:     Response(estado, body: jsonEncode(cuerpo), headers: _cabecerasJson);
 12: 
 13: /// Lee el cuerpo como objeto JSON o lanza `json_invalido`.
 14: Future<Map<String, Object?>> leerObjetoJson(Request peticion) async {
 15:   final texto = await peticion.readAsString();
 16:   try {
 17:     final valor = jsonDecode(texto);
 18:     if (valor is Map<String, Object?>) return valor;
 19:   } on FormatException {
 20:     // Se responde abajo con el mismo error.
 21:   }
 22:   throw ErrorApi.jsonInvalido();
 23: }
 24: 
 25: /// Junta los errores de todos los campos para responderlos de una vez.
 26: ///
 27: /// ```dart
 28: /// final v = Validador(cuerpo);
 29: /// final nombre = v.texto('nombre', max: 80);
 30: /// final precio = v.centavos('precio');
 31: /// v.comprobar(); // lanza datos_invalidos si algo falló
 32: /// ```
 33: class Validador {
 34:   Validador(this._datos);
 35: 
 36:   final Map<String, Object?> _datos;
 37:   final errores = <String, String>{};
 38: 
 39:   bool presente(String campo) => _datos[campo] != null;
 40: 
 41:   void error(String campo, String mensaje) =>
 42:       errores.putIfAbsent(campo, () => mensaje);
 43: 
 44:   String? texto(
 45:     String campo, {
 46:     bool requerido = true,
 47:     int min = 1,
 48:     required int max,
 49:     RegExp? patron,
 50:     String? mensajePatron,
 51:   }) {
 52:     final v = _datos[campo];
 53:     if (v == null) {
 54:       if (requerido) error(campo, 'Es obligatorio');
 55:       return null;
 56:     }
 57:     if (v is! String) {
 58:       error(campo, 'Debe ser texto');
 59:       return null;
 60:     }
 61:     final t = v.trim();
 62:     if (t.length < min || t.length > max) {
 63:       error(
 64:         campo,
 65:         min == max
 66:             ? 'Debe tener $max caracteres'
 67:             : 'Debe tener de $min a $max caracteres',
 68:       );
 69:       return null;
 70:     }
 71:     if (patron != null && !patron.hasMatch(t)) {
 72:       error(campo, mensajePatron ?? 'Formato no válido');
 73:       return null;
 74:     }
 75:     return t;
 76:   }
 77: 
 78:   // backend/lib/src/comun/json.dart
 79: 
 80:   int? entero(
 81:     String campo, {
 82:     bool requerido = true,
 83:     int? min,
 84:     int? max,
 85:     String? mensaje,
 86:   }) {
 87:     final v = _datos[campo];
 88:     if (v == null) {
 89:       if (requerido) error(campo, 'Es obligatorio');
 90:       return null;
 91:     }
 92:     if (v is! int || (min != null && v < min) || (max != null && v > max)) {
 93:       error(
 94:         campo,
 95:         mensaje ??
 96:             (min != null && max != null
 97:                 ? 'Debe ser un entero entre $min y $max'
 98:                 : min != null
 99:                 ? 'Debe ser un entero mayor o igual a $min'
100:                 : 'Debe ser un entero válido'),
101:       );
102:       return null;
103:     }
104:     return v;
105:   }
106: 
107:   /// Dinero en centavos: entero mayor que 0 y con límite de $10,000,000 MXN.
108:   int? centavos(String campo, {bool requerido = true}) => entero(
109:     campo,
110:     requerido: requerido,
111:     min: 1,
112:     max: 1000000000, // 10 millones de pesos en centavos
113:     mensaje:
114:         'Debe ser un entero mayor que 0 y menor a 1,000,000,000 (centavos)',
115:   );
116: 
117:   String? opcion(String campo, Set<String> opciones, {bool requerido = true}) {
118:     final v = _datos[campo];
119:     if (v == null) {
120:       if (requerido) error(campo, 'Es obligatorio');
121:       return null;
122:     }
123:     if (v is! String || !opciones.contains(v)) {
124:       error(campo, 'Debe ser uno de: ${opciones.join(', ')}');
125:       return null;
126:     }
127:     return v;
128:   }
129: 
130:   /// Fecha de calendario `AAAA-MM-DD`.
131:   String? fecha(String campo, {bool requerido = true}) {
132:     final v = _datos[campo];
133:     if (v == null) {
134:       if (requerido) error(campo, 'Es obligatorio');
135:       return null;
136:     }
137:     if (v is! String || parsearFecha(v) == null) {
138:       error(campo, 'Debe ser una fecha válida AAAA-MM-DD');
139:       return null;
140:     }
141:     return v;
142:   }
143: 
144:   void comprobar() {
145:     if (errores.isNotEmpty) throw ErrorApi.datosInvalidos(errores);
146:   }
147: }
````

## File: backend/lib/src/comun/middleware.dart
````dart
  1: import 'package:shelf/shelf.dart';
  2: import 'package:sqlite3/sqlite3.dart';
  3: 
  4: import '../servicios/servicio_terminales.dart';
  5: import 'bitacora.dart';
  6: import 'errores.dart';
  7: import 'json.dart';
  8: import 'seguridad.dart';
  9: import 'sesion.dart';
 10: 
 11: const cabeceraClave = 'x-clave-terminal';
 12: 
 13: /// Rutas que no piden clave (relativas, sin `/` inicial).
 14: const _rutasPublicas = {'salud', 'api/v1/terminales/registro'};
 15: 
 16: /// Escribe en la bitácora cada petición con su estado y duración.
 17: Middleware registrarPeticiones(Bitacora bitacora) =>
 18:     (siguiente) => (peticion) async {
 19:       final cronometro = Stopwatch()..start();
 20:       final respuesta = await siguiente(peticion);
 21:       bitacora.info(
 22:         '${peticion.method} /${peticion.url.path} ${respuesta.statusCode} '
 23:         '${cronometro.elapsedMilliseconds}ms',
 24:       );
 25:       return respuesta;
 26:     };
 27: 
 28: /// Convierte cualquier error en una respuesta con el formato del contrato.
 29: Middleware manejarErrores(Bitacora bitacora) =>
 30:     (siguiente) => (peticion) async {
 31:       try {
 32:         return await siguiente(peticion);
 33:       } on HijackException {
 34:         rethrow; // El WebSocket toma la conexión; shelf lo maneja.
 35:       } on ErrorApi catch (e) {
 36:         return respuestaJson(e.toJson(), estado: e.estado);
 37:       } on SqliteException catch (e, pila) {
 38:         final error = _traducirSqlite(e);
 39:         if (error != null) {
 40:           return respuestaJson(error.toJson(), estado: error.estado);
 41:         }
 42:         bitacora.error(
 43:           'SQLite en ${peticion.method} /${peticion.url.path}',
 44:           e,
 45:           pila,
 46:         );
 47:         return respuestaJson(ErrorApi.interno().toJson(), estado: 500);
 48:       } catch (e, pila) {
 49:         bitacora.error(
 50:           'Error no previsto en ${peticion.method} /${peticion.url.path}',
 51:           e,
 52:           pila,
 53:         );
 54:         return respuestaJson(ErrorApi.interno().toJson(), estado: 500);
 55:       }
 56:     };
 57: 
 58: /// Respaldo por si dos peticiones pasan la validación al mismo tiempo: el
 59: /// índice UNIQUE de la base es quien de verdad impide el duplicado.
 60: ErrorApi? _traducirSqlite(SqliteException e) {
 61:   const sqliteConstraintUnique = 2067;
 62:   if (e.extendedResultCode == sqliteConstraintUnique &&
 63:       e.message.contains('productos.codigo')) {
 64:     return ErrorApi(
 65:       409,
 66:       'codigo_duplicado',
 67:       'Ya existe un producto con ese código',
 68:     );
 69:   }
 70:   return null;
 71: }
 72: 
 73: /// Identifica a la caja o a la terminal por `X-Clave-Terminal` (o `?clave=`
 74: /// en el WebSocket) y pone la [Sesion] en la petición. Es el único punto de
 75: /// autenticación para HTTP y WebSocket.
 76: Middleware autenticar({
 77:   required String claveCaja,
 78:   required ServicioTerminales terminales,
 79: }) =>
 80:     (siguiente) => (peticion) {
 81:       if (_rutasPublicas.contains(peticion.url.path)) {
 82:         return siguiente(peticion);
 83:       }
 84: 
 85:       final clave =
 86:           peticion.headers[cabeceraClave] ??
 87:           peticion.url.queryParameters['clave'];
 88:       if (clave == null || clave.isEmpty) throw ErrorApi.noAutorizado();
 89: 
 90:       if (igualesSeguro(clave, claveCaja)) {
 91:         return siguiente(conSesion(peticion, const Sesion.caja()));
 92:       }
 93:       final terminal = terminales.autenticar(clave);
 94:       if (terminal == null) throw ErrorApi.noAutorizado();
 95:       return siguiente(
 96:         conSesion(
 97:           peticion,
 98:           Sesion.terminal(id: terminal.id, nombre: terminal.nombre),
 99:         ),
100:       );
101:     };
````

## File: backend/lib/src/comun/seguridad.dart
````dart
 1: import 'dart:convert';
 2: import 'dart:math';
 3: 
 4: import 'package:crypto/crypto.dart';
 5: 
 6: final _aleatorio = Random.secure();
 7: const _alfabetoId = '0123456789abcdefghijkmnpqrstuvwxyz';
 8: 
 9: /// ID con prefijo por tipo (`p_`, `t_`...) y 10 caracteres aleatorios.
10: String generarId(String prefijo) {
11:   final sufijo = List.generate(
12:     10,
13:     (_) => _alfabetoId[_aleatorio.nextInt(_alfabetoId.length)],
14:   ).join();
15:   return '${prefijo}_$sufijo';
16: }
17: 
18: /// Clave secreta de 32 bytes en base64 URL (43 caracteres, sin relleno).
19: String generarClave() {
20:   final bytes = List<int>.generate(32, (_) => _aleatorio.nextInt(256));
21:   return base64Url.encode(bytes).replaceAll('=', '');
22: }
23: 
24: /// Código numérico de [digitos] dígitos para emparejar terminales.
25: String generarCodigoNumerico(int digitos) =>
26:     List.generate(digitos, (_) => _aleatorio.nextInt(10)).join();
27: 
28: /// Hash que se guarda en la base de datos en lugar de la clave.
29: String hashClave(String clave) => sha256.convert(utf8.encode(clave)).toString();
30: 
31: /// Compara sin salir antes al primer carácter distinto, para no filtrar
32: /// información por el tiempo de respuesta.
33: bool igualesSeguro(String a, String b) {
34:   if (a.length != b.length) return false;
35:   var diferencia = 0;
36:   for (var i = 0; i < a.length; i++) {
37:     diferencia |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
38:   }
39:   return diferencia == 0;
40: }
````

## File: backend/lib/src/comun/sesion.dart
````dart
 1: import 'package:shelf/shelf.dart';
 2: 
 3: import 'errores.dart';
 4: 
 5: enum Rol { caja, terminal }
 6: 
 7: /// Quién hace la petición. La pone el middleware de autenticación.
 8: class Sesion {
 9:   const Sesion.caja() : rol = Rol.caja, terminalId = null, nombre = 'Caja';
10: 
11:   const Sesion.terminal({required String id, required this.nombre})
12:     : rol = Rol.terminal,
13:       terminalId = id;
14: 
15:   final Rol rol;
16:   final String? terminalId;
17: 
18:   /// Se guarda como `origen` en movimientos, ventas y pedidos.
19:   final String nombre;
20: 
21:   bool get esCaja => rol == Rol.caja;
22: }
23: 
24: const _llave = 'anaquel.sesion';
25: 
26: Request conSesion(Request peticion, Sesion sesion) =>
27:     peticion.change(context: {_llave: sesion});
28: 
29: Sesion sesionDe(Request peticion) {
30:   final sesion = peticion.context[_llave];
31:   if (sesion is! Sesion) throw ErrorApi.noAutorizado();
32:   return sesion;
33: }
34: 
35: /// Para endpoints marcados "Solo caja" en el contrato.
36: Sesion exigirCaja(Request peticion) {
37:   final sesion = sesionDe(peticion);
38:   if (!sesion.esCaja) throw ErrorApi.soloCaja();
39:   return sesion;
40: }
````

## File: backend/lib/src/comun/texto.dart
````dart
 1: const _sinAcento = {
 2:   'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a', //
 3:   'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e', //
 4:   'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i', //
 5:   'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o', //
 6:   'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u', //
 7:   'ñ': 'n',
 8: };
 9: 
10: /// Texto en minúsculas y sin acentos, para búsquedas: "Pacífico" → "pacifico".
11: String normalizarBusqueda(String texto) {
12:   final b = StringBuffer();
13:   for (final c in texto.toLowerCase().split('')) {
14:     b.write(_sinAcento[c] ?? c);
15:   }
16:   return b.toString().trim();
17: }
````

## File: backend/lib/src/db/migraciones/m001_inicial.dart
````dart
 1: import '../migraciones.dart';
 2: 
 3: /// Productos, movimientos de inventario, terminales y ajustes.
 4: ///
 5: /// Dinero en centavos (INTEGER), instantes en texto ISO UTC, fechas de
 6: /// calendario en texto AAAA-MM-DD.
 7: const m001Inicial = Migracion(1, 'inicial', '''
 8: CREATE TABLE productos (
 9:   id                TEXT PRIMARY KEY,
10:   codigo            TEXT NOT NULL,
11:   nombre            TEXT NOT NULL,
12:   nombre_busqueda   TEXT NOT NULL,
13:   categoria         TEXT NOT NULL,
14:   presentacion      TEXT,
15:   precio            INTEGER NOT NULL CHECK (precio > 0),
16:   precio_caja       INTEGER CHECK (precio_caja > 0),
17:   piezas_por_caja   INTEGER CHECK (piezas_por_caja >= 2),
18:   existencia_piezas INTEGER NOT NULL DEFAULT 0 CHECK (existencia_piezas >= 0),
19:   minimo            INTEGER NOT NULL DEFAULT 0 CHECK (minimo >= 0),
20:   envase            TEXT CHECK (envase IN ('mega', 'media', 'cuarto')),
21:   caducidad         TEXT,
22:   foto              TEXT,
23:   eliminado         INTEGER NOT NULL DEFAULT 0,
24:   creado            TEXT NOT NULL,
25:   actualizado       TEXT NOT NULL,
26:   CHECK ((precio_caja IS NULL) = (piezas_por_caja IS NULL))
27: );
28: 
29: -- Único solo entre activos: un producto eliminado no bloquea su código.
30: CREATE UNIQUE INDEX productos_codigo_activo ON productos (codigo) WHERE eliminado = 0;
31: CREATE INDEX productos_categoria ON productos (categoria) WHERE eliminado = 0;
32: 
33: -- Bitácora de todo cambio de existencia. Nunca se edita ni se borra.
34: CREATE TABLE movimientos (
35:   id                    INTEGER PRIMARY KEY AUTOINCREMENT,
36:   producto_id           TEXT NOT NULL REFERENCES productos (id),
37:   tipo                  TEXT NOT NULL CHECK (tipo IN
38:                           ('inicial', 'entrada', 'venta', 'cancelacion', 'ajuste', 'merma')),
39:   piezas                INTEGER NOT NULL,
40:   existencia_resultante INTEGER NOT NULL CHECK (existencia_resultante >= 0),
41:   referencia            TEXT,
42:   origen                TEXT NOT NULL,
43:   nota                  TEXT,
44:   fecha                 TEXT NOT NULL
45: );
46: CREATE INDEX movimientos_producto ON movimientos (producto_id, fecha);
47: 
48: CREATE TABLE terminales (
49:   id              TEXT PRIMARY KEY,
50:   nombre          TEXT NOT NULL,
51:   clave_hash      TEXT NOT NULL UNIQUE,
52:   registrada      TEXT NOT NULL,
53:   ultima_conexion TEXT NOT NULL,
54:   revocada        INTEGER NOT NULL DEFAULT 0
55: );
56: 
57: CREATE TABLE ajustes (
58:   clave TEXT PRIMARY KEY,
59:   valor TEXT NOT NULL
60: );
61: 
62: -- México centro, sin horario de verano desde 2022.
63: INSERT INTO ajustes (clave, valor) VALUES ('zonaHoraria', '-06:00');
64: ''');
````

## File: backend/lib/src/db/base_datos.dart
````dart
 1: import 'package:sqlite3/sqlite3.dart';
 2: 
 3: /// Ruta especial para una base en memoria (pruebas y demos).
 4: const enMemoria = ':memory:';
 5: 
 6: /// Abre la base con la configuración del proyecto:
 7: /// - WAL: lecturas y escritura al mismo tiempo, y menos riesgo de corrupción.
 8: /// - Llaves foráneas activas (SQLite las trae apagadas).
 9: /// - Espera hasta 5 s si la base está ocupada en vez de fallar al instante.
10: Database abrirBaseDatos(String ruta) {
11:   final db = ruta == enMemoria ? sqlite3.openInMemory() : sqlite3.open(ruta);
12:   db.execute('PRAGMA journal_mode = WAL');
13:   db.execute('PRAGMA foreign_keys = ON');
14:   db.execute('PRAGMA busy_timeout = 5000');
15:   db.execute('PRAGMA synchronous = NORMAL');
16:   return db;
17: }
18: 
19: /// Ejecuta [accion] completa o no la ejecuta (estándar: toda operación de
20: /// dinero o existencias pasa por aquí).
21: ///
22: /// `BEGIN IMMEDIATE` toma el bloqueo de escritura al empezar, así dos ventas
23: /// simultáneas no pueden leer la misma existencia y descontarla dos veces.
24: T transaccion<T>(Database db, T Function() accion) {
25:   if (!db.autocommit) {
26:     throw StateError('Ya hay una transacción abierta; no se anidan');
27:   }
28:   db.execute('BEGIN IMMEDIATE');
29:   try {
30:     final resultado = accion();
31:     db.execute('COMMIT');
32:     return resultado;
33:   } catch (_) {
34:     db.execute('ROLLBACK');
35:     rethrow;
36:   }
37: }
````

## File: backend/lib/src/db/migraciones.dart
````dart
 1: import 'package:sqlite3/sqlite3.dart';
 2: 
 3: import '../comun/fechas.dart';
 4: import 'base_datos.dart';
 5: import 'migraciones/m001_inicial.dart';
 6: import 'migraciones/m002_ventas_pedidos_envases.dart';
 7: 
 8: class Migracion {
 9:   const Migracion(this.numero, this.nombre, this.sql);
10: 
11:   final int numero;
12:   final String nombre;
13:   final String sql;
14: }
15: 
16: /// Todas las migraciones, en orden.
17: ///
18: /// Reglas:
19: /// - Nunca se edita una migración ya publicada en un tag; se agrega otra.
20: /// - El número es consecutivo y no se repite (lo comprueba una prueba).
21: /// - Viven como texto en Dart y no como archivos .sql porque la app de
22: ///   Flutter no puede leer archivos sueltos del paquete del backend.
23: const migraciones = <Migracion>[m001Inicial, m002VentasPedidosEnvases];
24: 
25: /// Aplica las migraciones pendientes, cada una en su transacción.
26: ///
27: /// Si la base ya tenía datos y hay migraciones pendientes, antes guarda una
28: /// copia completa en [rutaRespaldo] (por ejemplo, al actualizar la app).
29: /// Regresa los números aplicados.
30: List<int> aplicarMigraciones(
31:   Database db, {
32:   String? Function(int versionActual)? rutaRespaldo,
33:   Reloj reloj = relojSistema,
34: }) {
35:   db.execute('''
36:     CREATE TABLE IF NOT EXISTS esquema_migraciones (
37:       numero  INTEGER PRIMARY KEY,
38:       nombre  TEXT NOT NULL,
39:       aplicada TEXT NOT NULL
40:     )
41:   ''');
42:   final actual = versionEsquema(db);
43:   final pendientes = migraciones.where((m) => m.numero > actual).toList();
44:   if (pendientes.isEmpty) return const [];
45: 
46:   if (actual > 0) {
47:     final ruta = rutaRespaldo?.call(actual);
48:     if (ruta != null) db.execute('VACUUM INTO ?', [ruta]);
49:   }
50: 
51:   for (final m in pendientes) {
52:     transaccion(db, () {
53:       db.execute(m.sql);
54:       db.execute(
55:         'INSERT INTO esquema_migraciones (numero, nombre, aplicada) VALUES (?, ?, ?)',
56:         [m.numero, m.nombre, instanteIso(reloj())],
57:       );
58:     });
59:   }
60:   return [for (final m in pendientes) m.numero];
61: }
62: 
63: int versionEsquema(Database db) =>
64:     db
65:             .select(
66:               'SELECT COALESCE(MAX(numero), 0) AS v FROM esquema_migraciones',
67:             )
68:             .first['v']
69:         as int;
````

## File: backend/lib/src/db/repositorio_ajustes.dart
````dart
 1: import 'package:sqlite3/sqlite3.dart';
 2: 
 3: import '../comun/fechas.dart';
 4: 
 5: class RepositorioAjustes {
 6:   RepositorioAjustes(this._db);
 7: 
 8:   final Database _db;
 9: 
10:   String? leer(String clave) {
11:     final filas = _db.select('SELECT valor FROM ajustes WHERE clave = ?', [
12:       clave,
13:     ]);
14:     return filas.isEmpty ? null : filas.first['valor'] as String;
15:   }
16: 
17:   /// Desfase de la zona del negocio respecto a UTC, para [diaNegocio].
18:   Duration get zonaHoraria =>
19:       parsearDesfase(leer('zonaHoraria') ?? '') ?? const Duration(hours: -6);
20: }
````

## File: backend/lib/src/db/repositorio_productos.dart
````dart
  1: import 'package:sqlite3/sqlite3.dart';
  2: 
  3: import '../comun/texto.dart';
  4: import '../modelos/producto.dart';
  5: 
  6: /// Acceso a `productos` y `movimientos`. Sin reglas de negocio: eso va en
  7: /// servicios/. Las escrituras se llaman dentro de una `transaccion`.
  8: class RepositorioProductos {
  9:   RepositorioProductos(this._db);
 10: 
 11:   final Database _db;
 12: 
 13:   // backend/lib/src/db/repositorio_productos.dart
 14: 
 15:   List<Producto> listar({String? busqueda, String? categoria}) {
 16:     final condiciones = ['eliminado = 0'];
 17:     final parametros = <Object?>[];
 18:     if (busqueda != null && busqueda.isNotEmpty) {
 19:       condiciones.add(
 20:         "(nombre_busqueda LIKE ? ESCAPE '^' OR codigo LIKE ? ESCAPE '^')",
 21:       );
 22:       final patron = '%${_escaparLike(normalizarBusqueda(busqueda))}%';
 23:       parametros.addAll([patron, patron]);
 24:     }
 25:     if (categoria != null && categoria.isNotEmpty) {
 26:       condiciones.add('categoria = ?');
 27:       parametros.add(categoria);
 28:     }
 29:     return _db
 30:         .select(
 31:           'SELECT * FROM productos WHERE ${condiciones.join(' AND ')} '
 32:           'ORDER BY nombre_busqueda, id',
 33:           parametros,
 34:         )
 35:         .map(_desdeFila)
 36:         .toList();
 37:   }
 38: 
 39:   Producto? porId(String id) {
 40:     final filas = _db.select(
 41:       'SELECT * FROM productos WHERE id = ? AND eliminado = 0',
 42:       [id],
 43:     );
 44:     return filas.isEmpty ? null : _desdeFila(filas.first);
 45:   }
 46: 
 47:   bool existeCodigo(String codigo) => _db.select(
 48:     'SELECT 1 FROM productos WHERE codigo = ? AND eliminado = 0',
 49:     [codigo],
 50:   ).isNotEmpty;
 51: 
 52:   void insertar(Producto p) {
 53:     _db.execute(
 54:       '''
 55:       INSERT INTO productos (id, codigo, nombre, nombre_busqueda, categoria, presentacion,
 56:         precio, precio_caja, piezas_por_caja, existencia_piezas, minimo, envase, caducidad,
 57:         foto, creado, actualizado)
 58:       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
 59:       ''',
 60:       [
 61:         p.id,
 62:         p.codigo,
 63:         p.nombre,
 64:         normalizarBusqueda(p.nombre),
 65:         p.categoria,
 66:         p.presentacion,
 67:         p.precio,
 68:         p.precioCaja,
 69:         p.piezasPorCaja,
 70:         p.existenciaPiezas,
 71:         p.minimo,
 72:         p.envase,
 73:         p.caducidad,
 74:         p.foto,
 75:         p.creado,
 76:         p.actualizado,
 77:       ],
 78:     );
 79:   }
 80: 
 81:   /// Registra un cambio de existencia. [piezas] lleva signo: `-3` en una venta.
 82:   void registrarMovimiento({
 83:     required String productoId,
 84:     required String tipo,
 85:     required int piezas,
 86:     required int existenciaResultante,
 87:     required String origen,
 88:     required String fecha,
 89:     String? referencia,
 90:     String? nota,
 91:   }) {
 92:     _db.execute(
 93:       '''
 94:       INSERT INTO movimientos (producto_id, tipo, piezas, existencia_resultante, referencia,
 95:         origen, nota, fecha)
 96:       VALUES (?, ?, ?, ?, ?, ?, ?, ?)
 97:       ''',
 98:       [
 99:         productoId,
100:         tipo,
101:         piezas,
102:         existenciaResultante,
103:         referencia,
104:         origen,
105:         nota,
106:         fecha,
107:       ],
108:     );
109:   }
110: 
111:   int contar() =>
112:       _db
113:               .select('SELECT COUNT(*) AS n FROM productos WHERE eliminado = 0')
114:               .first['n']
115:           as int;
116: 
117:   static String _escaparLike(String texto) =>
118:       texto.replaceAll('^', '^^').replaceAll('%', '^%').replaceAll('_', '^_');
119: 
120:   static Producto _desdeFila(Row f) => Producto(
121:     id: f['id'] as String,
122:     codigo: f['codigo'] as String,
123:     nombre: f['nombre'] as String,
124:     categoria: f['categoria'] as String,
125:     presentacion: f['presentacion'] as String?,
126:     precio: f['precio'] as int,
127:     precioCaja: f['precio_caja'] as int?,
128:     piezasPorCaja: f['piezas_por_caja'] as int?,
129:     existenciaPiezas: f['existencia_piezas'] as int,
130:     minimo: f['minimo'] as int,
131:     envase: f['envase'] as String?,
132:     caducidad: f['caducidad'] as String?,
133:     foto: f['foto'] as String?,
134:     creado: f['creado'] as String,
135:     actualizado: f['actualizado'] as String,
136:   );
137: }
````

## File: backend/lib/src/db/repositorio_terminales.dart
````dart
 1: import 'package:sqlite3/sqlite3.dart';
 2: 
 3: import '../modelos/terminal.dart';
 4: 
 5: class RepositorioTerminales {
 6:   RepositorioTerminales(this._db);
 7: 
 8:   final Database _db;
 9: 
10:   void insertar(Terminal t, {required String claveHash}) {
11:     _db.execute(
12:       'INSERT INTO terminales (id, nombre, clave_hash, registrada, ultima_conexion) '
13:       'VALUES (?, ?, ?, ?, ?)',
14:       [t.id, t.nombre, claveHash, t.registrada, t.ultimaConexion],
15:     );
16:   }
17: 
18:   List<Terminal> listarActivas() => _db
19:       .select('SELECT * FROM terminales WHERE revocada = 0 ORDER BY registrada')
20:       .map(_desdeFila)
21:       .toList();
22: 
23:   Terminal? activaPorHash(String claveHash) {
24:     final filas = _db.select(
25:       'SELECT * FROM terminales WHERE clave_hash = ? AND revocada = 0',
26:       [claveHash],
27:     );
28:     return filas.isEmpty ? null : _desdeFila(filas.first);
29:   }
30: 
31:   void marcarConexion(String id, String fecha) {
32:     _db.execute('UPDATE terminales SET ultima_conexion = ? WHERE id = ?', [
33:       fecha,
34:       id,
35:     ]);
36:   }
37: 
38:   /// Regresa `false` si no existía o ya estaba revocada.
39:   bool revocar(String id) {
40:     _db.execute(
41:       'UPDATE terminales SET revocada = 1 WHERE id = ? AND revocada = 0',
42:       [id],
43:     );
44:     return _db.updatedRows > 0;
45:   }
46: 
47:   static Terminal _desdeFila(Row f) => Terminal(
48:     id: f['id'] as String,
49:     nombre: f['nombre'] as String,
50:     registrada: f['registrada'] as String,
51:     ultimaConexion: f['ultima_conexion'] as String,
52:   );
53: }
````

## File: backend/lib/src/modelos/evento.dart
````dart
 1: /// Tipos de evento del WebSocket (docs/API.md, sección WebSocket).
 2: abstract final class TiposEvento {
 3:   static const conexionLista = 'conexion.lista';
 4:   static const productoActualizado = 'producto.actualizado';
 5:   static const pedidoCreado = 'pedido.creado';
 6:   static const pedidoAtendido = 'pedido.atendido';
 7:   static const balanceEnvasesActualizado = 'envases.actualizado';
 8: }
 9: 
10: /// Mensaje del servidor: `{ "tipo", "datos", "fecha" }`.
11: class Evento {
12:   const Evento({required this.tipo, required this.datos, required this.fecha});
13: 
14:   final String tipo;
15:   final Map<String, Object?> datos;
16: 
17:   /// ISO 8601 UTC.
18:   final String fecha;
19: 
20:   factory Evento.fromJson(Map<String, Object?> j) => Evento(
21:     tipo: j['tipo'] as String,
22:     datos: (j['datos'] as Map).cast<String, Object?>(),
23:     fecha: j['fecha'] as String,
24:   );
25: 
26:   Map<String, Object?> toJson() => {
27:     'tipo': tipo,
28:     'datos': datos,
29:     'fecha': fecha,
30:   };
31: }
````

## File: backend/lib/src/modelos/producto.dart
````dart
 1: /// Formatos de envase retornable.
 2: const formatosEnvase = {'mega', 'media', 'cuarto'};
 3: 
 4: /// Producto tal como lo describe docs/API.md. Lo usan el backend y la app,
 5: /// así los campos nunca se desincronizan.
 6: class Producto {
 7:   const Producto({
 8:     required this.id,
 9:     required this.codigo,
10:     required this.nombre,
11:     required this.categoria,
12:     this.presentacion,
13:     required this.precio,
14:     this.precioCaja,
15:     this.piezasPorCaja,
16:     required this.existenciaPiezas,
17:     required this.minimo,
18:     this.envase,
19:     this.caducidad,
20:     this.foto,
21:     required this.creado,
22:     required this.actualizado,
23:   });
24: 
25:   final String id;
26:   final String codigo;
27:   final String nombre;
28:   final String categoria;
29:   final String? presentacion;
30: 
31:   /// Centavos por pieza.
32:   final int precio;
33: 
34:   /// Centavos por caja; va junto con [piezasPorCaja].
35:   final int? precioCaja;
36:   final int? piezasPorCaja;
37:   final int existenciaPiezas;
38:   final int minimo;
39: 
40:   /// `mega`, `media`, `cuarto` o `null`.
41:   final String? envase;
42: 
43:   /// `AAAA-MM-DD`.
44:   final String? caducidad;
45:   final String? foto;
46: 
47:   /// ISO 8601 UTC.
48:   final String creado;
49:   final String actualizado;
50: 
51:   bool get seVendePorCaja => piezasPorCaja != null;
52: 
53:   bool get bajoMinimo => existenciaPiezas < minimo;
54: 
55:   factory Producto.fromJson(Map<String, Object?> j) => Producto(
56:     id: j['id'] as String,
57:     codigo: j['codigo'] as String,
58:     nombre: j['nombre'] as String,
59:     categoria: j['categoria'] as String,
60:     presentacion: j['presentacion'] as String?,
61:     precio: j['precio'] as int,
62:     precioCaja: j['precioCaja'] as int?,
63:     piezasPorCaja: j['piezasPorCaja'] as int?,
64:     existenciaPiezas: j['existenciaPiezas'] as int,
65:     minimo: j['minimo'] as int,
66:     envase: j['envase'] as String?,
67:     caducidad: j['caducidad'] as String?,
68:     foto: j['foto'] as String?,
69:     creado: j['creado'] as String,
70:     actualizado: j['actualizado'] as String,
71:   );
72: 
73:   Map<String, Object?> toJson() => {
74:     'id': id,
75:     'codigo': codigo,
76:     'nombre': nombre,
77:     'categoria': categoria,
78:     'presentacion': presentacion,
79:     'precio': precio,
80:     'precioCaja': precioCaja,
81:     'piezasPorCaja': piezasPorCaja,
82:     'existenciaPiezas': existenciaPiezas,
83:     'minimo': minimo,
84:     'envase': envase,
85:     'caducidad': caducidad,
86:     'foto': foto,
87:     'creado': creado,
88:     'actualizado': actualizado,
89:   };
90: }
````

## File: backend/lib/src/modelos/terminal.dart
````dart
 1: class Terminal {
 2:   const Terminal({
 3:     required this.id,
 4:     required this.nombre,
 5:     required this.registrada,
 6:     required this.ultimaConexion,
 7:     this.conectada = false,
 8:   });
 9: 
10:   final String id;
11:   final String nombre;
12: 
13:   /// ISO 8601 UTC.
14:   final String registrada;
15:   final String ultimaConexion;
16: 
17:   /// Tiene un WebSocket abierto en este momento.
18:   final bool conectada;
19: 
20:   Terminal conConexion(bool conectada) => Terminal(
21:     id: id,
22:     nombre: nombre,
23:     registrada: registrada,
24:     ultimaConexion: ultimaConexion,
25:     conectada: conectada,
26:   );
27: 
28:   factory Terminal.fromJson(Map<String, Object?> j) => Terminal(
29:     id: j['id'] as String,
30:     nombre: j['nombre'] as String,
31:     registrada: j['registrada'] as String,
32:     ultimaConexion: j['ultimaConexion'] as String,
33:     conectada: j['conectada'] as bool? ?? false,
34:   );
35: 
36:   Map<String, Object?> toJson() => {
37:     'id': id,
38:     'nombre': nombre,
39:     'registrada': registrada,
40:     'ultimaConexion': ultimaConexion,
41:     'conectada': conectada,
42:   };
43: }
44: 
45: /// Código de emparejamiento que la caja muestra en el QR.
46: class CodigoEmparejamiento {
47:   const CodigoEmparejamiento({required this.codigo, required this.expira});
48: 
49:   final String codigo;
50: 
51:   /// ISO 8601 UTC.
52:   final String expira;
53: 
54:   factory CodigoEmparejamiento.fromJson(Map<String, Object?> j) =>
55:       CodigoEmparejamiento(
56:         codigo: j['codigo'] as String,
57:         expira: j['expira'] as String,
58:       );
59: 
60:   Map<String, Object?> toJson() => {'codigo': codigo, 'expira': expira};
61: }
````

## File: backend/lib/src/rutas/rutas_productos.dart
````dart
 1: import 'package:shelf/shelf.dart';
 2: import 'package:shelf_router/shelf_router.dart';
 3: 
 4: import '../comun/json.dart';
 5: import '../comun/sesion.dart';
 6: import '../servicios/servicio_productos.dart';
 7: 
 8: /// Las rutas solo leen la petición y responden; la lógica está en el servicio.
 9: void montarRutasProductos(Router r, ServicioProductos productos) {
10:   r.get('/api/v1/productos', (Request p) {
11:     final q = p.url.queryParameters;
12:     final lista = productos.listar(busqueda: q['q'], categoria: q['categoria']);
13:     return respuestaJson({
14:       'productos': [for (final x in lista) x.toJson()],
15:     });
16:   });
17: 
18:   r.get('/api/v1/productos/<id>', (Request p, String id) {
19:     return respuestaJson(productos.obtener(id).toJson());
20:   });
21: 
22:   r.post('/api/v1/productos', (Request p) async {
23:     final sesion = exigirCaja(p);
24:     final producto = productos.crear(
25:       await leerObjetoJson(p),
26:       origen: sesion.nombre,
27:     );
28:     return respuestaJson(producto.toJson(), estado: 201);
29:   });
30: }
````

## File: backend/lib/src/rutas/rutas_terminales.dart
````dart
 1: import 'package:shelf/shelf.dart';
 2: import 'package:shelf_router/shelf_router.dart';
 3: 
 4: import '../comun/json.dart';
 5: import '../comun/sesion.dart';
 6: import '../servicios/servicio_terminales.dart';
 7: 
 8: void montarRutasTerminales(Router r, ServicioTerminales terminales) {
 9:   r.post('/api/v1/terminales/codigo', (Request p) {
10:     exigirCaja(p);
11:     return respuestaJson(terminales.crearCodigo().toJson(), estado: 201);
12:   });
13: 
14:   r.post('/api/v1/terminales/registro', (Request p) async {
15:     final registro = terminales.registrar(await leerObjetoJson(p));
16:     return respuestaJson({
17:       'terminal': registro.terminal.toJson(),
18:       'clave': registro.clave,
19:     }, estado: 201);
20:   });
21: 
22:   r.get('/api/v1/terminales', (Request p) {
23:     exigirCaja(p);
24:     return respuestaJson({
25:       'terminales': [for (final t in terminales.listar()) t.toJson()],
26:     });
27:   });
28: 
29:   r.delete('/api/v1/terminales/<id>', (Request p, String id) async {
30:     exigirCaja(p);
31:     await terminales.revocar(id);
32:     return Response(204);
33:   });
34: }
````

## File: backend/lib/src/seed/datos_ejemplo.dart
````dart
 1: import '../comun/fechas.dart';
 2: import '../servicios/servicio_productos.dart';
 3: 
 4: /// Productos del prototipo (docs/prototipo) para demos y para que el front
 5: /// pruebe con datos con forma real. Precios en centavos; "-" es vacío.
 6: ///
 7: /// Columnas: código | nombre | categoría | presentación | precio |
 8: /// precio caja | piezas por caja | existencia | mínimo | envase |
 9: /// días para caducar
10: const _tabla = '''
11: 7501064191015|Victoria Mega|cerveza|Mega 1.2 L|4200|48000|12|66|36|mega|120
12: 7501064191022|Corona Mega|cerveza|Mega 1.2 L|4400|50000|12|30|36|mega|95
13: 7501064191039|Modelo Especial|cerveza|Media 355 ml|2400|54000|24|120|48|media|40
14: 7501064191046|Corona Cuarto|cerveza|Cuarto 210 ml|1700|38000|24|200|48|cuarto|20
15: 7501064191053|Indio Mega|cerveza|Mega 1.2 L|4000|46000|12|14|24|mega|6
16: 7501064191060|Pacífico|cerveza|Media 355 ml|2500|56000|24|72|48|media|60
17: 7502000000017|Hielo en bolsa|hielo|Bolsa 5 kg|3500|-|-|18|10|-|-
18: 7502000000024|Coca-Cola|refresco|Botella 600 ml|2200|-|-|40|24|-|150
19: 7502000000031|Agua mineral|refresco|Botella 355 ml|1600|-|-|8|12|-|200
20: 7502000000048|Papas adobadas|botana|Bolsa 45 g|2000|-|-|25|20|-|12
21: 7502000000055|Cacahuates japoneses|botana|Bolsa 100 g|1800|-|-|6|15|-|45
22: ''';
23: 
24: /// Carga los productos de ejemplo. Las caducidades se calculan desde hoy en
25: /// la zona del negocio para que siempre haya alertas que mostrar.
26: void cargarDatosEjemplo(
27:   ServicioProductos productos, {
28:   required Duration zonaHoraria,
29:   Reloj reloj = relojSistema,
30: }) {
31:   final hoy = reloj();
32:   for (final linea in _tabla.trim().split('\n')) {
33:     final c = [for (final x in linea.split('|')) x == '-' ? null : x];
34:     int? n(int i) => c[i] == null ? null : int.parse(c[i]!);
35:     productos.crear({
36:       'codigo': c[0],
37:       'nombre': c[1],
38:       'categoria': c[2],
39:       'presentacion': c[3],
40:       'precio': n(4),
41:       'precioCaja': n(5),
42:       'piezasPorCaja': n(6),
43:       'existenciaPiezas': n(7),
44:       'minimo': n(8),
45:       'envase': c[9],
46:       'caducidad': n(10) == null
47:           ? null
48:           : diaNegocio(hoy.add(Duration(days: n(10)!)), zonaHoraria),
49:     }, origen: 'Datos de ejemplo');
50:   }
51: }
````

## File: backend/test/ayudantes/servidor_prueba.dart
````dart
  1: import 'dart:convert';
  2: import 'dart:io';
  3: 
  4: import 'package:deposito_backend/deposito_backend.dart';
  5: import 'package:http/http.dart' as http;
  6: 
  7: /// Servidor real con SQLite en memoria en un puerto libre, para pruebas e2e.
  8: ///
  9: /// ```dart
 10: /// late ServidorPrueba s;
 11: /// setUp(() async => s = await crearServidorDePrueba());
 12: /// tearDown(() => s.cerrar());
 13: /// ```
 14: Future<ServidorPrueba> crearServidorDePrueba({
 15:   bool datosEjemplo = false,
 16:   Reloj? reloj,
 17: }) async {
 18:   final servidor = DepositoServer(
 19:     rutaBaseDatos: enMemoria,
 20:     puerto: 0,
 21:     direccion: InternetAddress.loopbackIPv4,
 22:     datosEjemplo: datosEjemplo,
 23:     bitacora: Bitacora.silenciosa(),
 24:     reloj: reloj ?? () => DateTime.now().toUtc(),
 25:   );
 26:   await servidor.iniciar();
 27:   return ServidorPrueba._(servidor);
 28: }
 29: 
 30: class ServidorPrueba {
 31:   ServidorPrueba._(this.servidor)
 32:     : base = Uri.parse('http://127.0.0.1:${servidor.puertoActual}');
 33: 
 34:   final DepositoServer servidor;
 35:   final Uri base;
 36:   final _cliente = http.Client();
 37: 
 38:   String get claveCaja => servidor.claveCaja;
 39: 
 40:   Uri uri(String ruta) => base.resolve(ruta);
 41: 
 42:   /// [clave] `null` usa la de caja; `''` no manda clave.
 43:   Future<http.Response> get(String ruta, {String? clave}) =>
 44:       _cliente.get(uri(ruta), headers: _cabeceras(clave));
 45: 
 46:   Future<http.Response> post(String ruta, Object? cuerpo, {String? clave}) =>
 47:       _cliente.post(
 48:         uri(ruta),
 49:         headers: _cabeceras(clave),
 50:         body: cuerpo is String ? cuerpo : jsonEncode(cuerpo),
 51:       );
 52: 
 53:   Future<http.Response> delete(String ruta, {String? clave}) =>
 54:       _cliente.delete(uri(ruta), headers: _cabeceras(clave));
 55: 
 56:   /// Empareja una terminal como lo haría la app y regresa su clave.
 57:   Future<String> registrarTerminal([String nombre = 'Terminal S24']) async {
 58:     final codigo = json(
 59:       await post('/api/v1/terminales/codigo', null),
 60:     )['codigo'];
 61:     final r = await post('/api/v1/terminales/registro', {
 62:       'nombre': nombre,
 63:       'codigo': codigo,
 64:     }, clave: '');
 65:     return json(r)['clave'] as String;
 66:   }
 67: 
 68:   Future<void> cerrar() async {
 69:     _cliente.close();
 70:     await servidor.detener();
 71:   }
 72: 
 73:   Map<String, String> _cabeceras(String? clave) => {
 74:     'content-type': 'application/json',
 75:     if (clave != '') cabeceraClave: clave ?? claveCaja,
 76:   };
 77: }
 78: 
 79: Map<String, Object?> json(http.Response r) =>
 80:     jsonDecode(r.body) as Map<String, Object?>;
 81: 
 82: /// `codigo` del error del contrato.
 83: String? codigoError(http.Response r) =>
 84:     (json(r)['error'] as Map<String, Object?>?)?['codigo'] as String?;
 85: 
 86: /// Producto válido mínimo para pruebas; [cambios] reemplaza campos.
 87: Map<String, Object?> productoValido([
 88:   Map<String, Object?> cambios = const {},
 89: ]) => {
 90:   'codigo': '7501064191015',
 91:   'nombre': 'Victoria Mega',
 92:   'categoria': 'cerveza',
 93:   'presentacion': 'Mega 1.2 L',
 94:   'precio': 4200,
 95:   'precioCaja': 48000,
 96:   'piezasPorCaja': 12,
 97:   'existenciaPiezas': 66,
 98:   'minimo': 36,
 99:   'envase': 'mega',
100:   'caducidad': '2027-01-29',
101:   ...cambios,
102: };
````

## File: backend/test/api_test.dart
````dart
  1: import 'dart:async';
  2: import 'dart:convert';
  3: 
  4: import 'package:test/test.dart';
  5: import 'package:web_socket_channel/io.dart';
  6: 
  7: import 'ayudantes/servidor_prueba.dart';
  8: 
  9: /// Pruebas e2e: servidor real en un puerto libre, como lo usará la app.
 10: void main() {
 11:   late ServidorPrueba s;
 12: 
 13:   setUp(() async => s = await crearServidorDePrueba());
 14:   tearDown(() => s.cerrar());
 15: 
 16:   group('salud y errores generales', () {
 17:     test('GET /salud responde ok sin clave', () async {
 18:       final r = await s.get('/salud', clave: '');
 19:       expect(r.statusCode, 200);
 20:       expect(r.body, 'ok');
 21:     });
 22: 
 23:     test('sin clave responde 401 con el formato del contrato', () async {
 24:       final r = await s.get('/api/v1/productos', clave: '');
 25:       expect(r.statusCode, 401);
 26:       expect(codigoError(r), 'no_autorizado');
 27:       expect(r.headers['content-type'], contains('application/json'));
 28:     });
 29: 
 30:     test('una clave inventada es 401', () async {
 31:       final r = await s.get('/api/v1/productos', clave: 'inventada');
 32:       expect(r.statusCode, 401);
 33:     });
 34: 
 35:     test('una ruta que no existe es 404 no_encontrado', () async {
 36:       final r = await s.get('/api/v1/nada');
 37:       expect(r.statusCode, 404);
 38:       expect(codigoError(r), 'no_encontrado');
 39:     });
 40: 
 41:     test('un cuerpo que no es JSON es 400 json_invalido', () async {
 42:       final r = await s.post('/api/v1/productos', '{no es json');
 43:       expect(r.statusCode, 400);
 44:       expect(codigoError(r), 'json_invalido');
 45:     });
 46:   });
 47: 
 48:   group('productos', () {
 49:     test('la caja crea, consulta y lista', () async {
 50:       final creado = await s.post('/api/v1/productos', productoValido());
 51:       expect(creado.statusCode, 201);
 52:       final id = json(creado)['id'];
 53: 
 54:       final detalle = await s.get('/api/v1/productos/$id');
 55:       expect(detalle.statusCode, 200);
 56:       expect(json(detalle)['precio'], 4200);
 57: 
 58:       final lista = json(await s.get('/api/v1/productos?q=victoria'));
 59:       expect((lista['productos'] as List).single['id'], id);
 60:     });
 61: 
 62:     test('datos_invalidos dice qué campo falló', () async {
 63:       final r = await s.post(
 64:         '/api/v1/productos',
 65:         productoValido({'precio': 42.5}),
 66:       );
 67:       expect(r.statusCode, 400);
 68:       expect(codigoError(r), 'datos_invalidos');
 69:       expect((json(r)['error'] as Map)['campos'], contains('precio'));
 70:     });
 71: 
 72:     test('código repetido es 409 codigo_duplicado', () async {
 73:       await s.post('/api/v1/productos', productoValido());
 74:       final r = await s.post('/api/v1/productos', productoValido());
 75:       expect(r.statusCode, 409);
 76:       expect(codigoError(r), 'codigo_duplicado');
 77:     });
 78: 
 79:     test('una terminal consulta pero no crea', () async {
 80:       final clave = await s.registrarTerminal();
 81:       expect((await s.get('/api/v1/productos', clave: clave)).statusCode, 200);
 82:       final r = await s.post(
 83:         '/api/v1/productos',
 84:         productoValido(),
 85:         clave: clave,
 86:       );
 87:       expect(r.statusCode, 403);
 88:       expect(codigoError(r), 'solo_caja');
 89:     });
 90:   });
 91: 
 92:   group('terminales', () {
 93:     test('se empareja con el código del QR y su clave funciona', () async {
 94:       final clave = await s.registrarTerminal('Terminal S24');
 95:       expect(clave, hasLength(43));
 96:       final lista = json(await s.get('/api/v1/terminales'));
 97:       expect((lista['terminales'] as List).single['nombre'], 'Terminal S24');
 98:       expect((await s.get('/api/v1/productos', clave: clave)).statusCode, 200);
 99:     });
100: 
101:     test('un código sirve para una sola terminal', () async {
102:       final codigo = json(
103:         await s.post('/api/v1/terminales/codigo', null),
104:       )['codigo'];
105:       final cuerpo = {'nombre': 'A', 'codigo': codigo};
106:       expect(
107:         (await s.post(
108:           '/api/v1/terminales/registro',
109:           cuerpo,
110:           clave: '',
111:         )).statusCode,
112:         201,
113:       );
114:       final r = await s.post('/api/v1/terminales/registro', cuerpo, clave: '');
115:       expect(r.statusCode, 401);
116:       expect(codigoError(r), 'codigo_invalido');
117:     });
118: 
119:     test('cinco intentos fallidos invalidan el código', () async {
120:       final codigo =
121:           json(await s.post('/api/v1/terminales/codigo', null))['codigo']
122:               as String;
123:       final incorrecto = codigo == '000000' ? '111111' : '000000';
124:       for (var i = 0; i < 5; i++) {
125:         await s.post('/api/v1/terminales/registro', {
126:           'nombre': 'X',
127:           'codigo': incorrecto,
128:         }, clave: '');
129:       }
130:       final r = await s.post('/api/v1/terminales/registro', {
131:         'nombre': 'X',
132:         'codigo': codigo,
133:       }, clave: '');
134:       expect(r.statusCode, 401);
135:     });
136: 
137:     test(
138:       'una terminal no puede generar códigos ni listar terminales',
139:       () async {
140:         final clave = await s.registrarTerminal();
141:         expect(
142:           (await s.post(
143:             '/api/v1/terminales/codigo',
144:             null,
145:             clave: clave,
146:           )).statusCode,
147:           403,
148:         );
149:         expect(
150:           (await s.get('/api/v1/terminales', clave: clave)).statusCode,
151:           403,
152:         );
153:       },
154:     );
155: 
156:     test('revocar deja la clave sin efecto', () async {
157:       final clave = await s.registrarTerminal();
158:       final id =
159:           ((json(await s.get('/api/v1/terminales'))['terminales'] as List)
160:                   .single
161:               as Map)['id'];
162:       expect((await s.delete('/api/v1/terminales/$id')).statusCode, 204);
163:       expect((await s.get('/api/v1/productos', clave: clave)).statusCode, 401);
164:       expect((await s.delete('/api/v1/terminales/$id')).statusCode, 404);
165:     });
166:   });
167: 
168:   group('WebSocket', () {
169:     Future<StreamIterator<Map<String, Object?>>> conectar(String clave) async {
170:       final canal = IOWebSocketChannel.connect(
171:         s.uri('/api/v1/ws').replace(scheme: 'ws'),
172:         headers: {'x-clave-terminal': clave},
173:       );
174:       await canal.ready;
175:       addTearDown(canal.sink.close);
176:       return StreamIterator(
177:         canal.stream.map(
178:           (m) => jsonDecode(m as String) as Map<String, Object?>,
179:         ),
180:       );
181:     }
182: 
183:     test(
184:       'saluda con conexion.lista y avisa cuando se crea un producto',
185:       () async {
186:         final clave = await s.registrarTerminal();
187:         final eventos = await conectar(clave);
188: 
189:         expect(await eventos.moveNext(), isTrue);
190:         expect(eventos.current['tipo'], 'conexion.lista');
191: 
192:         final terminales =
193:             json(await s.get('/api/v1/terminales'))['terminales'] as List;
194:         expect((terminales.single as Map)['conectada'], isTrue);
195: 
196:         await s.post('/api/v1/productos', productoValido());
197:         expect(await eventos.moveNext(), isTrue);
198:         expect(eventos.current['tipo'], 'producto.actualizado');
199:         expect(
200:           ((eventos.current['datos'] as Map)['producto'] as Map)['codigo'],
201:           '7501064191015',
202:         );
203:       },
204:     );
205: 
206:     test('sin clave no conecta', () async {
207:       final canal = IOWebSocketChannel.connect(
208:         s.uri('/api/v1/ws').replace(scheme: 'ws'),
209:       );
210:       await expectLater(canal.ready, throwsA(anything));
211:     });
212:   });
213: 
214:   test(
215:     'con datos de ejemplo arranca con los productos del prototipo',
216:     () async {
217:       final conEjemplos = await crearServidorDePrueba(datosEjemplo: true);
218:       addTearDown(conEjemplos.cerrar);
219:       final lista =
220:           json(await conEjemplos.get('/api/v1/productos'))['productos'] as List;
221:       expect(lista, hasLength(11));
222:     },
223:   );
224: }
````

## File: backend/test/migraciones_test.dart
````dart
 1: import 'package:deposito_backend/src/db/base_datos.dart';
 2: import 'package:deposito_backend/src/db/migraciones.dart';
 3: import 'package:test/test.dart';
 4: 
 5: void main() {
 6:   test(
 7:     'los números de migración empiezan en 1, son consecutivos y no se repiten',
 8:     () {
 9:       final numeros = [for (final m in migraciones) m.numero];
10:       expect(numeros, List.generate(numeros.length, (i) => i + 1));
11:     },
12:   );
13: 
14:   test('todas las migraciones aplican sobre una base vacía', () {
15:     final db = abrirBaseDatos(enMemoria);
16:     addTearDown(db.close);
17:     final aplicadas = aplicarMigraciones(db);
18:     expect(aplicadas, [for (final m in migraciones) m.numero]);
19:     expect(versionEsquema(db), migraciones.last.numero);
20:   });
21: 
22:   test('volver a aplicar no hace nada ni pide respaldo', () {
23:     final db = abrirBaseDatos(enMemoria);
24:     addTearDown(db.close);
25:     aplicarMigraciones(db);
26:     var pidioRespaldo = false;
27:     final aplicadas = aplicarMigraciones(
28:       db,
29:       rutaRespaldo: (_) {
30:         pidioRespaldo = true;
31:         return null;
32:       },
33:     );
34:     expect(aplicadas, isEmpty);
35:     expect(pidioRespaldo, isFalse);
36:   });
37: 
38:   test('el código de barras es único solo entre productos activos', () {
39:     final db = abrirBaseDatos(enMemoria);
40:     addTearDown(db.close);
41:     aplicarMigraciones(db);
42:     void insertar(String id, int eliminado) => db.execute(
43:       "INSERT INTO productos (id, codigo, nombre, nombre_busqueda, categoria, precio, eliminado, creado, actualizado) "
44:       "VALUES (?, '750', 'X', 'x', 'c', 100, ?, 't', 't')",
45:       [id, eliminado],
46:     );
47:     insertar('p_1', 1);
48:     insertar('p_2', 0); // El eliminado no bloquea el código.
49:     expect(() => insertar('p_3', 0), throwsA(anything));
50:   });
51: 
52:   test('la base rechaza existencias negativas y precioCaja sin piezasPorCaja', () {
53:     final db = abrirBaseDatos(enMemoria);
54:     addTearDown(db.close);
55:     aplicarMigraciones(db);
56:     const sql =
57:         'INSERT INTO productos (id, codigo, nombre, nombre_busqueda, categoria, precio, '
58:         'precio_caja, piezas_por_caja, existencia_piezas, creado, actualizado) '
59:         "VALUES (?, ?, 'X', 'x', 'c', 100, ?, ?, ?, 't', 't')";
60:     expect(
61:       () => db.execute(sql, ['p_1', 'a', null, null, -1]),
62:       throwsA(anything),
63:     );
64:     expect(
65:       () => db.execute(sql, ['p_2', 'b', 500, null, 0]),
66:       throwsA(anything),
67:     );
68:   });
69: }
````

## File: backend/test/servicio_productos_test.dart
````dart
  1: import 'package:deposito_backend/deposito_backend.dart';
  2: import 'package:deposito_backend/src/comun/errores.dart';
  3: import 'package:deposito_backend/src/db/base_datos.dart';
  4: import 'package:deposito_backend/src/db/migraciones.dart';
  5: import 'package:deposito_backend/src/db/repositorio_productos.dart';
  6: import 'package:deposito_backend/src/servicios/servicio_productos.dart';
  7: import 'package:deposito_backend/src/ws/hub.dart';
  8: import 'package:sqlite3/sqlite3.dart';
  9: import 'package:test/test.dart';
 10: 
 11: import 'ayudantes/servidor_prueba.dart';
 12: 
 13: void main() {
 14:   late Database db;
 15:   late ServicioProductos servicio;
 16:   final ahora = DateTime.utc(2026, 10, 2, 18, 30);
 17: 
 18:   setUp(() {
 19:     db = abrirBaseDatos(enMemoria);
 20:     aplicarMigraciones(db);
 21:     servicio = ServicioProductos(
 22:       db: db,
 23:       repositorio: RepositorioProductos(db),
 24:       hub: Hub(version: 'prueba', bitacora: Bitacora.silenciosa()),
 25:       reloj: () => ahora,
 26:     );
 27:   });
 28:   tearDown(() => db.close());
 29: 
 30:   Map<String, String> camposConError(void Function() accion) {
 31:     try {
 32:       accion();
 33:     } on ErrorApi catch (e) {
 34:       expect(e.codigo, 'datos_invalidos');
 35:       return e.campos!;
 36:     }
 37:     fail('Se esperaba datos_invalidos');
 38:   }
 39: 
 40:   group('crear', () {
 41:     test('guarda el producto con fechas UTC e ID con prefijo', () {
 42:       final p = servicio.crear(productoValido(), origen: 'Caja');
 43:       expect(p.id, startsWith('p_'));
 44:       expect(p.creado, '2026-10-02T18:30:00Z');
 45:       expect(servicio.obtener(p.id).toJson(), p.toJson());
 46:     });
 47: 
 48:     test('registra la existencia inicial como movimiento de inventario', () {
 49:       final p = servicio.crear(
 50:         productoValido({'existenciaPiezas': 66}),
 51:         origen: 'Caja',
 52:       );
 53:       final m = db.select('SELECT * FROM movimientos WHERE producto_id = ?', [
 54:         p.id,
 55:       ]);
 56:       expect(m, hasLength(1));
 57:       expect(m.first['tipo'], 'inicial');
 58:       expect(m.first['piezas'], 66);
 59:       expect(m.first['existencia_resultante'], 66);
 60:       expect(m.first['origen'], 'Caja');
 61:     });
 62: 
 63:     test('sin existencia inicial no hay movimiento', () {
 64:       final p = servicio.crear(
 65:         productoValido({'existenciaPiezas': null}),
 66:         origen: 'Caja',
 67:       );
 68:       expect(p.existenciaPiezas, 0);
 69:       expect(db.select('SELECT 1 FROM movimientos'), isEmpty);
 70:     });
 71: 
 72:     test('el dinero con decimales se rechaza, no se redondea', () {
 73:       final campos = camposConError(
 74:         () => servicio.crear(productoValido({'precio': 42.5}), origen: 'Caja'),
 75:       );
 76:       expect(campos.keys, ['precio']);
 77:     });
 78: 
 79:     test('precioCaja y piezasPorCaja van juntos', () {
 80:       final campos = camposConError(
 81:         () => servicio.crear(
 82:           productoValido({'piezasPorCaja': null}),
 83:           origen: 'Caja',
 84:         ),
 85:       );
 86:       expect(campos.keys, ['piezasPorCaja']);
 87:     });
 88: 
 89:     test('responde todos los campos con error a la vez', () {
 90:       final campos = camposConError(
 91:         () => servicio.crear({
 92:           'codigo': '750 106',
 93:           'precio': 0,
 94:           'envase': 'litro',
 95:           'caducidad': '2026-02-30',
 96:         }, origen: 'Caja'),
 97:       );
 98:       expect(
 99:         campos.keys,
100:         unorderedEquals([
101:           'codigo',
102:           'nombre',
103:           'categoria',
104:           'precio',
105:           'envase',
106:           'caducidad',
107:         ]),
108:       );
109:     });
110: 
111:     test('un código repetido es codigo_duplicado y no deja nada a medias', () {
112:       servicio.crear(productoValido(), origen: 'Caja');
113:       expect(
114:         () =>
115:             servicio.crear(productoValido({'nombre': 'Otro'}), origen: 'Caja'),
116:         throwsA(
117:           isA<ErrorApi>().having((e) => e.codigo, 'codigo', 'codigo_duplicado'),
118:         ),
119:       );
120:       expect(db.select('SELECT 1 FROM productos'), hasLength(1));
121:       expect(db.select('SELECT 1 FROM movimientos'), hasLength(1));
122:     });
123: 
124:     test('la categoría se guarda en minúsculas', () {
125:       expect(
126:         servicio
127:             .crear(productoValido({'categoria': 'Cerveza'}), origen: 'Caja')
128:             .categoria,
129:         'cerveza',
130:       );
131:     });
132:   });
133: 
134:   group('listar', () {
135:     setUp(() {
136:       servicio.crear(
137:         productoValido({'codigo': '1', 'nombre': 'Pacífico'}),
138:         origen: 'Caja',
139:       );
140:       servicio.crear(
141:         productoValido({
142:           'codigo': '2',
143:           'nombre': 'Coca-Cola',
144:           'categoria': 'refresco',
145:         }),
146:         origen: 'Caja',
147:       );
148:       servicio.crear(
149:         productoValido({'codigo': '3', 'nombre': 'Agua 100%'}),
150:         origen: 'Caja',
151:       );
152:     });
153: 
154:     test('ordena por nombre', () {
155:       expect(servicio.listar().map((p) => p.nombre), [
156:         'Agua 100%',
157:         'Coca-Cola',
158:         'Pacífico',
159:       ]);
160:     });
161: 
162:     test('busca sin distinguir mayúsculas ni acentos', () {
163:       expect(servicio.listar(busqueda: 'PACIF').map((p) => p.nombre), [
164:         'Pacífico',
165:       ]);
166:     });
167: 
168:     test('busca por código', () {
169:       expect(servicio.listar(busqueda: '2').map((p) => p.nombre), [
170:         'Coca-Cola',
171:       ]);
172:     });
173: 
174:     test('% y _ en la búsqueda son texto, no comodines', () {
175:       expect(servicio.listar(busqueda: '%').map((p) => p.nombre), [
176:         'Agua 100%',
177:       ]);
178:     });
179: 
180:     test('filtra por categoría', () {
181:       expect(servicio.listar(categoria: 'refresco').map((p) => p.nombre), [
182:         'Coca-Cola',
183:       ]);
184:     });
185:   });
186: 
187:   test('obtener un ID inexistente es no_encontrado', () {
188:     expect(
189:       () => servicio.obtener('p_no'),
190:       throwsA(isA<ErrorApi>().having((e) => e.estado, 'estado', 404)),
191:     );
192:   });
193: }
````

## File: backend/analysis_options.yaml
````yaml
 1: # This file configures the static analysis results for your project (errors,
 2: # warnings, and lints).
 3: #
 4: # This enables the 'recommended' set of lints from `package:lints`.
 5: # This set helps identify many issues that may lead to problems when running
 6: # or consuming Dart code, and enforces writing Dart using a single, idiomatic
 7: # style and format.
 8: #
 9: # If you want a smaller set of lints you can change this to specify
10: # 'package:lints/core.yaml'. These are just the most critical lints
11: # (the recommended set includes the core lints).
12: # The core lints are also what is used by pub.dev for scoring packages.
13: 
14: include: package:lints/recommended.yaml
15: 
16: # Uncomment the following section to specify additional rules.
17: 
18: # linter:
19: #   rules:
20: #     - camel_case_types
21: 
22: # analyzer:
23: #   exclude:
24: #     - path/to/excluded/files/**
25: 
26: # For more information about the core and recommended set of lints, see
27: # https://dart.dev/go/core-lints
28: 
29: # For additional information about configuring this file, see
30: # https://dart.dev/tools/analysis
````

## File: docs/prototipo/index.html
````html
   1: <!DOCTYPE html>
   2: <html lang="es">
   3: <head>
   4: <meta charset="utf-8">
   5: <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
   6: <title>POS Depósito</title>
   7: <link rel="preconnect" href="https://fonts.googleapis.com">
   8: <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
   9: <link href="https://fonts.googleapis.com/css2?family=Barlow:wght@400;500;600;700&family=Barlow+Condensed:wght@500;600;700&display=swap" rel="stylesheet">
  10: <style>
  11: :root{
  12:   --bg:#E4ECEE; --surface:#FFFFFF; --surface-2:#F1F5F6; --surface-3:#E7EEF0; --ink:#1B2226; --ink-2:#56646B; --line:#CFDADE;
  13:   --vidrio:#3A2518; --vidrio-2:#4E3322; --vidrio-ink:#F6E7D2; --vidrio-ink-2:#C9AE8E;
  14:   --lager:#F0A500; --lager-ink:#2A1A00; --lager-soft:#FFF1CC;
  15:   --verde:#2E6B4E; --verde-soft:#DDEFE5; --alerta:#B8322A; --alerta-soft:#F9E0DD; --azul:#2F6690;
  16:   --pbg-cerveza:#F5E3C3; --pbg-refresco:#F4DEDC; --pbg-botana:#F7E6C8; --pbg-hielo:#D9ECF4; --pbg-otro:#E5E9EA;
  17:   --papel:#FFFDF6; --papel-ink:#2B2B2B; --sel:#3A2518; --sel-ink:#F6E7D2;
  18:   --shadow:0 1px 2px rgba(20,35,40,.06),0 8px 24px -12px rgba(20,35,40,.18);
  19:   --cond:"Barlow Condensed","Arial Narrow",Arial,sans-serif;
  20:   --body:"Barlow","Segoe UI",Roboto,Arial,sans-serif;
  21:   box-sizing:border-box;
  22:   padding-top:env(safe-area-inset-top,0px);
  23:   padding-bottom:env(safe-area-inset-bottom,0px);
  24: }
  25: @media (prefers-color-scheme: dark){
  26:   :root:not([data-theme="light"]){
  27:     --bg:#0F171A; --surface:#172226; --surface-2:#1F2C31; --surface-3:#26353B; --ink:#E7EEF0; --ink-2:#9AAAB0; --line:#2E3E44;
  28:     --vidrio:#24160D; --vidrio-2:#352216; --vidrio-ink:#F3E1C7; --vidrio-ink-2:#B89A78;
  29:     --lager:#F4B324; --lager-ink:#2A1A00; --lager-soft:#3A2C0C;
  30:     --verde:#5BB287; --verde-soft:#193428; --alerta:#E8645B; --alerta-soft:#3A1A18; --azul:#6FA8D6;
  31:     --pbg-cerveza:#3A2E1C; --pbg-refresco:#3A2322; --pbg-botana:#3B301E; --pbg-hielo:#1D3440; --pbg-otro:#2A3336; --sel:#F4B324; --sel-ink:#2A1A00;
  32:     --shadow:0 1px 2px rgba(0,0,0,.3),0 10px 28px -14px rgba(0,0,0,.6);
  33:   }
  34: }
  35: :root[data-theme="dark"]{
  36:   --bg:#0F171A; --surface:#172226; --surface-2:#1F2C31; --surface-3:#26353B; --ink:#E7EEF0; --ink-2:#9AAAB0; --line:#2E3E44;
  37:   --vidrio:#24160D; --vidrio-2:#352216; --vidrio-ink:#F3E1C7; --vidrio-ink-2:#B89A78;
  38:   --lager:#F4B324; --lager-ink:#2A1A00; --lager-soft:#3A2C0C;
  39:   --verde:#5BB287; --verde-soft:#193428; --alerta:#E8645B; --alerta-soft:#3A1A18; --azul:#6FA8D6;
  40:   --pbg-cerveza:#3A2E1C; --pbg-refresco:#3A2322; --pbg-botana:#3B301E; --pbg-hielo:#1D3440; --pbg-otro:#2A3336; --sel:#F4B324; --sel-ink:#2A1A00;
  41:   --shadow:0 1px 2px rgba(0,0,0,.3),0 10px 28px -14px rgba(0,0,0,.6);
  42: }
  43: html{scroll-padding-top:env(safe-area-inset-top,0px)}
  44: *,*::before,*::after{box-sizing:inherit}
  45: html,body{height:100%;margin:0}
  46: body{background:var(--bg);color:var(--ink);font-family:var(--body);font-size:17px;line-height:1.45;-webkit-tap-highlight-color:transparent}
  47: #app{height:100%}
  48: button,input,select,textarea{font:inherit;color:inherit}
  49: button{cursor:pointer}
  50: :focus-visible{outline:3px solid var(--lager);outline-offset:2px}
  51: h1,h2,h3,h4{font-family:var(--cond);font-weight:700;line-height:1.05;margin:0}
  52: small{font-size:14px}
  53: .muted{color:var(--ink-2)}
  54: svg.ico{width:22px;height:22px;flex-shrink:0}
  55: 
  56: /* Imagen de producto */
  57: .pimg{display:grid;place-items:center;overflow:hidden;border-radius:12px;flex-shrink:0}
  58: .pimg svg{width:100%;height:100%;display:block}
  59: img.pimg{object-fit:cover;background:var(--surface-2)}
  60: 
  61: /* Botones */
  62: .btn{display:inline-flex;align-items:center;justify-content:center;gap:8px;min-height:46px;border:1px solid var(--line);background:var(--surface);border-radius:10px;padding:8px 16px;font-weight:600;text-align:center;line-height:1.2}
  63: .btn:hover{background:var(--surface-2)}
  64: .btn-sm{min-height:38px;padding:5px 12px;font-size:15px}
  65: .btn-lg{min-height:62px;font-size:19px}
  66: .btn-primary{background:var(--lager);border-color:var(--lager);color:var(--lager-ink)}
  67: .btn-primary:hover{background:var(--lager);filter:brightness(1.05)}
  68: .btn-dark{background:var(--ink);border-color:var(--ink);color:var(--bg)}
  69: .btn-dark:hover{background:var(--ink);opacity:.9}
  70: .btn-danger{color:var(--alerta);border-color:var(--alerta)}
  71: .btn-ghost{border-color:transparent;background:transparent}
  72: .btn[disabled]{opacity:.45;cursor:not-allowed}
  73: .full{width:100%}
  74: .icon-btn{width:46px;height:46px;display:inline-grid;place-items:center;border:1px solid var(--line);background:var(--surface);border-radius:10px;padding:0}
  75: .badge{min-width:24px;height:24px;padding:0 7px;border-radius:999px;background:var(--alerta);color:#fff;font-size:13px;font-weight:600;display:inline-grid;place-items:center;font-family:var(--body)}
  76: .nav button[aria-current="page"] .badge{background:var(--vidrio);color:var(--vidrio-ink)}
  77: .dot{display:inline-block;width:9px;height:9px;border-radius:50%;background:#46C281;margin-right:7px;vertical-align:1px}
  78: .dot.off{background:#9A8B7A}
  79: 
  80: /* Caja */
  81: .caja{display:grid;grid-template-columns:236px 1fr;height:100%}
  82: .rail{background:var(--vidrio);color:var(--vidrio-ink);display:flex;flex-direction:column;padding:20px 14px;overflow:auto}
  83: .brand{display:flex;align-items:center;gap:10px;padding:0 8px 20px}
  84: .brand-mark{width:42px;height:42px;border-radius:12px;background:var(--lager);display:grid;place-items:center;flex-shrink:0}
  85: .brand-mark svg{width:28px;height:28px}
  86: .brand b{display:block;font-family:var(--cond);font-weight:700;font-size:26px;line-height:1}
  87: .brand small{display:block;color:var(--vidrio-ink-2);font-weight:500}
  88: .nav{display:flex;flex-direction:column;gap:3px}
  89: .nav button{display:flex;align-items:center;gap:12px;text-align:left;border:0;background:transparent;color:var(--vidrio-ink);padding:9px 12px;border-radius:10px;font-weight:500;font-size:18px;min-height:48px}
  90: .nav button .lbl{flex:1}
  91: .nav button:hover{background:var(--vidrio-2)}
  92: .nav button[aria-current="page"]{background:var(--lager);color:var(--lager-ink);font-weight:600}
  93: .rail-foot{margin-top:auto;padding:16px 8px 0;font-size:14px;color:var(--vidrio-ink-2);display:grid;gap:4px}
  94: .rail-foot b{color:var(--vidrio-ink);font-weight:600}
  95: .main{display:flex;flex-direction:column;min-width:0;min-height:0}
  96: .topbar{display:flex;align-items:center;gap:10px;padding:12px 24px;border-bottom:1px solid var(--line);background:var(--surface)}
  97: .topbar h1{font-size:34px;flex:1}
  98: .pill{font-size:14px;font-weight:500;color:var(--ink-2);background:var(--surface-2);border:1px solid var(--line);border-radius:999px;padding:6px 12px;white-space:nowrap}
  99: .host{flex:1;min-height:0;overflow:auto;padding:20px 24px 28px}
 100: .host-fixed{overflow:hidden;padding-bottom:20px}
 101: 
 102: /* Tablero */
 103: .hello{display:flex;justify-content:space-between;align-items:flex-end;gap:16px;margin-bottom:18px;flex-wrap:wrap}
 104: .hello h2{font-size:40px}
 105: .hello p{margin:4px 0 0;color:var(--ink-2)}
 106: .kpis{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:18px}
 107: .kpi{background:var(--surface);border:1px solid var(--line);border-radius:16px;padding:16px;box-shadow:var(--shadow);display:flex;gap:12px;align-items:flex-start}
 108: .kpi .kico{width:44px;height:44px;border-radius:12px;display:grid;place-items:center;flex-shrink:0;background:var(--lager-soft);color:var(--ink)}
 109: .kpi .kico.g{background:var(--verde-soft);color:var(--verde)}
 110: .kpi .kico.r{background:var(--alerta-soft);color:var(--alerta)}
 111: .kpi .kico.b{background:var(--surface-3);color:var(--azul)}
 112: .kpi small{color:var(--ink-2);display:block}
 113: .kpi b{display:block;font-family:var(--cond);font-size:34px;line-height:1.05}
 114: .dash{display:grid;grid-template-columns:1.6fr 1fr;gap:18px}
 115: .card{background:var(--surface);border:1px solid var(--line);border-radius:16px;padding:16px 18px;box-shadow:var(--shadow);min-width:0}
 116: .card-h{display:flex;justify-content:space-between;align-items:center;gap:10px;margin-bottom:10px}
 117: .card-h h3{font-size:24px}
 118: .chart{width:100%;height:auto;display:block}
 119: .chart text{font-family:var(--body);fill:var(--ink-2)}
 120: .rank{display:flex;align-items:center;gap:12px;padding:8px 0;border-bottom:1px solid var(--line)}
 121: .rank:last-child{border-bottom:0}
 122: .rank .pimg{width:48px;height:48px}
 123: .rank .info{flex:1;min-width:0}
 124: .rank .info b{display:block;line-height:1.2}
 125: .rank .num{font-family:var(--cond);font-size:24px;font-weight:700}
 126: .stack-cards{display:grid;gap:18px;align-content:start}
 127: 
 128: /* Vender */
 129: .sell{display:grid;grid-template-columns:1fr 400px;gap:20px;height:100%}
 130: .sell-left{display:flex;flex-direction:column;min-height:0}
 131: .toolbar{display:flex;gap:10px;margin-bottom:12px;flex-wrap:wrap;align-items:center}
 132: .search{flex:1;min-width:160px;min-height:50px;border:1px solid var(--line);background:var(--surface);border-radius:10px;padding:10px 14px}
 133: .chips{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:14px}
 134: .chip{min-height:40px;border:1px solid var(--line);background:var(--surface);border-radius:999px;padding:6px 16px;font-weight:500;display:inline-flex;align-items:center;gap:6px}
 135: .chip[aria-pressed="true"]{background:var(--sel);border-color:var(--sel);color:var(--sel-ink)}
 136: .grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(172px,1fr));gap:12px;overflow:auto;align-content:start;flex:1;min-height:0;padding:2px 2px 8px}
 137: .tile{position:relative;text-align:left;border:1px solid var(--line);background:var(--surface);border-radius:14px;padding:10px 10px 12px;display:flex;flex-direction:column;gap:2px;box-shadow:var(--shadow);transition:transform .08s}
 138: .tile:hover{border-color:var(--lager)}
 139: .tile:active{transform:scale(.97)}
 140: .tile .pimg{width:100%;height:104px;margin-bottom:8px}
 141: .tile .nm{font-weight:600;line-height:1.2;font-size:17px;padding:0 4px}
 142: .tile .fm{font-size:14px;color:var(--ink-2);padding:0 4px}
 143: .tile .pr{font-family:var(--cond);font-weight:700;font-size:30px;line-height:1;margin-top:6px;padding:0 4px}
 144: .tile .pr span{font-family:var(--body);font-size:13px;font-weight:500;color:var(--ink-2);margin-left:5px}
 145: .tile .st{font-size:13px;color:var(--ink-2);padding:0 4px}
 146: .tile .st.low{color:var(--alerta);font-weight:600}
 147: .tile .incart{position:absolute;top:8px;right:8px;background:var(--lager);color:var(--lager-ink);font-weight:700;border-radius:999px;min-width:28px;height:28px;display:grid;place-items:center;padding:0 8px;font-size:14px;box-shadow:var(--shadow)}
 148: .tile.out{opacity:.5}
 149: .ticket{background:var(--surface);border:1px solid var(--line);border-radius:18px;display:flex;flex-direction:column;min-height:0;box-shadow:var(--shadow)}
 150: .ticket-head{padding:14px 16px;border-bottom:1px solid var(--line);display:flex;justify-content:space-between;align-items:center;gap:8px}
 151: .ticket-head h2{font-size:26px}
 152: .ticket-head small{display:block;color:var(--ink-2);font-family:var(--body);font-weight:500}
 153: .lines{flex:1;overflow:auto;padding:4px 16px;min-height:80px}
 154: .empty{color:var(--ink-2);text-align:center;padding:28px 12px}
 155: .empty svg{width:120px;height:auto;display:block;margin:0 auto 10px}
 156: .line{padding:12px 0;border-bottom:1px dashed var(--line);display:grid;grid-template-columns:48px 1fr;gap:10px;border-radius:8px}
 157: .line:last-child{border-bottom:0}
 158: .line .pimg{width:48px;height:48px;border-radius:10px}
 159: .line.flash{animation:flash .7s ease-out}
 160: @keyframes flash{from{background:var(--lager-soft)}to{background:transparent}}
 161: .line-top{display:flex;justify-content:space-between;gap:8px;font-weight:600;line-height:1.2}
 162: .line-bot{display:flex;align-items:center;justify-content:space-between;margin-top:8px;gap:8px;flex-wrap:wrap}
 163: .seg{display:inline-flex;border:1px solid var(--line);border-radius:8px;overflow:hidden;flex-wrap:wrap}
 164: .seg button{border:0;background:transparent;padding:6px 12px;font-size:14px;font-weight:600;color:var(--ink-2);min-height:36px}
 165: .seg button[aria-pressed="true"]{background:var(--sel);color:var(--sel-ink)}
 166: .seg.wide{display:grid;grid-template-columns:repeat(3,1fr);width:100%}
 167: .qty{display:inline-flex;align-items:center;gap:8px}
 168: .qty button{width:40px;height:40px;border-radius:8px;border:1px solid var(--line);background:var(--surface-2);font-weight:700;font-size:20px;line-height:1}
 169: .qty span{min-width:26px;text-align:center;font-weight:600;font-size:18px}
 170: .env{padding:12px 16px;border-top:1px solid var(--line);font-size:15px;display:grid;gap:8px}
 171: .env-title{display:flex;align-items:center;gap:8px;font-weight:600}
 172: .env-row{display:flex;justify-content:space-between;color:var(--ink-2)}
 173: .total{padding:12px 16px;border-top:1px solid var(--line);display:flex;justify-content:space-between;align-items:baseline}
 174: .total b{font-family:var(--cond);font-size:54px;line-height:1;font-weight:700}
 175: .pay{display:grid;grid-template-columns:1fr 1fr;gap:10px;padding:0 16px 16px}
 176: .banner{display:flex;align-items:center;justify-content:space-between;gap:12px;background:var(--lager-soft);border:1px solid var(--lager);border-radius:12px;padding:10px 14px;margin-bottom:10px}
 177: .banner small{display:block;color:var(--ink-2)}
 178: .banner-act{display:flex;gap:8px;flex-shrink:0}
 179: .ban-imgs{display:flex;margin-right:4px}
 180: .ban-imgs .pimg{width:34px;height:34px;border-radius:50%;border:2px solid var(--lager-soft);margin-left:-8px}
 181: .ban-imgs .pimg:first-child{margin-left:0}
 182: 
 183: /* Tablas, paneles y listas */
 184: .table-wrap{overflow-x:auto;border:1px solid var(--line);border-radius:14px;background:var(--surface);box-shadow:var(--shadow)}
 185: table{border-collapse:collapse;width:100%;font-size:15px}
 186: th,td{padding:10px 14px;text-align:left;border-bottom:1px solid var(--line);white-space:nowrap;vertical-align:middle}
 187: th{font-weight:600;color:var(--ink-2);background:var(--surface-2)}
 188: tr:last-child td{border-bottom:0}
 189: tr.click{cursor:pointer}
 190: tr.click:hover td{background:var(--surface-2)}
 191: td.num,th.num{text-align:right;font-variant-numeric:tabular-nums}
 192: td small{display:block;color:var(--ink-2)}
 193: .cell-prod{display:flex;align-items:center;gap:12px}
 194: .cell-prod .pimg{width:46px;height:46px;border-radius:10px}
 195: .tag{display:inline-block;padding:2px 10px;border-radius:999px;font-size:13px;font-weight:600;background:var(--surface-2);border:1px solid var(--line);white-space:nowrap}
 196: .tag.low{background:var(--alerta-soft);color:var(--alerta);border-color:transparent}
 197: .tag.ok{background:var(--verde-soft);color:var(--verde);border-color:transparent}
 198: .tag.warn{background:var(--lager-soft);color:var(--ink);border-color:var(--lager)}
 199: .row-actions{display:flex;justify-content:space-between;align-items:center;margin:0 0 14px;gap:12px;flex-wrap:wrap}
 200: .row-actions h2{font-size:26px}
 201: .row-actions .acts{display:flex;gap:8px;flex-wrap:wrap}
 202: .panels{display:grid;grid-template-columns:repeat(3,1fr);gap:14px;margin-bottom:18px}
 203: .panel{background:var(--surface);border:1px solid var(--line);border-radius:16px;padding:16px;box-shadow:var(--shadow)}
 204: .panel h3{font-size:24px;margin-bottom:8px}
 205: .env-panel{display:grid;grid-template-columns:84px 1fr;gap:14px;align-items:center}
 206: .env-panel .pimg{width:84px;height:100px}
 207: .kv{display:flex;justify-content:space-between;gap:12px;padding:5px 0;color:var(--ink-2)}
 208: .kv b{color:var(--ink);font-variant-numeric:tabular-nums}
 209: .kv.sum{border-top:1px solid var(--line);margin-top:6px;padding-top:10px}
 210: .big{font-family:var(--cond);font-size:44px;font-weight:700;line-height:1}
 211: .two{display:grid;grid-template-columns:1fr 1fr;gap:18px;margin-bottom:18px}
 212: .list{background:var(--surface);border:1px solid var(--line);border-radius:16px;box-shadow:var(--shadow)}
 213: .list > h3{padding:14px 16px;border-bottom:1px solid var(--line);font-size:24px}
 214: .li{display:flex;justify-content:space-between;align-items:center;gap:12px;padding:12px 16px;border-bottom:1px solid var(--line)}
 215: .li:last-child{border-bottom:0}
 216: .li small{display:block;color:var(--ink-2)}
 217: .li .acts{display:flex;gap:8px;align-items:center;flex-shrink:0}
 218: .li .who{display:flex;align-items:center;gap:12px;min-width:0}
 219: .li .who .pimg{width:46px;height:46px;border-radius:10px}
 220: .avatar{width:42px;height:42px;border-radius:50%;display:grid;place-items:center;font-weight:700;background:var(--surface-3);color:var(--ink);flex-shrink:0}
 221: .bar{height:12px;border-radius:999px;background:var(--surface-2);overflow:hidden;margin-top:6px}
 222: .bar i{display:block;height:100%;background:var(--lager);border-radius:999px}
 223: .field{display:flex;flex-direction:column;gap:4px;margin-bottom:12px;font-size:15px;color:var(--ink-2)}
 224: .field input,.field select,.field textarea{border:1px solid var(--line);background:var(--surface);border-radius:10px;padding:10px 12px;color:var(--ink);min-height:48px;font-size:17px}
 225: .field input[type="color"]{padding:4px;min-height:44px;width:100%}
 226: .check{display:flex;gap:10px;align-items:center;margin-bottom:12px}
 227: .check input{width:22px;height:22px}
 228: .form{display:grid;grid-template-columns:1fr 1fr;gap:0 14px}
 229: .form .span{grid-column:1/-1}
 230: .diff-ok{color:var(--verde)} .diff-bad{color:var(--alerta)}
 231: .section{margin-bottom:22px}
 232: .section > h2{font-size:26px;margin-bottom:10px}
 233: .note{font-size:15px;color:var(--ink-2);margin:8px 0 0}
 234: .donut-wrap{display:flex;align-items:center;gap:18px}
 235: .donut-wrap svg{width:140px;height:140px;flex-shrink:0}
 236: .legend{display:grid;gap:6px}
 237: .legend span{display:flex;align-items:center;gap:8px}
 238: .legend i{width:12px;height:12px;border-radius:3px;display:inline-block}
 239: 
 240: /* Imagen en el formulario */
 241: .img-edit{display:grid;grid-template-columns:150px 1fr;gap:16px;align-items:start;margin-bottom:14px}
 242: .img-edit .pimg{width:150px;height:150px}
 243: .img-tools{display:grid;gap:10px}
 244: .img-tools .form{grid-template-columns:repeat(3,1fr);gap:0 10px}
 245: 
 246: /* Modal y avisos */
 247: .modal-bg{position:fixed;inset:0;background:rgba(10,16,19,.55);display:grid;place-items:center;z-index:50;padding:20px;backdrop-filter:blur(2px)}
 248: .modal-bg[hidden]{display:none}
 249: .modal{background:var(--surface);border-radius:20px;padding:24px;width:min(470px,100%);max-height:calc(100% - 20px);overflow:auto;box-shadow:0 30px 60px -20px rgba(0,0,0,.5);animation:pop .16s ease-out}
 250: @keyframes pop{from{transform:translateY(8px);opacity:0}to{transform:none;opacity:1}}
 251: .modal.wide{width:min(700px,100%)}
 252: .modal.xwide{width:min(860px,100%)}
 253: .modal h2{font-size:32px;margin-bottom:4px}
 254: .modal > p{margin:0 0 16px;color:var(--ink-2)}
 255: .quick{display:grid;grid-template-columns:repeat(4,1fr);gap:8px;margin-bottom:12px}
 256: .keypad{display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-bottom:14px}
 257: .keypad button{min-height:56px;border-radius:12px;border:1px solid var(--line);background:var(--surface-2);font-size:24px;font-weight:600}
 258: .keypad button:active{background:var(--lager-soft)}
 259: .change{background:var(--surface-2);border-radius:12px;padding:14px 16px;display:flex;justify-content:space-between;align-items:baseline;margin-bottom:16px}
 260: .change b{font-family:var(--cond);font-size:46px;line-height:1}
 261: .modal-actions{display:flex;gap:8px;justify-content:flex-end;flex-wrap:wrap;margin-top:6px}
 262: .share{display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-bottom:14px}
 263: .split{display:grid;grid-template-columns:320px 1fr;gap:22px;align-items:start}
 264: .qrbox{background:#fff;border-radius:12px;padding:12px;width:max-content;margin:4px auto 12px}
 265: .qrbox svg,.qrbox img{display:block;width:220px;height:220px}
 266: .addr{text-align:center;font-family:var(--cond);font-size:30px;font-weight:600;margin-bottom:14px}
 267: .toast{position:fixed;left:50%;bottom:calc(24px + env(safe-area-inset-bottom,0px));transform:translateX(-50%);background:var(--ink);color:var(--bg);padding:12px 18px;border-radius:12px;font-weight:600;z-index:60;opacity:0;transition:opacity .2s;pointer-events:none;max-width:min(560px,calc(100% - 32px));text-align:center}
 268: .toast.show{opacity:1}
 269: body[data-rol="terminal"] .toast{bottom:calc(100px + env(safe-area-inset-bottom,0px))}
 270: .detail{display:grid;grid-template-columns:200px 1fr;gap:20px;align-items:start}
 271: .detail .pimg{width:200px;height:200px}
 272: .detail .pr{font-family:var(--cond);font-size:44px;font-weight:700;line-height:1;margin:8px 0}
 273: 
 274: /* Recibo */
 275: .recibo{margin-bottom:14px;background:var(--papel);color:var(--papel-ink);font-family:"Courier New",Courier,monospace;font-size:13.5px;line-height:1.45;padding:20px 18px 26px;position:relative;box-shadow:0 10px 30px -12px rgba(0,0,0,.35);border-radius:4px 4px 0 0}
 276: .recibo::after{content:"";position:absolute;left:0;right:0;bottom:-10px;height:10px;background:linear-gradient(-45deg,transparent 7px,var(--papel) 0) 0 0/14px 10px repeat-x,linear-gradient(45deg,transparent 7px,var(--papel) 0) 0 0/14px 10px repeat-x}
 277: .recibo .c{text-align:center}
 278: .recibo .h{font-size:18px;font-weight:700;letter-spacing:.04em}
 279: .recibo .r{display:flex;justify-content:space-between;gap:10px}
 280: .recibo .hr{border-top:1px dashed #9a9a9a;margin:8px 0}
 281: .recibo .t{font-size:17px;font-weight:700}
 282: .recibo .sello{margin-top:8px;border:2px solid #B8322A;color:#B8322A;text-align:center;font-weight:700;padding:2px;transform:rotate(-4deg)}
 283: 
 284: /* Cámara */
 285: .cam{position:relative;height:300px;background:#1A1512;border-radius:14px;overflow:hidden;margin-bottom:14px}
 286: .cam video{width:100%;height:100%;object-fit:cover;display:block}
 287: .cam-msg{position:absolute;left:12px;right:12px;bottom:12px;text-align:center;color:#F1E6D8;font-size:14px;background:rgba(0,0,0,.55);padding:8px 10px;border-radius:8px}
 288: .corner{position:absolute;width:36px;height:36px;border:4px solid var(--lager)}
 289: .c1{top:34px;left:34px;border-right:0;border-bottom:0;border-radius:8px 0 0 0}
 290: .c2{top:34px;right:34px;border-left:0;border-bottom:0;border-radius:0 8px 0 0}
 291: .c3{bottom:60px;left:34px;border-right:0;border-top:0;border-radius:0 0 0 8px}
 292: .c4{bottom:60px;right:34px;border-left:0;border-top:0;border-radius:0 0 8px 0}
 293: .scanline{position:absolute;left:44px;right:44px;top:45%;height:2px;background:var(--lager);box-shadow:0 0 12px var(--lager);animation:scan 2.2s ease-in-out infinite alternate}
 294: @keyframes scan{from{top:22%}to{top:66%}}
 295: .pick{display:flex;flex-wrap:wrap;gap:6px;align-items:center;margin-bottom:12px;font-size:14px;color:var(--ink-2)}
 296: .pick .chip{min-height:38px;padding:3px 12px 3px 4px;font-size:14px}
 297: .pick .chip .pimg{width:30px;height:30px;border-radius:50%}
 298: 
 299: /* Terminal */
 300: .term{display:flex;flex-direction:column;height:100%;max-width:640px;margin:0 auto;background:var(--bg)}
 301: .term-top{background:var(--vidrio);color:var(--vidrio-ink);padding:18px 20px 16px;display:flex;justify-content:space-between;align-items:center;gap:12px}
 302: .term-top h1{font-size:36px}
 303: .term-top div small{color:var(--vidrio-ink-2);display:block;margin-top:4px}
 304: .term-top .icon-btn{background:var(--vidrio-2);border-color:transparent;color:var(--vidrio-ink)}
 305: .term-body{flex:1;overflow:auto;padding:18px}
 306: .tabs{display:grid;grid-template-columns:repeat(4,1fr);border-top:1px solid var(--line);background:var(--surface);padding:6px 6px 10px}
 307: .tabs button{border:0;background:transparent;padding:8px 4px;border-radius:12px;font-weight:600;font-size:14px;color:var(--ink-2);display:flex;flex-direction:column;align-items:center;gap:3px;min-height:58px}
 308: .tabs button[aria-current="page"]{color:var(--ink);background:var(--lager-soft)}
 309: .scan-big{width:100%;min-height:150px;border:2px dashed var(--lager);background:var(--surface);border-radius:18px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:8px;font-weight:600;font-size:20px;margin-bottom:14px}
 310: .scan-big svg{width:44px;height:44px}
 311: .pcard{background:var(--surface);border:1px solid var(--line);border-radius:18px;padding:16px;margin-top:14px;box-shadow:var(--shadow)}
 312: .pcard .top{display:flex;gap:14px;align-items:center}
 313: .pcard .top .pimg{width:110px;height:110px}
 314: .pcard .nm{font-weight:600;font-size:20px;line-height:1.2}
 315: .pcard .pr{font-family:var(--cond);font-size:40px;font-weight:700;line-height:1;margin-top:6px}
 316: .stack{display:flex;flex-direction:column;gap:10px}
 317: .inline{display:flex;gap:8px}
 318: .inline input{flex:1;min-width:0;min-height:50px;border:1px solid var(--line);background:var(--surface);border-radius:10px;padding:10px 12px}
 319: .tgrid{display:grid;grid-template-columns:repeat(auto-fill,minmax(150px,1fr));gap:10px}
 320: .tgrid .tile .pimg{height:90px}
 321: 
 322: /* Inicio */
 323: .start{min-height:100%;display:grid;place-items:center;padding:40px 24px}
 324: .start-in{max-width:860px;width:100%}
 325: .hero{display:grid;grid-template-columns:1fr 320px;gap:28px;align-items:center;margin-bottom:26px}
 326: .hero svg{width:100%;height:auto}
 327: .start h1{font-size:54px;margin-bottom:10px}
 328: .start-in p.lead{color:var(--ink-2);margin:0;font-size:18px}
 329: .choices{display:grid;grid-template-columns:1fr 1fr;gap:16px}
 330: .choice{text-align:left;border:2px solid var(--line);background:var(--surface);border-radius:18px;padding:22px;min-height:170px;display:grid;grid-template-columns:56px 1fr;gap:14px;align-items:start;box-shadow:var(--shadow)}
 331: .choice:hover{border-color:var(--lager)}
 332: .choice[aria-pressed="true"]{border-color:var(--lager);background:var(--lager-soft)}
 333: .choice .cico{width:56px;height:56px;border-radius:14px;background:var(--lager);color:var(--lager-ink);display:grid;place-items:center}
 334: .choice .cico svg{width:30px;height:30px}
 335: .choice b{display:block;font-family:var(--cond);font-size:34px;line-height:1;margin-bottom:8px}
 336: .choice span{color:var(--ink-2)}
 337: .next{margin-top:18px;background:var(--surface);border:1px solid var(--line);border-radius:18px;padding:20px}
 338: .next h2{font-size:28px;margin-bottom:6px}
 339: 
 340: @media (prefers-reduced-motion: reduce){.scanline,.line.flash,.modal{animation:none}.toast,.tile{transition:none}}
 341: @media (max-width:1240px){ .caja{grid-template-columns:204px 1fr} .nav button{font-size:17px} .sell{grid-template-columns:1fr 352px} .grid{grid-template-columns:repeat(auto-fill,minmax(148px,1fr))} .tile .pimg{height:86px} .tile .pr{font-size:26px} }
 342: @media (max-width:1100px){ .kpis{grid-template-columns:repeat(2,1fr)} .dash{grid-template-columns:1fr} .sell{grid-template-columns:1fr 350px} }
 343: @media (max-width:900px){
 344:   .caja{grid-template-columns:1fr;grid-template-rows:auto 1fr}
 345:   .rail{flex-direction:row;align-items:center;padding:8px;overflow-x:auto}
 346:   .brand,.rail-foot{display:none}
 347:   .nav{flex-direction:row}
 348:   .nav button{white-space:nowrap;min-height:44px;font-size:16px}
 349:   .topbar{padding:10px 16px}
 350:   .topbar h1{font-size:28px}
 351:   .topbar .pill{display:none}
 352:   .host{padding:16px}
 353:   .host-fixed{overflow:auto}
 354:   .sell{grid-template-columns:1fr;height:auto}
 355:   .grid{overflow:visible}
 356:   .panels,.two,.choices,.form,.split,.hero,.detail,.img-edit{grid-template-columns:1fr}
 357:   .start h1{font-size:40px}
 358: }
 359: @media (max-width:560px){ .kpis{grid-template-columns:1fr} }
 360: </style>
 361: </head>
 362: <body>
 363: <div id="app"></div>
 364: <div class="modal-bg" id="modal" hidden><div class="modal" id="modal-box" role="dialog" aria-modal="true"></div></div>
 365: <div class="toast" id="toast" role="status" aria-live="polite"></div>
 366: 
 367: <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
 368: <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcode-generator/1.4.4/qrcode.min.js"></script>
 369: <script>
 370: (function(){
 371: "use strict";
 372: 
 373: /* ================= Utilidades ================= */
 374: const $ = s => document.querySelector(s);
 375: const DAY = 864e5;
 376: const uid = () => Date.now().toString(36) + Math.random().toString(36).slice(2,7);
 377: const esc = s => String(s == null ? "" : s).replace(/[&<>"']/g, c => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
 378: const money = n => { const v = Math.round((+n || 0) * 100) / 100; return "$" + v.toLocaleString("es-MX", { minimumFractionDigits: v % 1 ? 2 : 0, maximumFractionDigits: 2 }); };
 379: const hoy0 = () => { const d = new Date(); d.setHours(0,0,0,0); return d; };
 380: const addDays = (d, n) => new Date(d.getTime() + n * DAY);
 381: const isoDate = d => d.getFullYear() + "-" + String(d.getMonth()+1).padStart(2,"0") + "-" + String(d.getDate()).padStart(2,"0");
 382: const diasPara = s => s ? Math.round((new Date(s + "T00:00:00") - hoy0()) / DAY) : null;
 383: const fHora = s => new Date(s).toLocaleTimeString("es-MX", { hour:"2-digit", minute:"2-digit" });
 384: const fFecha = s => new Date(s).toLocaleDateString("es-MX", { day:"numeric", month:"short" });
 385: const fFechaHora = s => new Date(s).toLocaleString("es-MX", { day:"2-digit", month:"2-digit", year:"numeric", hour:"2-digit", minute:"2-digit" });
 386: const fCad = s => s ? new Date(s + "T00:00:00").toLocaleDateString("es-MX", { day:"numeric", month:"short", year:"numeric" }) : "Sin fecha";
 387: const plural = (n, a, b) => n + " " + (n === 1 ? a : b);
 388: const cap = s => s.charAt(0).toUpperCase() + s.slice(1);
 389: const CATS = [["cerveza","Cerveza"],["refresco","Refrescos"],["botana","Botanas"],["hielo","Hielo"],["otro","Otros"]];
 390: const CATN = Object.fromEntries(CATS);
 391: const ENVN = { mega:"Mega", media:"Media", cuarto:"Cuarto" };
 392: const FORMAS = [["mega","Botella mega"],["media","Botella media"],["cuarto","Botella cuarto"],["lata","Lata"],["pet","Botella de plástico"],["bolsa","Bolsa"],["hielo","Bolsa de hielo"],["caja","Caja"]];
 393: const lsGet = k => { try { return localStorage.getItem(k); } catch(e) { return null; } };
 394: const lsSet = (k, v) => { try { localStorage.setItem(k, v); return true; } catch(e) { return false; } };
 395: const ssGet = k => { try { return sessionStorage.getItem(k); } catch(e) { return null; } };
 396: const ssSet = (k, v) => { try { sessionStorage.setItem(k, v); } catch(e) {} };
 397: const reduceMotion = () => window.matchMedia && matchMedia("(prefers-reduced-motion: reduce)").matches;
 398: 
 399: /* ================= Íconos ================= */
 400: const IC = {
 401:   inicio:'<path d="M3 11l9-7 9 7v9a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z"/>',
 402:   vender:'<circle cx="9" cy="20" r="1.5"/><circle cx="18" cy="20" r="1.5"/><path d="M2 3h3l2.7 12.4a1 1 0 0 0 1 .8h9.6a1 1 0 0 0 1-.8L21 7H6"/>',
 403:   ventas:'<path d="M6 3h12v18l-3-2-3 2-3-2-3 2zM9 8h6M9 12h6M9 16h3"/>',
 404:   catalogo:'<rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/>',
 405:   envases:'<path d="M10 2h4v4l2 3v12a1 1 0 0 1-1 1H9a1 1 0 0 1-1-1V9l2-3z"/><path d="M8 13h8"/>',
 406:   corte:'<rect x="2" y="6" width="20" height="13" rx="2"/><circle cx="12" cy="12.5" r="3"/><path d="M6 10v5M18 10v5"/>',
 407:   alertas:'<path d="M6 8a6 6 0 1 1 12 0c0 7 3 8 3 8H3s3-1 3-8"/><path d="M10 20a2 2 0 0 0 4 0"/>',
 408:   resurtido:'<path d="M2 6h11v10H2zM13 10h4l4 4v2h-8z"/><circle cx="6" cy="18" r="2"/><circle cx="17" cy="18" r="2"/>',
 409:   ajustes:'<circle cx="12" cy="12" r="3"/><path d="M12 2v3M12 19v3M4.2 4.2l2.1 2.1M17.7 17.7l2.1 2.1M2 12h3M19 12h3M4.2 19.8l2.1-2.1M17.7 6.3l2.1-2.1"/>',
 410:   escanear:'<path d="M4 7V5a1 1 0 0 1 1-1h2M17 4h2a1 1 0 0 1 1 1v2M20 17v2a1 1 0 0 1-1 1h-2M7 20H5a1 1 0 0 1-1-1v-2M8 8v8M11 8v8M14 8v8M17 8v8"/>',
 411:   pedido:'<path d="M6 3h12v18l-3-2-3 2-3-2-3 2zM9 8h6M9 12h6"/>',
 412:   stock:'<path d="M3 8l9-5 9 5-9 5zM3 8v8l9 5 9-5V8M12 13v8"/>',
 413:   sol:'<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>',
 414:   luna:'<path d="M20 14.5A8 8 0 1 1 9.5 4a6.5 6.5 0 0 0 10.5 10.5z"/>',
 415:   auto:'<circle cx="12" cy="12" r="9"/><path d="M12 3v18" /><path d="M12 3a9 9 0 0 1 0 18z" fill="currentColor"/>',
 416:   qr:'<rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><path d="M14 14h3v3M21 14v7h-7M17 21v-3"/>',
 417:   caja:'<rect x="3" y="4" width="18" height="12" rx="2"/><path d="M8 20h8M12 16v4"/>',
 418:   tel:'<rect x="7" y="2" width="10" height="20" rx="2"/><path d="M11 18h2"/>',
 419:   dinero:'<rect x="2" y="6" width="20" height="12" rx="2"/><circle cx="12" cy="12" r="2.5"/>',
 420:   ticket:'<path d="M4 7a2 2 0 0 0 2-2h12a2 2 0 0 0 2 2v2a3 3 0 0 0 0 6v2a2 2 0 0 0-2 2H6a2 2 0 0 0-2-2v-2a3 3 0 0 0 0-6z"/>',
 421:   mas:'<path d="M12 5v14M5 12h14"/>',
 422:   wifi:'<path d="M2 9a15 15 0 0 1 20 0M5 12.5a10 10 0 0 1 14 0M8.5 16a5 5 0 0 1 7 0"/><circle cx="12" cy="19.5" r="1"/>'
 423: };
 424: const ico = (k, cls) => `<svg class="ico ${cls || ""}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${IC[k]}</svg>`;
 425: 
 426: /* ================= Ilustraciones de producto ================= */
 427: const FORM_DIMS = { mega:{y0:16,ys:36,y1:54,y2:108,nw:13,bw:40}, media:{y0:22,ys:44,y1:60,y2:106,nw:11,bw:32}, cuarto:{y0:40,ys:56,y1:68,y2:104,nw:10,bw:27}, pet:{y0:20,ys:30,y1:46,y2:108,nw:15,bw:38} };
 428: function botella(o, c1, c2, c3, pet){
 429:   const c = 60, L = c - o.bw/2, R = c + o.bw/2, nl = c - o.nw/2, nr = c + o.nw/2;
 430:   const d = `M${nl} ${o.y0} L${nl} ${o.ys} C${nl} ${o.ys+10} ${L} ${o.y1-10} ${L} ${o.y1} L${L} ${o.y2-6} Q${L} ${o.y2} ${L+6} ${o.y2} L${R-6} ${o.y2} Q${R} ${o.y2} ${R} ${o.y2-6} L${R} ${o.y1} C${R} ${o.y1-10} ${nr} ${o.ys+10} ${nr} ${o.ys} L${nr} ${o.y0} Z`;
 431:   const lh = (o.y2 - o.y1) * (pet ? .34 : .42), ly = o.y1 + (o.y2 - o.y1) * (pet ? .22 : .28);
 432:   let s = `<path d="${d}" fill="${c1}" ${pet ? 'fill-opacity=".85"' : ""}/>`;
 433:   if (pet) s += `<path d="M${L} ${o.y2-14} H${R} M${L} ${o.y2-22} H${R}" stroke="#fff" stroke-opacity=".35" stroke-width="2"/>`;
 434:   s += `<rect x="${L}" y="${ly}" width="${o.bw}" height="${lh}" fill="${c2}"/>`;
 435:   s += `<rect x="${L}" y="${ly + lh*.7}" width="${o.bw}" height="${lh*.12}" fill="#fff" fill-opacity=".5"/>`;
 436:   s += `<circle cx="${c}" cy="${ly + lh*.38}" r="${Math.min(o.bw, lh) * .2}" fill="#fff" fill-opacity=".55"/>`;
 437:   s += `<rect x="${nl-1.5}" y="${o.y0-6}" width="${o.nw+3}" height="8" rx="2" fill="${c3}"/>`;
 438:   if (!pet) s += `<rect x="${nl}" y="${o.ys-5}" width="${o.nw}" height="6" fill="${c2}"/>`;
 439:   s += `<path d="M${L+5} ${o.y1+3} L${L+5} ${o.y2-10}" stroke="#fff" stroke-opacity=".38" stroke-width="3" stroke-linecap="round"/>`;
 440:   return s;
 441: }
 442: function ilusSVG(p){
 443:   const il = p.ilus || { forma:"caja", c1:"#B98B55", c2:"#8C5A2B", c3:"#E3C08F" };
 444:   const bg = `var(--pbg-${CATN[p.cat] ? p.cat : "otro"})`;
 445:   let body = "";
 446:   const f = il.forma;
 447:   if (FORM_DIMS[f]) body = botella(FORM_DIMS[f], il.c1, il.c2, il.c3, f === "pet");
 448:   else if (f === "lata"){
 449:     body = `<rect x="40" y="32" width="40" height="76" rx="7" fill="${il.c1}"/><ellipse cx="60" cy="33" rx="20" ry="5" fill="${il.c3}"/><rect x="40" y="55" width="40" height="30" fill="${il.c2}"/><circle cx="60" cy="70" r="8" fill="#fff" fill-opacity=".55"/><path d="M45 38v62" stroke="#fff" stroke-opacity=".35" stroke-width="3" stroke-linecap="round"/>`;
 450:   } else if (f === "bolsa"){
 451:     let top = "M30 30", bot = "";
 452:     for (let x = 30; x < 90; x += 6) top += ` L${x+3} 24 L${x+6} 30`;
 453:     for (let x = 90; x > 30; x -= 6) bot += ` L${x-3} 108 L${x-6} 102`;
 454:     body = `<path d="${top} L92 44 L90 102 ${bot} L30 102 L28 44 Z" fill="${il.c1}"/>
 455:       <path d="M29 50 H91" stroke="${il.c2}" stroke-width="7"/>
 456:       <ellipse cx="60" cy="78" rx="22" ry="17" fill="#fff" fill-opacity=".85"/>
 457:       <circle cx="52" cy="76" r="7" fill="${il.c3}"/><circle cx="64" cy="72" r="6" fill="${il.c3}"/><circle cx="66" cy="84" r="6.5" fill="${il.c3}"/><circle cx="55" cy="86" r="5" fill="${il.c3}"/>
 458:       <path d="M36 36 L34 96" stroke="#fff" stroke-opacity=".35" stroke-width="3" stroke-linecap="round"/>`;
 459:   } else if (f === "hielo"){
 460:     body = `<path d="M36 42 Q38 30 52 29 L68 29 Q82 30 84 42 L90 100 Q90 109 81 109 L39 109 Q30 109 30 100 Z" fill="${il.c1}" fill-opacity=".92"/>
 461:       <path d="M52 29 Q60 16 68 29" fill="none" stroke="${il.c3}" stroke-width="4" stroke-linecap="round"/><rect x="50" y="25" width="20" height="7" rx="3" fill="${il.c3}"/>
 462:       ${[[44,58],[62,54],[50,76],[68,74],[42,92],[60,93],[76,92]].map(([x,y]) => `<rect x="${x-8}" y="${y-8}" width="16" height="16" rx="4" fill="#fff" fill-opacity=".85" stroke="${il.c2}" stroke-opacity=".5"/>`).join("")}
 463:       <rect x="38" y="62" width="44" height="12" rx="3" fill="${il.c2}" fill-opacity=".9"/>`;
 464:   } else {
 465:     body = `<rect x="22" y="44" width="76" height="60" rx="6" fill="${il.c1}"/><path d="M22 60 H98 M22 76 H98 M22 92 H98" stroke="${il.c2}" stroke-width="3"/><rect x="44" y="50" width="32" height="12" rx="4" fill="${il.c3}"/>`;
 466:   }
 467:   return `<svg viewBox="0 0 120 120" aria-hidden="true"><circle cx="60" cy="64" r="54" style="fill:${bg}"/><ellipse cx="60" cy="110" rx="30" ry="5" fill="#000" fill-opacity=".08"/>${body}</svg>`;
 468: }
 469: const imgProd = (p, cls) => p && p.foto ? `<img class="pimg ${cls || ""}" src="${p.foto}" alt="">` : `<span class="pimg ${cls || ""}">${ilusSVG(p || {})}</span>`;
 470: const imgEnvase = f => imgProd({ cat:"cerveza", ilus:{ forma:f, c1:"#7A5A3A", c2:"#C9B79C", c3:"#9A8B7A" } });
 471: 
 472: const EMPTY_SVG = `<svg viewBox="0 0 160 110" aria-hidden="true"><rect x="20" y="46" width="120" height="54" rx="8" fill="var(--surface-3)"/><path d="M20 64h120M20 82h120" stroke="var(--line)" stroke-width="3"/><path d="M52 46V26a4 4 0 0 1 4-4h8a4 4 0 0 1 4 4v20M92 46V18a4 4 0 0 1 4-4h8a4 4 0 0 1 4 4v28" fill="none" stroke="var(--ink-2)" stroke-width="3" stroke-linecap="round"/><rect x="56" y="30" width="8" height="10" rx="2" fill="var(--lager)"/><rect x="96" y="22" width="8" height="12" rx="2" fill="var(--lager)"/></svg>`;
 473: const HERO_SVG = `<svg viewBox="0 0 320 230" aria-hidden="true">
 474:   <rect x="10" y="30" width="210" height="150" rx="16" fill="var(--ink)"/><rect x="20" y="40" width="190" height="130" rx="8" fill="var(--surface)"/>
 475:   <rect x="20" y="40" width="40" height="130" fill="var(--vidrio)"/><rect x="26" y="50" width="28" height="8" rx="3" fill="var(--lager)"/>
 476:   <rect x="26" y="66" width="28" height="5" rx="2" fill="var(--vidrio-ink-2)"/><rect x="26" y="78" width="28" height="5" rx="2" fill="var(--vidrio-ink-2)"/><rect x="26" y="90" width="28" height="5" rx="2" fill="var(--vidrio-ink-2)"/>
 477:   ${[0,1,2].map(i => [0,1].map(j => `<rect x="${68+i*33}" y="${50+j*50}" width="28" height="42" rx="5" fill="var(--surface-2)" stroke="var(--line)"/><rect x="${78+i*33}" y="${55+j*50}" width="8" height="20" rx="3" fill="#B8742A"/><rect x="${72+i*33}" y="${80+j*50}" width="18" height="5" rx="2" fill="var(--ink-2)"/>`).join("")).join("")}
 478:   <rect x="168" y="50" width="36" height="112" rx="5" fill="var(--surface-2)" stroke="var(--line)"/><rect x="172" y="140" width="28" height="16" rx="4" fill="var(--lager)"/>
 479:   <rect x="236" y="70" width="70" height="136" rx="14" fill="var(--ink)"/><rect x="242" y="80" width="58" height="116" rx="8" fill="var(--surface)"/>
 480:   <rect x="242" y="80" width="58" height="22" fill="var(--vidrio)"/><rect x="252" y="112" width="38" height="30" rx="4" fill="none" stroke="var(--lager)" stroke-width="3"/><path d="M256 127h30" stroke="var(--lager)" stroke-width="2"/>
 481:   <rect x="250" y="150" width="42" height="8" rx="3" fill="var(--lager)"/><rect x="250" y="164" width="42" height="6" rx="3" fill="var(--surface-3)"/>
 482:   <path d="M214 22a30 30 0 0 1 36 0M221 30a18 18 0 0 1 22 0" fill="none" stroke="var(--verde)" stroke-width="4" stroke-linecap="round"/><circle cx="232" cy="38" r="4" fill="var(--verde)"/>
 483: </svg>`;
 484: 
 485: /* ================= Datos ================= */
 486: const KEY = "pos-deposito-v3";
 487: function seed(){
 488:   const base = [
 489:     ["Victoria Mega","cerveza","Mega 1.2 L",42,480,12,66,36,"mega",120,18,"7501064191015",["mega","#7A3E12","#E0B04A","#B7892B"]],
 490:     ["Corona Mega","cerveza","Mega 1.2 L",44,500,12,30,36,"mega",95,14,"7501064191022",["mega","#E2B343","#2F5DA8","#D5D5D5"]],
 491:     ["Modelo Especial","cerveza","Media 355 ml",24,540,24,120,48,"media",40,20,"7501064191039",["media","#6B3410","#D9B45A","#C8A04A"]],
 492:     ["Corona Cuarto","cerveza","Cuarto 210 ml",17,380,24,200,48,"cuarto",20,30,"7501064191046",["cuarto","#E2B343","#2F5DA8","#D5D5D5"]],
 493:     ["Indio Mega","cerveza","Mega 1.2 L",40,460,12,14,24,"mega",6,6,"7501064191053",["mega","#6E3A12","#D9722E","#8C5A2B"]],
 494:     ["Pacífico","cerveza","Media 355 ml",25,560,24,72,48,"media",60,8,"7501064191060",["media","#E8C45A","#F2C230","#DADADA"]],
 495:     ["Hielo en bolsa","hielo","Bolsa 5 kg",35,null,null,18,10,"",null,12,"7502000000017",["hielo","#CFE8F3","#6FB3D2","#3E86A8"]],
 496:     ["Coca-Cola","refresco","Botella 600 ml",22,null,null,40,24,"",150,9,"7502000000024",["pet","#3A1C10","#C62828","#B71C1C"]],
 497:     ["Agua mineral","refresco","Botella 355 ml",16,null,null,8,12,"",200,4,"7502000000031",["pet","#BFE0EA","#2E8B57","#1F6E45"]],
 498:     ["Papas adobadas","botana","Bolsa 45 g",20,null,null,25,20,"",12,5,"7502000000048",["bolsa","#D9412B","#F2C230","#F6C85F"]],
 499:     ["Cacahuates japoneses","botana","Bolsa 100 g",18,null,null,6,15,"",45,3,"7502000000055",["bolsa","#E3B23C","#8C3B1F","#C98B4B"]]
 500:   ];
 501:   const t0 = hoy0(), now = Date.now();
 502:   const productos = base.map((b,i) => ({ id:"p"+(i+1), nombre:b[0], cat:b[1], fmt:b[2], precio:b[3], precioCaja:b[4], ppc:b[5], stock:b[6], min:b[7], env:b[8], cad: b[9] == null ? "" : isoDate(addDays(t0, b[9])), codigo:b[11], foto:"", ilus:{ forma:b[12][0], c1:b[12][1], c2:b[12][2], c3:b[12][3] } }));
 503:   const P = id => productos.find(p => p.id === id);
 504:   let s = 11; const rnd = () => (s = (s * 9301 + 49297) % 233280) / 233280;
 505:   const ventas = []; let folio = 1000;
 506:   for (let d = 30; d >= 1; d--){
 507:     const items = base.map((b,i) => { const q = Math.max(0, Math.round(b[10] * (0.6 + rnd() * 0.8))); return q ? { pid:"p"+(i+1), nombre:b[0], unidad:"pieza", qty:q, precio:b[3], piezas:q } : null; }).filter(Boolean);
 508:     ventas.push({ id:"h"+d, folio:++folio, fecha:new Date(addDays(t0,-d).getTime() + 20*3600e3).toISOString(), items, env:{modo:"na",n:0,monto:0}, total:items.reduce((a,it)=>a+it.precio*it.qty,0), metodo:"efectivo", hist:true, corteId:"hist", origen:"Caja", cancelada:false });
 509:   }
 510:   const apertura = Math.max(t0.getTime() + 60e3, Math.min(t0.getTime() + 8*3600e3, now - 2*3600e3), now - 7*3600e3);
 511:   const span = Math.max(60e3, now - apertura - 12*60e3);
 512:   const combos = [[["p1","caja",1]],[["p4","pieza",6],["p10","pieza",2]],[["p3","caja",1],["p7","pieza",2]],[["p2","pieza",3],["p7","pieza",1]],[["p6","pieza",6]],[["p8","pieza",2],["p9","pieza",1],["p11","pieza",1]],[["p1","pieza",4],["p10","pieza",1]],[["p4","caja",1]],[["p5","pieza",2]],[["p3","pieza",6],["p7","pieza",1]],[["p2","caja",1],["p7","pieza",2]],[["p8","pieza",3]],[["p1","pieza",2]],[["p6","caja",1]]];
 513:   combos.forEach((lines, k) => {
 514:     const items = lines.map(([pid,u,q]) => { const p = P(pid); return { pid, nombre:p.nombre, unidad:u, qty:q, precio: u === "caja" ? p.precioCaja : p.precio, piezas: q * (u === "caja" ? p.ppc : 1) }; });
 515:     let n = 0, monto = 0; const pf = {};
 516:     items.forEach(it => { const p = P(it.pid); if (p.env){ n += it.piezas; pf[p.env] = (pf[p.env]||0) + it.piezas; monto += it.piezas * ({mega:8,media:3,cuarto:3}[p.env]); } });
 517:     const envModo = n ? (k % 3 === 1 ? "cobrar" : "trae") : "na";
 518:     const envMonto = envModo === "cobrar" ? monto : 0;
 519:     const total = items.reduce((a,it)=>a+it.precio*it.qty,0) + envMonto;
 520:     const metodo = k % 4 === 2 ? "tarjeta" : "efectivo";
 521:     const recibido = metodo === "efectivo" ? Math.ceil(total/100)*100 : 0;
 522:     ventas.push({ id:uid(), folio:++folio, fecha:new Date(apertura + 8*60e3 + span * (k / combos.length)).toISOString(), items, env:{ modo:envModo, n, monto:envMonto, porFormato:pf }, total, metodo, tarjeta: metodo === "tarjeta" ? "Débito" : "", recibido, cambio: metodo === "efectivo" ? recibido - total : 0, corteId:null, origen: k % 5 === 3 ? "Terminal S24" : "Caja", cancelada:false });
 523:   });
 524:   const ayer = addDays(t0,-1);
 525:   return {
 526:     v:3, folio,
 527:     ajustes:{ negocio:"Depósito", ip:"192.168.1.50:8080", cobertura:7, alertaCad:15, fondo:500 },
 528:     productos, ventas,
 529:     envases:{ mega:{bodega:84,prestados:36,precio:8}, media:{bodega:240,prestados:48,precio:3}, cuarto:{bodega:168,prestados:24,precio:3} },
 530:     prestamos:[
 531:       { id:uid(), cliente:"Don Chucho", formato:"mega", cant:12, fecha:new Date(now-5*3600e3).toISOString() },
 532:       { id:uid(), cliente:"Tienda La Lupita", formato:"cuarto", cant:24, fecha:addDays(t0,-1).toISOString() },
 533:       { id:uid(), cliente:"Fiesta en calle Hidalgo", formato:"media", cant:48, fecha:addDays(t0,-2).toISOString() },
 534:       { id:uid(), cliente:"Taquería El Sabor", formato:"mega", cant:24, fecha:addDays(t0,-3).toISOString() }
 535:     ],
 536:     turno:{ abierto:true, fondo:500, apertura:new Date(apertura).toISOString() },
 537:     cortes:[{ id:uid(), apertura:new Date(ayer.getTime()+8*3600e3).toISOString(), cierre:new Date(ayer.getTime()+21*3600e3).toISOString(), fondo:500, efectivo:4120, tarjeta:1890, ventas:31, canceladas:1, contado:4620, diferencia:0 }],
 538:     pedidos:[]
 539:   };
 540: }
 541: function load(){ const raw = lsGet(KEY); if (!raw) return null; try { const d = JSON.parse(raw); return d && d.productos ? d : null; } catch(e) { return null; } }
 542: let S = load() || seed();
 543: function save(){ const ok = lsSet(KEY, JSON.stringify(S)); if (!ok) toast("No hay espacio para guardar. Quita algunas fotos o exporta un respaldo."); return ok; }
 544: save();
 545: 
 546: const getRol = () => ssGet("pos-rol") || lsGet("pos-rol") || "";
 547: const setRol = r => { ssSet("pos-rol", r); lsSet("pos-rol", r); };
 548: const getTermName = () => ssGet("pos-term") || lsGet("pos-term") || "Terminal S24";
 549: const setTermName = n => { ssSet("pos-term", n); lsSet("pos-term", n); };
 550: const getTema = () => lsGet("pos-tema") || "auto";
 551: function aplicarTema(){ const t = getTema(); if (t === "auto") document.documentElement.removeAttribute("data-theme"); else document.documentElement.setAttribute("data-theme", t); }
 552: aplicarTema();
 553: 
 554: const U = { screen:"inicio", cat:"todo", q:"", cart:[], envModo:"cobrar", envCliente:"", recibido:"", tarjeta:"Débito", metodo:"efectivo",
 555:   vf:"turno", catQ:"", catCat:"todo", resSel:null, tScreen:"escanear", tcart:[], tq:"", tnota:"", lastScan:null, startRol:"", startIp:"", scanCtx:"", flash:null, form:null };
 556: 
 557: /* ================= Lógica de negocio ================= */
 558: const P = id => S.productos.find(p => p.id === id);
 559: const byCode = c => S.productos.find(p => p.codigo === String(c).trim());
 560: function stockTxt(p, n){
 561:   const st = n == null ? p.stock : n;
 562:   if (st <= 0) return "Agotado";
 563:   if (!p.ppc) return st + " pz";
 564:   const c = Math.floor(st / p.ppc), r = st % p.ppc, parts = [];
 565:   if (c) parts.push(plural(c, "caja", "cajas"));
 566:   if (r) parts.push(r + " pz");
 567:   return parts.join(" + ");
 568: }
 569: const isLow = p => p.stock < p.min;
 570: const piezasL = l => { const p = P(l.pid); return p ? l.qty * (l.unidad === "caja" ? p.ppc : 1) : 0; };
 571: const precioL = l => { const p = P(l.pid); return p ? (l.unidad === "caja" ? p.precioCaja : p.precio) : 0; };
 572: const subtotal = cart => cart.reduce((a,l) => a + precioL(l) * l.qty, 0);
 573: const enCarrito = (cart, pid) => cart.filter(l => l.pid === pid).reduce((a,l) => a + piezasL(l), 0);
 574: function envasesCart(cart){
 575:   let n = 0, monto = 0; const pf = {};
 576:   cart.forEach(l => { const p = P(l.pid); if (p && p.env){ const k = piezasL(l); n += k; pf[p.env] = (pf[p.env]||0) + k; monto += k * S.envases[p.env].precio; } });
 577:   return { n, monto, pf };
 578: }
 579: function totalCart(){ const e = envasesCart(U.cart); return subtotal(U.cart) + (U.envModo === "cobrar" ? e.monto : 0); }
 580: function addCart(cart, pid, unidad, check){
 581:   const p = P(pid); if (!p) return false;
 582:   if (unidad === "caja" && !p.ppc) unidad = "pieza";
 583:   const add = unidad === "caja" ? p.ppc : 1;
 584:   if (check && enCarrito(cart, pid) + add > p.stock){ toast(p.stock <= 0 ? `${p.nombre} está agotado` : `Solo hay ${stockTxt(p)} de ${p.nombre}`); return false; }
 585:   const ex = cart.find(l => l.pid === pid && l.unidad === unidad);
 586:   if (ex) ex.qty++; else cart.push({ pid, unidad, qty:1 });
 587:   return true;
 588: }
 589: function alertas(){
 590:   const low = S.productos.filter(isLow);
 591:   const cad = S.productos.filter(p => p.cad && diasPara(p.cad) <= S.ajustes.alertaCad).sort((a,b) => diasPara(a.cad) - diasPara(b.cad));
 592:   return { low, cad, n: low.length + cad.length };
 593: }
 594: function ventasTurno(){ if (!S.turno.abierto) return []; return S.ventas.filter(v => !v.hist && !v.corteId && v.fecha >= S.turno.apertura); }
 595: function resumenTurno(){
 596:   const vs = ventasTurno(), ok = vs.filter(v => !v.cancelada);
 597:   return { efectivo: ok.filter(v => v.metodo === "efectivo").reduce((a,v)=>a+v.total,0), tarjeta: ok.filter(v => v.metodo === "tarjeta").reduce((a,v)=>a+v.total,0), ventas: ok.length, canceladas: vs.length - ok.length, envCobrados: ok.reduce((a,v)=>a+(v.env&&v.env.monto||0),0) };
 598: }
 599: const ventasHoy = () => S.ventas.filter(v => !v.cancelada && v.fecha >= hoy0().toISOString());
 600: function registrarVenta(){
 601:   const lowAntes = new Set(S.productos.filter(isLow).map(p => p.id));
 602:   const items = U.cart.map(l => { const p = P(l.pid); return { pid:p.id, nombre:p.nombre, unidad:l.unidad, qty:l.qty, precio:precioL(l), piezas:piezasL(l) }; });
 603:   const e = envasesCart(U.cart);
 604:   const modo = e.n ? U.envModo : "na";
 605:   const envMonto = modo === "cobrar" ? e.monto : 0;
 606:   const total = subtotal(U.cart) + envMonto;
 607:   items.forEach(it => { const p = P(it.pid); p.stock = Math.max(0, p.stock - it.piezas); });
 608:   for (const f in e.pf){
 609:     const n = e.pf[f];
 610:     if (modo === "trae") S.envases[f].bodega += n;
 611:     if (modo === "prestamo"){ S.envases[f].prestados += n; S.prestamos.unshift({ id:uid(), cliente:U.envCliente.trim() || "Cliente", formato:f, cant:n, fecha:new Date().toISOString() }); }
 612:   }
 613:   const recibido = U.metodo === "efectivo" ? parseFloat(U.recibido) : 0;
 614:   const v = { id:uid(), folio:++S.folio, fecha:new Date().toISOString(), items, env:{ modo, n:e.n, monto:envMonto, cliente: modo === "prestamo" ? U.envCliente.trim() : "", porFormato:e.pf },
 615:     total, metodo:U.metodo, tarjeta: U.metodo === "tarjeta" ? U.tarjeta : "", recibido, cambio: U.metodo === "efectivo" ? recibido - total : 0, corteId:null, origen:U.origen || "Caja", cancelada:false };
 616:   S.ventas.push(v); save();
 617:   U.cart = []; U.envModo = "cobrar"; U.envCliente = ""; U.recibido = ""; U.origen = "";
 618:   return { v, nuevos: S.productos.filter(p => isLow(p) && !lowAntes.has(p.id)) };
 619: }
 620: function cancelarVenta(v){
 621:   v.items.forEach(it => { const p = P(it.pid); if (p) p.stock += it.piezas; });
 622:   if (v.env && v.env.porFormato){
 623:     for (const f in v.env.porFormato){ const n = v.env.porFormato[f];
 624:       if (v.env.modo === "trae") S.envases[f].bodega = Math.max(0, S.envases[f].bodega - n);
 625:       if (v.env.modo === "prestamo") S.envases[f].prestados = Math.max(0, S.envases[f].prestados - n);
 626:     }
 627:   }
 628:   if (v.envVacios) S.envases[v.envVacios.formato].bodega += v.envVacios.cant;
 629:   v.cancelada = true; save();
 630: }
 631: function vendidas30(){
 632:   const desde = addDays(hoy0(), -30).toISOString(), m = {};
 633:   S.ventas.forEach(v => { if (v.cancelada || v.fecha < desde) return; v.items.forEach(it => { if (it.pid) m[it.pid] = (m[it.pid]||0) + it.piezas; }); });
 634:   return m;
 635: }
 636: function sugerencias(){
 637:   const m = vendidas30(), dias = Math.max(1, +S.ajustes.cobertura || 7);
 638:   return S.productos.map(p => {
 639:     const vendidas = m[p.id] || 0, vd = vendidas / 30;
 640:     const alcanza = vd > 0 ? Math.floor(p.stock / vd) : Infinity;
 641:     const need = Math.ceil(vd * dias + p.min - p.stock);
 642:     let cant = 0, unidad = "pz", txt = "No hace falta";
 643:     if (need > 0 && vd > 0){ if (p.ppc){ cant = Math.ceil(need / p.ppc); unidad = "caja"; txt = plural(cant, "caja", "cajas"); } else { cant = need; txt = need + " pz"; } }
 644:     return { p, vendidas, vd, alcanza, cant, unidad, txt };
 645:   }).sort((a,b) => a.alcanza - b.alcanza);
 646: }
 647: 
 648: /* ================= Gráficas ================= */
 649: function barChart(data, o){
 650:   o = Object.assign({ h:200, color:"var(--lager)", fmt:money, hi:-1 }, o || {});
 651:   const W = 640, H = o.h, padB = 26, padT = 22, n = Math.max(1, data.length);
 652:   const max = Math.max(1, ...data.map(d => d.v)), bw = W / n;
 653:   const bars = data.map((d,i) => {
 654:     const h = Math.round((H - padB - padT) * d.v / max), x = i * bw + bw * .18, w = bw * .64, y = H - padB - h;
 655:     const hl = i === o.hi;
 656:     return `<g><title>${esc(d.l)}: ${esc(o.fmt(d.v))}</title>
 657:       ${n > 8 ? `<rect x="${x}" y="${padT}" width="${w}" height="${H - padB - padT}" rx="6" style="fill:var(--surface-2)"/>` : ""}
 658:       <rect x="${x}" y="${y}" width="${w}" height="${Math.max(h, d.v ? 3 : 0)}" rx="6" style="fill:${hl ? "var(--vidrio)" : o.color}"/>
 659:       ${d.v && (hl || n <= 8) ? `<text x="${x + w/2}" y="${y - 6}" text-anchor="middle" font-size="12" font-weight="600" style="fill:var(--ink)">${esc(o.fmt(d.v))}</text>` : ""}
 660:       <text x="${x + w/2}" y="${H - 8}" text-anchor="middle" font-size="12">${esc(d.l)}</text></g>`;
 661:   }).join("");
 662:   return `<svg class="chart" viewBox="0 0 ${W} ${H}" role="img">${bars}</svg>`;
 663: }
 664: function donut(parts){
 665:   const tot = parts.reduce((a,p) => a + p.v, 0) || 1; let a0 = -Math.PI / 2;
 666:   const R = 60, r = 38, cx = 70, cy = 70;
 667:   const segs = parts.map(p => {
 668:     const a1 = a0 + 2 * Math.PI * (p.v / tot) - 0.0001, large = a1 - a0 > Math.PI ? 1 : 0;
 669:     const P1 = [cx + R*Math.cos(a0), cy + R*Math.sin(a0)], P2 = [cx + R*Math.cos(a1), cy + R*Math.sin(a1)], P3 = [cx + r*Math.cos(a1), cy + r*Math.sin(a1)], P4 = [cx + r*Math.cos(a0), cy + r*Math.sin(a0)];
 670:     const d = `M${P1} A${R} ${R} 0 ${large} 1 ${P2} L${P3} A${r} ${r} 0 ${large} 0 ${P4} Z`; a0 = a1 + 0.0001;
 671:     return p.v ? `<path d="${d}" style="fill:${p.c}"><title>${esc(p.l)}</title></path>` : "";
 672:   }).join("");
 673:   return `<svg viewBox="0 0 140 140">${segs}<text x="70" y="75" text-anchor="middle" font-size="15" font-weight="700" style="fill:var(--ink);font-family:var(--body)">${money(tot)}</text></svg>`;
 674: }
 675: function datosHoras(){
 676:   const vs = ventasHoy(), now = new Date().getHours();
 677:   const hs = vs.map(v => new Date(v.fecha).getHours());
 678:   const h0 = Math.min(8, ...hs), h1 = Math.max(21, now);
 679:   const out = []; for (let h = h0; h <= h1; h++) out.push({ l: String(h), v: vs.filter(v => new Date(v.fecha).getHours() === h).reduce((a,v)=>a+v.total,0) });
 680:   return { out, hi: out.findIndex(d => +d.l === now) };
 681: }
 682: function datosSemana(){
 683:   const out = [];
 684:   for (let d = 6; d >= 0; d--){
 685:     const a = addDays(hoy0(), -d), b = addDays(a, 1);
 686:     const v = S.ventas.filter(x => !x.cancelada && x.fecha >= a.toISOString() && x.fecha < b.toISOString()).reduce((s,x)=>s+x.total,0);
 687:     out.push({ l: d === 0 ? "Hoy" : cap(a.toLocaleDateString("es-MX", { weekday:"short" }).replace(".","")), v });
 688:   }
 689:   return out;
 690: }
 691: const kfmt = v => v >= 1000 ? "$" + (Math.round(v/100)/10) + "k" : money(v);
 692: 
 693: /* ================= Archivos ================= */
 694: let dlP = null;
 695: function getDl(){ if (!dlP) dlP = (window.claude && typeof window.claude.use === "function") ? window.claude.use("downloads").catch(() => null) : Promise.resolve(null); return dlP; }
 696: async function entregar(blob, filename, compartir){
 697:   if (compartir){
 698:     try { const file = new File([blob], filename, { type: blob.type || "application/pdf" }); if (navigator.canShare && navigator.canShare({ files:[file] })){ await navigator.share({ files:[file], title:filename }); return; } }
 699:     catch(e){ if (e && e.name === "AbortError") return; }
 700:   }
 701:   const dl = await getDl();
 702:   if (dl){ try { await dl.save({ filename, data:blob }); toast("Archivo listo: " + filename); } catch(e){ if (!e || e.code !== "declined") toast("No se pudo guardar el archivo"); } return; }
 703:   try { const url = URL.createObjectURL(blob); const a = document.createElement("a"); a.href = url; a.download = filename; document.body.appendChild(a); a.click(); a.remove(); setTimeout(() => URL.revokeObjectURL(url), 5000); }
 704:   catch(e){ toast("No se pudo guardar el archivo"); }
 705: }
 706: function nuevoPDF(w, h){ if (!window.jspdf || !window.jspdf.jsPDF){ toast("El generador de PDF no cargó. Revisa la conexión."); return null; } return new window.jspdf.jsPDF({ unit:"mm", format:[w, h] }); }
 707: function pdfTicket(v){
 708:   const doc = nuevoPDF(80, 110 + v.items.length * 10 + (v.env && v.env.n ? 10 : 0)); if (!doc) return null;
 709:   let y = 10; const L = 6, R = 74, C = 40;
 710:   const hr = () => { doc.setDrawColor(170); doc.setLineDashPattern([1,1],0); doc.line(L, y, R, y); y += 5; };
 711:   doc.setFont("helvetica","bold"); doc.setFontSize(15); doc.text(S.ajustes.negocio, C, y, { align:"center" }); y += 6;
 712:   doc.setFont("helvetica","normal"); doc.setFontSize(9); doc.text("Comprobante de venta", C, y, { align:"center" }); y += 6;
 713:   doc.text("Folio " + v.folio, L, y); doc.text(fFechaHora(v.fecha), R, y, { align:"right" }); y += 4;
 714:   if (v.cancelada){ doc.setFont("helvetica","bold"); doc.text("VENTA CANCELADA", C, y + 2, { align:"center" }); doc.setFont("helvetica","normal"); y += 5; }
 715:   y += 2; hr();
 716:   v.items.forEach(it => {
 717:     doc.setFontSize(9.5); doc.text(`${it.qty} x ${it.nombre}${it.unidad === "caja" ? " (caja)" : ""}`, L, y, { maxWidth:50 }); doc.text(money(it.precio * it.qty), R, y, { align:"right" }); y += 4.5;
 718:     doc.setFontSize(8); doc.setTextColor(110); doc.text(money(it.precio) + " c/u", L, y); doc.setTextColor(0); y += 5.5;
 719:   });
 720:   if (v.env && v.env.n){
 721:     doc.setFontSize(9);
 722:     if (v.env.modo === "cobrar"){ doc.text(`Depósito de ${v.env.n} envases`, L, y); doc.text(money(v.env.monto), R, y, { align:"right" }); }
 723:     else if (v.env.modo === "trae"){ doc.text(`Intercambio de ${v.env.n} envases`, L, y); doc.text("$0", R, y, { align:"right" }); }
 724:     else if (v.env.modo === "prestamo"){ doc.text(`Envases prestados: ${v.env.n}${v.env.cliente ? " a " + v.env.cliente : ""}`, L, y, { maxWidth:66 }); }
 725:     y += 7;
 726:   }
 727:   hr();
 728:   doc.setFont("helvetica","bold"); doc.setFontSize(13); doc.text("TOTAL", L, y + 1); doc.text(money(v.total), R, y + 1, { align:"right" }); y += 8;
 729:   doc.setFont("helvetica","normal"); doc.setFontSize(9);
 730:   doc.text("Pago", L, y); doc.text(v.metodo === "efectivo" ? "Efectivo" : "Tarjeta de " + (v.tarjeta || "débito").toLowerCase(), R, y, { align:"right" }); y += 5;
 731:   if (v.metodo === "efectivo"){ doc.text("Recibido", L, y); doc.text(money(v.recibido), R, y, { align:"right" }); y += 5; doc.text("Cambio", L, y); doc.text(money(v.cambio), R, y, { align:"right" }); y += 5; }
 732:   y += 4; doc.text("Gracias por su compra", C, y, { align:"center" });
 733:   return doc;
 734: }
 735: function textoTicket(v){
 736:   let t = `*${S.ajustes.negocio}*\nFolio ${v.folio}, ${fFechaHora(v.fecha)}\n\n`;
 737:   v.items.forEach(it => { t += `${it.qty} x ${it.nombre}${it.unidad === "caja" ? " (caja)" : ""}  ${money(it.precio * it.qty)}\n`; });
 738:   if (v.env && v.env.modo === "cobrar" && v.env.monto) t += `Depósito de ${v.env.n} envases  ${money(v.env.monto)}\n`;
 739:   return t + `\n*Total: ${money(v.total)}*\nPago: ${v.metodo === "efectivo" ? "Efectivo" : "Tarjeta"}`;
 740: }
 741: function pdfCorte(c){
 742:   const doc = nuevoPDF(80, 120); if (!doc) return null;
 743:   let y = 10; const L = 6, R = 74, C = 40;
 744:   doc.setFont("helvetica","bold"); doc.setFontSize(15); doc.text(S.ajustes.negocio, C, y, { align:"center" }); y += 6;
 745:   doc.setFontSize(11); doc.text("Corte de caja", C, y, { align:"center" }); y += 7;
 746:   doc.setFont("helvetica","normal"); doc.setFontSize(9);
 747:   const kv = (k, v, b) => { if (b) doc.setFont("helvetica","bold"); doc.text(k, L, y); doc.text(v, R, y, { align:"right" }); doc.setFont("helvetica","normal"); y += 5.5; };
 748:   kv("Apertura", fFechaHora(c.apertura)); kv("Cierre", fFechaHora(c.cierre)); y += 2;
 749:   kv("Fondo inicial", money(c.fondo)); kv("Ventas en efectivo", money(c.efectivo)); kv("Ventas con tarjeta", money(c.tarjeta));
 750:   kv("Número de ventas", String(c.ventas)); kv("Ventas canceladas", String(c.canceladas || 0)); y += 2;
 751:   kv("Debía haber en caja", money(c.fondo + c.efectivo), true); kv("Efectivo contado", money(c.contado), true);
 752:   kv("Diferencia", (c.diferencia > 0 ? "+" : "") + money(c.diferencia), true);
 753:   y += 6; doc.text("Firma del cajero: ____________________", L, y);
 754:   return doc;
 755: }
 756: function pdfPedido(lines){
 757:   const doc = nuevoPDF(210, 297); if (!doc) return null;
 758:   let y = 22;
 759:   doc.setFont("helvetica","bold"); doc.setFontSize(20); doc.text(`Pedido de resurtido, ${S.ajustes.negocio}`, 18, y); y += 8;
 760:   doc.setFont("helvetica","normal"); doc.setFontSize(11); doc.text(`Fecha: ${new Date().toLocaleDateString("es-MX", { day:"numeric", month:"long", year:"numeric" })}. Cubre ${S.ajustes.cobertura} días de venta.`, 18, y); y += 12;
 761:   doc.setFont("helvetica","bold"); doc.text("Producto", 18, y); doc.text("Presentación", 95, y); doc.text("Cantidad", 190, y, { align:"right" }); y += 3;
 762:   doc.setDrawColor(150); doc.line(18, y, 192, y); y += 7; doc.setFont("helvetica","normal");
 763:   lines.forEach(s => { doc.text(s.p.nombre, 18, y); doc.text(s.p.fmt + (s.unidad === "caja" ? `, caja de ${s.p.ppc}` : ""), 95, y); doc.text(s.txt, 190, y, { align:"right" }); y += 8; });
 764:   return doc;
 765: }
 766: const textoPedido = lines => `*Pedido de resurtido, ${S.ajustes.negocio}*\n` + lines.map(s => `${s.txt} de ${s.p.nombre} (${s.p.fmt})`).join("\n");
 767: function abrirWhatsApp(texto){
 768:   try { if (navigator.clipboard) navigator.clipboard.writeText(texto).catch(() => {}); } catch(e){}
 769:   try { window.open("https://wa.me/?text=" + encodeURIComponent(texto), "_blank", "noopener"); } catch(e){}
 770:   toast("Texto copiado. Si WhatsApp no se abrió, pégalo en el chat.");
 771: }
 772: const blobDe = doc => doc.output("blob");
 773: function leerFoto(file){
 774:   return new Promise((res, rej) => {
 775:     const fr = new FileReader();
 776:     fr.onload = () => { const im = new Image(); im.onload = () => { const s = 360, k = Math.min(1, s / Math.max(im.width, im.height)); const c = document.createElement("canvas"); c.width = Math.round(im.width * k); c.height = Math.round(im.height * k); c.getContext("2d").drawImage(im, 0, 0, c.width, c.height); res(c.toDataURL("image/jpeg", .8)); }; im.onerror = rej; im.src = fr.result; };
 777:     fr.onerror = rej; fr.readAsDataURL(file);
 778:   });
 779: }
 780: 
 781: /* ================= Recibo visual ================= */
 782: function reciboHTML(v){
 783:   const envTxt = v.env && v.env.n ? (v.env.modo === "cobrar" ? `<div class="r"><span>Depósito ${v.env.n} envases</span><span>${money(v.env.monto)}</span></div>` : v.env.modo === "trae" ? `<div class="r"><span>Intercambio ${v.env.n} envases</span><span>$0</span></div>` : `<div>Envases prestados: ${v.env.n}${v.env.cliente ? " a " + esc(v.env.cliente) : ""}</div>`) : "";
 784:   return `<div class="recibo">
 785:     <div class="c h">${esc(S.ajustes.negocio.toUpperCase())}</div><div class="c">Comprobante de venta</div>
 786:     <div class="hr"></div><div class="r"><span>Folio ${v.folio}</span><span>${fFechaHora(v.fecha)}</span></div><div>Atendió: ${esc(v.origen)}</div><div class="hr"></div>
 787:     ${v.items.map(it => `<div class="r"><span>${it.qty} x ${esc(it.nombre)}${it.unidad === "caja" ? " (caja)" : ""}</span><span>${money(it.precio * it.qty)}</span></div><div style="color:#777">&nbsp;&nbsp;${money(it.precio)} c/u</div>`).join("")}
 788:     ${envTxt}<div class="hr"></div>
 789:     <div class="r t"><span>TOTAL</span><span>${money(v.total)}</span></div>
 790:     <div class="r"><span>Pago</span><span>${v.metodo === "efectivo" ? "Efectivo" : "Tarjeta " + (v.tarjeta || "").toLowerCase()}</span></div>
 791:     ${v.metodo === "efectivo" ? `<div class="r"><span>Recibido</span><span>${money(v.recibido)}</span></div><div class="r"><span>Cambio</span><span>${money(v.cambio)}</span></div>` : ""}
 792:     <div class="hr"></div><div class="c">¡Gracias por su compra!</div>
 793:     ${v.cancelada ? `<div class="sello">VENTA CANCELADA</div>` : ""}
 794:   </div>`;
 795: }
 796: 
 797: /* ================= Toast y modal ================= */
 798: function toast(msg){ const t = $("#toast"); t.textContent = msg; t.classList.add("show"); clearTimeout(t._h); t._h = setTimeout(() => t.classList.remove("show"), 2800); }
 799: function openModal(html, size){
 800:   const box = $("#modal-box"); box.className = "modal" + (size ? " " + size : ""); box.innerHTML = html; $("#modal").hidden = false;
 801:   const f = box.querySelector("[autofocus]") || box.querySelector("input,select,button"); if (f) f.focus({ preventScroll:true });
 802: }
 803: function closeModal(){ stopCam(); $("#modal").hidden = true; $("#modal-box").innerHTML = ""; U.form = null; }
 804: 
 805: /* ================= Cámara ================= */
 806: let camStream = null, camTimer = null;
 807: function stopCam(){ clearInterval(camTimer); camTimer = null; if (camStream){ camStream.getTracks().forEach(t => t.stop()); camStream = null; } }
 808: function abrirScanner(ctx){
 809:   U.scanCtx = ctx;
 810:   const titulo = ctx === "start" ? "Escanear el código de la caja" : "Escanear producto";
 811:   const pruebas = ctx === "start" ? "" : `<div class="pick"><span>Códigos de prueba:</span>${S.productos.slice(0,8).map(p => `<button class="chip" data-act="scan-pick" data-code="${esc(p.codigo)}">${imgProd(p)}${esc(p.nombre)}</button>`).join("")}</div>`;
 812:   openModal(`<h2>${titulo}</h2><p>Apunta la cámara al código. También puedes escribirlo.</p>
 813:     <div class="cam"><video id="camv" playsinline muted></video><span class="corner c1"></span><span class="corner c2"></span><span class="corner c3"></span><span class="corner c4"></span><span class="scanline"></span><div class="cam-msg" id="cammsg">Abriendo la cámara…</div></div>
 814:     <label class="field">Código<input id="scode" inputmode="${ctx === "start" ? "url" : "numeric"}" autocomplete="off" placeholder="${ctx === "start" ? "192.168.1.50:8080" : "7501064191015"}"></label>
 815:     ${pruebas}
 816:     <div class="modal-actions"><button class="btn" data-act="close">Cerrar</button><button class="btn btn-primary" data-act="scan-code">Buscar código</button></div>`, "wide");
 817:   iniciarCamara();
 818: }
 819: async function iniciarCamara(){
 820:   const msg = () => $("#cammsg");
 821:   if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia){ if (msg()) msg().textContent = "La cámara no está disponible aquí. Escribe el código o usa uno de prueba."; return; }
 822:   try { camStream = await navigator.mediaDevices.getUserMedia({ video:{ facingMode:"environment" }, audio:false }); }
 823:   catch(e){ if (msg()) msg().textContent = "No se pudo abrir la cámara. Escribe el código o usa uno de prueba."; return; }
 824:   const v = $("#camv"); if (!v){ stopCam(); return; }
 825:   v.srcObject = camStream; try { await v.play(); } catch(e){}
 826:   if (!("BarcodeDetector" in window)){ if (msg()) msg().textContent = "Este navegador no lee códigos con la cámara. En la app Flutter lo hará mobile_scanner. Escribe el código."; return; }
 827:   let det; try { const fm = await window.BarcodeDetector.getSupportedFormats(); det = new window.BarcodeDetector(fm && fm.length ? { formats:fm } : undefined); }
 828:   catch(e){ if (msg()) msg().textContent = "No se pudo iniciar el lector. Escribe el código."; return; }
 829:   if (msg()) msg().textContent = "Apunta al código de barras";
 830:   camTimer = setInterval(async () => {
 831:     const vv = $("#camv"); if (!vv){ stopCam(); return; }
 832:     if (!vv.videoWidth) return;
 833:     try { const r = await det.detect(vv); if (r && r.length){ const c = r[0].rawValue; stopCam(); onCodigo(c); } } catch(e){}
 834:   }, 350);
 835: }
 836: function onCodigo(code){
 837:   code = String(code || "").trim(); if (!code) return;
 838:   const ctx = U.scanCtx;
 839:   if (ctx === "start"){ U.startIp = code.replace(/^https?:\/\//, "").replace(/\/$/, ""); closeModal(); render(); return; }
 840:   const p = byCode(code);
 841:   if (!p){
 842:     if (getRol() === "caja") openModal(`<h2>Código no registrado</h2><p>El código ${esc(code)} no está en el catálogo.</p><div class="modal-actions"><button class="btn" data-act="close">Cerrar</button><button class="btn btn-primary" data-act="prod-nuevo" data-code="${esc(code)}">Registrar producto</button></div>`);
 843:     else { closeModal(); toast(`El código ${code} no está en el catálogo`); }
 844:     return;
 845:   }
 846:   closeModal();
 847:   if (ctx === "pos"){ if (addCart(U.cart, p.id, "pieza", true)){ U.flash = p.id; toast("Agregado: " + p.nombre); } }
 848:   else { U.lastScan = p.id; U.tScreen = "escanear"; try { navigator.vibrate && navigator.vibrate(30); } catch(e){} }
 849:   render();
 850: }
 851: 
 852: /* ================= Vistas: Caja ================= */
 853: const TITLES = { inicio:"Inicio", vender:"Vender", ventas:"Ventas", catalogo:"Catálogo", envases:"Envases retornables", corte:"Corte de caja", alertas:"Alertas", resurtido:"Resurtido", ajustes:"Ajustes" };
 854: 
 855: function vStart(){
 856:   const t = U.startRol === "terminal";
 857:   return `<div class="start"><div class="start-in">
 858:     <div class="hero"><div><h1>Punto de venta del depósito</h1><p class="lead">Ventas, inventario y envases en tiempo real entre la caja y los teléfonos del equipo. Para empezar, dinos cómo se usará este dispositivo; puedes cambiarlo después en Ajustes.</p></div>${HERO_SVG}</div>
 859:     <div class="choices">
 860:       <button class="choice" data-act="rol-caja"><span class="cico">${ico("caja")}</span><span><b>Caja</b><span>Guarda la base de datos, cobra y recibe a las terminales. Debe quedarse encendida con la app abierta.</span></span></button>
 861:       <button class="choice" data-act="rol-term" aria-pressed="${t}"><span class="cico">${ico("tel")}</span><span><b>Terminal</b><span>Escanea productos, arma pedidos y consulta existencias en los pasillos. Se conecta a la caja por Wi-Fi.</span></span></button>
 862:     </div>
 863:     ${t ? `<div class="next"><h2>Conectar con la caja</h2><p class="muted" style="margin:0 0 12px">Escanea el código que muestra la caja en “Conectar terminal”, o escribe su dirección.</p>
 864:       <div class="form"><label class="field">Nombre de esta terminal<input id="start-name" value="${esc(getTermName())}"></label>
 865:       <label class="field">Dirección de la caja<input id="start-ip" value="${esc(U.startIp || S.ajustes.ip)}"></label></div>
 866:       <div class="inline"><button class="btn" data-act="scan" data-ctx="start">${ico("qr")}Escanear código</button><button class="btn btn-primary" style="flex:1" data-act="rol-term-ok">Conectar</button></div></div>` : ""}
 867:     <p class="note" style="text-align:center;margin-top:18px">Prototipo: abre este enlace en otra pestaña y elige el otro modo para ver caja y terminal funcionando juntas.</p>
 868:   </div></div>`;
 869: }
 870: 
 871: function temaBtn(){ const t = getTema(); return `<button class="icon-btn" data-act="tema" title="Tema: ${t === "auto" ? "automático" : t === "dark" ? "oscuro" : "claro"}" aria-label="Cambiar tema">${ico(t === "auto" ? "auto" : t === "dark" ? "luna" : "sol")}</button>`; }
 872: function fechaPill(){ const d = new Date(); return cap(d.toLocaleDateString("es-MX", { weekday:"long", day:"numeric", month:"long" })) + ", " + d.toLocaleTimeString("es-MX", { hour:"2-digit", minute:"2-digit" }); }
 873: 
 874: function vCaja(){
 875:   const al = alertas();
 876:   const nav = [["inicio"],["vender",S.pedidos.length],["ventas"],["catalogo"],["envases"],["corte"],["alertas",al.n],["resurtido"],["ajustes"]];
 877:   return `<div class="caja">
 878:     <aside class="rail"><div class="brand"><span class="brand-mark">${imgEnvase("media").replace('class="pimg "','class="pimg" style="width:34px;height:34px;background:none"')}</span><span><b>${esc(S.ajustes.negocio)}</b><small>Caja principal</small></span></div>
 879:       <nav class="nav" aria-label="Secciones">${nav.map(([k,n]) => `<button data-act="go" data-s="${k}" ${U.screen === k ? 'aria-current="page"' : ""}>${ico(k)}<span class="lbl">${k === "catalogo" ? "Catálogo" : k === "corte" ? "Corte de caja" : cap(k)}</span>${n ? `<span class="badge">${n}</span>` : ""}</button>`).join("")}</nav>
 880:       <div class="rail-foot"><div><span class="dot ${S.turno.abierto ? "" : "off"}"></span><b>${S.turno.abierto ? "Caja abierta" : "Caja cerrada"}</b></div><div>${ico("wifi","")} ${esc(S.ajustes.ip)}</div></div>
 881:     </aside>
 882:     <div class="main">
 883:       <header class="topbar"><h1>${TITLES[U.screen]}</h1><span class="pill" id="reloj">${fechaPill()}</span>${temaBtn()}<button class="btn btn-sm" data-act="qr">${ico("qr")}Conectar terminal</button></header>
 884:       <div class="host ${U.screen === "vender" ? "host-fixed" : ""}" id="host" data-scroll>${SCREENS[U.screen]()}</div>
 885:     </div></div>`;
 886: }
 887: 
 888: function vInicio(){
 889:   const h = new Date().getHours(), saludo = h < 12 ? "Buenos días" : h < 19 ? "Buenas tardes" : "Buenas noches";
 890:   const vh = ventasHoy(), tot = vh.reduce((a,v)=>a+v.total,0), prom = vh.length ? tot / vh.length : 0;
 891:   const r = resumenTurno(), prest = Object.values(S.envases).reduce((a,e)=>a+e.prestados,0);
 892:   const al = alertas(); const hrs = datosHoras();
 893:   const top = {}; vh.forEach(v => v.items.forEach(it => { if (it.pid) top[it.pid] = (top[it.pid]||0) + it.piezas; }));
 894:   const topL = Object.entries(top).sort((a,b) => b[1]-a[1]).slice(0,5).map(([pid,n]) => ({ p:P(pid), n })).filter(x => x.p);
 895:   const ult = S.ventas.filter(v => !v.hist).slice(-5).reverse();
 896:   return `<div class="hello"><div><h2>${saludo}</h2><p>${S.turno.abierto ? `Caja abierta desde las ${fHora(S.turno.apertura)} con ${money(S.turno.fondo)} de fondo.` : "La caja está cerrada. Ábrela en Corte de caja para empezar a vender."}</p></div>
 897:       <button class="btn btn-primary btn-lg" data-act="go" data-s="vender">${ico("vender")}Nueva venta</button></div>
 898:     <div class="kpis">
 899:       <div class="kpi"><span class="kico">${ico("dinero")}</span><div><small>Ventas de hoy</small><b>${money(tot)}</b><small>${plural(vh.length,"venta","ventas")}</small></div></div>
 900:       <div class="kpi"><span class="kico b">${ico("ticket")}</span><div><small>Ticket promedio</small><b>${money(Math.round(prom))}</b><small>por venta</small></div></div>
 901:       <div class="kpi"><span class="kico g">${ico("corte")}</span><div><small>Efectivo en caja</small><b>${S.turno.abierto ? money(S.turno.fondo + r.efectivo) : "Cerrada"}</b><small>tarjeta ${money(r.tarjeta)}</small></div></div>
 902:       <div class="kpi"><span class="kico r">${ico("envases")}</span><div><small>Envases prestados</small><b>${prest}</b><small>${plural(S.prestamos.length,"cliente","clientes")}</small></div></div>
 903:     </div>
 904:     <div class="dash">
 905:       <div class="stack-cards">
 906:         <div class="card"><div class="card-h"><h3>Ventas por hora, hoy</h3><span class="muted">${money(tot)}</span></div>${barChart(hrs.out, { hi:hrs.hi, fmt:kfmt })}</div>
 907:         <div class="card"><div class="card-h"><h3>Últimos 7 días</h3><button class="btn btn-sm" data-act="go" data-s="ventas">Ver ventas</button></div>${barChart(datosSemana(), { h:180, fmt:kfmt, hi:6, color:"var(--vidrio-ink-2)" })}</div>
 908:       </div>
 909:       <div class="stack-cards">
 910:         <div class="card"><div class="card-h"><h3>Lo más vendido hoy</h3></div>${topL.length ? topL.map((x,i) => `<div class="rank">${imgProd(x.p)}<div class="info"><b>${esc(x.p.nombre)}</b><small class="muted">${stockTxt(x.p)} en existencia</small></div><span class="num">${x.n}<small class="muted"> pz</small></span></div>`).join("") : `<p class="empty">Aún no hay ventas hoy.</p>`}</div>
 911:         <div class="card"><div class="card-h"><h3>Necesita atención</h3><button class="btn btn-sm" data-act="go" data-s="alertas">Ver todo</button></div>
 912:           ${al.n ? al.low.slice(0,3).map(p => `<div class="rank">${imgProd(p)}<div class="info"><b>${esc(p.nombre)}</b><small class="diff-bad">Quedan ${stockTxt(p)}</small></div><button class="btn btn-sm" data-act="recibir" data-id="${p.id}">Recibir</button></div>`).join("") + al.cad.slice(0,2).map(p => `<div class="rank">${imgProd(p)}<div class="info"><b>${esc(p.nombre)}</b><small class="muted">Caduca ${fCad(p.cad)}</small></div><span class="tag ${diasPara(p.cad) <= 7 ? "low" : "warn"}">${diasPara(p.cad) < 0 ? "Vencido" : "En " + plural(diasPara(p.cad),"día","días")}</span></div>`).join("") : `<p class="empty">Todo en orden.</p>`}</div>
 913:         <div class="card"><div class="card-h"><h3>Últimas ventas</h3></div>${ult.map(v => `<div class="rank click" data-act="venta-ver" data-id="${v.id}" style="cursor:pointer"><span class="avatar">${v.origen === "Caja" ? ico("caja") : ico("tel")}</span><div class="info"><b>Folio ${v.folio}</b><small class="muted">${fHora(v.fecha)}, ${plural(v.items.reduce((a,i)=>a+i.qty,0),"artículo","artículos")}${v.cancelada ? ", cancelada" : ""}</small></div><span class="num">${money(v.total)}</span></div>`).join("")}</div>
 914:       </div>
 915:     </div>`;
 916: }
 917: 
 918: function vVender(){
 919:   const q = U.q.trim().toLowerCase();
 920:   const list = S.productos.filter(p => (U.cat === "todo" || p.cat === U.cat) && (!q || p.nombre.toLowerCase().includes(q) || p.codigo.includes(q)));
 921:   const cats = [["todo","Todo"]].concat(CATS.filter(([k]) => S.productos.some(p => p.cat === k)));
 922:   const tiles = list.map(p => { const n = enCarrito(U.cart, p.id); return `<button class="tile ${p.stock <= 0 ? "out" : ""}" data-act="add" data-id="${p.id}" aria-label="Agregar ${esc(p.nombre)}">
 923:       ${n ? `<span class="incart">${n}</span>` : ""}${imgProd(p)}
 924:       <span class="nm">${esc(p.nombre)}</span><span class="fm">${esc(p.fmt)}</span>
 925:       <span class="pr">${money(p.precio)}${p.precioCaja ? `<span>caja ${money(p.precioCaja)}</span>` : ""}</span>
 926:       <span class="st ${isLow(p) ? "low" : ""}">${stockTxt(p)}${isLow(p) && p.stock > 0 ? ", bajo mínimo" : ""}</span></button>`; }).join("")
 927:     || `<div class="empty" style="grid-column:1/-1">${EMPTY_SVG}No hay productos que coincidan con “${esc(U.q)}”.</div>`;
 928:   const lines = U.cart.length ? U.cart.map((l,i) => { const p = P(l.pid); return `<div class="line ${U.flash === l.pid ? "flash" : ""}">${imgProd(p)}<div>
 929:       <div class="line-top"><span>${esc(p.nombre)}</span><span>${money(precioL(l) * l.qty)}</span></div>
 930:       <div class="line-bot">${p.ppc ? `<span class="seg" role="group" aria-label="Unidad"><button data-act="unit" data-i="${i}" data-u="pieza" aria-pressed="${l.unidad === "pieza"}">Pieza</button><button data-act="unit" data-i="${i}" data-u="caja" aria-pressed="${l.unidad === "caja"}">Caja de ${p.ppc}</button></span>` : `<span class="tag">${money(p.precio)} c/u</span>`}
 931:       <span class="qty"><button data-act="dec" data-i="${i}" aria-label="Quitar uno">−</button><span>${l.qty}</span><button data-act="inc" data-i="${i}" aria-label="Agregar uno">+</button></span></div></div></div>`; }).join("")
 932:     : `<div class="empty">${EMPTY_SVG}Toca un producto o escanéalo para empezar la venta.</div>`;
 933:   const e = envasesCart(U.cart);
 934:   const envBlock = e.n ? `<div class="env"><div class="env-title">${ico("envases")}${plural(e.n, "envase retornable", "envases retornables")}</div>
 935:       <span class="seg wide" role="group" aria-label="Envases"><button data-act="envmodo" data-m="cobrar" aria-pressed="${U.envModo === "cobrar"}">Cobrar</button><button data-act="envmodo" data-m="trae" aria-pressed="${U.envModo === "trae"}">Trae vacíos</button><button data-act="envmodo" data-m="prestamo" aria-pressed="${U.envModo === "prestamo"}">Préstamo</button></span>
 936:       ${U.envModo === "prestamo" ? `<input class="search" id="envCliente" placeholder="Nombre del cliente" value="${esc(U.envCliente)}" style="min-height:44px">` : ""}
 937:       <div class="env-row"><span>${U.envModo === "cobrar" ? "Depósito de envases" : U.envModo === "trae" ? "Intercambio de envases" : "Se registran como prestados"}</span><span>${U.envModo === "cobrar" ? money(e.monto) : "$0"}</span></div></div>` : "";
 938:   const pend = S.pedidos.map(pd => { const n = pd.items.reduce((a,l)=>a+l.qty,0); return `<div class="banner"><span class="ban-imgs">${pd.items.slice(0,3).map(l => imgProd(P(l.pid))).join("")}</span><div style="flex:1"><b>Pedido de ${esc(pd.origen)}</b><small>${plural(n,"artículo","artículos")}, ${money(subtotal(pd.items))}, ${fHora(pd.fecha)}${pd.nota ? `, nota: ${esc(pd.nota)}` : ""}</small></div><div class="banner-act"><button class="btn btn-sm" data-act="ped-descartar" data-id="${pd.id}">Descartar</button><button class="btn btn-sm btn-primary" data-act="ped-cargar" data-id="${pd.id}">Pasar al ticket</button></div></div>`; }).join("");
 939:   const total = totalCart(), nArt = U.cart.reduce((a,l)=>a+l.qty,0);
 940:   U.flash = null;
 941:   return `<div class="sell"><div class="sell-left">${pend}
 942:       <div class="toolbar"><input class="search" id="q" type="search" placeholder="Buscar por nombre o código" value="${esc(U.q)}" aria-label="Buscar producto"><button class="btn btn-dark" data-act="scan" data-ctx="pos">${ico("escanear")}Escanear</button></div>
 943:       <div class="chips">${cats.map(([k,v]) => `<button class="chip" data-act="cat" data-c="${k}" aria-pressed="${U.cat === k}">${v}</button>`).join("")}</div>
 944:       <div class="grid" id="grid" data-scroll>${tiles}</div></div>
 945:     <div class="ticket" id="ticket"><div class="ticket-head"><h2>Venta actual<small>${nArt ? plural(nArt,"artículo","artículos") : "Folio " + (S.folio + 1)}</small></h2>${U.cart.length ? `<button class="btn btn-sm" data-act="vaciar">Vaciar</button>` : ""}</div>
 946:       <div class="lines" id="lines" data-scroll>${lines}</div>${envBlock}
 947:       <div class="total"><span>Total</span><b>${money(total)}</b></div>
 948:       <div class="pay"><button class="btn btn-primary btn-lg" data-act="cobrar" data-m="efectivo" ${U.cart.length ? "" : "disabled"}>${ico("dinero")}Efectivo</button><button class="btn btn-dark btn-lg" data-act="cobrar" data-m="tarjeta" ${U.cart.length ? "" : "disabled"}>${ico("ticket")}Tarjeta</button></div>
 949:     </div></div>`;
 950: }
 951: 
 952: function vVentas(){
 953:   let list = S.ventas.filter(v => !v.hist);
 954:   if (U.vf === "turno") list = ventasTurno();
 955:   else if (U.vf === "hoy") list = list.filter(v => v.fecha >= hoy0().toISOString());
 956:   else list = list.filter(v => v.fecha >= addDays(hoy0(), -6).toISOString());
 957:   list = list.slice().sort((a,b) => b.fecha.localeCompare(a.fecha));
 958:   const ok = list.filter(v => !v.cancelada), tot = ok.reduce((a,v)=>a+v.total,0);
 959:   const ef = ok.filter(v => v.metodo === "efectivo").reduce((a,v)=>a+v.total,0);
 960:   const rows = list.map(v => `<tr class="click" data-act="venta-ver" data-id="${v.id}" tabindex="0">
 961:     <td><b>${v.folio}</b></td><td>${U.vf === "7d" ? fFecha(v.fecha) + ", " : ""}${fHora(v.fecha)}</td>
 962:     <td><div class="ban-imgs">${v.items.slice(0,4).map(it => it.pid && P(it.pid) ? imgProd(P(it.pid)) : imgEnvase("mega")).join("")}</div></td>
 963:     <td>${esc(v.items.map(it => it.qty + " " + it.nombre).join(", ")).slice(0,48)}${v.items.length > 2 ? "…" : ""}</td>
 964:     <td>${esc(v.origen)}</td><td>${v.metodo === "efectivo" ? "Efectivo" : "Tarjeta"}</td><td class="num"><b>${money(v.total)}</b></td>
 965:     <td>${v.cancelada ? `<span class="tag low">Cancelada</span>` : v.corteId ? `<span class="tag">En corte</span>` : `<span class="tag ok">Pagada</span>`}</td></tr>`).join("");
 966:   return `<div class="row-actions"><div class="chips" style="margin:0">${[["turno","Este turno"],["hoy","Hoy"],["7d","Últimos 7 días"]].map(([k,t]) => `<button class="chip" data-act="vf" data-f="${k}" aria-pressed="${U.vf === k}">${t}</button>`).join("")}</div></div>
 967:     <div class="two" style="grid-template-columns:1fr 1.4fr">
 968:       <div class="card"><div class="card-h"><h3>Resumen</h3></div><div class="donut-wrap">${donut([{ l:"Efectivo", v:ef, c:"var(--lager)" },{ l:"Tarjeta", v:tot - ef, c:"var(--vidrio)" }])}<div class="legend"><span><i style="background:var(--lager)"></i>Efectivo ${money(ef)}</span><span><i style="background:var(--vidrio)"></i>Tarjeta ${money(tot - ef)}</span><span class="muted">${plural(ok.length,"venta","ventas")}${list.length - ok.length ? `, ${plural(list.length - ok.length,"cancelada","canceladas")}` : ""}</span></div></div></div>
 969:       <div class="card"><div class="card-h"><h3>Últimos 7 días</h3></div>${barChart(datosSemana(), { h:170, fmt:kfmt, hi:6 })}</div>
 970:     </div>
 971:     ${list.length ? `<div class="table-wrap"><table><thead><tr><th>Folio</th><th>Hora</th><th></th><th>Productos</th><th>Origen</th><th>Pago</th><th class="num">Total</th><th>Estado</th></tr></thead><tbody>${rows}</tbody></table></div>`
 972:       : `<div class="panel"><div class="empty">${EMPTY_SVG}${U.vf === "turno" && !S.turno.abierto ? "La caja está cerrada. Ábrela en Corte de caja para empezar un turno." : "No hay ventas en este periodo."}</div></div>`}`;
 973: }
 974: 
 975: function vCatalogo(){
 976:   const q = U.catQ.trim().toLowerCase();
 977:   const list = S.productos.filter(p => (U.catCat === "todo" || p.cat === U.catCat) && (!q || p.nombre.toLowerCase().includes(q) || p.codigo.includes(q)));
 978:   const valor = S.productos.reduce((a,p) => a + p.stock * p.precio, 0);
 979:   const rows = list.map(p => { const d = diasPara(p.cad); return `<tr class="click" data-act="prod-ver" data-id="${p.id}">
 980:     <td><div class="cell-prod">${imgProd(p)}<div><b>${esc(p.nombre)}</b><small>${esc(p.fmt)}, ${esc(p.codigo || "sin código")}</small></div></div></td>
 981:     <td>${CATN[p.cat] || "Otros"}</td>
 982:     <td class="num">${money(p.precio)}${p.precioCaja ? `<small>caja ${money(p.precioCaja)}</small>` : ""}</td>
 983:     <td class="num"><b>${stockTxt(p)}</b><small>${p.stock} pz, mínimo ${p.min}</small></td>
 984:     <td>${p.cad ? `${fCad(p.cad)}${d < 0 ? `<small class="diff-bad">Vencido</small>` : d <= S.ajustes.alertaCad ? `<small>En ${plural(d,"día","días")}</small>` : ""}` : `<span class="muted">Sin fecha</span>`}</td>
 985:     <td>${isLow(p) ? `<span class="tag low">Bajo mínimo</span>` : `<span class="tag ok">Suficiente</span>`}</td>
 986:     <td><div style="display:flex;gap:6px"><button class="btn btn-sm" data-act="recibir" data-id="${p.id}">Recibir</button><button class="btn btn-sm" data-act="prod-editar" data-id="${p.id}">Editar</button></div></td></tr>`; }).join("");
 987:   return `<div class="row-actions"><div class="toolbar" style="margin:0;flex:1"><input class="search" id="catq" type="search" placeholder="Buscar por nombre o código" value="${esc(U.catQ)}" aria-label="Buscar en catálogo"></div>
 988:       <div class="acts"><button class="btn" data-act="csv">Exportar inventario</button><button class="btn btn-primary" data-act="prod-nuevo">${ico("mas")}Agregar producto</button></div></div>
 989:     <div class="row-actions"><div class="chips" style="margin:0">${[["todo","Todo"]].concat(CATS).map(([k,v]) => `<button class="chip" data-act="ccat" data-c="${k}" aria-pressed="${U.catCat === k}">${v}</button>`).join("")}</div><span class="muted">${plural(S.productos.length,"producto","productos")}, inventario valuado en ${money(valor)}</span></div>
 990:     ${list.length ? `<div class="table-wrap"><table><thead><tr><th>Producto</th><th>Categoría</th><th class="num">Precio</th><th class="num">Existencia</th><th>Caducidad</th><th>Estado</th><th></th></tr></thead><tbody>${rows}</tbody></table></div>`
 991:       : `<div class="panel"><div class="empty">${EMPTY_SVG}No hay productos con ese filtro.</div></div>`}`;
 992: }
 993: 
 994: function vEnvases(){
 995:   const panels = Object.keys(S.envases).map(k => { const e = S.envases[k], tot = e.bodega + e.prestados; return `<div class="panel env-panel">${imgEnvase(k)}<div><h3>${ENVN[k]}</h3>
 996:     <div class="kv"><span>Vacíos en bodega</span><b>${e.bodega}</b></div><div class="kv"><span>Prestados</span><b>${e.prestados}</b></div><div class="kv"><span>Depósito</span><b>${money(e.precio)}</b></div>
 997:     <div class="bar" title="Prestados"><i style="width:${tot ? Math.round(e.prestados / tot * 100) : 0}%;background:var(--vidrio)"></i></div></div></div>`; }).join("");
 998:   const lis = S.prestamos.length ? S.prestamos.map(x => { const dias = Math.floor((Date.now() - new Date(x.fecha)) / DAY); return `<div class="li"><div class="who"><span class="avatar">${esc(x.cliente.split(" ").map(w => w[0]).slice(0,2).join("").toUpperCase())}</span><div><b>${esc(x.cliente)}</b><small>${plural(x.cant,"envase","envases")} ${ENVN[x.formato]}, desde ${fFecha(x.fecha)}${dias >= 3 ? `, <span class="diff-bad">hace ${dias} días</span>` : ""}</small></div></div><div class="acts">${imgEnvase(x.formato).replace('class="pimg "','class="pimg" style="width:40px;height:40px"')}<button class="btn btn-sm" data-act="devolver" data-id="${x.id}">Registrar devolución</button></div></div>`; }).join("")
 999:     : `<div class="empty">${EMPTY_SVG}No hay envases prestados.</div>`;
1000:   return `<div class="panels">${panels}</div>
1001:     <div class="row-actions"><h2>Préstamos a clientes</h2><div class="acts"><button class="btn" data-act="vender-env">Vender vacíos</button><button class="btn" data-act="recibir-env">Recibir vacíos</button><button class="btn btn-primary" data-act="prestamo">${ico("mas")}Registrar préstamo</button></div></div>
1002:     <div class="list">${lis}</div>`;
1003: }
1004: 
1005: function vCorte(){
1006:   const hist = S.cortes.slice().reverse().map(c => `<div class="li"><div class="who"><span class="avatar">${ico("corte")}</span><div><b>${cap(fFecha(c.cierre))}, ${fHora(c.apertura)} a ${fHora(c.cierre)}</b><small>${plural(c.ventas,"venta","ventas")}, efectivo ${money(c.efectivo)}, tarjeta ${money(c.tarjeta)}</small></div></div><div class="acts"><span class="${c.diferencia === 0 ? "tag ok" : "tag low"}">${c.diferencia === 0 ? "Cuadró" : (c.diferencia > 0 ? "Sobraron " : "Faltaron ") + money(Math.abs(c.diferencia))}</span><button class="btn btn-sm" data-act="corte-pdf" data-id="${c.id}">PDF</button></div></div>`).join("") || `<div class="empty">Aún no hay cortes.</div>`;
1007:   if (!S.turno.abierto){
1008:     return `<div class="two"><div class="panel"><h3>La caja está cerrada</h3><p class="muted">Para vender, abre la caja con el efectivo que hay para dar cambio.</p>
1009:       <label class="field">Fondo inicial<input id="fondo" type="number" inputmode="decimal" value="${S.ajustes.fondo}"></label><button class="btn btn-primary btn-lg full" data-act="abrir-caja">Abrir caja</button></div><div class="panel"><div class="empty">${EMPTY_SVG}Los cortes quedan guardados abajo.</div></div></div>
1010:       <div class="list"><h3>Cortes anteriores</h3>${hist}</div>`;
1011:   }
1012:   const r = resumenTurno(), esperado = S.turno.fondo + r.efectivo;
1013:   return `<div class="two">
1014:       <div class="panel"><h3>Ventas del turno</h3><div class="donut-wrap">${donut([{ l:"Efectivo", v:r.efectivo, c:"var(--lager)" },{ l:"Tarjeta", v:r.tarjeta, c:"var(--vidrio)" }])}<div class="legend"><span><i style="background:var(--lager)"></i>Efectivo ${money(r.efectivo)}</span><span><i style="background:var(--vidrio)"></i>Tarjeta ${money(r.tarjeta)}</span><span class="muted">${plural(r.ventas,"venta","ventas")}${r.canceladas ? `, ${plural(r.canceladas,"cancelada","canceladas")}` : ""}</span></div></div></div>
1015:       <div class="panel"><h3>Arqueo</h3>
1016:         <div class="kv"><span>Turno abierto a las</span><b>${fHora(S.turno.apertura)}</b></div>
1017:         <div class="kv"><span>Fondo inicial</span><b>${money(S.turno.fondo)}</b></div>
1018:         <div class="kv"><span>Ventas en efectivo</span><b>${money(r.efectivo)}</b></div>
1019:         <div class="kv"><span>Incluye depósitos de envase</span><b>${money(r.envCobrados)}</b></div>
1020:         <div class="kv sum"><span>Debe haber en caja</span><b style="font-size:22px">${money(esperado)}</b></div></div></div>
1021:     <div class="two"><div class="panel"><h3>Cerrar el turno</h3>
1022:         <label class="field">Efectivo contado en caja<input id="contado" type="number" inputmode="decimal" placeholder="0"></label>
1023:         <div style="min-height:30px;font-weight:600;margin-bottom:8px" id="diff"></div>
1024:         <button class="btn btn-primary btn-lg full" data-act="cerrar-caja" id="btn-cerrar" disabled>Cerrar caja</button></div>
1025:       <div class="list"><h3>Cortes anteriores</h3>${hist}</div></div>`;
1026: }
1027: 
1028: function vAlertas(){
1029:   const a = alertas();
1030:   return `<div class="two">
1031:     <div class="list"><h3>Poco stock</h3>${a.low.length ? a.low.map(p => `<div class="li"><div class="who">${imgProd(p)}<div><b>${esc(p.nombre)}</b><small>Hay ${stockTxt(p)}; mínimo ${p.min} pz</small><div class="bar" style="width:160px"><i style="width:${Math.min(100, Math.round(p.stock / p.min * 100))}%;background:var(--alerta)"></i></div></div></div><div class="acts"><button class="btn btn-sm btn-primary" data-act="recibir" data-id="${p.id}">Recibir</button></div></div>`).join("") : `<div class="empty">${EMPTY_SVG}Todo está sobre su mínimo.</div>`}</div>
1032:     <div class="list"><h3>Caducan pronto</h3>${a.cad.length ? a.cad.map(p => { const d = diasPara(p.cad); return `<div class="li"><div class="who">${imgProd(p)}<div><b>${esc(p.nombre)}</b><small>${fCad(p.cad)}, ${stockTxt(p)} en existencia</small></div></div><div class="acts"><span class="tag ${d <= 7 ? "low" : "warn"}">${d < 0 ? "Vencido" : d === 0 ? "Vence hoy" : "En " + plural(d,"día","días")}</span><button class="btn btn-sm" data-act="prod-editar" data-id="${p.id}">Editar</button></div></div>`; }).join("") : `<div class="empty">${EMPTY_SVG}Nada vence en los próximos ${S.ajustes.alertaCad} días.</div>`}</div></div>
1033:     <p class="note">Se avisa ${S.ajustes.alertaCad} días antes de la caducidad y cuando un producto baja de su mínimo. Cámbialo en Ajustes o en cada producto.</p>`;
1034: }
1035: 
1036: function vResurtido(){
1037:   const sg = sugerencias();
1038:   if (!U.resSel) U.resSel = new Set(sg.filter(s => s.cant > 0).map(s => s.p.id));
1039:   const top = sg.slice().sort((a,b) => b.vendidas - a.vendidas).slice(0,6); const max = top[0] ? top[0].vendidas || 1 : 1;
1040:   const sel = sg.filter(s => s.cant > 0 && U.resSel.has(s.p.id));
1041:   return `<div class="two" style="grid-template-columns:1fr 1.6fr">
1042:     <div class="card"><div class="card-h"><h3>Productos estrella, 30 días</h3></div>${top.map((s,i) => `<div class="rank">${imgProd(s.p)}<div class="info"><div style="display:flex;justify-content:space-between;gap:8px"><b>${i + 1}. ${esc(s.p.nombre)}</b><span>${s.vendidas} pz</span></div><div class="bar"><i style="width:${Math.round(s.vendidas/max*100)}%"></i></div></div></div>`).join("")}</div>
1043:     <div><div class="row-actions"><label class="field" style="margin:0;flex-direction:row;align-items:center;gap:10px">Cubrir<input id="cobertura" type="number" min="1" max="60" value="${S.ajustes.cobertura}" style="width:84px">días</label>
1044:       <button class="btn btn-primary" data-act="res-pedido" ${sel.length ? "" : "disabled"}>${ico("resurtido")}Generar pedido (${sel.length})</button></div>
1045:       <div class="table-wrap"><table><thead><tr><th></th><th>Producto</th><th class="num">Venta diaria</th><th class="num">Alcanza para</th><th>Sugerido</th></tr></thead><tbody>
1046:       ${sg.map(s => `<tr><td>${s.cant > 0 ? `<input type="checkbox" data-res="${s.p.id}" ${U.resSel.has(s.p.id) ? "checked" : ""} aria-label="Incluir ${esc(s.p.nombre)}" style="width:20px;height:20px">` : ""}</td>
1047:         <td><div class="cell-prod">${imgProd(s.p)}<div>${esc(s.p.nombre)}<small>${stockTxt(s.p)} en existencia</small></div></div></td><td class="num">${s.vd.toFixed(1)} pz</td>
1048:         <td class="num">${s.alcanza === Infinity ? "Sin ventas" : `<span class="${s.alcanza <= 2 ? "diff-bad" : ""}">${plural(s.alcanza,"día","días")}</span>`}</td>
1049:         <td>${s.cant > 0 ? `<b>${s.txt}</b>` : `<span class="muted">${s.txt}</span>`}</td></tr>`).join("")}
1050:       </tbody></table></div>
1051:       <p class="note">Sugerido = venta diaria de los últimos 30 días × días a cubrir + mínimo − existencia, redondeado a cajas completas.</p></div></div>`;
1052: }
1053: 
1054: function vAjustes(){
1055:   const a = S.ajustes, t = getTema();
1056:   return `<div class="two">
1057:     <div>
1058:       <div class="section"><h2>Negocio</h2><label class="field">Nombre que aparece en los tickets<input data-aj="negocio" value="${esc(a.negocio)}"></label></div>
1059:       <div class="section"><h2>Apariencia</h2><span class="seg wide" role="group" aria-label="Tema">${[["auto","Automático"],["light","Claro"],["dark","Oscuro"]].map(([k,l]) => `<button data-act="tema-set" data-t="${k}" aria-pressed="${t === k}">${l}</button>`).join("")}</span></div>
1060:       <div class="section"><h2>Conexión</h2><label class="field">Dirección de este servidor en la red<input data-aj="ip" value="${esc(a.ip)}"></label>
1061:         <button class="btn" data-act="qr">${ico("qr")}Mostrar código para terminales</button>
1062:         <p class="note">En la app real la IP se detecta sola y conviene reservarla en el router. En este prototipo, abre el enlace en otra pestaña, elige Terminal y verás los pedidos llegar aquí.</p></div>
1063:       <div class="section"><h2>Este dispositivo</h2><p class="muted" style="margin:0 0 10px">Funciona como caja.</p><button class="btn" data-act="rol-cambiar" data-r="terminal">Usarlo como terminal</button></div>
1064:     </div>
1065:     <div>
1066:       <div class="section"><h2>Parámetros</h2><div class="form">
1067:         <label class="field">Fondo inicial sugerido<input data-aj="fondo" type="number" value="${a.fondo}"></label>
1068:         <label class="field">Avisar caducidad con (días)<input data-aj="alertaCad" type="number" value="${a.alertaCad}"></label>
1069:         <label class="field">Días que cubre el resurtido<input data-aj="cobertura" type="number" value="${a.cobertura}"></label><span></span>
1070:         ${Object.keys(S.envases).map(k => `<label class="field">Depósito envase ${ENVN[k]}<input data-env="${k}" type="number" value="${S.envases[k].precio}"></label>`).join("")}
1071:       </div></div>
1072:       <div class="section"><h2>Datos</h2><div class="stack">
1073:         <button class="btn" data-act="backup">Exportar respaldo</button>
1074:         <label class="btn" style="cursor:pointer">Importar respaldo<input type="file" id="import" accept=".json,application/json" hidden></label>
1075:         <button class="btn btn-danger" data-act="reset">Restablecer datos de ejemplo</button></div>
1076:         <p class="note">Toda la información vive en este dispositivo. Exporta un respaldo al cerrar el día.</p></div>
1077:     </div></div>`;
1078: }
1079: 
1080: const SCREENS = { inicio:vInicio, vender:vVender, ventas:vVentas, catalogo:vCatalogo, envases:vEnvases, corte:vCorte, alertas:vAlertas, resurtido:vResurtido, ajustes:vAjustes };
1081: 
1082: /* ================= Vistas: Terminal ================= */
1083: function vTerminal(){
1084:   const T = { escanear:"Escanear", pedido:"Pedido", stock:"Productos", ajustes:"Ajustes" };
1085:   const n = U.tcart.reduce((a,l)=>a+l.qty,0);
1086:   let body = "";
1087:   if (U.tScreen === "escanear"){
1088:     const p = U.lastScan ? P(U.lastScan) : null;
1089:     body = `<button class="scan-big" data-act="scan" data-ctx="terminal">${ico("escanear")}Abrir cámara</button>
1090:       <div class="inline"><input id="tcode" inputmode="numeric" placeholder="O escribe el código" autocomplete="off"><button class="btn btn-dark" data-act="tcode">Buscar</button></div>
1091:       ${p ? tCard(p) : `<div class="empty">${EMPTY_SVG}Escanea un producto para ver su precio y existencia.</div>`}`;
1092:   } else if (U.tScreen === "pedido"){
1093:     body = U.tcart.length ? `<div class="list">${U.tcart.map((l,i) => { const p = P(l.pid); return `<div class="li"><div class="who">${imgProd(p)}<div><b>${esc(p.nombre)}</b><small>${l.unidad === "caja" ? "Caja de " + p.ppc : "Pieza"}, ${money(precioL(l))}</small></div></div><span class="qty"><button data-act="tdec" data-i="${i}" aria-label="Quitar uno">−</button><span>${l.qty}</span><button data-act="tinc" data-i="${i}" aria-label="Agregar uno">+</button></span></div>`; }).join("")}</div>
1094:       <div class="total" style="border:0;padding:14px 2px"><span>Subtotal</span><b style="font-size:42px">${money(subtotal(U.tcart))}</b></div>
1095:       <label class="field">Nota para la caja (opcional)<input id="tnota" placeholder="Ej. cliente de la camioneta roja" value="${esc(U.tnota)}"></label>
1096:       <button class="btn btn-primary btn-lg full" data-act="tenviar">Enviar pedido a la caja</button>`
1097:       : `<div class="empty">${EMPTY_SVG}El pedido está vacío. Escanea o elige productos para agregarlos.</div><button class="btn btn-primary btn-lg full" data-act="tgo" data-s="stock">Ver productos</button>`;
1098:   } else if (U.tScreen === "stock"){
1099:     const q = U.tq.trim().toLowerCase();
1100:     const list = S.productos.filter(p => !q || p.nombre.toLowerCase().includes(q) || p.codigo.includes(q));
1101:     body = `<input class="search full" id="tq" type="search" placeholder="Buscar producto" value="${esc(U.tq)}" aria-label="Buscar producto" style="margin-bottom:14px">
1102:       <div class="tgrid">${list.map(p => { const k = enCarrito(U.tcart, p.id); return `<button class="tile ${p.stock <= 0 ? "out" : ""}" data-act="tver" data-id="${p.id}">${k ? `<span class="incart">${k}</span>` : ""}${imgProd(p)}<span class="nm">${esc(p.nombre)}</span><span class="pr" style="font-size:26px">${money(p.precio)}</span><span class="st ${isLow(p) ? "low" : ""}">${stockTxt(p)}</span></button>`; }).join("") || `<div class="empty" style="grid-column:1/-1">Sin resultados.</div>`}</div>`;
1103:   } else {
1104:     body = `<label class="field">Nombre de esta terminal<input id="tname" value="${esc(getTermName())}"></label>
1105:       <div class="panel" style="margin-bottom:14px"><div class="kv"><span>Conectada a</span><b>${esc(S.ajustes.ip)}</b></div><div class="kv"><span>Estado</span><b><span class="dot"></span>En línea</b></div></div>
1106:       <div class="section"><h2 style="font-size:24px;margin-bottom:8px">Apariencia</h2><span class="seg wide" role="group">${[["auto","Automático"],["light","Claro"],["dark","Oscuro"]].map(([k,l]) => `<button data-act="tema-set" data-t="${k}" aria-pressed="${getTema() === k}">${l}</button>`).join("")}</span></div>
1107:       <div class="stack"><button class="btn" data-act="rol-cambiar" data-r="">Volver a elegir modo</button><button class="btn" data-act="rol-cambiar" data-r="caja">Usar como caja</button></div>`;
1108:   }
1109:   return `<div class="term"><header class="term-top"><div><h1>${T[U.tScreen]}</h1><small><span class="dot"></span>${esc(getTermName())}, conectada a la caja</small></div>${n ? `<button class="icon-btn" data-act="tgo" data-s="pedido" aria-label="Ver pedido" style="width:auto;padding:0 12px;gap:6px;display:inline-flex">${ico("pedido")}<b>${n}</b></button>` : ""}</header>
1110:     <div class="term-body" id="tbody" data-scroll>${body}</div>
1111:     <nav class="tabs" aria-label="Terminal">${[["escanear","escanear"],["pedido","pedido"],["stock","catalogo"],["ajustes","ajustes"]].map(([k,ic]) => `<button data-act="tgo" data-s="${k}" ${U.tScreen === k ? 'aria-current="page"' : ""}>${ico(ic)}<span>${T[k]}${k === "pedido" && n ? ` (${n})` : ""}</span></button>`).join("")}</nav></div>`;
1112: }
1113: function tCard(p){
1114:   return `<div class="pcard"><div class="top">${imgProd(p)}<div><div class="nm">${esc(p.nombre)}</div><div class="muted">${esc(p.fmt)}</div><div class="pr">${money(p.precio)}</div></div></div>
1115:     <div style="display:flex;gap:8px;flex-wrap:wrap;margin:12px 0"><span class="tag ${isLow(p) ? "low" : "ok"}">${stockTxt(p)}</span>${p.precioCaja ? `<span class="tag">Caja de ${p.ppc}: ${money(p.precioCaja)}</span>` : ""}${p.cad ? `<span class="tag">Caduca ${fCad(p.cad)}</span>` : ""}</div>
1116:     <div class="stack"><button class="btn btn-primary btn-lg" data-act="tadd" data-id="${p.id}" data-u="pieza">Agregar 1 pieza</button>
1117:     ${p.ppc ? `<button class="btn btn-lg" data-act="tadd" data-id="${p.id}" data-u="caja">Agregar 1 caja de ${p.ppc}</button>` : ""}</div></div>`;
1118: }
1119: 
1120: /* ================= Render ================= */
1121: let lastKey = "";
1122: function render(){
1123:   const rol = getRol();
1124:   const key = rol + (rol === "caja" ? U.screen : U.tScreen);
1125:   const a = document.activeElement;
1126:   const fid = a && a.id && $("#app").contains(a) ? a.id : null;
1127:   let ss = null, se = null; try { ss = a.selectionStart; se = a.selectionEnd; } catch(e){}
1128:   const scr = {};
1129:   if (key === lastKey) document.querySelectorAll("#app [data-scroll]").forEach(el => { scr[el.id] = el.scrollTop; });
1130:   $("#app").className = rol ? "r-" + rol : "r-start"; document.body.dataset.rol = rol || "start";
1131:   $("#app").innerHTML = !rol ? vStart() : rol === "caja" ? vCaja() : vTerminal();
1132:   for (const id in scr){ const el = document.getElementById(id); if (el) el.scrollTop = scr[id]; }
1133:   if (fid && key === lastKey){ const el = document.getElementById(fid); if (el){ el.focus({ preventScroll:true }); try { if (ss != null) el.setSelectionRange(ss, se); } catch(e){} } }
1134:   lastKey = key;
1135: }
1136: setInterval(() => { const r = $("#reloj"); if (r) r.textContent = fechaPill(); }, 30000);
1137: 
1138: function volar(fromEl, toSel){
1139:   if (reduceMotion() || !fromEl) return null;
1140:   const img = fromEl.querySelector(".pimg"); if (!img) return null;
1141:   const a = img.getBoundingClientRect(), cl = img.cloneNode(true);
1142:   Object.assign(cl.style, { position:"fixed", left:a.left + "px", top:a.top + "px", width:a.width + "px", height:a.height + "px", zIndex:70, pointerEvents:"none", margin:0 });
1143:   return () => {
1144:     const to = $(toSel); if (!to){ return; }
1145:     const b = to.getBoundingClientRect(); document.body.appendChild(cl);
1146:     const dx = b.left + 40 - (a.left + a.width/2), dy = b.top + 60 - (a.top + a.height/2);
1147:     const an = cl.animate([{ transform:"translate(0,0) scale(1)", opacity:1 }, { transform:`translate(${dx}px,${dy}px) scale(.25)`, opacity:.3 }], { duration:420, easing:"cubic-bezier(.5,0,.75,1)" });
1148:     an.onfinish = () => cl.remove();
1149:   };
1150: }
1151: 
1152: /* ================= Modales ================= */
1153: function modalCobro(){
1154:   const total = totalCart();
1155:   if (U.metodo === "efectivo"){
1156:     openModal(`<h2>Cobro en efectivo</h2><p>Total a cobrar: <b style="color:var(--ink);font-size:22px">${money(total)}</b></p>
1157:       <label class="field">Recibido<input id="recibido" type="number" inputmode="decimal" placeholder="0" value="${esc(U.recibido)}" autofocus></label>
1158:       <div class="quick"><button class="btn btn-sm" data-act="rec" data-v="${total}">Exacto</button>${[200,500,1000].map(b => `<button class="btn btn-sm" data-act="rec" data-v="${b}">${money(b)}</button>`).join("")}</div>
1159:       <div class="keypad">${["1","2","3","4","5","6","7","8","9",".","0","⌫"].map(k => `<button data-act="kp" data-k="${k}" aria-label="${k === "⌫" ? "Borrar" : k}">${k}</button>`).join("")}</div>
1160:       <div class="change"><span id="cambio-lbl">Cambio</span><b id="cambio">$0</b></div>
1161:       <div class="modal-actions"><button class="btn" data-act="close">Cancelar</button><button class="btn btn-primary btn-lg" data-act="confirmar" id="btn-confirmar" disabled>Registrar venta</button></div>`);
1162:     updCambio();
1163:   } else {
1164:     openModal(`<h2>Cobro con tarjeta</h2><p>Cobra <b style="color:var(--ink);font-size:22px">${money(total)}</b> en la terminal bancaria y confirma cuando se apruebe.</p>
1165:       <span class="seg" role="group" aria-label="Tipo de tarjeta" style="margin-bottom:18px"><button data-act="tt" data-v="Débito" aria-pressed="${U.tarjeta === "Débito"}">Débito</button><button data-act="tt" data-v="Crédito" aria-pressed="${U.tarjeta === "Crédito"}">Crédito</button></span>
1166:       <div class="modal-actions"><button class="btn" data-act="close">Cancelar</button><button class="btn btn-primary btn-lg" data-act="confirmar">Pago aprobado, registrar</button></div>`);
1167:   }
1168: }
1169: function updCambio(){
1170:   const total = totalCart(), rec = parseFloat(U.recibido), ok = !isNaN(rec) && rec >= total - 1e-9;
1171:   const lbl = $("#cambio-lbl"), c = $("#cambio"), b = $("#btn-confirmar"), inp = $("#recibido"); if (!c) return;
1172:   if (inp && inp.value !== U.recibido) inp.value = U.recibido;
1173:   if (!isNaN(rec) && rec < total){ lbl.innerHTML = `<span class="diff-bad">Faltan ${money(total - rec)}</span>`; c.textContent = "$0"; }
1174:   else { lbl.textContent = "Cambio"; c.textContent = money(ok ? rec - total : 0); }
1175:   b.disabled = !ok;
1176: }
1177: function accionesTicket(v){ return `<div class="share"><button class="btn" data-act="t-share" data-id="${v.id}">Compartir PDF</button><button class="btn" data-act="t-wa" data-id="${v.id}">WhatsApp</button><button class="btn" data-act="t-pdf" data-id="${v.id}">Descargar PDF</button></div>`; }
1178: function modalVentaHecha(v, nuevos){
1179:   openModal(`<div class="split">${reciboHTML(v)}<div>
1180:     <h2>Venta ${v.folio} registrada</h2>
1181:     <p class="muted" style="margin:0 0 14px">${money(v.total)} ${v.metodo === "efectivo" ? "en efectivo." : `con tarjeta de ${v.tarjeta.toLowerCase()}.`} El stock ya se actualizó en todas las terminales.</p>
1182:     ${v.metodo === "efectivo" && v.cambio > 0 ? `<div class="change"><span>Entrega de cambio</span><b>${money(v.cambio)}</b></div>` : ""}
1183:     ${nuevos.length ? `<div class="banner" style="background:var(--alerta-soft);border-color:var(--alerta)"><div><b class="diff-bad">Quedó bajo el mínimo</b><small>${esc(nuevos.map(p => p.nombre).join(", "))}</small></div></div>` : ""}
1184:     ${accionesTicket(v)}
1185:     <button class="btn btn-primary btn-lg full" data-act="close">Nueva venta</button></div></div>`, "xwide");
1186: }
1187: function modalVenta(v){
1188:   const cancelable = !v.cancelada && !v.corteId;
1189:   openModal(`<div class="split">${reciboHTML(v)}<div><h2>Venta ${v.folio}</h2><p class="muted" style="margin:0 0 14px">${fFechaHora(v.fecha)}, desde ${esc(v.origen)}.</p>
1190:     ${accionesTicket(v)}
1191:     <div class="modal-actions">${cancelable ? `<button class="btn btn-danger" data-act="venta-cancelar" data-id="${v.id}">Cancelar venta</button>` : ""}<button class="btn btn-primary" data-act="close">Listo</button></div></div></div>`, "xwide");
1192: }
1193: function modalProdVer(p){
1194:   const m = vendidas30(), vend = m[p.id] || 0;
1195:   openModal(`<div class="detail">${imgProd(p)}<div><h2>${esc(p.nombre)}</h2><p class="muted" style="margin:0">${esc(p.fmt)}, ${CATN[p.cat] || "Otros"}, código ${esc(p.codigo || "sin código")}</p>
1196:     <div class="pr">${money(p.precio)}${p.precioCaja ? ` <span class="muted" style="font-size:20px">caja de ${p.ppc}: ${money(p.precioCaja)}</span>` : ""}</div>
1197:     <div class="kv"><span>Existencia</span><b>${stockTxt(p)} (${p.stock} pz)</b></div>
1198:     <div class="kv"><span>Mínimo</span><b>${p.min} pz</b></div>
1199:     <div class="kv"><span>Vendidas en 30 días</span><b>${vend} pz, ${(vend/30).toFixed(1)} por día</b></div>
1200:     <div class="kv"><span>Caducidad</span><b>${fCad(p.cad)}</b></div>
1201:     ${p.env ? `<div class="kv"><span>Envase retornable</span><b>${ENVN[p.env]}, depósito ${money(S.envases[p.env].precio)}</b></div>` : ""}
1202:     <div class="modal-actions" style="margin-top:14px"><button class="btn" data-act="close">Cerrar</button><button class="btn" data-act="recibir" data-id="${p.id}">Recibir</button><button class="btn btn-primary" data-act="prod-editar" data-id="${p.id}">Editar</button></div></div></div>`, "wide");
1203: }
1204: function formPrev(){ const f = U.form; return imgProd({ cat:$("#f-cat") ? $("#f-cat").value : f.cat, foto:f.foto, ilus:f.ilus }); }
1205: function modalProducto(p, code){
1206:   const n = !p; p = p || { nombre:"", codigo:code || "", cat:"cerveza", fmt:"", precio:"", precioCaja:"", ppc:"", stock:0, min:12, env:"", cad:"", foto:"", ilus:{ forma:"media", c1:"#7A3E12", c2:"#E0B04A", c3:"#B7892B" } };
1207:   U.form = { id: n ? null : p.id, foto:p.foto || "", ilus:Object.assign({}, p.ilus || { forma:"caja", c1:"#B98B55", c2:"#8C5A2B", c3:"#E3C08F" }), cat:p.cat };
1208:   const porCaja = n ? true : !!p.ppc, il = U.form.ilus;
1209:   openModal(`<h2>${n ? "Agregar producto" : "Editar producto"}</h2><p>${n ? "Registra un producto del depósito." : "Los cambios se ven al instante en las terminales."}</p>
1210:     <div class="img-edit"><div id="f-prev">${formPrev()}</div><div class="img-tools">
1211:       <div style="display:flex;gap:8px;flex-wrap:wrap"><label class="btn btn-sm" style="cursor:pointer">Tomar o subir foto<input type="file" id="f-foto" accept="image/*" capture="environment" hidden></label><span id="f-fbtn">${U.form.foto ? `<button class="btn btn-sm" data-act="foto-quitar">Usar ilustración</button>` : ""}</span></div>
1212:       <label class="field" style="margin:0">Ilustración<select id="f-forma">${FORMAS.map(([k,v]) => `<option value="${k}" ${il.forma === k ? "selected" : ""}>${v}</option>`).join("")}</select></label>
1213:       <div class="form"><label class="field">Cuerpo<input type="color" id="f-c1" value="${il.c1}"></label><label class="field">Etiqueta<input type="color" id="f-c2" value="${il.c2}"></label><label class="field">Tapa<input type="color" id="f-c3" value="${il.c3}"></label></div>
1214:     </div></div>
1215:     <div class="form">
1216:       <label class="field span">Nombre<input id="f-nombre" value="${esc(p.nombre)}" placeholder="Ej. Victoria Mega" autofocus></label>
1217:       <label class="field">Código de barras<input id="f-codigo" value="${esc(p.codigo)}" inputmode="numeric"></label>
1218:       <label class="field">Categoría<select id="f-cat">${CATS.map(([k,v]) => `<option value="${k}" ${p.cat === k ? "selected" : ""}>${v}</option>`).join("")}</select></label>
1219:       <label class="field">Presentación<input id="f-fmt" value="${esc(p.fmt)}" placeholder="Ej. Mega 1.2 L"></label>
1220:       <label class="field">Precio por pieza<input id="f-precio" type="number" inputmode="decimal" value="${p.precio}"></label>
1221:       <label class="check span"><input type="checkbox" id="f-porcaja" ${porCaja ? "checked" : ""}> También se vende por caja</label>
1222:       <div class="span form" id="f-caja" ${porCaja ? "" : "hidden"}>
1223:         <label class="field">Piezas por caja<input id="f-ppc" type="number" value="${p.ppc || ""}" placeholder="12"></label>
1224:         <label class="field">Precio por caja<input id="f-precioCaja" type="number" inputmode="decimal" value="${p.precioCaja || ""}"></label></div>
1225:       <label class="field">Envase retornable<select id="f-env"><option value="">No usa</option>${Object.keys(ENVN).map(k => `<option value="${k}" ${p.env === k ? "selected" : ""}>${ENVN[k]}</option>`).join("")}</select></label>
1226:       <label class="field">Existencia mínima (piezas)<input id="f-min" type="number" value="${p.min}"></label>
1227:       <label class="field">${n ? "Existencia inicial (piezas)" : "Existencia actual (piezas)"}<input id="f-stock" type="number" value="${p.stock}"></label>
1228:       <label class="field">Caducidad del lote más próximo<input id="f-cad" type="date" value="${p.cad || ""}"></label>
1229:     </div>
1230:     <p class="diff-bad" id="f-err" style="font-weight:600;margin:0 0 8px"></p>
1231:     <div class="modal-actions">${n ? "" : `<button class="btn btn-danger" data-act="prod-borrar" data-id="${p.id}">Eliminar</button>`}<button class="btn" data-act="close">Cancelar</button><button class="btn btn-primary" data-act="prod-guardar">${n ? "Agregar producto" : "Guardar cambios"}</button></div>`, "wide");
1232: }
1233: function refrescarPrev(){ const el = $("#f-prev"); if (el) el.innerHTML = formPrev(); const fb = $("#f-fbtn"); if (fb) fb.innerHTML = U.form && U.form.foto ? `<button class="btn btn-sm" data-act="foto-quitar">Usar ilustración</button>` : ""; }
1234: function guardarProducto(){
1235:   const id = U.form && U.form.id;
1236:   const g = s => $(s).value.trim(), err = m => { $("#f-err").textContent = m; };
1237:   const nombre = g("#f-nombre"), codigo = g("#f-codigo"), precio = parseFloat(g("#f-precio"));
1238:   const porCaja = $("#f-porcaja").checked, ppc = parseInt(g("#f-ppc"), 10), precioCaja = parseFloat(g("#f-precioCaja"));
1239:   if (!nombre) return err("Escribe el nombre del producto.");
1240:   if (!(precio > 0)) return err("Escribe un precio por pieza mayor a cero.");
1241:   if (porCaja && !(ppc > 1)) return err("Indica cuántas piezas trae la caja.");
1242:   if (porCaja && !(precioCaja > 0)) return err("Escribe el precio por caja.");
1243:   if (codigo && S.productos.some(p => p.codigo === codigo && p.id !== id)) return err("Ese código ya lo usa otro producto.");
1244:   const data = { nombre, codigo, cat:$("#f-cat").value, fmt:g("#f-fmt"), precio, ppc: porCaja ? ppc : null, precioCaja: porCaja ? precioCaja : null, env:$("#f-env").value, min: Math.max(0, parseInt(g("#f-min"),10) || 0), stock: Math.max(0, parseInt(g("#f-stock"),10) || 0), cad:$("#f-cad").value, foto:U.form.foto, ilus:U.form.ilus };
1245:   if (id) Object.assign(P(id), data); else S.productos.push(Object.assign({ id:uid() }, data));
1246:   if (!save()) return err("No se pudo guardar: el almacenamiento está lleno.");
1247:   closeModal(); render(); toast(id ? "Producto actualizado" : "Producto agregado");
1248: }
1249: function modalRecibir(p){
1250:   openModal(`<div class="detail" style="grid-template-columns:120px 1fr">${imgProd(p).replace('class="pimg "','class="pimg" style="width:120px;height:120px"')}<div><h2>Recibir mercancía</h2><p class="muted" style="margin:0 0 12px">${esc(p.nombre)}, hay ${stockTxt(p)}.</p>
1251:     <div class="form">${p.ppc ? `<label class="field">Cajas de ${p.ppc}<input id="r-cajas" type="number" min="0" value="1" autofocus></label>` : ""}
1252:       <label class="field">Piezas sueltas<input id="r-pz" type="number" min="0" value="${p.ppc ? 0 : 1}" ${p.ppc ? "" : "autofocus"}></label>
1253:       <label class="field span">Caducidad de este lote (opcional)<input id="r-cad" type="date"></label></div>
1254:     <div class="modal-actions"><button class="btn" data-act="close">Cancelar</button><button class="btn btn-primary" data-act="recibir-ok" data-id="${p.id}">Agregar al inventario</button></div></div></div>`, "wide");
1255: }
1256: function modalQR(){
1257:   const url = "http://" + S.ajustes.ip; let q = "";
1258:   try { const g = window.qrcode(0, "M"); g.addData(url); g.make(); q = g.createSvgTag(6, 2); } catch(e){ q = ""; }
1259:   openModal(`<h2>Conectar una terminal</h2><p>En el teléfono, abre la app, elige Terminal y escanea este código.</p>
1260:     ${q ? `<div class="qrbox">${q}</div>` : ""}<div class="addr">${esc(S.ajustes.ip)}</div>
1261:     <div class="modal-actions"><button class="btn btn-primary" data-act="close">Listo</button></div>`);
1262: }
1263: function csvInventario(){
1264:   const h = ["Codigo","Producto","Categoria","Presentacion","Existencia_piezas","Existencia","Minimo","Caducidad","Precio_pieza","Precio_caja","Piezas_por_caja"];
1265:   const q = s => `"${String(s == null ? "" : s).replace(/"/g,'""')}"`;
1266:   return "\ufeff" + h.join(",") + "\n" + S.productos.map(p => [p.codigo, p.nombre, CATN[p.cat], p.fmt, p.stock, stockTxt(p), p.min, p.cad, p.precio, p.precioCaja || "", p.ppc || ""].map(q).join(",")).join("\n");
1267: }
1268: 
1269: /* ================= Eventos ================= */
1270: document.addEventListener("click", async ev => {
1271:   const b = ev.target.closest("[data-act]"); if (!b) return;
1272:   if (b.disabled) return;
1273:   const d = b.dataset, act = d.act;
1274:   const venta = id => S.ventas.find(v => v.id === id);
1275:   switch (act){
1276:     case "rol-caja": setRol("caja"); U.screen = "inicio"; render(); toast("Servidor iniciado en " + S.ajustes.ip); break;
1277:     case "rol-term": U.startRol = "terminal"; render(); break;
1278:     case "rol-term-ok": { const nm = ($("#start-name").value || "").trim() || "Terminal"; setTermName(nm); const ip = ($("#start-ip").value || "").trim(); setRol("terminal"); U.tScreen = "escanear"; render(); toast("Conectada a " + (ip || S.ajustes.ip)); break; }
1279:     case "rol-cambiar": setRol(d.r); U.startRol = ""; closeModal(); render(); break;
1280:     case "tema": { const t = getTema(), nx = t === "auto" ? "light" : t === "light" ? "dark" : "auto"; lsSet("pos-tema", nx); aplicarTema(); render(); toast("Tema: " + (nx === "auto" ? "automático" : nx === "dark" ? "oscuro" : "claro")); break; }
1281:     case "tema-set": lsSet("pos-tema", d.t); aplicarTema(); render(); break;
1282:     case "go": U.screen = d.s; if (d.s === "resurtido") U.resSel = null; closeModal(); render(); { const h = $("#host"); if (h) h.scrollTop = 0; } break;
1283:     case "tgo": U.tScreen = d.s; render(); break;
1284:     case "cat": U.cat = d.c; render(); break;
1285:     case "ccat": U.catCat = d.c; render(); break;
1286:     case "vf": U.vf = d.f; render(); break;
1287:     case "add": { const fly = volar(b, "#lines"); if (addCart(U.cart, d.id, "pieza", true)){ U.flash = d.id; render(); if (fly) fly(); } else render(); break; }
1288:     case "unit": { const l = U.cart[+d.i], old = l.unidad; l.unidad = d.u; if (enCarrito(U.cart, l.pid) > P(l.pid).stock){ l.unidad = old; toast("No hay suficiente existencia para venderlo por caja"); } else { const dup = U.cart.find((x,j) => j !== +d.i && x.pid === l.pid && x.unidad === l.unidad); if (dup){ dup.qty += l.qty; U.cart.splice(+d.i,1); } } render(); break; }
1289:     case "inc": { const l = U.cart[+d.i]; if (addCart(U.cart, l.pid, l.unidad, true)) U.flash = l.pid; render(); break; }
1290:     case "dec": { const l = U.cart[+d.i]; l.qty--; if (l.qty <= 0) U.cart.splice(+d.i,1); render(); break; }
1291:     case "vaciar": U.cart = []; U.envModo = "cobrar"; U.envCliente = ""; render(); break;
1292:     case "envmodo": U.envModo = d.m; render(); if (d.m === "prestamo"){ const e = $("#envCliente"); if (e) e.focus(); } break;
1293:     case "cobrar":
1294:       if (!S.turno.abierto){ openModal(`<h2>La caja está cerrada</h2><p>Abre la caja para poder cobrar.</p><label class="field">Fondo inicial<input id="fondo-m" type="number" value="${S.ajustes.fondo}" autofocus></label><div class="modal-actions"><button class="btn" data-act="close">Cancelar</button><button class="btn btn-primary" data-act="abrir-caja" data-m="${d.m}">Abrir caja</button></div>`); break; }
1295:       if (U.envModo === "prestamo" && envasesCart(U.cart).n && !U.envCliente.trim()){ toast("Escribe el nombre del cliente del préstamo"); const e = $("#envCliente"); if (e) e.focus(); break; }
1296:       U.metodo = d.m; U.recibido = ""; modalCobro(); break;
1297:     case "rec": U.recibido = String(d.v); updCambio(); break;
1298:     case "kp": { const k = d.k; if (k === "⌫") U.recibido = U.recibido.slice(0,-1); else if (k === "." && U.recibido.includes(".")) break; else if (U.recibido.length < 8) U.recibido += k; updCambio(); break; }
1299:     case "tt": U.tarjeta = d.v; b.parentElement.querySelectorAll("button").forEach(x => x.setAttribute("aria-pressed", x === b)); break;
1300:     case "confirmar": { const r = registrarVenta(); render(); modalVentaHecha(r.v, r.nuevos); break; }
1301:     case "t-pdf": case "t-share": { const v = venta(d.id), doc = v && pdfTicket(v); if (doc) await entregar(blobDe(doc), `ticket-${v.folio}.pdf`, act === "t-share"); break; }
1302:     case "t-wa": { const v = venta(d.id); if (v) abrirWhatsApp(textoTicket(v)); break; }
1303:     case "ped-cargar": {
1304:       const pd = S.pedidos.find(x => x.id === d.id); if (!pd) break;
1305:       pd.items.forEach(l => { for (let k = 0; k < l.qty; k++) addCart(U.cart, l.pid, l.unidad, false); });
1306:       U.origen = pd.origen;
1307:       S.pedidos = S.pedidos.filter(x => x.id !== d.id); save();
1308:       const sobre = U.cart.some(l => enCarrito(U.cart, l.pid) > P(l.pid).stock);
1309:       render(); toast(sobre ? "Pedido cargado. Revisa existencias: algún producto excede el stock." : "Pedido cargado al ticket"); break;
1310:     }
1311:     case "ped-descartar": S.pedidos = S.pedidos.filter(x => x.id !== d.id); save(); render(); break;
1312:     case "scan": abrirScanner(d.ctx); break;
1313:     case "scan-pick": onCodigo(d.code); break;
1314:     case "scan-code": onCodigo(($("#scode") || {}).value); break;
1315:     case "close": closeModal(); break;
1316:     case "qr": modalQR(); break;
1317:     case "venta-ver": { const v = venta(d.id); if (v) modalVenta(v); break; }
1318:     case "venta-cancelar": openModal(`<h2>¿Cancelar la venta ${venta(d.id).folio}?</h2><p>El stock y los envases regresan al inventario y la venta ya no cuenta en el corte.</p><div class="modal-actions"><button class="btn" data-act="venta-ver" data-id="${d.id}">No, regresar</button><button class="btn btn-danger" data-act="venta-cancelar-ok" data-id="${d.id}">Cancelar venta</button></div>`); break;
1319:     case "venta-cancelar-ok": { const v = venta(d.id); cancelarVenta(v); closeModal(); render(); toast(`Venta ${v.folio} cancelada`); break; }
1320:     case "prod-ver": if (!ev.target.closest("button")) modalProdVer(P(d.id)); else if (ev.target.closest("button") === b) modalProdVer(P(d.id)); break;
1321:     case "prod-nuevo": modalProducto(null, d.code); break;
1322:     case "prod-editar": modalProducto(P(d.id)); break;
1323:     case "prod-guardar": guardarProducto(); break;
1324:     case "foto-quitar": U.form.foto = ""; refrescarPrev(); break;
1325:     case "prod-borrar": openModal(`<h2>¿Eliminar ${esc(P(d.id).nombre)}?</h2><p>Se quita del catálogo. Las ventas anteriores se conservan.</p><div class="modal-actions"><button class="btn" data-act="prod-editar" data-id="${d.id}">No, regresar</button><button class="btn btn-danger" data-act="prod-borrar-ok" data-id="${d.id}">Eliminar</button></div>`); break;
1326:     case "prod-borrar-ok": { const nm = P(d.id).nombre; S.productos = S.productos.filter(p => p.id !== d.id); U.cart = U.cart.filter(l => l.pid !== d.id); U.tcart = U.tcart.filter(l => l.pid !== d.id); save(); closeModal(); render(); toast(nm + " eliminado"); break; }
1327:     case "recibir": modalRecibir(P(d.id)); break;
1328:     case "recibir-ok": {
1329:       const p = P(d.id), c = parseInt(($("#r-cajas") || {}).value, 10) || 0, pz = parseInt($("#r-pz").value, 10) || 0, cad = $("#r-cad").value;
1330:       const add = c * (p.ppc || 0) + pz; if (add <= 0){ toast("Indica cuántas cajas o piezas llegaron"); break; }
1331:       p.stock += add; if (cad && (!p.cad || cad < p.cad || diasPara(p.cad) < 0)) p.cad = cad;
1332:       save(); closeModal(); render(); toast(`${p.nombre}: +${add} pz, ahora hay ${stockTxt(p)}`); break;
1333:     }
1334:     case "csv": await entregar(new Blob([csvInventario()], { type:"text/csv" }), `inventario-${isoDate(new Date())}.csv`, false); break;
1335:     case "prestamo": openModal(`<h2>Registrar préstamo</h2><p>Envases que el cliente se lleva y regresará después.</p>
1336:       <label class="field">Cliente<input id="p-cliente" placeholder="Nombre o negocio" autofocus></label>
1337:       <div class="form"><label class="field">Envase<select id="p-formato">${Object.keys(ENVN).map(k => `<option value="${k}">${ENVN[k]}</option>`).join("")}</select></label><label class="field">Cantidad<input id="p-cant" type="number" min="1" value="12"></label></div>
1338:       <div class="modal-actions"><button class="btn" data-act="close">Cancelar</button><button class="btn btn-primary" data-act="prestamo-ok">Registrar préstamo</button></div>`); break;
1339:     case "prestamo-ok": {
1340:       const cliente = $("#p-cliente").value.trim(), f = $("#p-formato").value, n = parseInt($("#p-cant").value, 10) || 0;
1341:       if (!cliente){ toast("Escribe el nombre del cliente"); break; } if (n <= 0){ toast("La cantidad debe ser mayor a cero"); break; }
1342:       S.prestamos.unshift({ id:uid(), cliente, formato:f, cant:n, fecha:new Date().toISOString() }); S.envases[f].prestados += n;
1343:       save(); closeModal(); render(); toast(`Préstamo de ${n} envases a ${cliente} registrado`); break;
1344:     }
1345:     case "devolver": { const x = S.prestamos.find(p => p.id === d.id); openModal(`<h2>Registrar devolución</h2><p>${esc(x.cliente)} tiene ${plural(x.cant,"envase","envases")} ${ENVN[x.formato]}.</p><label class="field">Envases que regresa<input id="dv-cant" type="number" min="1" max="${x.cant}" value="${x.cant}" autofocus></label><div class="modal-actions"><button class="btn" data-act="close">Cancelar</button><button class="btn btn-primary" data-act="devolver-ok" data-id="${x.id}">Registrar devolución</button></div>`); break; }
1346:     case "devolver-ok": {
1347:       const x = S.prestamos.find(p => p.id === d.id), n = Math.min(x.cant, parseInt($("#dv-cant").value, 10) || 0);
1348:       if (n <= 0){ toast("La cantidad debe ser mayor a cero"); break; }
1349:       S.envases[x.formato].bodega += n; S.envases[x.formato].prestados = Math.max(0, S.envases[x.formato].prestados - n); x.cant -= n;
1350:       if (x.cant <= 0) S.prestamos = S.prestamos.filter(p => p !== x);
1351:       save(); closeModal(); render(); toast(`Devolución de ${n} envases registrada`); break;
1352:     }
1353:     case "vender-env": openModal(`<h2>Vender envases vacíos</h2><p>Se descuentan de los vacíos en bodega.</p>
1354:       <div class="form"><label class="field">Envase<select id="ve-f">${Object.keys(ENVN).map(k => `<option value="${k}">${ENVN[k]} (${money(S.envases[k].precio)}, hay ${S.envases[k].bodega})</option>`).join("")}</select></label><label class="field">Cantidad<input id="ve-n" type="number" min="1" value="12" autofocus></label>
1355:       <label class="field span">Pago<select id="ve-m"><option value="efectivo">Efectivo</option><option value="tarjeta">Tarjeta</option></select></label></div>
1356:       <div class="modal-actions"><button class="btn" data-act="close">Cancelar</button><button class="btn btn-primary" data-act="vender-env-ok">Registrar venta</button></div>`); break;
1357:     case "vender-env-ok": {
1358:       if (!S.turno.abierto){ toast("Abre la caja en Corte de caja para vender"); break; }
1359:       const f = $("#ve-f").value, n = parseInt($("#ve-n").value, 10) || 0, m = $("#ve-m").value;
1360:       if (n <= 0 || n > S.envases[f].bodega){ toast(`Solo hay ${S.envases[f].bodega} vacíos ${ENVN[f]} en bodega`); break; }
1361:       const precio = S.envases[f].precio, total = precio * n;
1362:       S.envases[f].bodega -= n;
1363:       const v = { id:uid(), folio:++S.folio, fecha:new Date().toISOString(), items:[{ pid:null, nombre:`Envase ${ENVN[f]} vacío`, unidad:"pieza", qty:n, precio, piezas:0 }], env:{modo:"na",n:0,monto:0}, envVacios:{formato:f,cant:n}, total, metodo:m, tarjeta: m === "tarjeta" ? "Débito" : "", recibido: m === "efectivo" ? total : 0, cambio:0, corteId:null, origen:"Caja", cancelada:false };
1364:       S.ventas.push(v); save(); render(); modalVentaHecha(v, []); break;
1365:     }
1366:     case "recibir-env": openModal(`<h2>Recibir envases vacíos</h2><p>Para envases que llegan sin una venta, por ejemplo de un proveedor.</p>
1367:       <div class="form"><label class="field">Envase<select id="re-f">${Object.keys(ENVN).map(k => `<option value="${k}">${ENVN[k]}</option>`).join("")}</select></label><label class="field">Cantidad<input id="re-n" type="number" min="1" value="24" autofocus></label></div>
1368:       <div class="modal-actions"><button class="btn" data-act="close">Cancelar</button><button class="btn btn-primary" data-act="recibir-env-ok">Agregar a bodega</button></div>`); break;
1369:     case "recibir-env-ok": { const f = $("#re-f").value, n = parseInt($("#re-n").value, 10) || 0; if (n <= 0){ toast("La cantidad debe ser mayor a cero"); break; } S.envases[f].bodega += n; save(); closeModal(); render(); toast(`${n} envases ${ENVN[f]} agregados a bodega`); break; }
1370:     case "abrir-caja": {
1371:       const inp = $("#fondo-m") || $("#fondo"); const f = parseFloat(inp && inp.value) || 0;
1372:       S.turno = { abierto:true, fondo:f, apertura:new Date().toISOString() }; save(); closeModal(); render(); toast(`Caja abierta con ${money(f)} de fondo`);
1373:       if (d.m && U.cart.length){ U.metodo = d.m; U.recibido = ""; modalCobro(); }
1374:       break;
1375:     }
1376:     case "cerrar-caja": {
1377:       const r = resumenTurno(), contado = parseFloat($("#contado").value); if (isNaN(contado)) break;
1378:       const c = { id:uid(), apertura:S.turno.apertura, cierre:new Date().toISOString(), fondo:S.turno.fondo, efectivo:r.efectivo, tarjeta:r.tarjeta, ventas:r.ventas, canceladas:r.canceladas, contado, diferencia: Math.round((contado - (S.turno.fondo + r.efectivo)) * 100) / 100 };
1379:       ventasTurno().forEach(v => { v.corteId = c.id; });
1380:       S.cortes.push(c); S.turno = { abierto:false }; save(); render();
1381:       openModal(`<h2>Caja cerrada</h2><p>${plural(c.ventas,"venta","ventas")}, efectivo ${money(c.efectivo)}, tarjeta ${money(c.tarjeta)}. ${c.diferencia === 0 ? "El efectivo cuadró exacto." : (c.diferencia > 0 ? "Sobraron " : "Faltaron ") + money(Math.abs(c.diferencia)) + "."}</p>
1382:         <div class="share" style="grid-template-columns:1fr 1fr"><button class="btn" data-act="corte-pdf" data-id="${c.id}">Descargar corte en PDF</button><button class="btn" data-act="backup">Exportar respaldo</button></div>
1383:         <div class="modal-actions"><button class="btn btn-primary" data-act="close">Listo</button></div>`);
1384:       break;
1385:     }
1386:     case "corte-pdf": { const c = S.cortes.find(x => x.id === d.id), doc = c && pdfCorte(c); if (doc) await entregar(blobDe(doc), `corte-${isoDate(new Date(c.cierre))}.pdf`, false); break; }
1387:     case "res-pedido": {
1388:       const lines = sugerencias().filter(s => s.cant > 0 && U.resSel.has(s.p.id));
1389:       openModal(`<h2>Pedido al proveedor</h2><p>Para cubrir ${S.ajustes.cobertura} días de venta.</p>
1390:         <div class="list" style="margin-bottom:14px">${lines.map(s => `<div class="li"><div class="who">${imgProd(s.p)}<div><b>${esc(s.p.nombre)}</b><small>${esc(s.p.fmt)}</small></div></div><b>${s.txt}</b></div>`).join("")}</div>
1391:         <div class="share"><button class="btn" data-act="res-pdf">Descargar PDF</button><button class="btn" data-act="res-wa">WhatsApp</button><button class="btn" data-act="res-copy">Copiar texto</button></div>
1392:         <div class="modal-actions"><button class="btn btn-primary" data-act="close">Listo</button></div>`, "wide"); break;
1393:     }
1394:     case "res-pdf": { const lines = sugerencias().filter(s => s.cant > 0 && U.resSel.has(s.p.id)); const doc = pdfPedido(lines); if (doc) await entregar(blobDe(doc), `pedido-resurtido-${isoDate(new Date())}.pdf`, false); break; }
1395:     case "res-wa": abrirWhatsApp(textoPedido(sugerencias().filter(s => s.cant > 0 && U.resSel.has(s.p.id)))); break;
1396:     case "res-copy": try { await navigator.clipboard.writeText(textoPedido(sugerencias().filter(s => s.cant > 0 && U.resSel.has(s.p.id)))); toast("Pedido copiado"); } catch(e){ toast("No se pudo copiar"); } break;
1397:     case "backup": await entregar(new Blob([JSON.stringify(S, null, 1)], { type:"application/json" }), `respaldo-deposito-${isoDate(new Date())}.json`, false); break;
1398:     case "reset": openModal(`<h2>¿Restablecer los datos de ejemplo?</h2><p>Se borran las ventas, productos y cortes de este dispositivo y se cargan los datos iniciales.</p><div class="modal-actions"><button class="btn" data-act="close">Cancelar</button><button class="btn btn-danger" data-act="reset-ok">Restablecer</button></div>`); break;
1399:     case "reset-ok": S = seed(); save(); U.cart = []; U.tcart = []; U.resSel = null; closeModal(); render(); toast("Datos de ejemplo restablecidos"); break;
1400:     case "tver": { const p = P(d.id); openModal(`${tCard(p).replace('class="pcard"','class="pcard" style="margin:0;border:0;box-shadow:none;padding:0"')}<div class="modal-actions" style="margin-top:12px"><button class="btn" data-act="close">Cerrar</button></div>`); break; }
1401:     case "tadd": { addCart(U.tcart, d.id, d.u, false); const p = P(d.id); try { navigator.vibrate && navigator.vibrate(20); } catch(e){} if (!$("#modal").hidden) closeModal(); toast(enCarrito(U.tcart, p.id) > p.stock ? `Ojo: solo hay ${stockTxt(p)}` : "Agregado al pedido"); render(); break; }
1402:     case "tinc": { U.tcart[+d.i].qty++; render(); break; }
1403:     case "tdec": { const l = U.tcart[+d.i]; l.qty--; if (l.qty <= 0) U.tcart.splice(+d.i,1); render(); break; }
1404:     case "tcode": { U.scanCtx = "terminal"; onCodigo($("#tcode").value); break; }
1405:     case "tenviar": {
1406:       S = load() || S;
1407:       S.pedidos.push({ id:uid(), origen:getTermName(), items:U.tcart.map(l => ({...l})), nota:U.tnota.trim(), fecha:new Date().toISOString() });
1408:       save(); U.tcart = []; U.tnota = ""; U.tScreen = "escanear"; render(); toast("Pedido enviado a la caja"); break;
1409:     }
1410:   }
1411: });
1412: 
1413: document.addEventListener("keydown", ev => {
1414:   if (ev.key === "Escape" && !$("#modal").hidden){ closeModal(); return; }
1415:   const t = ev.target;
1416:   if (ev.key === "Enter"){
1417:     if (t.id === "q"){ const p = byCode(t.value); if (p){ if (addCart(U.cart, p.id, "pieza", true)) U.flash = p.id; U.q = ""; render(); toast("Agregado: " + p.nombre); } }
1418:     else if (t.id === "scode") onCodigo(t.value);
1419:     else if (t.id === "tcode"){ U.scanCtx = "terminal"; onCodigo(t.value); }
1420:     else if (t.id === "recibido"){ const b = $("#btn-confirmar"); if (b && !b.disabled) b.click(); }
1421:     else if (t.matches && t.matches("tr[data-act]")) t.click();
1422:   }
1423:   if (ev.key === "F2" && getRol() === "caja"){ ev.preventDefault(); U.screen = "vender"; render(); const q = $("#q"); if (q) q.focus(); }
1424: });
1425: 
1426: document.addEventListener("input", ev => {
1427:   const t = ev.target;
1428:   if (t.id === "q"){ U.q = t.value; render(); }
1429:   else if (t.id === "catq"){ U.catQ = t.value; render(); }
1430:   else if (t.id === "tq"){ U.tq = t.value; render(); }
1431:   else if (t.id === "tnota") U.tnota = t.value;
1432:   else if (t.id === "envCliente") U.envCliente = t.value;
1433:   else if (t.id === "recibido"){ U.recibido = t.value; updCambio(); }
1434:   else if (/^f-c[123]$/.test(t.id) && U.form){ U.form.ilus["c" + t.id.slice(-1)] = t.value; if (!U.form.foto) refrescarPrev(); }
1435:   else if (t.id === "contado"){
1436:     const r = resumenTurno(), esperado = S.turno.fondo + r.efectivo, c = parseFloat(t.value), el = $("#diff"), btn = $("#btn-cerrar");
1437:     if (isNaN(c)){ el.innerHTML = ""; btn.disabled = true; return; }
1438:     const d = Math.round((c - esperado) * 100) / 100;
1439:     el.innerHTML = d === 0 ? `<span class="diff-ok">Cuadra exacto</span>` : d > 0 ? `<span class="diff-ok">Sobran ${money(d)}</span>` : `<span class="diff-bad">Faltan ${money(-d)}</span>`;
1440:     btn.disabled = false;
1441:   }
1442: });
1443: 
1444: document.addEventListener("change", async ev => {
1445:   const t = ev.target;
1446:   if (t.id === "f-porcaja") $("#f-caja").hidden = !t.checked;
1447:   else if (t.id === "f-forma" && U.form){ U.form.ilus.forma = t.value; if (!U.form.foto) refrescarPrev(); }
1448:   else if (t.id === "f-cat" && U.form){ refrescarPrev(); }
1449:   else if (t.id === "f-foto" && t.files && t.files[0] && U.form){
1450:     try { U.form.foto = await leerFoto(t.files[0]); refrescarPrev(); toast("Foto lista. Guarda para aplicarla."); } catch(e){ toast("No se pudo leer la imagen"); }
1451:   }
1452:   else if (t.dataset && t.dataset.aj){ const k = t.dataset.aj; S.ajustes[k] = t.type === "number" ? Math.max(0, parseFloat(t.value) || 0) : (t.value.trim() || S.ajustes[k]); save(); render(); toast("Ajuste guardado"); }
1453:   else if (t.dataset && t.dataset.env){ S.envases[t.dataset.env].precio = Math.max(0, parseFloat(t.value) || 0); save(); toast("Ajuste guardado"); }
1454:   else if (t.id === "cobertura"){ S.ajustes.cobertura = Math.max(1, parseInt(t.value, 10) || 7); U.resSel = null; save(); render(); }
1455:   else if (t.dataset && t.dataset.res){ if (t.checked) U.resSel.add(t.dataset.res); else U.resSel.delete(t.dataset.res); render(); }
1456:   else if (t.id === "tname"){ setTermName(t.value.trim() || "Terminal"); render(); }
1457:   else if (t.id === "import" && t.files && t.files[0]){
1458:     const fr = new FileReader();
1459:     fr.onload = () => { try { const d = JSON.parse(fr.result); if (!d || !Array.isArray(d.productos) || !d.envases) throw 0; S = d; save(); U.cart = []; render(); toast("Respaldo importado"); } catch(e){ toast("Ese archivo no es un respaldo válido"); } };
1460:     fr.readAsText(t.files[0]);
1461:   }
1462: });
1463: 
1464: window.addEventListener("storage", ev => {
1465:   if (ev.key === "pos-tema"){ aplicarTema(); render(); return; }
1466:   if (ev.key !== KEY || !ev.newValue) return;
1467:   let d; try { d = JSON.parse(ev.newValue); } catch(e){ return; }
1468:   const antes = S.pedidos.length; S = d;
1469:   if (getRol() === "caja" && S.pedidos.length > antes){ const pd = S.pedidos[S.pedidos.length-1]; toast(`Nuevo pedido de ${pd.origen}`); }
1470:   render();
1471: });
1472: 
1473: render();
1474: if (getRol() === "caja"){ const a = alertas(); if (a.n) setTimeout(() => toast(`Tienes ${plural(a.n,"alerta","alertas")} de inventario`), 700); }
1475: })();
1476: </script>
1477: </body>
1478: </html>
````

## File: docs/ESTANDARES.md
````markdown
 1: # Estándares técnicos
 2: 
 3: Estas reglas son obligatorias en `backend/` y `app/`. Cada una previene un tipo de error que en proyectos reales se corrige una y otra vez: es más barato evitarlo desde el primer commit.
 4: 
 5: Un PR que no las cumple no se aprueba, aunque funcione.
 6: 
 7: ## Dinero
 8: 
 9: - Se maneja como **entero en centavos** en la API, la base de datos y el código. `$42.50` es `4250`.
10: - Un número con decimales en la API es `datos_invalidos`. **No se redondea.**
11: - En la app hay **un solo formateador de moneda**, en `core/`. Ninguna pantalla formatea dinero por su cuenta.
12: - Todo cálculo de dinero (cambio, total, envases, corte) tiene prueba unitaria.
13: 
14: ## Fechas
15: 
16: - Los instantes se guardan y viajan en **UTC**, con `instanteIso()`: `2026-10-02T18:30:00Z`.
17: - El **día del negocio** se calcula solo con `diaNegocio()`, con la zona horaria de los ajustes. Nunca con `DateTime.now().day` ni con la zona del dispositivo.
18: - Los rangos de un día para reportes y cortes salen de `rangoDiaNegocio()`.
19: - Toda función que dependa de la hora recibe un `Reloj`, para probarla con fechas fijas.
20: - Las fechas de calendario (caducidad) son texto `AAAA-MM-DD`.
21: - Hay pruebas con ventas a las 23:59 y a las 00:01 hora local.
22: 
23: ## Datos
24: 
25: - Toda operación de dinero o existencias va dentro de `transaccion()`: termina completa o no se hace.
26: - Cada cambio de existencia deja un registro en `movimientos`, con tipo, piezas con signo, origen y fecha. Esa tabla nunca se edita ni se borra.
27: - Los duplicados se impiden **en la base** con `UNIQUE`, no solo en el código.
28: - Con borrado lógico, los índices únicos son parciales (`WHERE eliminado = 0`).
29: - Ventas y cortes nunca se borran: se cancelan y queda el registro.
30: - Los cobros llevan clave de idempotencia (`X-Clave-Idempotencia`), para que un reintento no cobre dos veces.
31: 
32: ## Migraciones
33: 
34: - Una migración nueva es un archivo nuevo en `backend/lib/src/db/migraciones/` con el siguiente número, registrado en `migraciones.dart`.
35: - **Nunca** se edita una migración que ya salió en un tag.
36: - El CI aplica todas las migraciones sobre una base vacía.
37: 
38: ## API y errores
39: 
40: - Ningún endpoint se programa sin estar antes en `docs/API.md`.
41: - Todo error sale con el formato del contrato. Las rutas y servicios lanzan `ErrorApi`; el middleware lo responde.
42: - Los errores de validación devuelven `campos`, para que la app marque el campo que falló.
43: - Un error no previsto queda en el log con su pila y al cliente le llega `error_interno`, sin detalles técnicos.
44: - La autenticación vive en un solo middleware, para HTTP y WebSocket.
45: - Los eventos del WebSocket se emiten **después** de confirmar la transacción.
46: 
47: ## Capas
48: 
49: | Capa | Hace | No hace |
50: | --- | --- | --- |
51: | `rutas/` | Lee la petición, llama al servicio, responde | Reglas de negocio, SQL |
52: | `servicios/` | Valida y aplica reglas de negocio, abre transacciones, emite eventos | SQL directo |
53: | `db/` | SQL y conversión de filas a modelos | Reglas de negocio |
54: 
55: En la app, cada `feature` tiene `datos` (llamadas a la API), `estado` (providers) y `pantallas` (widgets).
56: 
57: ## Interfaz
58: 
59: - Componentes compartidos en `core/widgets/` para confirmar, mostrar errores, estado vacío y cargando. No se crea un diálogo nuevo por pantalla.
60: - Toda pantalla que carga datos maneja cargando, error, vacío y con datos.
61: - Al reconectarse, la app vuelve a pedir los datos completos.
62: - Los textos visibles van en el archivo de textos compartido, con acentos.
63: 
64: ## Código
65: 
66: - `dart format` antes de cada commit. El CI lo revisa.
67: - Cero avisos de `dart analyze` / `flutter analyze`.
68: - Nombres de clases, variables y endpoints en español sin acentos: `Producto`, `precioCaja`, `diaNegocio`.
69: - Comentarios solo donde la lógica no es obvia: dinero, envases, fechas, resurtido.
70: - Nada sensible en el repo: claves de Apple, keystores, bases de datos con datos reales.
71: 
72: ## Commits y ramas
73: 
74: - Ramas: `feature/back-...`, `feature/front-...`, `fix/...`, `chore/...`, desde `develop`.
75: - Commits con prefijo y la tarjeta de Trello: `feat(back): registrar venta (ANQ-12)`.
76: - **Hotfix** en producción: rama `hotfix/...` desde `main`, corrección con prueba, PR a `main` y a `develop`, sube el número de parche.
````

## File: docs/PLAN_DE_TRABAJO.md
````markdown
  1: # Plan de trabajo: POS e inventario del depósito
  2: 
  3: Documento para el equipo de desarrollo: **Gerardo y Ever** en backend, **Pablo, Daniel y Luis** en frontend. Explica cómo funciona el sistema, quién hace qué, cómo nos coordinamos y qué se entrega en cada sprint.
  4: 
  5: > Guarden este archivo en el repo de backend como `docs/PLAN_DE_TRABAJO.md` para que todos lo tengan a la mano.
  6: 
  7: ---
  8: 
  9: ## 1. Cómo funciona el sistema
 10: 
 11: ### 1.1 La idea general
 12: 
 13: El sistema no usa internet ni un servidor en la nube. Todo vive en la red Wi-Fi del depósito:
 14: 
 15: ```
 16:                  Wi-Fi del depósito (red local)
 17:    ┌──────────────────────────────────────────────────────┐
 18:    │                                                      │
 19:    │   iPad (modo CAJA)                                   │
 20:    │   ┌────────────────────────────────┐                 │
 21:    │   │ App Flutter (pantallas de caja)│                 │
 22:    │   │        │ http://localhost:8080 │                 │
 23:    │   │        ▼                       │                 │
 24:    │   │ deposito_backend (embebido)    │◄──── HTTP ──────┼── S24 (modo TERMINAL)
 25:    │   │  • API REST                    │◄── WebSocket ───┼── iPhone (modo TERMINAL)
 26:    │   │  • WebSocket (tiempo real)     │                 │
 27:    │   │  • SQLite (la base de datos)   │                 │
 28:    │   └────────────────────────────────┘                 │
 29:    └──────────────────────────────────────────────────────┘
 30: ```
 31: 
 32: - **El iPad es la caja y también el servidor.** La app Flutter, en modo Caja, arranca el backend dentro de sí misma. El backend guarda todo en una base de datos SQLite en el iPad.
 33: - **El S24 y el iPhone son terminales.** Tienen la misma app, en modo Terminal. Se conectan a la IP del iPad para escanear, consultar existencias y mandar pedidos.
 34: - **La caja también usa la API.** Aunque el servidor esté en el mismo iPad, sus pantallas le hablan por `http://localhost:8080`. Así hay un solo camino para los datos y el front se programa igual para caja y terminal.
 35: - **Tiempo real con WebSocket.** Cuando cambia algo (una venta descuenta stock, llega un pedido), el servidor avisa a todos los dispositivos conectados y estos actualizan su pantalla.
 36: 
 37: ### 1.2 Restricciones que hay que respetar
 38: 
 39: | Restricción | Qué significa para nosotros |
 40: | --- | --- |
 41: | iOS no permite servidores en segundo plano | El iPad debe tener la app abierta y en primer plano. Usar "Acceso guiado" y desactivar el bloqueo automático. |
 42: | Para compilar en iPad/iPhone se necesita macOS | Una persona con Mac (o Codemagic) se encarga de las builds de iOS. El día a día se prueba en Android. |
 43: | Permisos de red local en iOS | Hay que declarar `NSLocalNetworkUsageDescription` en `Info.plist` desde el Sprint 1. |
 44: | Toda la información vive en un solo iPad | El backend debe ofrecer respaldo y restauración de la base de datos (Sprint 4). |
 45: | La red puede fallar | Las terminales deben reconectarse solas y mostrar si están desconectadas. |
 46: 
 47: ---
 48: 
 49: ## 2. Repositorios
 50: 
 51: | Repo | Contenido | Quién trabaja |
 52: | --- | --- | --- |
 53: | `deposito-backend` | Paquete Dart puro: API, WebSocket, base de datos, reglas de negocio y **modelos compartidos**. Incluye `docs/API.md` (el contrato). | Gerardo y Ever |
 54: | `deposito-app` | App Flutter: pantallas de caja y terminal, escáner, PDFs, arranque del servidor embebido. Incluye `docs/prototipo/` con el prototipo HTML. | Pablo, Daniel y Luis |
 55: 
 56: **Cómo se conectan:** la app declara el backend como dependencia en `pubspec.yaml`, fijada a una versión (tag):
 57: 
 58: ```yaml
 59: dependencies:
 60:   deposito_backend:
 61:     git:
 62:       url: https://github.com/gerardoleon4/deposito-backend.git
 63:       ref: v0.1.0
 64: ```
 65: 
 66: Gracias a esto:
 67: - La app en modo Caja puede ejecutar `DepositoServer(...).start()`.
 68: - El front importa los **mismos modelos** que usa el backend (`Producto`, `Venta`, etc.), así que nunca se desincronizan los campos.
 69: 
 70: **Versión de herramientas para todos:** Flutter 3.47.5 y Dart 3.13.4. Si alguien actualiza, se acuerda en equipo y se cambia aquí.
 71: 
 72: ---
 73: 
 74: ## 3. Equipo y responsabilidades
 75: 
 76: | Rol | Persona | Responsable de |
 77: | --- | --- | --- |
 78: | **Back 1** | **Gerardo** | Núcleo del servidor: arranque, base de datos y migraciones, productos e inventario, WebSocket, pedidos de terminales, alertas, ajustes y respaldos. Mantiene `API.md` y crea los tags. |
 79: | **Back 2** | **Ever** | Negocio de ventas: modelos compartidos, ventas y cancelaciones, caja y cortes, envases y préstamos, reportes y algoritmo de resurtido. |
 80: | **Front 1** | **Pablo** | Base de la app: arquitectura, navegación, tema, cliente de API, conexión (IP y QR), arranque del servidor embebido, WebSocket en la app. Pantallas de Catálogo y Ajustes. |
 81: | **Front 2** | **Daniel** | Flujo de venta en la caja: pantalla Vender, cobro, tickets PDF y compartir, historial de ventas, corte de caja, tablero de Inicio. |
 82: | **Front 3** | **Luis** | Todo lo de la terminal (escáner, productos, pedido) y en la caja: Envases, Alertas y Resurtido. |
 83: 
 84: **Reglas de responsabilidad:**
 85: - Cada módulo tiene un dueño, pero cualquiera puede ayudar. Si tomas algo de otro, avísale primero.
 86: - **Gerardo y Pablo son los "integradores"**: si algo no conecta entre front y back, ellos lo resuelven juntos primero.
 87: - **Parejas de revisión:** Gerardo ↔ Ever revisan los PRs de backend; Pablo, Daniel y Luis se revisan entre ellos en rotación.
 88: - Si el equipo tiene Scrum Master o QA, el Scrum Master maneja Trello y las ceremonias, y QA prueba en dispositivos reales y revisa los PRs antes de pasar tareas a "Hecho".
 89: 
 90: ---
 91: 
 92: ## 4. El contrato entre back y front (API)
 93: 
 94: El contrato es el documento `docs/API.md` del repo de backend. **Ningún endpoint se programa sin estar primero en el contrato.** Así el front puede avanzar con datos falsos mientras el back lo construye.
 95: 
 96: ### 4.1 Convenciones
 97: 
 98: | Tema | Regla |
 99: | --- | --- |
100: | Prefijo | Todas las rutas empiezan con `/api/v1`. |
101: | Formato | JSON, UTF-8. |
102: | Nombres | En español y sin acentos, en `camelCase`: `precioCaja`, `piezasPorCaja`. |
103: | Dinero | **Entero en centavos**: `$42.50` se manda como `4250`. Evita errores de redondeo. El front lo formatea al mostrar. |
104: | Fechas | Texto ISO 8601 en UTC: `"2026-10-02T18:30:00Z"`. |
105: | Existencias | Siempre en **piezas**. La conversión a cajas es solo visual. |
106: | IDs | Los genera el servidor. El folio de venta es un número consecutivo. |
107: | Errores | Código HTTP adecuado y cuerpo con este formato: |
108: 
109: ```json
110: { "error": { "codigo": "stock_insuficiente", "mensaje": "Solo hay 8 piezas de Corona Mega" } }
111: ```
112: 
113: Códigos HTTP que usaremos: `200` OK, `201` creado, `400` datos inválidos, `401` terminal no autorizada, `404` no existe, `409` conflicto (stock insuficiente, caja cerrada, código de barras repetido), `500` error del servidor.
114: 
115: **Seguridad mínima:** el QR que muestra la caja incluye la IP y una clave. La terminal la manda en cada petición con el encabezado `X-Clave-Terminal`. Así un celular cualquiera en la misma Wi-Fi no puede modificar datos.
116: 
117: ### 4.2 Endpoints
118: 
119: | Módulo | Método y ruta | Para qué | Dueño back | Sprint |
120: | --- | --- | --- | --- | --- |
121: | Salud | `GET /salud` | Comprobar que el servidor responde | Gerardo | 1 |
122: | Terminales | `POST /terminales/registro` | Registrar una terminal con su nombre y la clave del QR | Ever | 1 |
123: | Productos | `GET /productos?cat=&q=` | Listar y buscar | Gerardo | 1 |
124: | | `GET /productos/{id}` | Detalle | Gerardo | 1 |
125: | | `POST /productos` | Crear | Gerardo | 1 |
126: | | `GET /productos/codigo/{codigo}` | Buscar por código de barras (escáner) | Gerardo | 2 |
127: | | `PUT /productos/{id}` | Editar (incluye ajuste de existencia) | Gerardo | 2 |
128: | | `DELETE /productos/{id}` | Eliminar | Gerardo | 2 |
129: | | `POST /productos/{id}/entradas` | Recibir mercancía (cajas, piezas, caducidad) | Gerardo | 2 |
130: | | `PUT /productos/{id}/foto` | Subir foto del producto | Gerardo | 2 |
131: | Envases | `GET /envases` | Existencias por formato (mega, media, cuarto) | Ever | 2 |
132: | | `GET /prestamos` | Préstamos activos | Ever | 2 |
133: | | `POST /prestamos` | Registrar préstamo | Ever | 2 |
134: | | `POST /prestamos/{id}/devolucion` | Devolución total o parcial | Ever | 2 |
135: | | `POST /envases/venta-vacios` | Vender envases vacíos | Ever | 2 |
136: | | `POST /envases/entrada` | Recibir vacíos sin venta | Ever | 2 |
137: | Pedidos | `GET /pedidos` | Pedidos pendientes enviados por terminales | Gerardo | 3 |
138: | | `POST /pedidos` | La terminal manda un pedido a la caja | Gerardo | 3 |
139: | | `DELETE /pedidos/{id}` | Descartar o marcar como cobrado | Gerardo | 3 |
140: | Ventas | `POST /ventas` | Registrar venta (descuenta stock en una transacción) | Gerardo | 3 |
141: | | `GET /ventas?desde=&hasta=&turno=actual` | Historial | Ever | 3 |
142: | | `GET /ventas/{id}` | Detalle para ticket | Ever | 3 |
143: | | `POST /ventas/{id}/cancelar` | Cancelar y regresar stock y envases | Gerardo | 3 |
144: | Caja | `GET /caja/turno` | Estado del turno actual y resumen | Ever | 3 |
145: | | `POST /caja/abrir` | Abrir con fondo inicial | Ever | 3 |
146: | | `POST /caja/cerrar` | Cerrar con efectivo contado; genera el corte | Ever | 3 |
147: | | `GET /caja/cortes` y `GET /caja/cortes/{id}` | Historial de cortes | Ever | 3 |
148: | Alertas | `GET /alertas` | Poco stock y caducidades próximas | Gerardo | 4 |
149: | Reportes | `GET /reportes/dia` | Totales del día para el tablero | Ever | 4 |
150: | | `GET /reportes/ventas-por-hora?fecha=` | Gráfica por hora | Ever | 4 |
151: | | `GET /reportes/semana` | Gráfica de 7 días | Ever | 4 |
152: | | `GET /reportes/resurtido?dias=7` | Sugerencias de compra | Ever | 4 |
153: | Ajustes | `GET /ajustes` y `PUT /ajustes` | Nombre del negocio, depósitos, días de alerta | Gerardo | 4 |
154: | Respaldo | `GET /respaldo` y `POST /respaldo` | Exportar e importar la base de datos (solo caja) | Gerardo | 4 |
155: | Tiempo real | `GET /ws` (WebSocket) | Eventos en vivo | Gerardo | 1 a 3 |
156: 
157: ### 4.3 Eventos del WebSocket
158: 
159: El servidor manda mensajes JSON con esta forma: `{ "tipo": "...", "datos": { ... } }`.
160: 
161: | Tipo | Cuándo se manda | Qué hace el front |
162: | --- | --- | --- |
163: | `producto.actualizado` | Se crea, edita o recibe mercancía de un producto | Refresca ese producto en listas y tarjetas |
164: | `producto.eliminado` | Se borra un producto | Lo quita de listas y carritos |
165: | `stock.actualizado` | Una venta o cancelación cambia existencias | Actualiza el número de existencias |
166: | `pedido.nuevo` | Una terminal manda pedido | La caja muestra el aviso "Pedido de Terminal S24" |
167: | `pedido.eliminado` | La caja cobra o descarta un pedido | Lo quita de la lista |
168: | `venta.registrada` | Se cobra una venta | Actualiza tablero e historial |
169: | `caja.abierta` y `caja.cerrada` | Cambia el turno | Habilita o bloquea el cobro |
170: | `alerta.nueva` | Un producto baja de su mínimo | Muestra notificación |
171: 
172: **Regla para el front:** al reconectarse, la app vuelve a pedir los datos completos (`GET`) en lugar de confiar en los eventos que se perdió mientras estaba desconectada.
173: 
174: ### 4.4 Ejemplo: registrar una venta
175: 
176: Petición `POST /api/v1/ventas`:
177: 
178: ```json
179: {
180:   "lineas": [
181:     { "productoId": "p1", "unidad": "caja", "cantidad": 1 },
182:     { "productoId": "p10", "unidad": "pieza", "cantidad": 2 }
183:   ],
184:   "envases": { "modo": "cobrar", "cliente": null },
185:   "pago": { "metodo": "efectivo", "recibido": 100000 },
186:   "origen": "Caja"
187: }
188: ```
189: 
190: Respuesta `201`:
191: 
192: ```json
193: {
194:   "id": "v_8f2a",
195:   "folio": 1046,
196:   "fecha": "2026-10-02T18:30:00Z",
197:   "total": 60000,
198:   "cambio": 40000,
199:   "lineas": [ { "productoId": "p1", "nombre": "Victoria Mega", "unidad": "caja", "cantidad": 1, "precioUnitario": 48000, "piezas": 12 } ],
200:   "envases": { "modo": "cobrar", "cantidad": 12, "monto": 9600 }
201: }
202: ```
203: 
204: Si no hay existencias suficientes: `409` con `"codigo": "stock_insuficiente"` y **no se descuenta nada** (la venta completa se hace en una sola transacción).
205: 
206: ---
207: 
208: ## 5. Base de datos (SQLite en el iPad)
209: 
210: | Tabla | Campos principales |
211: | --- | --- |
212: | `productos` | id, codigo (único), nombre, categoria, presentacion, precio, precio_caja, piezas_por_caja, stock_piezas, minimo, envase, caducidad, foto, creado, actualizado |
213: | `entradas` | id, producto_id, piezas, caducidad, fecha |
214: | `ventas` | id, folio (único), fecha, total, metodo, tipo_tarjeta, recibido, cambio, envases_modo, envases_cantidad, envases_monto, cliente_prestamo, origen, cancelada, corte_id |
215: | `venta_lineas` | id, venta_id, producto_id, nombre, unidad, cantidad, precio_unitario, piezas |
216: | `envases` | formato (mega, media, cuarto), bodega, prestados, precio_deposito |
217: | `prestamos` | id, cliente, formato, cantidad, fecha, devueltos |
218: | `pedidos` | id, origen, nota, fecha, lineas_json |
219: | `turnos` | id, apertura, cierre, fondo, efectivo_contado, diferencia |
220: | `ajustes` | clave, valor |
221: | `terminales` | id, nombre, clave, ultima_conexion |
222: 
223: Reglas:
224: - **Las migraciones son numeradas** (`001_inicial.sql`, `002_fotos.sql`...) y se aplican solas al arrancar. Nunca se modifica una migración ya publicada; se agrega una nueva.
225: - Las ventas guardan el nombre y precio del producto al momento de vender, para que el historial no cambie si después se edita el producto.
226: - Las fotos se guardan como archivos en la carpeta de documentos del iPad, y en la tabla solo la ruta.
227: 
228: ---
229: 
230: ## 6. Estructura de cada repo
231: 
232: ### 6.1 Backend
233: 
234: ```
235: deposito_backend/
236: ├── bin/server.dart              ← correr el servidor en la laptop para desarrollo
237: ├── lib/
238: │   ├── deposito_backend.dart    ← exporta DepositoServer y los modelos
239: │   └── src/
240: │       ├── servidor.dart        ← arranque, rutas, middleware (clave, logs, errores)
241: │       ├── db/                  ← conexión, migraciones, repositorios por tabla
242: │       ├── modelos/             ← Producto, Venta, Linea, Prestamo, Turno... (con toJson/fromJson)
243: │       ├── rutas/               ← un archivo por módulo: productos.dart, ventas.dart...
244: │       ├── servicios/           ← reglas de negocio: ventas, caja, envases, resurtido
245: │       └── ws/                  ← hub de WebSocket y eventos
246: ├── test/                        ← pruebas de servicios y de rutas
247: └── docs/API.md                  ← el contrato
248: ```
249: 
250: **Regla de capas:** las rutas solo reciben y responden; la lógica va en `servicios/`; el acceso a SQLite va en `db/`. Así la lógica se puede probar sin levantar el servidor.
251: 
252: ### 6.2 App
253: 
254: ```
255: deposito_app/
256: ├── lib/
257: │   ├── main.dart
258: │   ├── app/                     ← router, tema, arranque según modo (Caja o Terminal)
259: │   ├── core/
260: │   │   ├── api/                 ← ApiCliente (real) y ApiFalsa (datos de prueba)
261: │   │   ├── tiempo_real/         ← conexión WebSocket y reconexión
262: │   │   ├── servidor/            ← arranque del backend embebido (solo Caja)
263: │   │   └── widgets/             ← componentes compartidos: tarjeta de producto, teclado, etc.
264: │   └── features/
265: │       ├── inicio/  vender/  ventas/  catalogo/  envases/
266: │       ├── corte/  alertas/  resurtido/  ajustes/
267: │       └── terminal/            ← escanear, productos, pedido
268: ├── test/
269: └── docs/prototipo/              ← prototipo HTML de referencia
270: ```
271: 
272: Cada `feature` tiene tres partes: `datos` (llamadas a la API), `estado` (providers de Riverpod) y `pantallas` (widgets).
273: 
274: **Dueños de carpetas en la app:**
275: - Pablo: `app/`, `core/` completo, `features/catalogo`, `features/ajustes`.
276: - Daniel: `features/vender`, `features/ventas`, `features/corte`, `features/inicio`.
277: - Luis: `features/terminal`, `features/envases`, `features/alertas`, `features/resurtido`.
278: 
279: Si alguien necesita un widget nuevo en `core/widgets/`, lo propone a Pablo en el PR para evitar componentes duplicados.
280: 
281: ---
282: 
283: ## 7. Cómo trabajamos en paralelo
284: 
285: ### 7.1 Primero el contrato, luego el código
286: 
287: 1. Antes de empezar un módulo, Gerardo o Ever escriben en `API.md` los endpoints con ejemplos de petición y respuesta.
288: 2. Lo suben en un PR con la etiqueta **`contrato`**. Ese PR necesita la aprobación de **la persona de front que usará esos endpoints**.
289: 3. Ya aprobado, back programa el endpoint y front programa la pantalla **al mismo tiempo**.
290: 
291: ### 7.2 El front no espera al back
292: 
293: El front programa contra una interfaz, no contra el servidor. Mientras el endpoint no existe, usa una versión falsa que regresa los ejemplos del contrato:
294: 
295: ```dart
296: abstract class ApiProductos {
297:   Future<List<Producto>> listar({String? q});
298:   Future<Producto?> porCodigo(String codigo);
299: }
300: 
301: class ApiProductosFalsa implements ApiProductos {
302:   @override
303:   Future<List<Producto>> listar({String? q}) async => productosDePrueba;
304:   @override
305:   Future<Producto?> porCodigo(String c) async =>
306:       productosDePrueba.where((p) => p.codigo == c).firstOrNull;
307: }
308: ```
309: 
310: Cuando el back termina, solo se cambia qué implementación usa el provider. Ninguna pantalla se toca.
311: 
312: ### 7.3 Servidor de desarrollo compartido
313: 
314: - Mientras el iPad no esté listo, **Gerardo corre el servidor en su laptop** (`dart run bin/server.dart`) y comparte su IP en el grupo.
315: - Cada quien también puede correrlo en su propia computadora: el backend es Dart puro y funciona en Linux, Windows y Mac.
316: - Pablo, Daniel y Luis usan `pubspec_overrides.yaml` apuntando a su copia local del backend para probar cambios antes del tag.
317: 
318: ### 7.4 Día de integración
319: 
320: **Cada miércoles** se hace la integración:
321: 1. Gerardo crea un tag con lo que está estable en `develop` (por ejemplo `v0.2.1`).
322: 2. Pablo actualiza el `ref` en `pubspec.yaml` de la app.
323: 3. Se instala en el iPad, el S24 y el iPhone y se prueba el flujo completo.
324: 4. Lo que falle se anota en Trello como tarea para esa misma semana.
325: 
326: ---
327: 
328: ## 8. Flujo de Git
329: 
330: ### 8.1 Ramas
331: 
332: | Rama | Uso |
333: | --- | --- |
334: | `main` | Solo versiones estables que se entregan. Se actualiza al cerrar cada sprint. |
335: | `develop` | Lo que ya se integró. Rama por defecto. |
336: | `feature/rf01-crud-productos` | Una rama por tarea, desde `develop`. |
337: | `fix/cambio-negativo` | Corrección de un error. |
338: 
339: Nombre de rama: tipo, número de requerimiento si aplica y descripción corta en minúsculas con guiones.
340: 
341: ### 8.2 Commits
342: 
343: Mensajes cortos, en español y en presente, con un prefijo:
344: 
345: - `feat: registrar venta con descuento de stock`
346: - `fix: el cambio salía negativo con billetes de 1000`
347: - `docs: agregar endpoints de envases al contrato`
348: - `test: pruebas del algoritmo de resurtido`
349: - `refactor: separar repositorio de productos`
350: 
351: ### 8.3 Pull requests
352: 
353: - Todo entra a `develop` por PR. Nadie hace push directo a `develop` ni a `main`.
354: - **Revisores:** en backend, Gerardo y Ever se revisan entre sí. En frontend, rotación: Pablo revisa a Daniel, Daniel a Luis, Luis a Pablo. Los PRs con etiqueta `contrato` también los aprueba alguien del otro equipo.
355: - El PR debe explicar qué cambia, cómo probarlo y, si es de front, llevar captura de pantalla.
356: - El CI (GitHub Actions) debe pasar: `analyze`, `format` y pruebas.
357: - PRs pequeños: idealmente menos de 400 líneas. Es mejor abrir tres PRs chicos que uno enorme.
358: - Si tu PR lleva más de un día sin revisión, avisa en el grupo.
359: 
360: ### 8.4 Versiones del backend
361: 
362: | Tag | Cuándo |
363: | --- | --- |
364: | `v0.1.0`, `v0.2.0`... | Al cerrar cada sprint |
365: | `v0.2.1`, `v0.2.2`... | En cada día de integración o corrección urgente |
366: | `v1.0.0` | Entrega final |
367: 
368: Cada tag lleva una nota en `CHANGELOG.md` con lo que se agregó y lo que cambió en el contrato.
369: 
370: ---
371: 
372: ## 9. Plan por sprint
373: 
374: ### Sprint 1: Cimientos (25 sep – 9 oct)
375: 
376: **Meta:** el iPad corre el servidor dentro de la app y el S24 se conecta y lista productos.
377: 
378: | Persona | Tareas |
379: | --- | --- |
380: | Gerardo | Estructura del repo por capas. Conexión a SQLite y sistema de migraciones. Tabla `productos`. `GET /salud`, `GET` y `POST /productos`. WebSocket básico (`/ws` con un evento de prueba). Primera versión de `API.md`. Tag `v0.1.0`. |
381: | Ever | Modelos compartidos con `toJson`/`fromJson` y sus pruebas. Formato de errores y middleware (logs, clave de terminal). `POST /terminales/registro`. CI de GitHub Actions del backend. |
382: | Pablo | Estructura del repo, tema claro y oscuro, navegación. Pantalla de elegir modo. Conexión por IP y QR. `ApiCliente` y `ApiFalsa`. **Arranque del servidor embebido en modo Caja** (junto con Gerardo). Permisos de red local en iOS. CI de la app. |
383: | Daniel | Componentes compartidos: tarjeta de producto, botones, teclado numérico, tarjeta de total. Pantalla Vender con datos falsos (sin cobro). |
384: | Luis | Estructura de la terminal (pestañas). `mobile_scanner` funcionando en el S24 y el iPhone. Pantalla de producto escaneado con datos falsos. |
385: 
386: **Prueba de aceptación:** con el iPad en modo Caja y el S24 en modo Terminal en la misma Wi-Fi, el S24 escanea el QR, se conecta y ve la lista de productos creados desde el iPad.
387: 
388: ### Sprint 2: Catálogo, escaneo y envases (10 – 23 oct) · RF-01, RF-02, RF-03
389: 
390: | Persona | Tareas |
391: | --- | --- |
392: | Gerardo | CRUD completo de productos. Búsqueda por código. Entradas de mercancía con caducidad. Subida de fotos. Eventos `producto.*`. |
393: | Ever | Módulo de envases: existencias, préstamos, devoluciones parciales, venta de vacíos, entradas. Reglas de envases que usará la venta (cobrar, trae vacíos, préstamo). Pruebas. |
394: | Pablo | Pantalla Catálogo: lista con búsqueda y filtros, formulario de producto con foto, recibir mercancía, detalle de producto. |
395: | Daniel | Vender conectado a la API real: carrito, pieza o caja, validación de existencias, bloque de envases en el ticket. |
396: | Luis | Terminal conectada: escanear y mostrar el producto real, pestaña Productos con fotos, armar pedido local. En la caja: pantalla Envases. |
397: 
398: Tag `v0.2.0`.
399: 
400: ### Sprint 3: Ventas, cobro, caja y tiempo real (24 oct – 6 nov) · RF-04, RF-05, RF-06
401: 
402: | Persona | Tareas |
403: | --- | --- |
404: | Gerardo | Hub de WebSocket con todos los eventos. Pedidos de terminales. `POST /ventas` con transacción y validación de stock. Cancelación de ventas. |
405: | Ever | Caja: abrir, cerrar, corte y resumen del turno. Historial de ventas con filtros. Pruebas de ventas y cortes (cambio, cancelaciones, envases). |
406: | Pablo | Servicio de tiempo real en la app: conexión, reconexión automática, indicador "en línea / sin conexión", recarga al reconectar. |
407: | Daniel | Cobro en efectivo y tarjeta. Ticket en PDF con el paquete `pdf` y compartir por WhatsApp o correo. Historial de ventas. Pantalla de corte de caja. |
408: | Luis | Enviar pedido desde la terminal. Aviso de pedidos en la caja y "Pasar al ticket". Existencias en vivo en la terminal. |
409: 
410: **Prueba de rendimiento:** con los 3 dispositivos conectados, una venta en la caja debe verse reflejada en las terminales en menos de 500 ms.
411: 
412: Tag `v0.3.0`.
413: 
414: ### Sprint 4: Alertas, resurtido y tablero (7 – 20 nov) · RF-07, RF-08
415: 
416: | Persona | Tareas |
417: | --- | --- |
418: | Gerardo | Alertas de stock mínimo y caducidad, evento `alerta.nueva`. Ajustes. Respaldo y restauración de la base de datos. |
419: | Ever | Reportes: día, ventas por hora, semana, más vendidos. Algoritmo de resurtido con pruebas. |
420: | Pablo | Pantalla Ajustes, respaldo e importación, modo oscuro, revisión general de diseño y accesibilidad. |
421: | Daniel | Tablero de Inicio con gráficas (`fl_chart`). |
422: | Luis | Pantallas de Alertas y Resurtido, con pedido al proveedor en PDF y WhatsApp. |
423: 
424: QA integral en el depósito con productos reales. Tag `v0.4.0`.
425: 
426: ### Sprint 5: Cierre (21 – 27 nov)
427: 
428: | Persona | Tareas |
429: | --- | --- |
430: | Gerardo y Ever | Corrección de errores. Script para cargar el inventario inicial desde un CSV. Revisión de rendimiento con datos reales. |
431: | Pablo, Daniel y Luis | Corrección de errores y detalles visuales. Builds finales para iPad, iPhone y S24. |
432: | Todos | Manual de usuario, capacitación al dueño del depósito, instalación final. Tag `v1.0.0` y merge a `main`. |
433: 
434: ### Resumen de parejas back ↔ front por sprint
435: 
436: Quién debe hablar con quién para que cada pantalla conecte con su endpoint:
437: 
438: | Sprint | Gerardo trabaja con | Ever trabaja con |
439: | --- | --- | --- |
440: | 1 | Pablo (servidor embebido, conexión) y Luis (listar productos en la terminal) | Pablo (registro de terminales, errores) |
441: | 2 | Pablo (catálogo) y Luis (búsqueda por código) | Luis (envases) y Daniel (envases en la venta) |
442: | 3 | Daniel (registrar venta), Luis (pedidos) y Pablo (WebSocket) | Daniel (caja, corte, historial) |
443: | 4 | Pablo (ajustes, respaldo) y Luis (alertas) | Daniel (tablero) y Luis (resurtido) |
444: 
445: ---
446: 
447: ## 10. Cuándo una tarea está "Hecha"
448: 
449: Una tarjeta pasa a **Hecho** solo si cumple todo esto:
450: 
451: - [ ] El código está en `develop` mediante un PR aprobado.
452: - [ ] El CI pasó (análisis, formato y pruebas).
453: - [ ] Si toca la API, `API.md` está actualizado.
454: - [ ] Back: tiene pruebas de la lógica en `servicios/`.
455: - [ ] Front: se probó en un dispositivo real (mínimo el S24) y maneja los estados de carga, error y lista vacía.
456: - [ ] Alguien distinto a quien lo programó lo probó.
457: 
458: ---
459: 
460: ## 11. Ceremonias y comunicación
461: 
462: | Qué | Cuándo | Duración | Para qué |
463: | --- | --- | --- | --- |
464: | Planning | Primer día del sprint | 1 hora | Elegir tarjetas y repartirlas |
465: | Daily | Todos los días | 15 min | Qué hice, qué haré, qué me bloquea. Si no coinciden horarios, por escrito en el grupo antes de las 10 a.m. |
466: | Integración | Miércoles | 1 a 2 horas | Tag del backend, actualizar la app, probar en los 3 dispositivos |
467: | Review | Último día del sprint | 45 min | Demo en dispositivos reales, de preferencia con el dueño del depósito |
468: | Retrospectiva | Después de la review | 30 min | Qué funcionó y qué cambiar |
469: 
470: **Canales:**
471: - **Trello:** todas las tareas. Columnas: Backlog, Sprint, En progreso, En revisión, QA, Hecho. Cada tarjeta lleva el nombre de su dueño.
472: - **GitHub:** código, PRs y discusión técnica en los comentarios del PR.
473: - **Grupo de WhatsApp:** avisos rápidos, IP del servidor de desarrollo, bloqueos.
474: - **Si estás bloqueado más de 2 horas, pide ayuda.** No esperes al daily.
475: 
476: ---
477: 
478: ## 12. Pruebas
479: 
480: | Tipo | Quién | Qué |
481: | --- | --- | --- |
482: | Unitarias de backend | Gerardo y Ever | Servicios: ventas, cambio, envases, cortes, resurtido, alertas |
483: | De rutas | Gerardo y Ever | Cada endpoint responde con el código y formato del contrato |
484: | De widgets | Pablo, Daniel y Luis | Componentes clave: carrito, teclado, cálculo de cambio en pantalla |
485: | Manuales en dispositivo | Todos, al integrar | Lista de verificación por módulo en `docs/pruebas.md` |
486: | Rendimiento | Gerardo y Pablo | Menos de 500 ms entre la venta y la actualización en terminales |
487: | En el depósito | Todos, Sprint 4 | Un turno real de prueba con productos y personal del depósito |
488: 
489: ---
490: 
491: ## 13. Convenciones de código
492: 
493: - Formato automático con `dart format` antes de cada commit.
494: - Sin advertencias de `dart analyze` / `flutter analyze`.
495: - Nombres de clases, variables y endpoints **en español sin acentos**, igual que en el contrato (`Producto`, `precioCaja`, `registrarVenta`).
496: - Textos de la interfaz en español, con acentos, en un archivo de textos compartido para no repetirlos.
497: - Nada de datos sensibles en el repo (contraseñas, claves de Apple, etc.).
498: - Comentarios solo donde la lógica no sea obvia, sobre todo en cálculos de dinero, envases y resurtido.
499: 
500: ---
501: 
502: ## 14. Riesgos y cómo los atendemos
503: 
504: | Riesgo | Impacto | Plan | Responsable |
505: | --- | --- | --- | --- |
506: | Nadie tiene Mac o no hay cuenta de Apple Developer | No se puede instalar en iPad/iPhone | Resolverlo en la semana 1: Mac prestada o Codemagic, y confirmar la cuenta de Apple | Pablo |
507: | El servidor embebido falla en iOS | Todo el diseño depende de eso | Probarlo en el Sprint 1 con un "hola mundo" antes de avanzar | Gerardo y Pablo |
508: | El iPad se bloquea y se cae el servidor | Terminales sin servicio | Acceso guiado, sin bloqueo automático, cargador conectado | Pablo |
509: | Se pierde o daña el iPad | Se pierde la información | Respaldo diario exportado al cerrar caja (Sprint 4) | Gerardo |
510: | Cambios al contrato sin avisar | Front y back dejan de conectar | Todo cambio de API pasa por PR con etiqueta `contrato` | Gerardo y Ever |
511: | Conflictos de Git | Tiempo perdido | Ramas cortas, PRs pequeños, `git pull` de `develop` diario | Todos |
512: | Wi-Fi inestable | Terminales desconectadas | Reconexión automática e indicador visible de conexión | Pablo |
513: 
514: ---
515: 
516: ## 15. Lista de arranque (esta semana)
517: 
518: - [ ] Todos instalan Flutter 3.47.5 y ejecutan `flutter doctor`.
519: - [ ] Gerardo invita a Ever a `deposito-backend` y a Pablo, Daniel y Luis a `deposito-app` (Settings → Collaborators).
520: - [ ] Pablo crea la estructura inicial de `deposito-app` y la sube.
521: - [ ] Gerardo protege `main` y `develop` en ambos repos.
522: - [ ] Gerardo publica la primera versión de `API.md` con salud, terminales y productos.
523: - [ ] Confirmar quién tiene Mac y el tema de la cuenta de Apple.
524: - [ ] Llenar Trello con las tareas del Sprint 1 de este documento, cada una con su dueño.
525: - [ ] Fijar el horario del daily y del día de integración.
526: 
527: ---
528: 
529: ## 16. Glosario
530: 
531: | Término | Significado |
532: | --- | --- |
533: | Caja | El iPad donde se cobra; también es el servidor |
534: | Terminal | S24 o iPhone con la app en modo Terminal |
535: | Servidor embebido | El backend corriendo dentro de la app del iPad |
536: | Contrato | El archivo `API.md` con todos los endpoints |
537: | Tag | Versión marcada del backend que usa el front |
538: | Envase retornable | Botella que el cliente regresa; se cobra depósito si no la trae |
539: | Préstamo | Envases que el cliente se lleva sin dejar depósito y regresará después |
540: | Corte de caja | Cierre del turno comparando el efectivo esperado con el contado |
541: | Resurtido | Sugerencia de cuánto comprar según lo que se vende |
````

## File: docs/SETUP.md
````markdown
  1: # Guía de instalación por sistema operativo
  2: 
  3: El equipo trabaja en **Linux, Windows y macOS**. El código y los comandos son los mismos; lo que cambia es cómo se instalan las herramientas. Esta guía va en `docs/SETUP.md`.
  4: 
  5: ## Qué se puede hacer en cada sistema
  6: 
  7: | Tarea | Linux | Windows | macOS |
  8: | --- | --- | --- | --- |
  9: | Programar el backend y correr el servidor | Sí | Sí | Sí |
 10: | Programar la app y probarla en Android (teléfono o emulador) | Sí | Sí | Sí |
 11: | Compilar e instalar en iPad o iPhone | No | No | **Sí (requiere Xcode)** |
 12: 
 13: Quien use Mac es la persona natural para instalar en el iPad y el iPhone. Si nadie tiene Mac, se usa Codemagic (compila iOS en la nube).
 14: 
 15: ## Reglas para todos
 16: 
 17: - **Versión de Flutter: 3.47.5** (incluye Dart 3.13.4). Todos la misma. Se verifica con `flutter --version`.
 18: - **Los comandos del proyecto se escriben en una terminal tipo bash:** Terminal en Linux y macOS, **Git Bash en Windows**. No usar PowerShell ni CMD, porque `mkdir -p`, `cat`, `printf` y `~` no funcionan igual.
 19: - Los saltos de línea ya están normalizados en el repo con `.gitattributes` (`* text=auto eol=lf`), así que un archivo editado en Windows no aparece "todo modificado" en los PR.
 20: - Editor recomendado: **VS Code** con las extensiones **Dart** y **Flutter**.
 21: 
 22: ---
 23: 
 24: ## 1. Instalación
 25: 
 26: ### Linux (Mint o Ubuntu)
 27: 
 28: ```bash
 29: sudo apt update
 30: sudo apt install -y git curl unzip xz-utils zip libglu1-mesa
 31: mkdir -p ~/development
 32: git clone https://github.com/flutter/flutter.git -b stable ~/development/flutter
 33: echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
 34: ```
 35: 
 36: Si tu terminal usa bash en lugar de zsh, cambia `~/.zshrc` por `~/.bashrc`. Cierra y abre la terminal, y comprueba con `flutter --version`.
 37: 
 38: ### Windows
 39: 
 40: 1. Instala **Git para Windows** desde git-scm.com con las opciones por defecto. Incluye **Git Bash**.
 41: 2. Abre **Git Bash** y clona Flutter en una ruta corta, sin espacios y fuera de `Program Files`:
 42:    ```bash
 43:    mkdir -p /c/src
 44:    git clone https://github.com/flutter/flutter.git -b stable /c/src/flutter
 45:    ```
 46: 3. Agrega Flutter al PATH: busca **"Editar las variables de entorno del sistema"** → **Variables de entorno** → en **Path** del usuario, **Nuevo** → `C:\src\flutter\bin`.
 47: 4. Cierra Git Bash, ábrelo de nuevo y comprueba con `flutter --version`.
 48: 5. **Activa el Modo de desarrollador:** Configuración → Privacidad y seguridad → Para desarrolladores → Modo de desarrollador. Flutter lo necesita para enlazar los plugins; sin esto, `flutter pub get` puede fallar.
 49: 6. Activa las rutas largas de Git, en Git Bash:
 50:    ```bash
 51:    git config --global core.longpaths true
 52:    ```
 53: 
 54: Clona el repo en una carpeta corta como `C:\dev`, no dentro de OneDrive ni de Documentos.
 55: 
 56: ### macOS
 57: 
 58: ```bash
 59: xcode-select --install
 60: mkdir -p ~/development
 61: git clone https://github.com/flutter/flutter.git -b stable ~/development/flutter
 62: echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
 63: ```
 64: 
 65: Cierra y abre la Terminal y comprueba con `flutter --version`.
 66: 
 67: **Solo si vas a compilar para iPad o iPhone:**
 68: 1. Instala **Xcode** desde la App Store.
 69: 2. Ejecuta `sudo xcodebuild -runFirstLaunch`.
 70: 3. Instala CocoaPods: `brew install cocoapods` (o `sudo gem install cocoapods`).
 71: 4. En Xcode, inicia sesión con tu Apple ID en **Settings → Accounts**.
 72: 
 73: ### Fijar la versión (si `stable` ya avanzó)
 74: 
 75: Si `flutter --version` no muestra 3.47.5, fija la versión en la carpeta donde instalaste Flutter:
 76: 
 77: ```bash
 78: git -C ~/development/flutter checkout 3.47.5
 79: flutter --version
 80: ```
 81: 
 82: En Windows la ruta es `/c/src/flutter` en lugar de `~/development/flutter`.
 83: 
 84: ---
 85: 
 86: ## 2. Android (todos los sistemas)
 87: 
 88: 1. Instala **Android Studio** desde developer.android.com/studio.
 89: 2. Ábrelo y completa el asistente: instala el **Android SDK**.
 90: 3. En **More Actions → SDK Manager → SDK Tools**, marca **Android SDK Command-line Tools** y aplica.
 91: 4. Acepta las licencias:
 92:    ```bash
 93:    flutter doctor --android-licenses
 94:    ```
 95: 5. Para probar en un teléfono: activa **Opciones de desarrollador** y **Depuración USB**, conéctalo y verifica que aparezca con `flutter devices`.
 96: 6. Para probar en emulador: crea uno en **Device Manager**. En Windows puede pedir activar la virtualización en la BIOS.
 97: 
 98: Si en Linux el teléfono no aparece en `flutter devices`, instala `sudo apt install android-sdk-platform-tools-common`.
 99: 
100: ---
101: 
102: ## 3. Git y GitHub (una sola vez)
103: 
104: ```bash
105: git config --global user.name "Tu Nombre"
106: git config --global user.email "tu-correo-de-github"
107: git config --global init.defaultBranch main
108: ```
109: 
110: Si tu correo es privado en GitHub, usa el que aparece en **GitHub → Settings → Emails**, con esta forma: `12345678+usuario@users.noreply.github.com`.
111: 
112: **Iniciar sesión:**
113: - **Windows:** la primera vez que hagas `git clone` o `git push`, se abre el navegador para iniciar sesión.
114: - **macOS:** `brew install gh` y luego `gh auth login`. También funciona el inicio de sesión por el navegador al primer push.
115: - **Linux:** `sudo apt install -y gh` y luego `gh auth login`.
116: 
117: En `gh auth login` elige: **GitHub.com → HTTPS → Yes → Login with a web browser**.
118: 
119: ---
120: 
121: ## 4. Clonar y preparar el proyecto (igual en los tres)
122: 
123: En Git Bash (Windows) o la terminal (Linux y macOS):
124: 
125: ```bash
126: mkdir -p ~/deposito && cd ~/deposito
127: git clone https://github.com/gerardoleon4/deposito-app.git
128: cd deposito-app
129: git checkout develop
130: ```
131: 
132: ```bash
133: cd backend
134: dart pub get
135: cd ../app
136: flutter pub get
137: cd ..
138: ```
139: 
140: Verifica que todo esté bien:
141: 
142: ```bash
143: flutter doctor
144: ```
145: 
146: Lo que aparezca en rojo sobre **Xcode** o **CocoaPods** se puede ignorar si no vas a compilar para iOS. En Windows, lo relacionado con **Visual Studio** también, porque el proyecto solo compila para Android e iOS.
147: 
148: ### Probar el backend
149: 
150: ```bash
151: cd backend
152: dart run bin/server.dart
153: ```
154: 
155: Abre <http://localhost:8080/salud>: debe responder `ok`. Detén el servidor con `Ctrl + C`.
156: 
157: La primera vez puede tardar unos segundos, porque se prepara la librería de SQLite. Hazlo con internet. Si marca un error en ese paso, mándale la captura a Gerardo.
158: 
159: ---
160: 
161: ## 5. Firewall: para que los teléfonos vean el servidor de tu laptop
162: 
163: Cuando corras el backend en tu computadora y otro dispositivo quiera conectarse, el firewall puede bloquearlo:
164: 
165: - **Windows:** la primera vez aparece un aviso de Windows Defender. Marca **Redes privadas** y **Permitir acceso** para `dart`.
166: - **macOS:** aparece "¿Quieres que dart acepte conexiones entrantes?". Elige **Permitir**.
167: - **Linux:** si tienes `ufw` activo, ejecuta `sudo ufw allow 8080/tcp`.
168: 
169: Tu laptop y el teléfono deben estar en la **misma red Wi-Fi**. Para conocer la IP de tu laptop:
170: 
171: | Sistema | Comando |
172: | --- | --- |
173: | Linux | `hostname -I` |
174: | macOS | `ipconfig getifaddr en0` |
175: | Windows (Git Bash) | `ipconfig` y busca la **Dirección IPv4** |
176: 
177: ---
178: 
179: ## 6. Diferencias que conviene conocer
180: 
181: | Tema | Linux | Windows (Git Bash) | macOS |
182: | --- | --- | --- | --- |
183: | Reemplazar texto en un archivo | `sed -i 's/a/b/' archivo` | igual que Linux | `sed -i '' 's/a/b/' archivo` (lleva comillas vacías) |
184: | Carpeta de descargas | `~/Descargas` o `~/Downloads` | `~/Downloads` | `~/Downloads` |
185: | Abrir la carpeta actual | `xdg-open .` | `explorer .` | `open .` |
186: | Ruta de la carpeta de usuario | `/home/usuario` | `/c/Users/usuario` | `/Users/usuario` |
187: | Archivos basura que Git ignora | `.idea/` | `Thumbs.db`, `.idea/` | `.DS_Store` |
188: 
189: **Rutas en el código:** en `backend/`, arma las rutas de archivos con el paquete `path` (`p.join(...)`), nunca con `/` o `\` escritas a mano. En `pubspec.yaml` las rutas siempre llevan `/`, también en Windows (`path: ../backend`).
190: 
191: ---
192: 
193: ## 7. Si algo falla
194: 
195: | Síntoma | Causa probable | Solución |
196: | --- | --- | --- |
197: | `flutter: command not found` | El PATH no se aplicó | Cierra y abre la terminal; revisa el PATH |
198: | `flutter pub get` falla en Windows con un error de symlink | Falta el Modo de desarrollador | Actívalo (paso de Windows) |
199: | Un archivo aparece completamente modificado en Git | Saltos de línea de Windows | Confirma que existe `.gitattributes` en la raíz y ejecuta `git add --renormalize .` |
200: | `flutter devices` no muestra el teléfono | Depuración USB apagada o cable de solo carga | Activa la depuración USB y prueba otro cable |
201: | El teléfono no llega al servidor de la laptop | Firewall o red distinta | Sección 5 y verifica que estén en el mismo Wi-Fi |
202: | `Waiting for another flutter command to release the startup lock` | Otro proceso de Flutter abierto | Cierra VS Code y las terminales; vuelve a intentar |
203: | Versión distinta de Flutter | `stable` avanzó | Sección "Fijar la versión" |
````

## File: .gitattributes
````
1: * text=auto eol=lf
````

## File: AGENTS.md
````markdown
 1: # AGENTS.md — Guía para el equipo y sus asistentes de IA
 2: 
 3: Anaquel es un punto de venta e inventario sin internet para un depósito de cerveza. Un iPad en modo **Caja** corre la app y el servidor embebido (API REST, WebSocket y SQLite). Los teléfonos en modo **Terminal** se conectan por la Wi-Fi del local.
 4: 
 5: Se entrega a un negocio real: el dinero y los datos no pueden fallar.
 6: 
 7: ## Antes de escribir código, leer
 8: 
 9: 1. [`docs/ESTANDARES.md`](docs/ESTANDARES.md): reglas obligatorias (dinero, fechas, transacciones, migraciones, capas).
10: 2. [`docs/API.md`](docs/API.md): el contrato. Ningún endpoint existe si no está ahí.
11: 3. [`docs/PLAN_DE_TRABAJO.md`](docs/PLAN_DE_TRABAJO.md): quién es dueño de qué y qué toca en cada sprint.
12: 
13: ## Estructura
14: 
15: ```
16: backend/   Paquete Dart puro. DepositoServer, modelos compartidos, SQLite.
17: app/       App Flutter. Pantallas de caja y terminal; importa deposito_backend.
18: docs/      Contrato, estándares, plan, prototipo HTML (docs/prototipo/).
19: ```
20: 
21: La app depende del backend por ruta (`path: ../backend`): los dos viven en este repo.
22: 
23: ## Comandos
24: 
25: ```bash
26: # Backend
27: cd backend
28: dart pub get
29: dart run bin/server.dart        # servidor de desarrollo con datos de ejemplo
30: dart test                       # unitarias y e2e
31: dart format . && dart analyze
32: 
33: # App
34: cd app
35: flutter pub get
36: flutter run
37: flutter test
38: dart format lib test && flutter analyze
39: ```
40: 
41: Versiones fijas: **Flutter 3.47.5, Dart 3.13.4**.
42: 
43: ## Cómo agregar...
44: 
45: ### Un endpoint
46: 
47: 1. Documentarlo en `docs/API.md` (PR con etiqueta `contrato`, aprobado por quien lo consume).
48: 2. Modelo en `backend/lib/src/modelos/` con `toJson`/`fromJson`, exportado en `lib/deposito_backend.dart` si la app lo usa.
49: 3. SQL en un repositorio de `backend/lib/src/db/`.
50: 4. Reglas, validación con `Validador`, transacción y evento en `backend/lib/src/servicios/`.
51: 5. Ruta en `backend/lib/src/rutas/`: solo lee, llama al servicio y responde. Usar `exigirCaja()` si el contrato dice "Solo caja".
52: 6. Pruebas: unitarias del servicio y e2e en `test/api_test.dart` con `crearServidorDePrueba()`.
53: 
54: ### Una migración
55: 
56: 1. Archivo nuevo `backend/lib/src/db/migraciones/mNNN_descripcion.dart` con el siguiente número.
57: 2. Agregarla al final de la lista en `migraciones.dart`.
58: 3. Nunca editar una migración publicada en un tag.
59: 
60: ### Una pantalla
61: 
62: 1. Dentro de `app/lib/features/<feature>/` con `datos/`, `estado/` y `pantallas/`.
63: 2. Programar contra la interfaz de la API, con la versión falsa mientras el endpoint no exista.
64: 3. Reutilizar `core/widgets/` (confirmar, error, vacío, cargando, moneda). Si falta un componente, se propone en el PR.
65: 4. Manejar cargando, error, vacío y con datos. Probar en un dispositivo real.
66: 
67: ## No hacer
68: 
69: - Usar `double` para dinero o redondear.
70: - Usar `DateTime.now()` directo en lógica de negocio: recibir un `Reloj`.
71: - Calcular "hoy" con la zona del dispositivo: usar `diaNegocio()`.
72: - Cambiar existencias sin registrar el movimiento.
73: - Escribir SQL fuera de `db/` o lógica dentro de `rutas/`.
74: - Emitir eventos de WebSocket dentro de una transacción.
75: - Cambiar la API sin actualizar `docs/API.md`.
76: - Subir bases de datos, logs, claves o keystores.
77: 
78: ## Git
79: 
80: - Ramas desde `develop`: `feature/back-...`, `feature/front-...`, `fix/...`, `chore/...`.
81: - Commits: `feat(back): ...`, `fix(app): ...`, `docs: ...`, `test(back): ...`, con la tarjeta de Trello `(ANQ-12)`.
82: - Todo entra por PR con CI verde y una revisión. Nadie hace push directo a `develop` ni a `main`.
````

## File: .github/workflows/ci.yml
````yaml
 1: name: CI
 2: 
 3: on:
 4:   push:
 5:     branches: [develop]
 6:   pull_request:
 7:     branches: [develop, main]
 8: 
 9: # Un push nuevo al mismo PR cancela la corrida anterior.
10: concurrency:
11:   group: ci-${{ github.ref }}
12:   cancel-in-progress: true
13: 
14: jobs:
15:   backend:
16:     name: Backend (formato, análisis y pruebas)
17:     runs-on: ubuntu-latest
18:     defaults: { run: { working-directory: backend } }
19:     steps:
20:       - uses: actions/checkout@v4
21:       - uses: dart-lang/setup-dart@v1
22:         with: { sdk: 3.13.4 }
23:       - run: dart pub get
24:       - name: Formato
25:         run: dart format --output=none --set-exit-if-changed .
26:       - name: Análisis
27:         run: dart analyze --fatal-infos
28:       - name: Pruebas (incluye migraciones y e2e)
29:         run: dart test --reporter=expanded
30: 
31:   app:
32:     name: App (formato, análisis y pruebas)
33:     runs-on: ubuntu-latest
34:     defaults: { run: { working-directory: app } }
35:     steps:
36:       - uses: actions/checkout@v4
37:       - uses: subosito/flutter-action@v2
38:         with:
39:           channel: stable
40:           flutter-version: 3.47.5
41:           cache: true
42:       - run: flutter pub get
43:       - name: Formato
44:         run: dart format --output=none --set-exit-if-changed lib test
45:       - name: Análisis
46:         run: flutter analyze --fatal-infos
47:       - name: Pruebas
48:         run: flutter test
````

## File: app/android/app/src/main/AndroidManifest.xml
````xml
 1: <manifest xmlns:android="http://schemas.android.com/apk/res/android">
 2:     <!-- La caja sirve la API y las terminales se conectan a ella por la Wi-Fi.
 3:          Sin INTERNET en el manifiesto principal, las builds de release no
 4:          pueden abrir sockets (solo debug y profile lo traían). -->
 5:     <uses-permission android:name="android.permission.INTERNET"/>
 6:     <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
 7:     <uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
 8:     <!-- El escáner (mobile_scanner) pide la cámara en tiempo de ejecución. -->
 9:     <uses-feature android:name="android.hardware.camera" android:required="false"/>
10: 
11:     <!-- usesCleartextTraffic: la API viaja por HTTP dentro de la red local del
12:          depósito (http://192.168.x.x:8080). Android 9+ lo bloquea por omisión
13:          y la IP de la caja no se conoce de antemano para listarla. -->
14:     <application
15:         android:label="Anaquel"
16:         android:usesCleartextTraffic="true"
17:         android:name="${applicationName}"
18:         android:icon="@mipmap/ic_launcher">
19:         <activity
20:             android:name=".MainActivity"
21:             android:exported="true"
22:             android:launchMode="singleTop"
23:             android:taskAffinity=""
24:             android:theme="@style/LaunchTheme"
25:             android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
26:             android:hardwareAccelerated="true"
27:             android:windowSoftInputMode="adjustResize">
28:             <!-- Specifies an Android theme to apply to this Activity as soon as
29:                  the Android process has started. This theme is visible to the user
30:                  while the Flutter UI initializes. After that, this theme continues
31:                  to determine the Window background behind the Flutter UI. -->
32:             <meta-data
33:               android:name="io.flutter.embedding.android.NormalTheme"
34:               android:resource="@style/NormalTheme"
35:               />
36:             <intent-filter>
37:                 <action android:name="android.intent.action.MAIN"/>
38:                 <category android:name="android.intent.category.LAUNCHER"/>
39:             </intent-filter>
40:         </activity>
41:         <!-- Don't delete the meta-data below.
42:              This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
43:         <meta-data
44:             android:name="flutterEmbedding"
45:             android:value="2" />
46:     </application>
47:     <!-- Required to query activities that can process text, see:
48:          https://developer.android.com/training/package-visibility and
49:          https://developer.android.com/reference/android/content/Intent#ACTION_PROCESS_TEXT.
50: 
51:          In particular, this is used by the Flutter engine in io.flutter.plugin.text.ProcessTextPlugin. -->
52:     <queries>
53:         <intent>
54:             <action android:name="android.intent.action.PROCESS_TEXT"/>
55:             <data android:mimeType="text/plain"/>
56:         </intent>
57:     </queries>
58: </manifest>
````

## File: app/ios/Runner/Info.plist
````
 1: <?xml version="1.0" encoding="UTF-8"?>
 2: <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
 3: <plist version="1.0">
 4: <dict>
 5: 	<key>CADisableMinimumFrameDurationOnPhone</key>
 6: 	<true/>
 7: 	<key>CFBundleDevelopmentRegion</key>
 8: 	<string>$(DEVELOPMENT_LANGUAGE)</string>
 9: 	<key>CFBundleDisplayName</key>
10: 	<string>Anaquel</string>
11: 	<key>CFBundleExecutable</key>
12: 	<string>$(EXECUTABLE_NAME)</string>
13: 	<key>CFBundleIdentifier</key>
14: 	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
15: 	<key>CFBundleInfoDictionaryVersion</key>
16: 	<string>6.0</string>
17: 	<key>CFBundleName</key>
18: 	<string>Anaquel</string>
19: 	<key>CFBundlePackageType</key>
20: 	<string>APPL</string>
21: 	<key>CFBundleShortVersionString</key>
22: 	<string>$(FLUTTER_BUILD_NAME)</string>
23: 	<key>CFBundleSignature</key>
24: 	<string>????</string>
25: 	<key>CFBundleVersion</key>
26: 	<string>$(FLUTTER_BUILD_NUMBER)</string>
27: 	<key>LSRequiresIPhoneOS</key>
28: 	<true/>
29: 	<key>UIApplicationSceneManifest</key>
30: 	<dict>
31: 		<key>UIApplicationSupportsMultipleScenes</key>
32: 		<false/>
33: 		<key>UISceneConfigurations</key>
34: 		<dict>
35: 			<key>UIWindowSceneSessionRoleApplication</key>
36: 			<array>
37: 				<dict>
38: 					<key>UISceneClassName</key>
39: 					<string>UIWindowScene</string>
40: 					<key>UISceneConfigurationName</key>
41: 					<string>flutter</string>
42: 					<key>UISceneDelegateClassName</key>
43: 					<string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
44: 					<key>UISceneStoryboardFile</key>
45: 					<string>Main</string>
46: 				</dict>
47: 			</array>
48: 		</dict>
49: 	</dict>
50: 	<key>UIApplicationSupportsIndirectInputEvents</key>
51: 	<true/>
52: 	<key>UILaunchStoryboardName</key>
53: 	<string>LaunchScreen</string>
54: 	<key>UIMainStoryboardFile</key>
55: 	<string>Main</string>
56: 	<key>UISupportedInterfaceOrientations</key>
57: 	<array>
58: 		<string>UIInterfaceOrientationPortrait</string>
59: 		<string>UIInterfaceOrientationLandscapeLeft</string>
60: 		<string>UIInterfaceOrientationLandscapeRight</string>
61: 	</array>
62: 	<key>UISupportedInterfaceOrientations~ipad</key>
63: 	<array>
64: 		<string>UIInterfaceOrientationPortrait</string>
65: 		<string>UIInterfaceOrientationPortraitUpsideDown</string>
66: 		<string>UIInterfaceOrientationLandscapeLeft</string>
67: 		<string>UIInterfaceOrientationLandscapeRight</string>
68: 	</array>
69: 	<key>NSCameraUsageDescription</key>
70: 	<string>Anaquel usa la cámara para escanear códigos de barras de productos y el código QR de la caja.</string>
71: 	<key>NSLocalNetworkUsageDescription</key>
72: 	<string>Anaquel se comunica con la caja y las terminales por la Wi-Fi del negocio.</string>
73: 	<key>NSAppTransportSecurity</key>
74: 	<dict>
75: 		<key>NSAllowsLocalNetworking</key>
76: 		<true/>
77: 	</dict>
78: 	<key>UIRequiresFullScreen</key>
79: 	<false/>
80: </dict>
81: </plist>
````

## File: app/lib/features/caja/pantallas/inicio_caja.dart
````dart
  1: import 'package:deposito_backend/deposito_backend.dart';
  2: import 'package:flutter/material.dart';
  3: import 'package:flutter_riverpod/flutter_riverpod.dart';
  4: import 'package:go_router/go_router.dart';
  5: 
  6: import '../../../app/tema/colores.dart';
  7: import '../../../core/formato/formato.dart';
  8: import '../../../core/servidor/servidor_embebido.dart';
  9: import '../../../core/widgets/estados.dart';
 10: import '../../../core/widgets/ilustracion_producto.dart';
 11: import '../../catalogo/estado/productos.dart';
 12: import '../../catalogo/pantallas/detalle_producto.dart';
 13: import '../estado/terminales.dart';
 14: import 'conectar_terminal.dart';
 15: 
 16: /// Tablero de la caja. Las cifras de ventas llegan en el Sprint 4; por ahora
 17: /// muestra lo que ya existe: catálogo, alertas calculadas y terminales.
 18: class InicioCaja extends ConsumerWidget {
 19:   const InicioCaja({super.key});
 20: 
 21:   @override
 22:   Widget build(BuildContext context, WidgetRef ref) {
 23:     final productos = ref.watch(productosProvider);
 24:     return switch (productos) {
 25:       AsyncData(:final value) => _Tablero(productos: value),
 26:       AsyncError(:final error) => EstadoError(
 27:         error: error,
 28:         alReintentar: () => ref.invalidate(productosProvider),
 29:       ),
 30:       _ => const Cargando(),
 31:     };
 32:   }
 33: }
 34: 
 35: class _Tablero extends ConsumerWidget {
 36:   const _Tablero({required this.productos});
 37: 
 38:   final List<Producto> productos;
 39: 
 40:   @override
 41:   Widget build(BuildContext context, WidgetRef ref) {
 42:     final c = context.colores;
 43:     final textos = Theme.of(context).textTheme;
 44:     final ahora = DateTime.now();
 45:     final terminales =
 46:         ref.watch(terminalesProvider).value ?? const <Terminal>[];
 47:     final ip = ref.watch(direccionLocalProvider).value;
 48: 
 49:     final bajoMinimo = productos.where((p) => p.bajoMinimo).toList()
 50:       ..sort(
 51:         (a, b) => (a.existenciaPiezas / (a.minimo == 0 ? 1 : a.minimo))
 52:             .compareTo(b.existenciaPiezas / (b.minimo == 0 ? 1 : b.minimo)),
 53:       );
 54:     final porCaducar =
 55:         productos
 56:             .where(
 57:               (p) =>
 58:                   p.caducidad != null && diasHasta(p.caducidad!, ahora) <= 15,
 59:             )
 60:             .toList()
 61:           ..sort((a, b) => a.caducidad!.compareTo(b.caducidad!));
 62:     final atencion = {...bajoMinimo, ...porCaducar}.toList();
 63:     final conectadas = terminales.where((t) => t.conectada).length;
 64:     final piezas = productos.fold<int>(0, (s, p) => s + p.existenciaPiezas);
 65: 
 66:     final saludo = switch (ahora.hour) {
 67:       < 12 => 'Buenos días',
 68:       < 19 => 'Buenas tardes',
 69:       _ => 'Buenas noches',
 70:     };
 71: 
 72:     return LayoutBuilder(
 73:       builder: (context, medidas) {
 74:         final ancho = medidas.maxWidth;
 75:         final columnasKpi = ancho > 1000 ? 4 : 2;
 76:         final dosColumnas = ancho > 900;
 77:         return ListView(
 78:           padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
 79:           children: [
 80:             Wrap(
 81:               alignment: WrapAlignment.spaceBetween,
 82:               crossAxisAlignment: WrapCrossAlignment.end,
 83:               runSpacing: 12,
 84:               children: [
 85:                 Column(
 86:                   crossAxisAlignment: CrossAxisAlignment.start,
 87:                   children: [
 88:                     Text(saludo, style: textos.displaySmall),
 89:                     const SizedBox(height: 4),
 90:                     Text(
 91:                       ip == null
 92:                           ? 'La caja está lista. Conéctala a la Wi-Fi para recibir terminales.'
 93:                           : 'La caja está lista en $ip. ${_textoTerminales(conectadas)}',
 94:                       style: textos.bodyLarge?.copyWith(color: c.tinta2),
 95:                     ),
 96:                   ],
 97:                 ),
 98:                 FilledButton.icon(
 99:                   onPressed: () => context.go('/caja/vender'),
100:                   icon: const Icon(Icons.shopping_cart_rounded),
101:                   label: const Text('Nueva venta'),
102:                   style: FilledButton.styleFrom(
103:                     minimumSize: const Size(0, 60),
104:                     padding: const EdgeInsets.symmetric(horizontal: 22),
105:                     textStyle: textos.titleMedium?.copyWith(fontSize: 19),
106:                   ),
107:                 ),
108:               ],
109:             ),
110:             const SizedBox(height: 20),
111:             GridView(
112:               shrinkWrap: true,
113:               physics: const NeverScrollableScrollPhysics(),
114:               // Alto fijo: con proporción, una ventana angosta las aplasta.
115:               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
116:                 crossAxisCount: columnasKpi,
117:                 crossAxisSpacing: 14,
118:                 mainAxisSpacing: 14,
119:                 mainAxisExtent: 112,
120:               ),
121:               children: [
122:                 _Kpi(
123:                   icono: Icons.inventory_2_outlined,
124:                   etiqueta: 'Productos',
125:                   valor: '${productos.length}',
126:                   detalle: '$piezas piezas en existencia',
127:                   fondo: c.lagerSuave,
128:                   tinta: c.tinta,
129:                 ),
130:                 _Kpi(
131:                   icono: Icons.trending_down_rounded,
132:                   etiqueta: 'Bajo el mínimo',
133:                   valor: '${bajoMinimo.length}',
134:                   detalle: bajoMinimo.isEmpty
135:                       ? 'Todo en orden'
136:                       : 'por resurtir',
137:                   fondo: c.alertaSuave,
138:                   tinta: c.alerta,
139:                 ),
140:                 _Kpi(
141:                   icono: Icons.event_busy_outlined,
142:                   etiqueta: 'Caducan en 15 días',
143:                   valor: '${porCaducar.length}',
144:                   detalle: porCaducar.isEmpty ? 'Ninguno' : 'vender primero',
145:                   fondo: c.superficie3,
146:                   tinta: c.azul,
147:                 ),
148:                 _Kpi(
149:                   icono: Icons.smartphone_rounded,
150:                   etiqueta: 'Terminales',
151:                   valor: '$conectadas',
152:                   detalle: '${terminales.length} vinculadas',
153:                   fondo: c.verdeSuave,
154:                   tinta: c.verde,
155:                 ),
156:               ],
157:             ),
158:             const SizedBox(height: 18),
159:             Flex(
160:               direction: dosColumnas ? Axis.horizontal : Axis.vertical,
161:               crossAxisAlignment: CrossAxisAlignment.start,
162:               spacing: 18,
163:               children: [
164:                 _envolver(
165:                   dosColumnas,
166:                   3,
167:                   _Tarjeta(
168:                     titulo: 'Necesita atención',
169:                     accion: TextButton(
170:                       onPressed: () => context.go('/caja/catalogo'),
171:                       child: const Text('Ver catálogo'),
172:                     ),
173:                     child: atencion.isEmpty
174:                         ? const Padding(
175:                             padding: EdgeInsets.symmetric(vertical: 24),
176:                             child: EstadoVacio(
177:                               icono: Icons.check_circle_outline_rounded,
178:                               titulo: 'Todo en orden',
179:                               mensaje: 'Ningún producto está bajo su mínimo ni por caducar.',
180:                             ),
181:                           )
182:                         : Column(
183:                             children: [
184:                               for (final p in atencion.take(6))
185:                                 _FilaAtencion(producto: p, hoy: ahora),
186:                             ],
187:                           ),
188:                   ),
189:                 ),
190:                 _envolver(
191:                   dosColumnas,
192:                   2,
193:                   _Tarjeta(
194:                     titulo: 'Terminales',
195:                     accion: TextButton.icon(
196:                       onPressed: () => mostrarConectarTerminal(context),
197:                       icon: const Icon(Icons.add_rounded, size: 20),
198:                       label: const Text('Conectar'),
199:                     ),
200:                     child: terminales.isEmpty
201:                         ? Padding(
202:                             padding: const EdgeInsets.symmetric(vertical: 18),
203:                             child: Text(
204:                               'Conecta el S24 o el iPhone para escanear productos en los pasillos.',
205:                               style: TextStyle(color: c.tinta2),
206:                             ),
207:                           )
208:                         : Column(
209:                             children: [
210:                               for (final t in terminales)
211:                                 ListTile(
212:                                   contentPadding: EdgeInsets.zero,
213:                                   leading: Icon(
214:                                     Icons.smartphone_rounded,
215:                                     color: c.tinta2,
216:                                   ),
217:                                   title: Text(
218:                                     t.nombre,
219:                                     style: const TextStyle(
220:                                       fontWeight: FontWeight.w600,
221:                                     ),
222:                                   ),
223:                                   trailing: Row(
224:                                     mainAxisSize: MainAxisSize.min,
225:                                     children: [
226:                                       Container(
227:                                         width: 9,
228:                                         height: 9,
229:                                         decoration: BoxDecoration(
230:                                           shape: BoxShape.circle,
231:                                           color: t.conectada
232:                                               ? const Color(0xFF46C281)
233:                                               : c.linea,
234:                                         ),
235:                                       ),
236:                                       const SizedBox(width: 8),
237:                                       Text(
238:                                         t.conectada
239:                                             ? 'En línea'
240:                                             : 'Fuera de línea',
241:                                         style: TextStyle(color: c.tinta2),
242:                                       ),
243:                                     ],
244:                                   ),
245:                                 ),
246:                             ],
247:                           ),
248:                   ),
249:                 ),
250:               ],
251:             ),
252:           ],
253:         );
254:       },
255:     );
256:   }
257: 
258:   static Widget _envolver(bool fila, int flex, Widget hijo) =>
259:       fila ? Expanded(flex: flex, child: hijo) : hijo;
260: 
261:   static String _textoTerminales(int n) => switch (n) {
262:     0 => 'Ninguna terminal conectada.',
263:     1 => 'Una terminal conectada.',
264:     _ => '$n terminales conectadas.',
265:   };
266: }
267: 
268: class _Kpi extends StatelessWidget {
269:   const _Kpi({
270:     required this.icono,
271:     required this.etiqueta,
272:     required this.valor,
273:     required this.detalle,
274:     required this.fondo,
275:     required this.tinta,
276:   });
277: 
278:   final IconData icono;
279:   final String etiqueta;
280:   final String valor;
281:   final String detalle;
282:   final Color fondo;
283:   final Color tinta;
284: 
285:   @override
286:   Widget build(BuildContext context) {
287:     final c = context.colores;
288:     final textos = Theme.of(context).textTheme;
289:     return Container(
290:       padding: const EdgeInsets.all(16),
291:       decoration: BoxDecoration(
292:         color: c.superficie,
293:         borderRadius: BorderRadius.circular(16),
294:         border: Border.all(color: c.linea),
295:         boxShadow: c.sombra,
296:       ),
297:       child: Row(
298:         crossAxisAlignment: CrossAxisAlignment.start,
299:         children: [
300:           Container(
301:             width: 44,
302:             height: 44,
303:             decoration: BoxDecoration(
304:               color: fondo,
305:               borderRadius: BorderRadius.circular(12),
306:             ),
307:             child: Icon(icono, color: tinta, size: 22),
308:           ),
309:           const SizedBox(width: 12),
310:           Expanded(
311:             child: Column(
312:               crossAxisAlignment: CrossAxisAlignment.start,
313:               mainAxisSize: MainAxisSize.min,
314:               children: [
315:                 Text(
316:                   etiqueta,
317:                   style: textos.bodySmall,
318:                   maxLines: 1,
319:                   overflow: TextOverflow.ellipsis,
320:                 ),
321:                 Text(valor, style: textos.headlineLarge),
322:                 Text(
323:                   detalle,
324:                   style: textos.bodySmall,
325:                   maxLines: 1,
326:                   overflow: TextOverflow.ellipsis,
327:                 ),
328:               ],
329:             ),
330:           ),
331:         ],
332:       ),
333:     );
334:   }
335: }
336: 
337: class _Tarjeta extends StatelessWidget {
338:   const _Tarjeta({required this.titulo, required this.child, this.accion});
339: 
340:   final String titulo;
341:   final Widget child;
342:   final Widget? accion;
343: 
344:   @override
345:   Widget build(BuildContext context) {
346:     final c = context.colores;
347:     return Container(
348:       padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
349:       decoration: BoxDecoration(
350:         color: c.superficie,
351:         borderRadius: BorderRadius.circular(16),
352:         border: Border.all(color: c.linea),
353:         boxShadow: c.sombra,
354:       ),
355:       child: Column(
356:         crossAxisAlignment: CrossAxisAlignment.stretch,
357:         children: [
358:           Row(
359:             children: [
360:               Expanded(
361:                 child: Text(
362:                   titulo,
363:                   style: Theme.of(context).textTheme.titleLarge,
364:                 ),
365:               ),
366:               ?accion,
367:             ],
368:           ),
369:           const SizedBox(height: 6),
370:           child,
371:         ],
372:       ),
373:     );
374:   }
375: }
376: 
377: class _FilaAtencion extends StatelessWidget {
378:   const _FilaAtencion({required this.producto, required this.hoy});
379: 
380:   final Producto producto;
381:   final DateTime hoy;
382: 
383:   @override
384:   Widget build(BuildContext context) {
385:     final c = context.colores;
386:     final p = producto;
387:     final dias = p.caducidad == null ? null : diasHasta(p.caducidad!, hoy);
388:     final (motivo, color, fondo) = p.bajoMinimo
389:         ? ('Bajo el mínimo', c.alerta, c.alertaSuave)
390:         : (
391:             'Caduca ${dias! <= 0 ? 'hoy' : 'en $dias días'}',
392:             c.azul,
393:             c.superficie3,
394:           );
395:     return InkWell(
396:       onTap: () => mostrarDetalleProducto(context, p),
397:       borderRadius: BorderRadius.circular(10),
398:       child: Container(
399:         padding: const EdgeInsets.symmetric(vertical: 9),
400:         decoration: BoxDecoration(
401:           border: Border(top: BorderSide(color: c.linea)),
402:         ),
403:         child: Row(
404:           children: [
405:             SizedBox(
406:               width: 46,
407:               height: 46,
408:               child: IlustracionProducto(producto: p, radio: 10),
409:             ),
410:             const SizedBox(width: 12),
411:             Expanded(
412:               child: Column(
413:                 crossAxisAlignment: CrossAxisAlignment.start,
414:                 children: [
415:                   Text(
416:                     p.nombre,
417:                     style: const TextStyle(fontWeight: FontWeight.w600),
418:                   ),
419:                   Text(
420:                     '${existenciaLegible(p)} · mínimo ${p.minimo} pz',
421:                     style: TextStyle(color: c.tinta2, fontSize: 14),
422:                   ),
423:                 ],
424:               ),
425:             ),
426:             Container(
427:               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
428:               decoration: BoxDecoration(
429:                 color: fondo,
430:                 borderRadius: BorderRadius.circular(999),
431:               ),
432:               child: Text(
433:                 motivo,
434:                 style: TextStyle(
435:                   color: color,
436:                   fontWeight: FontWeight.w600,
437:                   fontSize: 13,
438:                 ),
439:               ),
440:             ),
441:           ],
442:         ),
443:       ),
444:     );
445:   }
446: }
````

## File: app/lib/main.dart
````dart
 1: import 'package:flutter/material.dart';
 2: import 'package:flutter_riverpod/flutter_riverpod.dart';
 3: import 'package:shared_preferences/shared_preferences.dart';
 4: 
 5: import 'app/app.dart';
 6: import 'core/config/configuracion.dart';
 7: 
 8: Future<void> main() async {
 9:   WidgetsFlutterBinding.ensureInitialized();
10:   final preferencias = await SharedPreferences.getInstance();
11:   runApp(
12:     ProviderScope(
13:       overrides: [preferenciasProvider.overrideWithValue(preferencias)],
14:       child: const AnaquelApp(),
15:     ),
16:   );
17: }
````

## File: app/test/integracion_backend_test.dart
````dart
  1: import 'dart:io';
  2: 
  3: import 'package:deposito_app/core/api/api.dart';
  4: import 'package:deposito_app/core/api/fallo_api.dart';
  5: import 'package:deposito_app/core/tiempo_real/tiempo_real.dart';
  6: import 'package:deposito_backend/deposito_backend.dart';
  7: import 'package:flutter_test/flutter_test.dart';
  8: 
  9: /// La capa de datos de la app contra el servidor real (sin pantallas):
 10: /// lo mismo que pasa entre la caja y una terminal en el depósito.
 11: void main() {
 12:   late DepositoServer servidor;
 13:   late Uri base;
 14:   late ApiHttp caja;
 15: 
 16:   setUp(() async {
 17:     servidor = DepositoServer(
 18:       rutaBaseDatos: enMemoria,
 19:       puerto: 0,
 20:       direccion: InternetAddress.loopbackIPv4,
 21:       datosEjemplo: true,
 22:       bitacora: Bitacora.silenciosa(),
 23:     );
 24:     await servidor.iniciar();
 25:     base = Uri.parse('http://127.0.0.1:${servidor.puertoActual}');
 26:     caja = ApiHttp(base: base, clave: servidor.claveCaja);
 27:   });
 28: 
 29:   tearDown(() => servidor.detener());
 30: 
 31:   test('la caja lista los productos de ejemplo', () async {
 32:     final productos = await caja.listarProductos();
 33:     expect(productos, hasLength(11));
 34:     expect(productos.map((p) => p.nombre), contains('Victoria Mega'));
 35:   });
 36: 
 37:   test(
 38:     'una terminal se vincula con el código y ve en vivo lo que crea la caja',
 39:     () async {
 40:       final codigo = await caja.crearCodigoEmparejamiento();
 41:       final registro = await ApiHttp.registrarTerminal(
 42:         base: base,
 43:         nombre: 'Terminal S24',
 44:         codigo: codigo.codigo,
 45:       );
 46:       final terminal = ApiHttp(base: base, clave: registro.clave);
 47:       expect(await terminal.listarProductos(), hasLength(11));
 48: 
 49:       final tiempoReal = TiempoReal(terminal);
 50:       addTearDown(tiempoReal.cerrar);
 51:       await tiempoReal.estados
 52:           .firstWhere((e) => e == EstadoConexion.enLinea)
 53:           .timeout(const Duration(seconds: 5));
 54:       final llegada = tiempoReal.eventos.firstWhere(
 55:         (e) => e.tipo == TiposEvento.productoActualizado,
 56:       );
 57: 
 58:       await caja.crearProducto({
 59:         'codigo': '750999',
 60:         'nombre': 'Tecate Light',
 61:         'categoria': 'cerveza',
 62:         'precio': 2350,
 63:       });
 64: 
 65:       final evento = await llegada.timeout(const Duration(seconds: 5));
 66:       expect((evento.datos['producto'] as Map)['nombre'], 'Tecate Light');
 67: 
 68:       final terminales = await caja.listarTerminales();
 69:       expect(terminales.single.conectada, isTrue);
 70:     },
 71:   );
 72: 
 73:   test(
 74:     'los errores del servidor llegan como FalloApi con sus campos',
 75:     () async {
 76:       await expectLater(
 77:         caja.crearProducto({
 78:           'codigo': '1',
 79:           'nombre': 'X',
 80:           'categoria': 'c',
 81:           'precio': 42.5,
 82:         }),
 83:         throwsA(
 84:           isA<FalloApi>()
 85:               .having((f) => f.codigo, 'codigo', 'datos_invalidos')
 86:               .having((f) => f.campos.keys, 'campos', contains('precio')),
 87:         ),
 88:       );
 89:     },
 90:   );
 91: 
 92:   test('una terminal revocada recibe no autorizado', () async {
 93:     final codigo = await caja.crearCodigoEmparejamiento();
 94:     final registro = await ApiHttp.registrarTerminal(
 95:       base: base,
 96:       nombre: 'iPhone',
 97:       codigo: codigo.codigo,
 98:     );
 99:     await caja.revocarTerminal(registro.terminal.id);
100:     await expectLater(
101:       ApiHttp(base: base, clave: registro.clave).listarProductos(),
102:       throwsA(
103:         isA<FalloApi>().having((f) => f.noAutorizado, 'noAutorizado', isTrue),
104:       ),
105:     );
106:   });
107: 
108:   test('sin servidor el error es sin_conexion', () async {
109:     await servidor.detener();
110:     await expectLater(
111:       caja.listarProductos(),
112:       throwsA(
113:         isA<FalloApi>().having((f) => f.sinConexion, 'sinConexion', isTrue),
114:       ),
115:     );
116:   });
117: 
118:   test('el tiempo real se reconecta solo y avisa para recargar', () async {
119:     final tiempoReal = TiempoReal(caja);
120:     addTearDown(tiempoReal.cerrar);
121:     final estados = <EstadoConexion>[];
122:     final sub = tiempoReal.estados.listen(estados.add);
123:     addTearDown(sub.cancel);
124:     await tiempoReal.estados.firstWhere((e) => e == EstadoConexion.enLinea);
125:     final reconectado = tiempoReal.eventos.firstWhere(
126:       (e) => e.tipo == eventoReconectado,
127:     );
128: 
129:     // Se cae el servidor (Wi-Fi, iPad bloqueado...) y vuelve en el mismo puerto.
130:     final puerto = servidor.puertoActual;
131:     await servidor.detener();
132:     servidor = DepositoServer(
133:       rutaBaseDatos: enMemoria,
134:       puerto: puerto,
135:       direccion: InternetAddress.loopbackIPv4,
136:       claveCaja: servidor.claveCaja,
137:       bitacora: Bitacora.silenciosa(),
138:     );
139:     await servidor.iniciar();
140: 
141:     await reconectado.timeout(const Duration(seconds: 10));
142:     expect(
143:       estados,
144:       containsAllInOrder([EstadoConexion.sinConexion, EstadoConexion.enLinea]),
145:     );
146:   });
147: }
````

## File: app/pubspec.yaml
````yaml
 1: name: deposito_app
 2: description: Anaquel, punto de venta e inventario del depósito. Modo Caja (iPad) y modo Terminal (teléfonos).
 3: publish_to: 'none'
 4: 
 5: version: 0.1.0+1
 6: 
 7: environment:
 8:   sdk: ^3.13.4
 9: 
10: dependencies:
11:   flutter:
12:     sdk: flutter
13:   flutter_localizations:
14:     sdk: flutter
15: 
16:   deposito_backend:
17:     path: ../backend
18:   dio: ^5.11.1
19:   flutter_riverpod: ^3.4.3
20:   go_router: ^18.0.2
21:   mobile_scanner: ^7.4.2
22:   path_provider: ^2.1.6
23:   pdf: ^3.13.1
24:   printing: ^5.15.1
25:   qr_flutter: ^4.1.0
26:   share_plus: ^13.3.0
27:   shared_preferences: ^2.5.5
28:   web_socket_channel: ^3.0.3
29: 
30: dev_dependencies:
31:   flutter_lints: ^6.0.0
32:   flutter_test:
33:     sdk: flutter
34: 
35: flutter:
36:   uses-material-design: true
37: 
38:   # Barlow (licencia OFL, assets/fonts/OFL.txt). Va dentro de la app porque
39:   # el depósito no tiene internet.
40:   fonts:
41:     - family: Barlow
42:       fonts:
43:         - asset: assets/fonts/Barlow-Regular.ttf
44:         - asset: assets/fonts/Barlow-Medium.ttf
45:           weight: 500
46:         - asset: assets/fonts/Barlow-SemiBold.ttf
47:           weight: 600
48:         - asset: assets/fonts/Barlow-Bold.ttf
49:           weight: 700
50:     - family: Barlow Condensed
51:       fonts:
52:         - asset: assets/fonts/BarlowCondensed-SemiBold.ttf
53:           weight: 600
54:         - asset: assets/fonts/BarlowCondensed-Bold.ttf
55:           weight: 700
````

## File: backend/bin/server.dart
````dart
 1: import 'dart:io';
 2: 
 3: import 'package:deposito_backend/deposito_backend.dart';
 4: import 'package:path/path.dart' as p;
 5: 
 6: /// Servidor de desarrollo: corre en la laptop mientras el iPad no está listo.
 7: ///
 8: ///   dart run bin/server.dart
 9: ///
10: /// Variables opcionales:
11: ///   PUERTO          8080 por omisión.
12: ///   BASE_DATOS      datos/anaquel.db por omisión (ignorado por git).
13: ///   CLAVE_CAJA      fija la clave de caja; si no, se genera una por arranque.
14: ///   SIN_EJEMPLOS=1  no carga los productos del prototipo.
15: Future<void> main() async {
16:   final entorno = Platform.environment;
17:   final rutaBase = entorno['BASE_DATOS'] ?? p.join('datos', 'anaquel.db');
18:   Directory(p.dirname(rutaBase)).createSync(recursive: true);
19: 
20:   final servidor = DepositoServer(
21:     rutaBaseDatos: rutaBase,
22:     puerto: int.tryParse(entorno['PUERTO'] ?? '') ?? 8080,
23:     claveCaja: entorno['CLAVE_CAJA'],
24:     datosEjemplo: entorno['SIN_EJEMPLOS'] != '1',
25:     bitacora: Bitacora(rutaArchivo: p.join(p.dirname(rutaBase), 'anaquel.log')),
26:   );
27:   await servidor.iniciar();
28: 
29:   stdout.writeln('''
30: 
31:   Anaquel $versionServidor escuchando en el puerto ${servidor.puertoActual}
32:   Base de datos: $rutaBase
33: 
34:   Clave de caja (solo desarrollo, no la compartas fuera del equipo):
35:     ${servidor.claveCaja}
36: 
37:   Prueba:
38:     curl -H "X-Clave-Terminal: ${servidor.claveCaja}" localhost:${servidor.puertoActual}/api/v1/productos
39: 
40:   Ctrl + C para detener.
41: ''');
42: 
43:   ProcessSignal.sigint.watch().first.then((_) async {
44:     await servidor.detener();
45:     exit(0);
46:   });
47: }
````

## File: backend/lib/src/comun/bitacora.dart
````dart
 1: import 'dart:io';
 2: 
 3: import 'fechas.dart';
 4: 
 5: enum NivelLog { info, advertencia, error }
 6: 
 7: /// Log del servidor: una línea por evento, en consola y opcionalmente en un
 8: /// archivo que rota al pasar de [tamanoMaximo] y conserva [archivosRotados]
 9: /// copias (`anaquel.log.1`, `.2`...). El archivo se puede exportar desde la
10: /// pantalla de Diagnóstico para dar soporte remoto.
11: class Bitacora {
12:   Bitacora({
13:     this.rutaArchivo,
14:     this.consola = true,
15:     this.tamanoMaximo = 1024 * 1024,
16:     this.archivosRotados = 3,
17:     Reloj reloj = relojSistema,
18:   }) : _reloj = reloj;
19: 
20:   /// Bitácora que no escribe nada (pruebas).
21:   Bitacora.silenciosa() : this(consola: false);
22: 
23:   final String? rutaArchivo;
24:   final bool consola;
25:   final int tamanoMaximo;
26:   final int archivosRotados;
27:   final Reloj _reloj;
28: 
29:   /// Últimos errores en memoria, para la pantalla de Diagnóstico.
30:   final ultimosErrores = <String>[];
31: 
32:   void info(String mensaje) => _escribir(NivelLog.info, mensaje);
33: 
34:   void advertencia(String mensaje) => _escribir(NivelLog.advertencia, mensaje);
35: 
36:   void error(String mensaje, [Object? error, StackTrace? pila]) {
37:     final detalle = [mensaje, ?error?.toString(), ?pila?.toString()].join('\n');
38:     _escribir(NivelLog.error, detalle);
39:     ultimosErrores.add(
40:       '${instanteIso(_reloj())} $mensaje${error == null ? '' : ': $error'}',
41:     );
42:     if (ultimosErrores.length > 50) ultimosErrores.removeAt(0);
43:   }
44: 
45:   void _escribir(NivelLog nivel, String mensaje) {
46:     final linea =
47:         '${instanteIso(_reloj())} ${nivel.name.toUpperCase()} $mensaje';
48:     if (consola) stdout.writeln(linea);
49:     final ruta = rutaArchivo;
50:     if (ruta == null) return;
51:     try {
52:       final archivo = File(ruta);
53:       if (archivo.existsSync() && archivo.lengthSync() > tamanoMaximo) {
54:         _rotar(ruta);
55:       }
56:       archivo.writeAsStringSync(
57:         '$linea\n',
58:         mode: FileMode.append,
59:         flush: false,
60:       );
61:     } on FileSystemException catch (e) {
62:       // Un log que falla no debe tumbar una venta.
63:       if (consola) stderr.writeln('No se pudo escribir el log: $e');
64:     }
65:   }
66: 
67:   void _rotar(String ruta) {
68:     for (var i = archivosRotados - 1; i >= 1; i--) {
69:       final anterior = File('$ruta.$i');
70:       if (anterior.existsSync()) anterior.renameSync('$ruta.${i + 1}');
71:     }
72:     File(ruta).renameSync('$ruta.1');
73:     final sobrante = File('$ruta.${archivosRotados + 1}');
74:     if (sobrante.existsSync()) sobrante.deleteSync();
75:   }
76: }
````

## File: backend/lib/src/servicios/servicio_productos.dart
````dart
  1: import 'package:sqlite3/sqlite3.dart';
  2: 
  3: import '../comun/errores.dart';
  4: import '../comun/fechas.dart';
  5: import '../comun/json.dart';
  6: import '../comun/seguridad.dart';
  7: import '../db/base_datos.dart';
  8: import '../db/repositorio_productos.dart';
  9: import '../modelos/evento.dart';
 10: import '../modelos/producto.dart';
 11: import '../ws/hub.dart';
 12: 
 13: final _patronCodigo = RegExp(r'^[0-9A-Za-z]+$');
 14: 
 15: class ServicioProductos {
 16:   ServicioProductos({
 17:     required Database db,
 18:     required RepositorioProductos repositorio,
 19:     required Hub hub,
 20:     Reloj reloj = relojSistema,
 21:   }) : _db = db,
 22:        _repo = repositorio,
 23:        _hub = hub,
 24:        _reloj = reloj;
 25: 
 26:   final Database _db;
 27:   final RepositorioProductos _repo;
 28:   final Hub _hub;
 29:   final Reloj _reloj;
 30: 
 31:   List<Producto> listar({String? busqueda, String? categoria}) =>
 32:       _repo.listar(busqueda: busqueda?.trim(), categoria: categoria?.trim());
 33: 
 34:   Producto obtener(String id) =>
 35:       _repo.porId(id) ?? (throw ErrorApi.noEncontrado('el producto'));
 36: 
 37:   /// Crea un producto con su existencia inicial. [origen] queda en el
 38:   /// movimiento de inventario: "Caja", el nombre de la terminal o "Datos de ejemplo".
 39:   Producto crear(Map<String, Object?> datos, {required String origen}) {
 40:     final v = Validador(datos);
 41:     final codigo = v.texto(
 42:       'codigo',
 43:       max: 64,
 44:       patron: _patronCodigo,
 45:       mensajePatron: 'Solo letras y dígitos, sin espacios',
 46:     );
 47:     final nombre = v.texto('nombre', max: 80);
 48:     final categoria = v.texto('categoria', max: 40)?.toLowerCase();
 49:     final presentacion = v.texto('presentacion', requerido: false, max: 40);
 50:     final precio = v.centavos('precio');
 51:     final precioCaja = v.centavos('precioCaja', requerido: false);
 52:     final piezasPorCaja = v.entero(
 53:       'piezasPorCaja',
 54:       requerido: false,
 55:       min: 2,
 56:       mensaje: 'Debe ser un entero de 2 o más',
 57:     );
 58:     final existencia =
 59:         v.entero('existenciaPiezas', requerido: false, min: 0) ?? 0;
 60:     final minimo = v.entero('minimo', requerido: false, min: 0) ?? 0;
 61:     final envase = v.opcion('envase', formatosEnvase, requerido: false);
 62:     final caducidad = v.fecha('caducidad', requerido: false);
 63: 
 64:     if (v.presente('precioCaja') != v.presente('piezasPorCaja')) {
 65:       v.error(
 66:         v.presente('precioCaja') ? 'piezasPorCaja' : 'precioCaja',
 67:         'precioCaja y piezasPorCaja van juntos: los dos o ninguno',
 68:       );
 69:     }
 70:     v.comprobar();
 71: 
 72:     final ahora = instanteIso(_reloj());
 73:     final producto = Producto(
 74:       id: generarId('p'),
 75:       codigo: codigo!,
 76:       nombre: nombre!,
 77:       categoria: categoria!,
 78:       presentacion: presentacion,
 79:       precio: precio!,
 80:       precioCaja: precioCaja,
 81:       piezasPorCaja: piezasPorCaja,
 82:       existenciaPiezas: existencia,
 83:       minimo: minimo,
 84:       envase: envase,
 85:       caducidad: caducidad,
 86:       creado: ahora,
 87:       actualizado: ahora,
 88:     );
 89: 
 90:     transaccion(_db, () {
 91:       if (_repo.existeCodigo(producto.codigo)) {
 92:         throw ErrorApi.codigoDuplicado(producto.codigo);
 93:       }
 94:       _repo.insertar(producto);
 95:       if (existencia > 0) {
 96:         _repo.registrarMovimiento(
 97:           productoId: producto.id,
 98:           tipo: 'inicial',
 99:           piezas: existencia,
100:           existenciaResultante: existencia,
101:           origen: origen,
102:           fecha: ahora,
103:         );
104:       }
105:     });
106: 
107:     _hub.emitir(TiposEvento.productoActualizado, {
108:       'producto': producto.toJson(),
109:     });
110:     return producto;
111:   }
112: }
````

## File: backend/lib/src/servicios/servicio_terminales.dart
````dart
  1: import '../comun/errores.dart';
  2: import '../comun/fechas.dart';
  3: import '../comun/json.dart';
  4: import '../comun/seguridad.dart';
  5: import '../db/repositorio_terminales.dart';
  6: import '../modelos/terminal.dart';
  7: import '../ws/hub.dart';
  8: 
  9: /// Emparejamiento, registro y autenticación de terminales.
 10: class ServicioTerminales {
 11:   ServicioTerminales({
 12:     required RepositorioTerminales repositorio,
 13:     required Hub hub,
 14:     Reloj reloj = relojSistema,
 15:   }) : _repo = repositorio,
 16:        _hub = hub,
 17:        _reloj = reloj;
 18: 
 19:   static const vigenciaCodigo = Duration(minutes: 10);
 20:   static const intentosPorCodigo = 5;
 21: 
 22:   /// No se escribe `ultima_conexion` en cada petición, solo si pasó este tiempo.
 23:   static const intervaloConexion = Duration(minutes: 1);
 24: 
 25:   final RepositorioTerminales _repo;
 26:   final Hub _hub;
 27:   final Reloj _reloj;
 28: 
 29:   ({String codigo, DateTime expira})? _codigo;
 30:   var _intentosFallidos = 0;
 31:   final _ultimaMarca = <String, DateTime>{};
 32: 
 33:   /// Un código nuevo invalida el anterior.
 34:   CodigoEmparejamiento crearCodigo() {
 35:     final expira = _reloj().add(vigenciaCodigo);
 36:     _codigo = (codigo: generarCodigoNumerico(6), expira: expira);
 37:     _intentosFallidos = 0;
 38:     return CodigoEmparejamiento(
 39:       codigo: _codigo!.codigo,
 40:       expira: instanteIso(expira),
 41:     );
 42:   }
 43: 
 44:   /// Regresa la terminal y su clave. La clave no se vuelve a mostrar.
 45:   ({Terminal terminal, String clave}) registrar(Map<String, Object?> datos) {
 46:     final v = Validador(datos);
 47:     final nombre = v.texto('nombre', max: 40);
 48:     final codigo = v.texto('codigo', min: 6, max: 6);
 49:     v.comprobar();
 50: 
 51:     final vigente = _codigo;
 52:     if (vigente == null || !_reloj().isBefore(vigente.expira)) {
 53:       throw ErrorApi.codigoInvalido();
 54:     }
 55:     if (!igualesSeguro(codigo!, vigente.codigo)) {
 56:       // Con 5 intentos sobre 1 000 000 de códigos, adivinar es inviable.
 57:       if (++_intentosFallidos >= intentosPorCodigo) _codigo = null;
 58:       throw ErrorApi.codigoInvalido();
 59:     }
 60:     _codigo = null; // Un código sirve para una sola terminal.
 61: 
 62:     final ahora = instanteIso(_reloj());
 63:     final clave = generarClave();
 64:     final terminal = Terminal(
 65:       id: generarId('t'),
 66:       nombre: nombre!,
 67:       registrada: ahora,
 68:       ultimaConexion: ahora,
 69:     );
 70:     _repo.insertar(terminal, claveHash: hashClave(clave));
 71:     return (terminal: terminal, clave: clave);
 72:   }
 73: 
 74:   /// Terminal dueña de [clave], o `null` si no existe o fue revocada.
 75:   Terminal? autenticar(String clave) {
 76:     final terminal = _repo.activaPorHash(hashClave(clave));
 77:     if (terminal == null) return null;
 78:     final ahora = _reloj();
 79:     final ultima = _ultimaMarca[terminal.id];
 80:     if (ultima == null || ahora.difference(ultima) >= intervaloConexion) {
 81:       _repo.marcarConexion(terminal.id, instanteIso(ahora));
 82:       _ultimaMarca[terminal.id] = ahora;
 83:     }
 84:     return terminal;
 85:   }
 86: 
 87:   List<Terminal> listar() {
 88:     final conectadas = _hub.terminalesConectadas;
 89:     return [
 90:       for (final t in _repo.listarActivas())
 91:         t.conConexion(conectadas.contains(t.id)),
 92:     ];
 93:   }
 94: 
 95:   Future<void> revocar(String id) async {
 96:     if (!_repo.revocar(id)) throw ErrorApi.noEncontrado('la terminal');
 97:     _ultimaMarca.remove(id);
 98:     await _hub.desconectarTerminal(id);
 99:   }
100: }
````

## File: backend/lib/src/ws/hub.dart
````dart
 1: import 'dart:convert';
 2: 
 3: import 'package:web_socket_channel/web_socket_channel.dart';
 4: 
 5: import '../comun/bitacora.dart';
 6: import '../comun/fechas.dart';
 7: import '../comun/sesion.dart';
 8: import '../modelos/evento.dart';
 9: 
10: /// Conexiones WebSocket abiertas y envío de eventos a todas.
11: ///
12: /// Los servicios llaman a [emitir] DESPUÉS de confirmar la transacción, para
13: /// no avisar de un cambio que terminó en rollback.
14: class Hub {
15:   Hub({
16:     required this.version,
17:     required Bitacora bitacora,
18:     Reloj reloj = relojSistema,
19:   }) : _bitacora = bitacora,
20:        _reloj = reloj;
21: 
22:   final String version;
23:   final Bitacora _bitacora;
24:   final Reloj _reloj;
25:   final _conexiones = <WebSocketChannel, Sesion>{};
26: 
27:   int get totalConexiones => _conexiones.length;
28: 
29:   Set<String> get terminalesConectadas => {
30:     for (final s in _conexiones.values)
31:       if (s.terminalId != null) s.terminalId!,
32:   };
33: 
34:   void conectar(WebSocketChannel canal, Sesion sesion) {
35:     _conexiones[canal] = sesion;
36:     _bitacora.info(
37:       'WS conectado: ${sesion.nombre} (${_conexiones.length} abiertos)',
38:     );
39:     _enviar(canal, _evento(TiposEvento.conexionLista, {'version': version}));
40:     canal.stream.listen(
41:       (_) {}, // El cliente no manda mensajes por ahora (contrato).
42:       onDone: () => _quitar(canal),
43:       onError: (Object e) => _quitar(canal),
44:       cancelOnError: true,
45:     );
46:   }
47: 
48:   void emitir(String tipo, Map<String, Object?> datos) {
49:     final texto = jsonEncode(_evento(tipo, datos).toJson());
50:     for (final canal in _conexiones.keys.toList()) {
51:       _enviarTexto(canal, texto);
52:     }
53:   }
54: 
55:   /// Cierra los WebSocket de una terminal revocada.
56:   Future<void> desconectarTerminal(String terminalId) async {
57:     final canales = [
58:       for (final e in _conexiones.entries)
59:         if (e.value.terminalId == terminalId) e.key,
60:     ];
61:     for (final c in canales) {
62:       _conexiones.remove(c);
63:       await c.sink.close();
64:     }
65:   }
66: 
67:   Future<void> cerrar() async {
68:     final canales = _conexiones.keys.toList();
69:     _conexiones.clear();
70:     await Future.wait(canales.map((c) => c.sink.close()));
71:   }
72: 
73:   Evento _evento(String tipo, Map<String, Object?> datos) =>
74:       Evento(tipo: tipo, datos: datos, fecha: instanteIso(_reloj()));
75: 
76:   void _enviar(WebSocketChannel canal, Evento evento) =>
77:       _enviarTexto(canal, jsonEncode(evento.toJson()));
78: 
79:   void _enviarTexto(WebSocketChannel canal, String texto) {
80:     try {
81:       canal.sink.add(texto);
82:     } catch (e) {
83:       // Si el socket falló o se cerró del lado del cliente, desconectarlo de inmediato
84:       _quitar(canal);
85:       try {
86:         canal.sink.close();
87:       } catch (_) {}
88:     }
89:   }
90: 
91:   void _quitar(WebSocketChannel canal) {
92:     final sesion = _conexiones.remove(canal);
93:     if (sesion != null) {
94:       _bitacora.info(
95:         'WS desconectado: ${sesion.nombre} (${_conexiones.length} abiertos)',
96:       );
97:     }
98:   }
99: }
````

## File: backend/lib/src/servidor.dart
````dart
  1: import 'dart:io';
  2: 
  3: import 'package:path/path.dart' as p;
  4: import 'package:shelf/shelf.dart';
  5: import 'package:shelf/shelf_io.dart' as io;
  6: import 'package:shelf_router/shelf_router.dart';
  7: import 'package:shelf_web_socket/shelf_web_socket.dart';
  8: import 'package:sqlite3/sqlite3.dart';
  9: 
 10: import 'comun/bitacora.dart';
 11: import 'comun/errores.dart';
 12: import 'comun/fechas.dart';
 13: import 'comun/middleware.dart';
 14: import 'comun/seguridad.dart';
 15: import 'comun/sesion.dart';
 16: import 'db/base_datos.dart';
 17: import 'db/migraciones.dart';
 18: import 'db/repositorio_ajustes.dart';
 19: import 'db/repositorio_productos.dart';
 20: import 'db/repositorio_terminales.dart';
 21: import 'rutas/rutas_productos.dart';
 22: import 'rutas/rutas_terminales.dart';
 23: import 'seed/datos_ejemplo.dart';
 24: import 'servicios/servicio_productos.dart';
 25: import 'servicios/servicio_terminales.dart';
 26: import 'ws/hub.dart';
 27: import 'db/repositorio_envases.dart';
 28: import 'db/repositorio_ventas.dart';
 29: import 'rutas/rutas_envases.dart';
 30: import 'rutas/rutas_ventas.dart';
 31: import 'rutas/rutas_pedidos.dart';
 32: import 'servicios/servicio_envases.dart';
 33: import 'servicios/servicio_ventas.dart';
 34: import 'servicios/servicio_pedidos.dart';
 35: 
 36: /// Versión del servidor; se manda en `conexion.lista`.
 37: const versionServidor = '0.1.0';
 38: 
 39: /// El servidor de Anaquel. La app lo arranca dentro de sí misma en modo Caja;
 40: /// en desarrollo lo arranca `bin/server.dart`.
 41: ///
 42: /// ```dart
 43: /// final servidor = DepositoServer(rutaBaseDatos: '${docs.path}/anaquel.db');
 44: /// await servidor.iniciar();
 45: /// // La app de la caja usa servidor.claveCaja en X-Clave-Terminal.
 46: /// await servidor.detener();
 47: /// ```
 48: class DepositoServer {
 49:   DepositoServer({
 50:     required this.rutaBaseDatos,
 51:     this.puerto = 8080,
 52:     InternetAddress? direccion,
 53:     String? claveCaja,
 54:     this.datosEjemplo = false,
 55:     Bitacora? bitacora,
 56:     Reloj reloj = relojSistema,
 57:   }) : direccion = direccion ?? InternetAddress.anyIPv4,
 58:        claveCaja = claveCaja ?? generarClave(),
 59:        bitacora = bitacora ?? Bitacora(),
 60:        _reloj = reloj;
 61: 
 62:   /// Archivo SQLite, o [enMemoria].
 63:   final String rutaBaseDatos;
 64: 
 65:   /// `0` elige un puerto libre (pruebas); el real queda en [puertoActual].
 66:   final int puerto;
 67:   final InternetAddress direccion;
 68: 
 69:   /// Clave con la que la app de la caja se identifica. Nunca sale del iPad.
 70:   final String claveCaja;
 71: 
 72:   /// Carga los productos del prototipo si la base está vacía.
 73:   final bool datosEjemplo;
 74:   final Bitacora bitacora;
 75:   final Reloj _reloj;
 76: 
 77:   HttpServer? _http;
 78:   Database? _db;
 79:   Hub? _hub;
 80: 
 81:   bool get iniciado => _http != null;
 82: 
 83:   int get puertoActual =>
 84:       _http?.port ?? (throw StateError('El servidor no está iniciado'));
 85: 
 86:   /// Abre la base, aplica migraciones (con respaldo previo) y empieza a escuchar.
 87:   // backend/lib/src/servidor.dart
 88: 
 89:   Future<void> iniciar() async {
 90:     if (iniciado) return;
 91:     final db = abrirBaseDatos(rutaBaseDatos);
 92:     try {
 93:       final aplicadas = aplicarMigraciones(
 94:         db,
 95:         rutaRespaldo: _rutaRespaldoMigracion,
 96:         reloj: _reloj,
 97:       );
 98:       if (aplicadas.isNotEmpty) {
 99:         bitacora.info('Migraciones aplicadas: ${aplicadas.join(', ')}');
100:       }
101: 
102:       final hub = Hub(
103:         version: versionServidor,
104:         bitacora: bitacora,
105:         reloj: _reloj,
106:       );
107:       final ajustes = RepositorioAjustes(db);
108:       final repoProductos = RepositorioProductos(db);
109:       final repoEnvases = RepositorioEnvases(db);
110:       final repoVentas = RepositorioVentas(db);
111:       final productos = ServicioProductos(
112:         db: db,
113:         repositorio: repoProductos,
114:         hub: hub,
115:         reloj: _reloj,
116:       );
117:       final terminales = ServicioTerminales(
118:         repositorio: RepositorioTerminales(db),
119:         hub: hub,
120:         reloj: _reloj,
121:       );
122:       final envases = ServicioEnvases(
123:         db: db,
124:         repositorio: repoEnvases,
125:         hub: hub,
126:         reloj: _reloj,
127:       );
128: 
129:       final ventas = ServicioVentas(
130:         db: db,
131:         repoVentas: repoVentas,
132:         repoProductos: repoProductos,
133:         repoEnvases: repoEnvases,
134:         repoAjustes: ajustes,
135:         hub: hub,
136:         reloj: _reloj,
137:       );
138: 
139:       final pedidos = ServicioPedidos(db: db, hub: hub, reloj: _reloj);
140: 
141:       if (datosEjemplo && repoProductos.contar() == 0) {
142:         cargarDatosEjemplo(
143:           productos,
144:           zonaHoraria: ajustes.zonaHoraria,
145:           reloj: _reloj,
146:         );
147:         bitacora.info('Datos de ejemplo cargados');
148:       }
149: 
150:       final router =
151:           Router(
152:               notFoundHandler: (_) => throw ErrorApi.noEncontrado('esa ruta'),
153:             )
154:             ..get('/salud', (Request _) => Response.ok('ok'))
155:             ..get('/api/v1/ws', (Request peticion) {
156:               final sesion = sesionDe(peticion);
157:               return webSocketHandler(
158:                 (canal, _) => hub.conectar(canal, sesion),
159:                 pingInterval: const Duration(seconds: 20),
160:               )(peticion);
161:             });
162:       montarRutasTerminales(router, terminales);
163:       montarRutasProductos(router, productos);
164:       montarRutasTerminales(router, terminales);
165:       montarRutasProductos(router, productos);
166:       montarRutasEnvases(router, envases);
167:       montarRutasVentas(router, ventas);
168:       montarRutasPedidos(router, pedidos);
169: 
170:       final manejador = const Pipeline()
171:           .addMiddleware(registrarPeticiones(bitacora))
172:           .addMiddleware(manejarErrores(bitacora))
173:           .addMiddleware(
174:             autenticar(claveCaja: claveCaja, terminales: terminales),
175:           )
176:           .addHandler(router.call);
177: 
178:       _http = await io.serve(manejador, direccion, puerto);
179:       _db = db;
180:       _hub = hub;
181:       bitacora.info(
182:         'Servidor $versionServidor en ${direccion.address}:${_http!.port}',
183:       );
184:     } catch (e, pila) {
185:       // Limpieza integral en caso de error durante el arranque
186:       await _hub?.cerrar();
187:       await _http?.close(force: true);
188:       db.close();
189:       _http = null;
190:       _db = null;
191:       _hub = null;
192:       bitacora.error('No se pudo iniciar el servidor', e, pila);
193:       rethrow;
194:     }
195:   }
196: 
197:   /// Cierra conexiones y la base. Se puede volver a [iniciar] después.
198:   Future<void> detener() async {
199:     await _hub?.cerrar();
200:     await _http?.close(force: true);
201:     _db?.close();
202:     _http = null;
203:     _db = null;
204:     _hub = null;
205:     bitacora.info('Servidor detenido');
206:   }
207: 
208:   String? _rutaRespaldoMigracion(int versionActual) {
209:     if (rutaBaseDatos == enMemoria) return null;
210:     final marca = instanteIso(_reloj()).replaceAll(RegExp('[-:]'), '');
211:     final carpeta = p.join(p.dirname(rutaBaseDatos), 'respaldos');
212:     Directory(carpeta).createSync(recursive: true);
213:     return p.join(carpeta, 'antes-de-migrar-v$versionActual-$marca.db');
214:   }
215: }
````

## File: backend/test/fechas_test.dart
````dart
 1: import 'package:deposito_backend/src/comun/fechas.dart';
 2: import 'package:test/test.dart';
 3: 
 4: void main() {
 5:   const mexico = Duration(hours: -6);
 6: 
 7:   group('diaNegocio', () {
 8:     test(
 9:       'una venta a las 23:59 del local cuenta en ese día, aunque en UTC ya sea el siguiente',
10:       () {
11:         // 2 de octubre 23:59 en México = 3 de octubre 05:59 UTC.
12:         expect(
13:           diaNegocio(DateTime.utc(2026, 10, 3, 5, 59), mexico),
14:           '2026-10-02',
15:         );
16:       },
17:     );
18: 
19:     test('una venta a las 00:01 del local cuenta en el día nuevo', () {
20:       expect(diaNegocio(DateTime.utc(2026, 10, 3, 6, 1), mexico), '2026-10-03');
21:     });
22: 
23:     test('ignora la zona del dispositivo: usa el instante en UTC', () {
24:       final local = DateTime.utc(2026, 10, 3, 5, 59).toLocal();
25:       expect(diaNegocio(local, mexico), '2026-10-02');
26:     });
27: 
28:     test('cambio de año', () {
29:       expect(diaNegocio(DateTime.utc(2027, 1, 1, 5, 0), mexico), '2026-12-31');
30:     });
31:   });
32: 
33:   test('rangoDiaNegocio cubre de medianoche a medianoche local en UTC', () {
34:     final r = rangoDiaNegocio('2026-10-02', mexico);
35:     expect(r.inicio, DateTime.utc(2026, 10, 2, 6));
36:     expect(r.fin, DateTime.utc(2026, 10, 3, 6));
37:     expect(diaNegocio(r.inicio, mexico), '2026-10-02');
38:     expect(
39:       diaNegocio(r.fin.subtract(const Duration(seconds: 1)), mexico),
40:       '2026-10-02',
41:     );
42:   });
43: 
44:   test('instanteIso es UTC sin milisegundos', () {
45:     expect(
46:       instanteIso(DateTime.utc(2026, 10, 2, 18, 30, 0, 456)),
47:       '2026-10-02T18:30:00Z',
48:     );
49:   });
50: 
51:   test('parsearFecha rechaza fechas que no existen', () {
52:     expect(parsearFecha('2026-02-28'), isNotNull);
53:     expect(parsearFecha('2026-02-30'), isNull);
54:     expect(parsearFecha('2026-13-01'), isNull);
55:     expect(parsearFecha('2026-1-01'), isNull);
56:   });
57: 
58:   test('parsearDesfase', () {
59:     expect(parsearDesfase('-06:00'), const Duration(hours: -6));
60:     expect(parsearDesfase('+05:30'), const Duration(hours: 5, minutes: 30));
61:     expect(parsearDesfase('-6'), isNull);
62:   });
63: }
````

## File: backend/pubspec.yaml
````yaml
 1: name: deposito_backend
 2: description: Servidor de Anaquel. API REST, WebSocket y SQLite, embebido en la app en modo Caja.
 3: version: 0.1.0
 4: publish_to: none
 5: 
 6: environment:
 7:   sdk: ^3.13.4
 8: 
 9: dependencies:
10:   crypto: ^3.0.6
11:   path: ^1.9.1
12:   shelf: ^1.4.2
13:   shelf_router: ^1.1.4
14:   shelf_web_socket: ^3.0.0
15:   sqlite3: ^3.6.0
16:   web_socket_channel: ^3.0.3
17: 
18: dev_dependencies:
19:   http: ^1.6.0
20:   lints: ^6.0.0
21:   test: ^1.25.6
````

## File: .gitignore
````
1: .DS_Store
2: .idea/
3: Thumbs.db
4: *.iml
````

## File: backend/lib/deposito_backend.dart
````dart
 1: /// Servidor de Anaquel y modelos compartidos con la app.
 2: ///
 3: /// La app importa este paquete para:
 4: /// - arrancar [DepositoServer] en modo Caja;
 5: /// - usar los mismos modelos ([Producto], [Terminal], [Evento]) que el
 6: ///   servidor, así los campos nunca se desincronizan.
 7: library;
 8: 
 9: export 'src/comun/bitacora.dart' show Bitacora;
10: export 'src/comun/fechas.dart'
11:     show Reloj, diaNegocio, instanteIso, rangoDiaNegocio;
12: export 'src/comun/middleware.dart' show cabeceraClave;
13: export 'src/comun/texto.dart' show normalizarBusqueda;
14: export 'src/db/base_datos.dart' show enMemoria;
15: export 'src/modelos/evento.dart';
16: export 'src/modelos/producto.dart';
17: export 'src/modelos/terminal.dart';
18: export 'src/servidor.dart' show DepositoServer, versionServidor;
````

## File: docs/API.md
````markdown
  1: # Contrato de la API
  2: 
  3: Este documento es el acuerdo entre `backend/` y `app/`. Ningún endpoint se programa sin estar primero aquí.
  4: 
  5: Los cambios a este archivo se hacen por pull request con la etiqueta `contrato`.
  6: 
  7: ## Convenciones
  8: 
  9: | Tema | Regla |
 10: | --- | --- |
 11: | Prefijo | Las rutas empiezan con `/api/v1`, salvo `/salud` |
 12: | Formato | JSON en UTF-8 |
 13: | Nombres | En español, sin acentos, en `camelCase`: `precioCaja`, `piezasPorCaja` |
 14: | Dinero | Entero en centavos: $42.50 se manda como `4250`. Un número con decimales es `datos_invalidos` |
 15: | Instantes | ISO 8601 en UTC, sin milisegundos: `2026-10-02T18:30:00Z` |
 16: | Fechas de calendario | `AAAA-MM-DD` en la hora local del negocio: `2027-03-15` (caducidad, día de un reporte) |
 17: | Existencias | Siempre en piezas. Las cajas son solo visuales |
 18: | IDs | Texto generado por el servidor, con prefijo por tipo: `p_` producto, `t_` terminal |
 19: | Autenticación | Encabezado `X-Clave-Terminal` en toda petición, salvo las marcadas como públicas |
 20: | Reintentos | Las operaciones de cobro llevan el encabezado `X-Clave-Idempotencia` (se detalla con ventas) |
 21: | Errores | `{ "error": { "codigo": "stock_insuficiente", "mensaje": "..." } }` |
 22: 
 23: ### Quién llama
 24: 
 25: | Rol | Cómo se identifica | Puede |
 26: | --- | --- | --- |
 27: | Caja | La clave de caja que el servidor embebido le da a la app al arrancar | Todo |
 28: | Terminal | La clave que recibió al registrarse con el código del QR | Consultar, y lo que cada endpoint indique |
 29: 
 30: Un endpoint marcado **Solo caja** responde `403 solo_caja` a una terminal.
 31: 
 32: ### Errores
 33: 
 34: | HTTP | `codigo` | Cuándo |
 35: | --- | --- | --- |
 36: | `400` | `datos_invalidos` | Falta un campo o tiene un formato o valor no permitido. Incluye `campos` (abajo) |
 37: | `400` | `json_invalido` | El cuerpo no es JSON válido |
 38: | `401` | `no_autorizado` | Falta `X-Clave-Terminal`, no existe o fue revocada |
 39: | `401` | `codigo_invalido` | Código de emparejamiento incorrecto o vencido |
 40: | `403` | `solo_caja` | Una terminal intenta algo que solo hace la caja |
 41: | `404` | `no_encontrado` | El recurso o la ruta no existe |
 42: | `409` | `codigo_duplicado` | Ya existe un producto activo con ese código de barras |
 43: | `409` | `stock_insuficiente` | No hay piezas suficientes (ventas, Sprint 3) |
 44: | `409` | `caja_cerrada` | Se intenta cobrar sin turno abierto (caja, Sprint 3) |
 45: | `500` | `error_interno` | Error no previsto. El detalle queda en el log del servidor |
 46: 
 47: Los errores de validación dicen qué campo falló, para que la app lo muestre junto al campo:
 48: 
 49: ```json
 50: {
 51:   "error": {
 52:     "codigo": "datos_invalidos",
 53:     "mensaje": "Revisa los campos marcados",
 54:     "campos": { "precio": "Debe ser un entero mayor que 0 (centavos)" }
 55:   }
 56: }
 57: ```
 58: 
 59: ## Endpoints
 60: 
 61: ### Salud
 62: 
 63: `GET /salud` · Pública
 64: 
 65: Comprueba que el servidor responde.
 66: 
 67: - Respuesta `200`: el texto `ok`.
 68: 
 69: ### Terminales
 70: 
 71: Una terminal se vincula así:
 72: 
 73: 1. La caja pide un código de emparejamiento y lo muestra en un QR.
 74: 2. La terminal escanea el QR y se registra con ese código.
 75: 3. El servidor le entrega una clave propia, que la terminal guarda y manda en cada petición.
 76: 
 77: El QR contiene este JSON:
 78: 
 79: ```json
 80: { "v": 1, "host": "192.168.1.20", "puerto": 8080, "codigo": "482913" }
 81: ```
 82: 
 83: #### Crear código de emparejamiento
 84: 
 85: `POST /api/v1/terminales/codigo` · Solo caja
 86: 
 87: Genera un código de 6 dígitos que vence en 10 minutos. Pedir uno nuevo invalida el anterior. Cinco intentos fallidos también lo invalidan, y sirve para registrar una sola terminal.
 88: 
 89: - Respuesta `201`:
 90: 
 91: ```json
 92: { "codigo": "482913", "expira": "2026-10-02T18:40:00Z" }
 93: ```
 94: 
 95: #### Registrar terminal
 96: 
 97: `POST /api/v1/terminales/registro` · Pública
 98: 
 99: ```json
100: { "nombre": "Terminal S24", "codigo": "482913" }
101: ```
102: 
103: - `nombre`: de 1 a 40 caracteres.
104: - Respuesta `201`. La `clave` se entrega **solo esta vez**; el servidor guarda únicamente su hash:
105: 
106: ```json
107: {
108:   "terminal": {
109:     "id": "t_8f2a4c9d1e",
110:     "nombre": "Terminal S24",
111:     "registrada": "2026-10-02T18:31:00Z",
112:     "ultimaConexion": "2026-10-02T18:31:00Z",
113:     "conectada": false
114:   },
115:   "clave": "Zq0vX3...43 caracteres..."
116: }
117: ```
118: 
119: - `400 datos_invalidos`, `401 codigo_invalido`.
120: 
121: #### Listar terminales
122: 
123: `GET /api/v1/terminales` · Solo caja
124: 
125: - Respuesta `200`: `{ "terminales": [ <terminal>, ... ] }`, sin las revocadas. `conectada` es `true` si tiene un WebSocket abierto.
126: 
127: #### Revocar terminal
128: 
129: `DELETE /api/v1/terminales/{id}` · Solo caja
130: 
131: La clave deja de servir de inmediato y se cierra su WebSocket.
132: 
133: - Respuesta `204` sin cuerpo. `404 no_encontrado`.
134: 
135: ### Productos
136: 
137: #### El objeto producto
138: 
139: ```json
140: {
141:   "id": "p_3k9x2m7q1z",
142:   "codigo": "7501064191015",
143:   "nombre": "Victoria Mega",
144:   "categoria": "cerveza",
145:   "presentacion": "Mega 1.2 L",
146:   "precio": 4200,
147:   "precioCaja": 48000,
148:   "piezasPorCaja": 12,
149:   "existenciaPiezas": 66,
150:   "minimo": 36,
151:   "envase": "mega",
152:   "caducidad": "2027-01-29",
153:   "foto": null,
154:   "creado": "2026-10-02T18:30:00Z",
155:   "actualizado": "2026-10-02T18:30:00Z"
156: }
157: ```
158: 
159: | Campo | Tipo | Regla |
160: | --- | --- | --- |
161: | `codigo` | texto | Código de barras, de 1 a 64 letras o dígitos. Único entre productos activos |
162: | `nombre` | texto | De 1 a 80 caracteres |
163: | `categoria` | texto | De 1 a 40 caracteres, en minúsculas: `cerveza`, `refresco`, `botana`, `hielo`... |
164: | `presentacion` | texto o `null` | Hasta 40 caracteres |
165: | `precio` | entero | Centavos por pieza, mayor que 0 |
166: | `precioCaja` | entero o `null` | Centavos por caja, mayor que 0. Va junto con `piezasPorCaja`: los dos o ninguno |
167: | `piezasPorCaja` | entero o `null` | 2 o más |
168: | `existenciaPiezas` | entero | 0 o más. Solo lectura después de crear: cambia por entradas, ventas o ajustes |
169: | `minimo` | entero | 0 o más. Bajo este número se genera alerta. Por omisión `0` |
170: | `envase` | texto o `null` | `mega`, `media` o `cuarto` si usa envase retornable |
171: | `caducidad` | fecha o `null` | `AAAA-MM-DD`, la más próxima |
172: | `foto` | texto o `null` | Ruta de la foto (Sprint 2). Solo lectura |
173: 
174: #### Listar y buscar
175: 
176: `GET /api/v1/productos?q=victoria&categoria=cerveza`
177: 
178: - `q` (opcional): busca en nombre y código, sin distinguir mayúsculas ni acentos.
179: - `categoria` (opcional): filtro exacto.
180: - Respuesta `200`: `{ "productos": [ <producto>, ... ] }`, ordenados por nombre. Sin paginación: el catálogo de un depósito cabe en una respuesta.
181: 
182: #### Detalle
183: 
184: `GET /api/v1/productos/{id}`
185: 
186: - Respuesta `200`: el producto. `404 no_encontrado`.
187: 
188: #### Crear
189: 
190: `POST /api/v1/productos` · Solo caja
191: 
192: El cuerpo es el producto sin `id`, `foto`, `creado` ni `actualizado`. `existenciaPiezas` es la existencia inicial (por omisión `0`) y queda registrada como movimiento de inventario.
193: 
194: ```json
195: {
196:   "codigo": "7501064191015",
197:   "nombre": "Victoria Mega",
198:   "categoria": "cerveza",
199:   "presentacion": "Mega 1.2 L",
200:   "precio": 4200,
201:   "precioCaja": 48000,
202:   "piezasPorCaja": 12,
203:   "existenciaPiezas": 66,
204:   "minimo": 36,
205:   "envase": "mega",
206:   "caducidad": "2027-01-29"
207: }
208: ```
209: 
210: - Respuesta `201`: el producto creado. Emite `producto.actualizado`.
211: - `400 datos_invalidos`, `409 codigo_duplicado`.
212: 
213: ## WebSocket
214: 
215: `GET /api/v1/ws`
216: 
217: Lleva la misma autenticación que el resto: el encabezado `X-Clave-Terminal`, o `?clave=` en la URL si el cliente no puede mandar encabezados.
218: 
219: Todos los mensajes del servidor tienen esta forma:
220: 
221: ```json
222: { "tipo": "producto.actualizado", "datos": { "producto": { } }, "fecha": "2026-10-02T18:30:00Z" }
223: ```
224: 
225: | Tipo | Cuándo | `datos` |
226: | --- | --- | --- |
227: | `conexion.lista` | Al conectarse | `{ "version": "0.1.0" }` |
228: | `producto.actualizado` | Se crea o cambia un producto | `{ "producto": <producto> }` |
229: 
230: - El servidor manda ping cada 20 segundos. Si no hay respuesta, cierra la conexión.
231: - Al reconectarse, la app vuelve a pedir los datos completos con `GET` en lugar de confiar en los eventos que se perdió.
232: - El cliente no manda mensajes por ahora.
233: 
234: ## Pendientes
235: 
236: Se documentarán aquí, en este orden:
237: 
238: - **Sprint 2:** productos por código, editar, eliminar, entradas de mercancía, foto, ajuste de existencia con motivo, movimientos de un producto; envases y préstamos.
239: - **Sprint 3:** pedidos, ventas (con `X-Clave-Idempotencia`), cancelaciones, caja y cortes, resto de eventos del WebSocket.
240: - **Sprint 4:** alertas, reportes, resurtido, ajustes, PIN del dueño, respaldo y diagnóstico.
````

## File: CHANGELOG.md
````markdown
 1: # Cambios
 2: 
 3: Formato: una sección por versión del backend (tag), con lo que se agregó y lo que cambió en el contrato de la API.
 4: 
 5: ## Sin publicar (rumbo a v0.1.0)
 6: Migración 002: tablas para ventas, venta_lineas, pedidos y balance_envases.   
 7: Endpoints POST/GET /api/v1/ventas, POST/GET/DELETE /api/v1/pedidos y GET/POST /api/v1/envases.   
 8: Eventos de tiempo real para actualización de envases y creación de pedidos.  
 9: ### Contrato
10: - Convenciones de autenticación (`X-Clave-Terminal`), catálogo de errores y fechas de calendario.
11: - Terminales: código de emparejamiento, registro, listado y revocación.
12: - Productos: listar y buscar, detalle y crear.
13: - WebSocket: `conexion.lista` y `producto.actualizado`.
14: 
15: ### Backend
16: - `DepositoServer` embebible con `iniciar()` y `detener()`.
17: - Estructura por capas, middleware de errores, log y autenticación.
18: - SQLite en modo WAL, transacciones `BEGIN IMMEDIATE`, migraciones numeradas con respaldo previo.
19: - Tabla `movimientos` para el historial de existencias.
20: - Datos de ejemplo del prototipo.
21: - Pruebas unitarias y e2e con `crearServidorDePrueba()`.
22: 
23: ### App
24: - Tema del prototipo (claro y oscuro) con Barlow incluida en la app.
25: - Elegir modo Caja o Terminal.
26: - Caja: servidor embebido, menú lateral adaptable, tablero, catálogo con búsqueda y filtros, alta de producto, QR para conectar terminales y ajustes.
27: - Terminal: vinculación por QR o a mano, escanear producto, catálogo y ajustes.
28: - Tiempo real con reconexión automática e indicador de conexión.
29: - Permisos de red y cámara en Android e iOS; nombre "Anaquel".
````

## File: README.md
````markdown
  1: # Anaquel
  2: 
  3: ![CI](https://github.com/gerardoleon4/deposito-app/actions/workflows/ci.yml/badge.svg)
  4: 
  5: Sistema de **punto de venta e inventario** para comercios pequeños que venden por pieza y por caja. Funciona **sin internet**, sobre la red Wi-Fi del local: un iPad hace de caja y de servidor, y los teléfonos (Samsung S24 e iPhone) se conectan como terminales para escanear productos, armar pedidos y consultar existencias en tiempo real.
  6: 
  7: ## Qué hace
  8: 
  9: | Módulo | Descripción |
 10: | --- | --- |
 11: | Catálogo (RF-01) | Productos con foto, código de barras, precio por pieza y por caja, existencia mínima y caducidad. El stock se guarda siempre en piezas. |
 12: | Escaneo (RF-02) | Búsqueda de productos por código de barras con la cámara del teléfono. |
 13: | Envases (RF-03) | Envases retornables por formato: cobro de garantía, intercambio, préstamos a clientes y devoluciones. |
 14: | Ventas (RF-04) | Venta por pieza o caja, efectivo con cálculo de cambio o tarjeta, cancelaciones e historial. |
 15: | Tickets y corte (RF-05) | Ticket en PDF para compartir por WhatsApp o correo. Apertura y cierre de caja con arqueo. |
 16: | Tiempo real (RF-06) | Cada venta actualiza las existencias en todos los dispositivos al instante. |
 17: | Alertas (RF-07) | Aviso de poco stock y de productos próximos a caducar. |
 18: | Resurtido (RF-08) | Sugerencia de cuánto comprar según las ventas de los últimos 30 días. |
 19: 
 20: ## Cómo funciona
 21: 
 22: ```
 23:               Wi-Fi del negocio (red local)
 24: 
 25:    iPad (modo CAJA)
 26:    ┌────────────────────────────────┐
 27:    │ App Flutter (pantallas)        │
 28:    │        │ localhost:8080        │
 29:    │        ▼                       │        S24 (modo TERMINAL)
 30:    │ backend embebido               │◄─ HTTP ─ iPhone (modo TERMINAL)
 31:    │  • API REST                    │◄─ WebSocket
 32:    │  • WebSocket                   │
 33:    │  • SQLite                      │
 34:    └────────────────────────────────┘
 35: ```
 36: 
 37: - La **caja** ejecuta el backend dentro de la propia app y guarda todo en SQLite.
 38: - Las **terminales** usan la misma app en modo Terminal y se conectan a la IP de la caja (por código QR).
 39: - Todo pasa por una API REST y un WebSocket para los cambios en vivo.
 40: 
 41: > **Importante:** iOS no permite servidores en segundo plano, así que el iPad debe tener la app abierta y en primer plano (Acceso guiado y sin bloqueo automático).
 42: 
 43: ## Estructura del repositorio
 44: 
 45: ```
 46: deposito-app/
 47: ├── backend/    Paquete Dart: API, WebSocket, SQLite y reglas de negocio
 48: ├── app/        App Flutter: pantallas de caja y terminal
 49: ├── docs/       Contrato de la API, plan de trabajo y prototipo HTML
 50: └── .github/    CI y plantilla de PR
 51: ```
 52: 
 53: ## Tecnologías
 54: 
 55: | Parte | Herramientas |
 56: | --- | --- |
 57: | Backend | Dart, `shelf`, `shelf_router`, `shelf_web_socket`, `sqlite3` |
 58: | App | Flutter, `flutter_riverpod`, `go_router`, `dio`, `web_socket_channel`, `mobile_scanner`, `pdf`, `printing`, `share_plus`, `qr_flutter` |
 59: | Calidad | GitHub Actions, `dart analyze`, `flutter analyze`, pruebas unitarias |
 60: 
 61: ## Requisitos
 62: 
 63: - **Flutter 3.47.5** (incluye Dart 3.13.4). Verifica con `flutter --version` y `flutter doctor`.
 64: - Git.
 65: - Para probar en Android: Android Studio (SDK y emulador) o un teléfono con depuración USB.
 66: - Para compilar en iPad o iPhone: **macOS con Xcode**. En Linux y Windows se puede programar y probar todo en Android.
 67: 
 68: ## Primeros pasos
 69: 
 70: ```bash
 71: git clone https://github.com/gerardoleon4/deposito-app.git
 72: cd deposito-app
 73: git checkout develop
 74: ```
 75: 
 76: ### Backend
 77: 
 78: ```bash
 79: cd backend
 80: dart pub get
 81: dart run bin/server.dart
 82: ```
 83: 
 84: Abre <http://localhost:8080/salud>: debe responder `ok`.
 85: 
 86: ### App
 87: 
 88: ```bash
 89: cd app
 90: flutter pub get
 91: flutter run
 92: ```
 93: 
 94: La primera vez, la app pregunta si el dispositivo será **Caja** o **Terminal**. Mientras el iPad no esté listo, el backend se corre en una laptop y las terminales se conectan a su IP.
 95: 
 96: ### Pruebas
 97: 
 98: ```bash
 99: cd backend && dart test
100: cd app && flutter test
101: ```
102: 
103: ## Documentación
104: 
105: | Documento | Contenido |
106: | --- | --- |
107: | [`docs/API.md`](docs/API.md) | Contrato de la API: endpoints, ejemplos y eventos del WebSocket |
108: | [`docs/PLAN_DE_TRABAJO.md`](docs/PLAN_DE_TRABAJO.md) | Cómo trabaja el equipo, sprints y reglas de Git |
109: | [`docs/SETUP.md`](docs/SETUP.md) | Instalación paso a paso en Linux, Windows y macOS |
110: | [`docs/ESTANDARES.md`](docs/ESTANDARES.md) | Reglas obligatorias de dinero, fechas, datos, capas y código |
111: | [`AGENTS.md`](AGENTS.md) | Guía rápida para el equipo y sus asistentes de IA |
112: | [`docs/prototipo/`](docs/prototipo/) | Prototipo HTML navegable con todas las pantallas |
113: | [`CHANGELOG.md`](CHANGELOG.md) | Cambios por versión |
114: 
115: ## Cómo contribuir
116: 
117: 1. Actualiza `develop` y crea tu rama: `feature/back-...` para `backend/` o `feature/front-...` para `app/`.
118: 2. Haz commits con prefijo: `feat(back):`, `fix(app):`, `docs:`, `test(back):`.
119: 3. Abre un pull request hacia `develop`. Debe pasar el CI y tener una revisión.
120: 4. Los cambios a la API se documentan primero en `docs/API.md` con la etiqueta `contrato`.
121: 
122: No se hace push directo a `develop` ni a `main`. Los detalles están en el [plan de trabajo](docs/PLAN_DE_TRABAJO.md).
123: 
124: ## Equipo
125: 
126: | Persona | Rol | Áreas |
127: | --- | --- | --- |
128: | Gerardo | Backend | Servidor, base de datos, productos, WebSocket, alertas, respaldos, contrato de la API |
129: | Ever | Backend | Ventas, caja y cortes, envases, reportes, resurtido |
130: | Pablo | Frontend | Base de la app, conexión, tiempo real, catálogo, ajustes |
131: | Daniel | Frontend | Vender, cobro, tickets, historial, corte, tablero de inicio |
132: | Luis | Frontend | Terminal, envases, alertas, resurtido |
133: 
134: ## Avance
135: 
136: | Sprint | Fechas | Meta | Estado |
137: | --- | --- | --- | --- |
138: | 1 | 25 sep – 9 oct | Cimientos: el iPad corre el servidor y una terminal se conecta | En curso |
139: | 2 | 10 – 23 oct | Catálogo, escaneo y envases | Pendiente |
140: | 3 | 24 oct – 6 nov | Ventas, caja y tiempo real | Pendiente |
141: | 4 | 7 – 20 nov | Alertas, resurtido y tablero | Pendiente |
142: | 5 | 21 – 27 nov | Corrección de errores, manual e instalación | Pendiente |
143: 
144: ## Licencia
145: 
146: Por definir con el equipo y el cliente.
````
