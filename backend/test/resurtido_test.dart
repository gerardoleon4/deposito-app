import 'dart:convert';

import 'package:deposito_backend/deposito_backend.dart';
import 'package:test/test.dart';

import 'ayudantes/servidor_prueba.dart';

void main() {
  group('GET /api/v1/reportes/resurtido', () {
    test(
      'sugiere productos agotados, bajo mínimo y por cubrir según ventas',
      () async {
        final s = await crearServidorDePrueba(datosEjemplo: false);
        try {
          final abrir = await s.post('/api/v1/caja/abrir', {'fondo': 10000});
          expect(abrir.statusCode, 201);

          final p1Res = await s.post('/api/v1/productos', {
            'codigo': '75010001',
            'nombre': 'Corona Mega',
            'categoria': 'cerveza',
            'precio': 4500,
            'precioCaja': 50000,
            'piezasPorCaja': 12,
            'existenciaPiezas': 0,
            'minimo': 6,
          });
          expect(p1Res.statusCode, 201);

          final p2Res = await s.post('/api/v1/productos', {
            'codigo': '75010002',
            'nombre': 'Victoria Media',
            'categoria': 'cerveza',
            'precio': 2500,
            'precioCaja': 54000,
            'piezasPorCaja': 24,
            'existenciaPiezas': 27,
            'minimo': 5,
          });
          expect(p2Res.statusCode, 201);
          final p2 = Producto.fromJson(
            jsonDecode(p2Res.body) as Map<String, Object?>,
          );

          final p3Res = await s.post('/api/v1/productos', {
            'codigo': '75010003',
            'nombre': 'Hielo',
            'categoria': 'hielo',
            'precio': 3000,
            'existenciaPiezas': 30,
            'minimo': 5,
          });
          expect(p3Res.statusCode, 201);

          // Registrar venta de 12 piezas de Victoria Media -> quedan 15 piezas.
          final ventaRes = await s.post(
            '/api/v1/ventas',
            {
              'metodo': 'efectivo',
              'recibido': 50000,
              'lineas': [
                {'productoId': p2.id, 'unidad': 'pieza', 'cantidad': 12},
              ],
            },
            cabeceras: {'x-clave-idempotencia': 'v-resurtido-1'},
          );
          expect(ventaRes.statusCode, 201);

          // Registrar otra venta y cancelarla: no debe contar en resurtido.
          final ventaCancRes = await s.post(
            '/api/v1/ventas',
            {
              'metodo': 'efectivo',
              'recibido': 50000,
              'lineas': [
                {'productoId': p2.id, 'unidad': 'pieza', 'cantidad': 5},
              ],
            },
            cabeceras: {'x-clave-idempotencia': 'v-resurtido-2'},
          );
          expect(ventaCancRes.statusCode, 201);
          final ventaCanc =
              jsonDecode(ventaCancRes.body) as Map<String, Object?>;
          final cancRes = await s.post(
            '/api/v1/ventas/${ventaCanc['id']}/cancelar',
            {'destino': 'inventario'},
          );
          expect(cancRes.statusCode, 204);

          final res = await s.get(
            '/api/v1/reportes/resurtido?dias=7&cobertura=14',
          );
          expect(res.statusCode, 200);
          final reporte = ReporteResurtido.fromJson(
            jsonDecode(res.body) as Map<String, Object?>,
          );

          expect(reporte.dias, 7);
          expect(reporte.cobertura, 14);
          // Corona Mega (agotado) y Victoria Media (12 * 14 / 7 = 24, tiene 15 -> faltan 9).
          expect(reporte.sugerencias.length, 2);

          final s0 = reporte.sugerencias[0];
          expect(s0.producto.nombre, 'Corona Mega');
          expect(s0.urgencia, UrgenciaResurtido.agotado);
          expect(s0.sugeridoPiezas, 6);
          expect(s0.sugeridoCajas, 1);

          final s1 = reporte.sugerencias[1];
          expect(s1.producto.nombre, 'Victoria Media');
          expect(s1.urgencia, UrgenciaResurtido.porCubrir);
          expect(s1.vendidasPeriodo, 12);
          expect(s1.sugeridoPiezas, 9);
          expect(s1.sugeridoCajas, 1);
        } finally {
          await s.cerrar();
        }
      },
    );

    test('rechaza parámetros inválidos y peticiones de terminal', () async {
      final s = await crearServidorDePrueba(datosEjemplo: false);
      try {
        final claveTerm = await s.registrarTerminal();
        final rTerm = await s.get(
          '/api/v1/reportes/resurtido',
          clave: claveTerm,
        );
        expect(rTerm.statusCode, 403);

        final rMal = await s.get(
          '/api/v1/reportes/resurtido?dias=0&cobertura=99',
        );
        expect(rMal.statusCode, 400);
      } finally {
        await s.cerrar();
      }
    });
  });
}
