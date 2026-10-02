import 'package:test/test.dart';
import 'ayudantes/servidor_prueba.dart';

void main() {
  late ServidorPrueba s;

  setUp(() async => s = await crearServidorDePrueba());
  tearDown(() => s.cerrar());

  group('Ventas y envases', () {
    test(
      'la caja registra una venta en efectivo y descuenta inventario',
      () async {
        // 1. Crear producto con 10 piezas
        final prodRes = await s.post(
          '/api/v1/productos',
          productoValido({
            'existenciaPiezas': 10,
            'precio': 4200,
            'precioCaja': 48000,
            'piezasPorCaja': 12,
          }),
        );
        final pid = json(prodRes)['id'] as String;

        // 2. Registrar cobro
        final ventaRes = await s.post('/api/v1/ventas', {
          'metodo': 'efectivo',
          'recibido': 5000,
          'envModo': 'trae',
          'lineas': [
            {'productoId': pid, 'unidad': 'pieza', 'cantidad': 1},
          ],
        });

        expect(ventaRes.statusCode, 201);
        final venta = json(ventaRes);
        expect(venta['folio'], 1001);
        expect(venta['total'], 4200);
        expect(venta['cambio'], 800);

        // 3. Verificar que descontó stock
        final detalle = json(await s.get('/api/v1/productos/$pid'));
        expect(detalle['existenciaPiezas'], 9);
      },
    );

    test('falla si no hay existencias suficientes', () async {
      final prodRes = await s.post(
        '/api/v1/productos',
        productoValido({'existenciaPiezas': 2}),
      );
      final pid = json(prodRes)['id'] as String;

      final ventaRes = await s.post('/api/v1/ventas', {
        'metodo': 'efectivo',
        'recibido': 50000,
        'lineas': [
          {'productoId': pid, 'unidad': 'pieza', 'cantidad': 5},
        ],
      });

      expect(ventaRes.statusCode, 400);
      expect(codigoError(ventaRes), 'datos_invalidos');
    });

    test('una terminal no puede cobrar ventas directo (solo caja)', () async {
      final claveTerminal = await s.registrarTerminal();
      final ventaRes = await s.post('/api/v1/ventas', {
        'metodo': 'efectivo',
        'lineas': [],
      }, clave: claveTerminal);

      expect(ventaRes.statusCode, 403);
      expect(codigoError(ventaRes), 'solo_caja');
    });

    test(
      'una terminal puede levantar pedidos y la caja descartarlos',
      () async {
        final claveTerminal = await s.registrarTerminal();
        final prodRes = await s.post('/api/v1/productos', productoValido());
        final pid = json(prodRes)['id'] as String;

        // Terminal crea pedido
        final pedRes = await s.post('/api/v1/pedidos', {
          'nota': 'Mesa 3',
          'lineas': [
            {'productoId': pid, 'unidad': 'pieza', 'cantidad': 2},
          ],
        }, clave: claveTerminal);
        expect(pedRes.statusCode, 201);
        final idPedido = json(pedRes)['id'] as String;

        // Caja lista pedidos
        final lista = json(await s.get('/api/v1/pedidos'))['pedidos'] as List;
        expect(lista.any((p) => p['id'] == idPedido), isTrue);

        // Caja descarta pedido
        final deleteRes = await s.delete('/api/v1/pedidos/$idPedido');
        expect(deleteRes.statusCode, 204);
      },
    );

    test('balance de envases se consulta y actualiza con préstamos', () async {
      final balRes = await s.get('/api/v1/envases');
      expect(balRes.statusCode, 200);
      expect(json(balRes)['balance'], contains('mega'));

      final prestamoRes = await s.post('/api/v1/envases/prestamos', {
        'cliente': 'Don Pedro',
        'formato': 'mega',
        'cantidad': 10,
      });
      expect(prestamoRes.statusCode, 201);
      final idPrestamo = json(prestamoRes)['id'] as String;

      final devRes = await s.post(
        '/api/v1/envases/prestamos/$idPrestamo/devolver',
        null,
      );
      expect(devRes.statusCode, 204);
    });
  });
}
