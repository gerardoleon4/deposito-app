import 'package:deposito_app/core/api/api_falsa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudantes.dart';

void main() {
  testWidgets(
    'sin modo elegido muestra la bienvenida y la terminal se vincula',
    (tester) async {
      await montarApp(tester, tamano: const Size(412, 915));
      expect(find.text('Configura tu punto de venta'), findsOneWidget);

      await tester.tap(find.text('Conectar Celular como Terminal'));
      await tester.pumpAndSettle();

      expect(find.text('Vincula esta terminal'), findsOneWidget);
    },
  );

  testWidgets('la caja abre el tablero con lo que necesita atención', (
    tester,
  ) async {
    await montarApp(tester, preferencias: prefsCaja);

    expect(find.text('Anaquel'), findsOneWidget); // menú lateral
    expect(find.text('Necesita atención'), findsOneWidget);
    // Corona Mega tiene 30 piezas con mínimo 36.
    expect(find.text('Corona Mega'), findsWidgets);
  });

  testWidgets('el catálogo filtra por búsqueda sin acentos y por categoría', (
    tester,
  ) async {
    await montarApp(tester, preferencias: prefsCaja);
    await tester.tap(find.text('Catálogo').first);
    await tester.pumpAndSettle();

    expect(find.text('Victoria Mega'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'CORONA');
    await tester.pumpAndSettle();
    expect(find.text('Victoria Mega'), findsNothing);
    expect(find.text('Corona Mega'), findsOneWidget);
    expect(find.text('Corona Cuarto'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Botana'));
    await tester.pumpAndSettle();
    expect(find.text('Papas adobadas'), findsOneWidget);
    expect(find.text('Corona Mega'), findsNothing);
  });

  testWidgets('crear un producto valida el precio en pantalla y lo guarda', (
    tester,
  ) async {
    final api = ApiFalsa();
    await montarApp(tester, preferencias: prefsCaja, api: api);
    await tester.tap(find.text('Catálogo').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nuevo producto'));
    await tester.pumpAndSettle();

    Finder campo(String etiqueta) => find.widgetWithText(TextField, etiqueta);
    await tester.enterText(campo('Código de barras'), '750999');
    await tester.enterText(campo('Nombre'), 'Tecate Light');
    await tester.tap(find.text('Guardar producto'));
    await tester.pumpAndSettle();
    expect(find.text('Escribe el precio, por ejemplo 42.50'), findsOneWidget);
    expect(api.productos.where((p) => p.nombre == 'Tecate Light'), isEmpty);

    await tester.enterText(campo('Precio por pieza'), '23.50');
    await tester.tap(find.text('Guardar producto'));
    await tester.pumpAndSettle();
    final creado = api.productos.singleWhere((p) => p.nombre == 'Tecate Light');
    expect(creado.precio, 2350);
    expect(find.text('Tecate Light quedó en el catálogo'), findsOneWidget);
  });

  testWidgets('la terminal escanea un código y muestra precio y existencia', (
    tester,
  ) async {
    await montarApp(
      tester,
      preferencias: prefsTerminal,
      tamano: const Size(412, 915),
    );
    expect(find.text('Listo para escanear'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '7501064191015');
    await tester.tap(find.text('Buscar'));
    await tester.pumpAndSettle();

    expect(find.text('Victoria Mega'), findsOneWidget);
    expect(find.text(r'$42'), findsOneWidget);
    expect(find.text('Hay 5 cajas + 6 pz'), findsOneWidget);
  });

  testWidgets('un código que no existe lo dice claramente', (tester) async {
    await montarApp(
      tester,
      preferencias: prefsTerminal,
      tamano: const Size(412, 915),
    );
    await tester.enterText(find.byType(TextField), '000');
    await tester.tap(find.text('Buscar'));
    await tester.pumpAndSettle();
    expect(find.text('Código no registrado'), findsOneWidget);
  });

  testWidgets('una terminal sin vincular va a la pantalla de vinculación', (
    tester,
  ) async {
    await montarApp(
      tester,
      preferencias: {'modo': 'terminal'},
      tamano: const Size(412, 915),
    );
    expect(find.text('Vincula esta terminal'), findsOneWidget);
  });

  group('vender', () {
    Future<ApiFalsa> abrirVender(WidgetTester tester) async {
      final api = ApiFalsa();
      await montarApp(tester, preferencias: prefsCaja, api: api);
      await tester.tap(find.text('Vender').first);
      await tester.pumpAndSettle();
      return api;
    }

    testWidgets('cobra con tarjeta, descuenta existencias y vacía la venta', (
      tester,
    ) async {
      final api = await abrirVender(tester);

      await tester.tap(find.text('Hielo en bolsa'));
      await tester.tap(find.text('Hielo en bolsa'));
      await tester.pumpAndSettle();
      expect(find.text(r'$70'), findsNWidgets(2)); // renglón y total: 2 x $35

      await tester.tap(find.text('Cobrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar y pagar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tarjeta'));
      // La pantalla de tarjeta tiene una animación que no termina.
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.tap(find.text('Pago aprobado'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Venta 1001 registrada'), findsOneWidget);
      final venta = api.ventas.values.single;
      expect(venta.total, 7000);
      expect(venta.metodo, 'tarjeta');
      final hielo = api.productos.singleWhere((p) => p.id == 'p_4');
      expect(hielo.existenciaPiezas, 16);

      await tester.tap(find.text('Nueva venta'));
      await tester.pumpAndSettle();
      expect(find.text('Aún no hay productos en la venta'), findsOneWidget);
    });

    testWidgets('vende una caja al precio de caja y cobra en efectivo', (
      tester,
    ) async {
      final api = await abrirVender(tester);

      await tester.tap(find.text('Victoria Mega'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vender 1 caja (12 pz)'));
      await tester.pumpAndSettle();
      expect(find.text('Victoria Mega (caja)'), findsOneWidget);

      await tester.tap(find.text('Cobrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar y pagar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Efectivo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(r'$500'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cobrar'));
      await tester.pumpAndSettle();
      expect(find.text(r'$20'), findsOneWidget); // cambio de $500 - $480
      await tester.tap(find.text('Cerrar venta'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      final venta = api.ventas.values.single;
      expect(venta.total, 48000);
      expect(venta.recibido, 50000);
      expect(venta.cambio, 2000);
      final victoria = api.productos.singleWhere((p) => p.id == 'p_1');
      expect(victoria.existenciaPiezas, 66 - 12);
    });

    testWidgets('no deja vender más de lo que hay', (tester) async {
      await abrirVender(tester);

      // Hielo: 18 piezas.
      for (var i = 0; i < 19; i++) {
        await tester.tap(find.text('Hielo en bolsa'));
      }
      await tester.pumpAndSettle();

      expect(find.text('Solo hay 18 piezas de Hielo en bolsa'), findsOneWidget);
    });
  });
}
