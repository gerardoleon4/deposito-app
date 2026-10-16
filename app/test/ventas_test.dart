import 'package:deposito_app/core/api/api_falsa.dart';
import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudantes.dart';

void main() {
  /// Cobra 2 hielos (p_4, $35 c/u) en efectivo como lo haría la caja.
  Future<ApiFalsa> conUnaVenta() async {
    final api = ApiFalsa();
    await api.registrarVenta(
      lineas: [
        const LineaVenta(productoId: 'p_4', porCaja: false, cantidad: 2),
      ],
      metodo: 'efectivo',
      recibido: 10000,
      claveIdempotencia: 'prueba-ventas-1',
    );
    return api;
  }

  Future<void> abrirVentas(WidgetTester tester, ApiFalsa api) async {
    await montarApp(tester, preferencias: prefsCaja, api: api);
    await tester.tap(find.text('Ventas').first);
    await tester.pumpAndSettle();
  }

  testWidgets('sin ventas lo dice', (tester) async {
    await abrirVentas(tester, ApiFalsa());
    expect(find.text('Todavía no hay ventas'), findsOneWidget);
  });

  testWidgets('lista las ventas del servidor y muestra su ticket', (
    tester,
  ) async {
    await abrirVentas(tester, await conUnaVenta());

    expect(find.text('Folio 1001'), findsWidgets); // lista y detalle
    expect(find.text('Hielo en bolsa'), findsOneWidget);
    expect(find.text(r'$70'), findsWidgets);
    expect(find.text(r'$100'), findsOneWidget); // recibido
    expect(find.text(r'$30'), findsOneWidget); // cambio

    await tester.tap(find.text('Tarjeta'));
    await tester.pumpAndSettle();
    expect(find.text('Ninguna venta coincide'), findsOneWidget);

    await tester.tap(find.text('Todas'));
    await tester.enterText(find.byType(TextField), '999');
    await tester.pumpAndSettle();
    expect(find.text('Ninguna venta coincide'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '1001');
    await tester.pumpAndSettle();
    expect(find.text('Ninguna venta coincide'), findsNothing);
  });

  testWidgets('cancelar pide confirmación y regresa las existencias', (
    tester,
  ) async {
    final api = await conUnaVenta();
    await abrirVentas(tester, api);
    expect(
      api.productos.singleWhere((p) => p.id == 'p_4').existenciaPiezas,
      16,
    );

    await tester.tap(find.text('Cancelar venta'));
    await tester.pumpAndSettle();
    expect(find.text('¿Cancelar el folio 1001?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Cancelar venta'));
    await tester.pumpAndSettle();

    expect(api.detalles.single.cancelada, isTrue);
    expect(
      api.productos.singleWhere((p) => p.id == 'p_4').existenciaPiezas,
      18,
    );
    expect(
      find.text('Venta cancelada: las existencias y los envases regresaron.'),
      findsOneWidget,
    );
    expect(find.text('Cancelar venta'), findsNothing);
  });

  testWidgets('en el teléfono el ticket se abre en otra pantalla', (
    tester,
  ) async {
    final api = await conUnaVenta();
    await montarApp(
      tester,
      preferencias: prefsCaja,
      api: api,
      tamano: const Size(390, 844),
    );
    await tester.tap(find.text('Ventas').last); // barra inferior
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Folio 1001'));
    await tester.pumpAndSettle();
    expect(find.text('Hielo en bolsa'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
