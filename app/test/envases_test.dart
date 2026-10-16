import 'package:deposito_app/core/api/api_falsa.dart';
import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudantes.dart';

void main() {
  Future<void> abrirEnvases(WidgetTester tester, ApiFalsa api) async {
    await montarApp(tester, preferencias: prefsCaja, api: api);
    await tester.tap(find.text('Envases').first);
    await tester.pumpAndSettle();
  }

  testWidgets('el tablero muestra el balance que da el servidor', (
    tester,
  ) async {
    await abrirEnvases(tester, ApiFalsa());

    // 84 + 240 + 168 en bodega y 36 + 48 + 24 prestados (balanceDePrueba).
    expect(find.text('492'), findsOneWidget);
    expect(find.text('108'), findsOneWidget);
    expect(find.text(r'$8 c/u'), findsOneWidget); // depósito del mega
    expect(find.text('No hay envases prestados'), findsOneWidget);
  });

  testWidgets('prestar registra el préstamo en el servidor', (tester) async {
    final api = ApiFalsa();
    await abrirEnvases(tester, api);

    await tester.tap(find.text('Prestar'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(
            find.ancestor(
              of: find.text('Guardar préstamo'),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed,
      isNull,
      reason: 'Sin nombre no se puede guardar',
    );
    await tester.enterText(find.byType(TextField), 'Don Pedro');
    await tester.tap(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.text('Mega 1.2 L'),
      ),
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar préstamo'));
    await tester.pumpAndSettle();

    final p = api.prestamos.single;
    expect((p.cliente, p.formato, p.cantidad), ('Don Pedro', 'mega', 2));
    expect(api.envases['mega']!.prestados, 38);
    expect(find.text('Don Pedro'), findsOneWidget);
  });

  testWidgets('recibir un préstamo lo salda y los vacíos entran a bodega', (
    tester,
  ) async {
    final api = ApiFalsa(
      prestamos: [
        const PrestamoEnvase(
          id: 'pre_1',
          cliente: 'Taquería El Pastor',
          formato: 'media',
          cantidad: 12,
          fecha: '2026-10-01T18:00:00Z',
        ),
      ],
    );
    await abrirEnvases(tester, api);

    await tester.tap(find.text('Recibir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recibir 12'));
    await tester.pumpAndSettle();

    expect(api.prestamos, isEmpty);
    expect(api.envases['media']!.bodega, 252);
    expect(api.envases['media']!.prestados, 36);
    expect(find.text('Préstamo de Taquería El Pastor saldado'), findsOneWidget);
  });

  testWidgets('recibir vacíos sin venta los suma a bodega', (tester) async {
    final api = ApiFalsa();
    await abrirEnvases(tester, api);

    await tester.tap(find.text('Recibir vacíos'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recibir 3 a bodega'));
    await tester.pumpAndSettle();

    expect(api.envases['media']!.bodega, 243);
    expect(find.text('495'), findsOneWidget);
  });

  testWidgets('en el teléfono el tablero cabe sin desbordarse', (tester) async {
    await montarApp(
      tester,
      preferencias: prefsCaja,
      tamano: const Size(390, 844),
    );
    await tester.tap(find.text('Envases').last); // barra inferior
    await tester.pumpAndSettle();
    expect(find.text('492'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
