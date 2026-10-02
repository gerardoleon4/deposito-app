import 'package:deposito_app/core/api/api_falsa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudantes.dart';

void main() {
  testWidgets(
    'sin modo elegido muestra la bienvenida y al elegir Caja abre el tablero',
    (tester) async {
      await montarApp(tester);
      expect(find.text('Punto de venta\ndel depósito'), findsOneWidget);

      await tester.tap(find.text('Caja'));
      await tester.pumpAndSettle();

      expect(find.text('Anaquel'), findsOneWidget); // menú lateral
      expect(find.text('Necesita atención'), findsOneWidget);
      // Corona Mega tiene 30 piezas con mínimo 36.
      expect(find.text('Corona Mega'), findsWidgets);
    },
  );

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
}
