import 'package:deposito_backend/deposito_backend.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'ayudantes/servidor_prueba.dart';

void main() {
  late ServidorPrueba s;
  var clavesUsadas = 0;

  setUp(() async => s = await crearServidorDePrueba());
  tearDown(() => s.cerrar());

  /// Cobra como la caja, con una clave de idempotencia nueva salvo que se pase.
  Future<http.Response> cobrar(Map<String, Object?> cuerpo, {String? clave}) =>
      s.post(
        '/api/v1/ventas',
        cuerpo,
        cabeceras: {
          cabeceraIdempotencia: clave ?? 'cobro-prueba-${clavesUsadas++}',
        },
      );

  Future<String> crearProducto([
    Map<String, Object?> cambios = const {},
  ]) async =>
      json(await s.post('/api/v1/productos', productoValido(cambios)))['id']
          as String;

  Future<int> existencia(String id) async =>
      json(await s.get('/api/v1/productos/$id'))['existenciaPiezas'] as int;

  group('Ventas', () {
    test('la caja cobra en efectivo y descuenta inventario', () async {
      final pid = await crearProducto({
        'existenciaPiezas': 10,
        'precio': 4200,
        'precioCaja': 48000,
        'piezasPorCaja': 12,
      });

      final r = await cobrar({
        'metodo': 'efectivo',
        'recibido': 5000,
        'envModo': 'trae',
        'lineas': [
          {'productoId': pid, 'unidad': 'pieza', 'cantidad': 1},
        ],
      });

      expect(r.statusCode, 201);
      final venta = json(r);
      expect(venta['folio'], 1001);
      expect(venta['total'], 4200);
      expect(venta['recibido'], 5000);
      expect(venta['cambio'], 800);
      expect(await existencia(pid), 9);
    });

    test('un reintento con la misma clave no cobra dos veces', () async {
      final pid = await crearProducto({'existenciaPiezas': 10});
      final cuerpo = {
        'metodo': 'efectivo',
        'lineas': [
          {'productoId': pid, 'unidad': 'pieza', 'cantidad': 3},
        ],
      };

      final primera = await cobrar(cuerpo, clave: 'reintento-123');
      final segunda = await cobrar(cuerpo, clave: 'reintento-123');

      expect(primera.statusCode, 201);
      expect(segunda.statusCode, 201);
      expect(json(segunda), json(primera));
      expect(await existencia(pid), 7);
      final ventas = json(await s.get('/api/v1/ventas'))['ventas'] as List;
      expect(ventas, hasLength(1));
    });

    test('sin clave de idempotencia no cobra', () async {
      final pid = await crearProducto({'existenciaPiezas': 10});
      final r = await s.post('/api/v1/ventas', {
        'metodo': 'efectivo',
        'lineas': [
          {'productoId': pid, 'unidad': 'pieza', 'cantidad': 1},
        ],
      });

      expect(r.statusCode, 400);
      expect(codigoError(r), 'datos_invalidos');
      expect(camposError(r), contains('X-Clave-Idempotencia'));
      expect(await existencia(pid), 10);
    });

    test('el mismo producto en piezas y en caja descuenta las dos', () async {
      final pid = await crearProducto({
        'existenciaPiezas': 30,
        'precio': 2000,
        'precioCaja': 20000,
        'piezasPorCaja': 12,
      });

      final r = await cobrar({
        'metodo': 'efectivo',
        'lineas': [
          {'productoId': pid, 'unidad': 'caja', 'cantidad': 1},
          {'productoId': pid, 'unidad': 'pieza', 'cantidad': 5},
        ],
      });

      expect(r.statusCode, 201);
      expect(json(r)['total'], 30000);
      expect(await existencia(pid), 13);
    });

    test('sin existencias suficientes es 409 stock_insuficiente', () async {
      final pid = await crearProducto({'existenciaPiezas': 6});

      // Cada línea cabe sola, juntas no.
      final r = await cobrar({
        'metodo': 'efectivo',
        'lineas': [
          {'productoId': pid, 'unidad': 'pieza', 'cantidad': 4},
          {'productoId': pid, 'unidad': 'pieza', 'cantidad': 4},
        ],
      });

      expect(r.statusCode, 409);
      expect(codigoError(r), 'stock_insuficiente');
      expect(await existencia(pid), 6);
    });

    test('con tarjeta se cobra exacto, sin cambio', () async {
      final pid = await crearProducto({'existenciaPiezas': 5, 'precio': 4200});

      final r = await cobrar({
        'metodo': 'tarjeta',
        'recibido': 100000,
        'lineas': [
          {'productoId': pid, 'unidad': 'pieza', 'cantidad': 2},
        ],
      });

      expect(r.statusCode, 201);
      expect(json(r)['recibido'], 8400);
      expect(json(r)['cambio'], 0);
    });

    test('una línea mal formada es 400 y no error interno', () async {
      final pid = await crearProducto();
      for (final linea in [
        {'productoId': pid, 'unidad': 'pieza', 'cantidad': '2'},
        {'productoId': pid, 'unidad': 'paquete', 'cantidad': 1},
        {'productoId': 5, 'unidad': 'pieza', 'cantidad': 1},
        'no es objeto',
      ]) {
        final r = await cobrar({
          'metodo': 'efectivo',
          'lineas': [linea],
        });
        expect(r.statusCode, 400, reason: '$linea');
        expect(codigoError(r), 'datos_invalidos');
      }
    });

    test('una terminal no puede cobrar (solo caja)', () async {
      final claveTerminal = await s.registrarTerminal();
      final r = await s.post(
        '/api/v1/ventas',
        {'metodo': 'efectivo', 'lineas': []},
        clave: claveTerminal,
        cabeceras: {cabeceraIdempotencia: 'terminal-1234'},
      );

      expect(r.statusCode, 403);
      expect(codigoError(r), 'solo_caja');
    });

    test('cancelar regresa existencias y el préstamo de envases', () async {
      final pid = await crearProducto({
        'existenciaPiezas': 10,
        'envase': 'mega',
      });
      final antes = json(await s.get('/api/v1/envases'))['balance'] as Map;

      final venta = json(
        await cobrar({
          'metodo': 'efectivo',
          'envModo': 'prestamo',
          'envCliente': 'Don Pedro',
          'lineas': [
            {'productoId': pid, 'unidad': 'pieza', 'cantidad': 4},
          ],
        }),
      );
      expect(
        json(await s.get('/api/v1/envases/prestamos'))['prestamos'],
        hasLength(1),
      );

      final r = await s.post('/api/v1/ventas/${venta['id']}/cancelar', null);

      expect(r.statusCode, 204);
      expect(await existencia(pid), 10);
      expect(json(await s.get('/api/v1/envases'))['balance'], antes);
      expect(
        json(await s.get('/api/v1/envases/prestamos'))['prestamos'],
        isEmpty,
      );
    });
  });

  group('Pedidos', () {
    test('una terminal levanta un pedido y la caja lo descarta', () async {
      final claveTerminal = await s.registrarTerminal();
      final pid = await crearProducto();

      final r = await s.post('/api/v1/pedidos', {
        'nota': 'Mesa 3',
        'lineas': [
          {'productoId': pid, 'unidad': 'pieza', 'cantidad': 2},
        ],
      }, clave: claveTerminal);
      expect(r.statusCode, 201);
      final id = json(r)['id'] as String;

      final lista = json(await s.get('/api/v1/pedidos'))['pedidos'] as List;
      expect(lista.any((p) => p['id'] == id), isTrue);

      expect((await s.delete('/api/v1/pedidos/$id')).statusCode, 204);
      expect((await s.delete('/api/v1/pedidos/$id')).statusCode, 404);
    });

    test('un pedido con un producto que no existe es 400', () async {
      final r = await s.post('/api/v1/pedidos', {
        'lineas': [
          {'productoId': 'p_no_existe', 'unidad': 'pieza', 'cantidad': 1},
        ],
      });

      expect(r.statusCode, 400);
      expect(codigoError(r), 'datos_invalidos');
    });
  });

  group('Envases', () {
    test('el balance se actualiza con préstamos y devoluciones', () async {
      final balance = await s.get('/api/v1/envases');
      expect(balance.statusCode, 200);
      expect(json(balance)['balance'], contains('mega'));

      final r = await s.post('/api/v1/envases/prestamos', {
        'cliente': 'Don Pedro',
        'formato': 'mega',
        'cantidad': 10,
      });
      expect(r.statusCode, 201);
      final id = json(r)['id'] as String;

      final devolver = await s.post(
        '/api/v1/envases/prestamos/$id/devolver',
        null,
      );
      expect(devolver.statusCode, 204);
    });

    test('una terminal no registra préstamos (solo caja)', () async {
      final claveTerminal = await s.registrarTerminal();
      final r = await s.post('/api/v1/envases/prestamos', {
        'cliente': 'Don Pedro',
        'formato': 'mega',
        'cantidad': 1,
      }, clave: claveTerminal);

      expect(r.statusCode, 403);
    });
  });
}
