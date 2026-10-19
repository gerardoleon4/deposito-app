import 'package:deposito_app/core/api/api_falsa.dart';
import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudantes.dart';

/// Envases con el diseño de Pablo, contra ApiFalsa.
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

    // 84 + 240 + 168 en bodega y nada prestado (balanceDePrueba).
    expect(find.text('Control de Envases Retornables'), findsOneWidget);
    expect(find.text('492'), findsOneWidget);
    expect(
      find.text('100% del inventario total bajo resguardo'),
      findsOneWidget,
    );
    expect(find.text(r'$8 c/u'), findsOneWidget); // depósito del mega
    expect(find.text('Préstamos (0)'), findsOneWidget);
    expect(find.text('No hay movimientos registrados'), findsOneWidget);
  });

  testWidgets('prestar saca vacíos de bodega y guarda el teléfono', (
    tester,
  ) async {
    final api = ApiFalsa();
    await abrirEnvases(tester, api);

    await tester.tap(find.text('Prestar'));
    await tester.pumpAndSettle();
    expect(find.text('Registro de Préstamo'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(
            find.ancestor(
              of: find.text('Guardar Préstamo'),
              matching: find.byWidgetPredicate((w) => w is ElevatedButton),
            ),
          )
          .onPressed,
      isNull,
      reason: 'Sin nombre no se puede guardar',
    );
    await tester.tap(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.text('Mega 1.2 L'),
      ),
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(0), 'Don Pedro');
    await tester.enterText(find.byType(TextField).at(1), '55 1234 5678');
    await tester.pump();
    await tester.tap(find.text('Guardar Préstamo'));
    await tester.pumpAndSettle();

    final p = api.prestamos.single;
    expect(
      (p.cliente, p.telefono, p.formato, p.cantidad),
      ('Don Pedro', '55 1234 5678', 'mega', 2),
    );
    expect(api.envases['mega']!.bodega, 82);
    expect(api.envases['mega']!.prestados, 2);
    expect(find.text('Préstamo a cliente'), findsOneWidget); // bitácora
  });

  testWidgets('recibir un préstamo por partes', (tester) async {
    final api = ApiFalsa(
      prestamos: [
        const PrestamoEnvase(
          id: 'pre_1',
          cliente: 'Taquería El Pastor',
          telefono: '55 9876 5432',
          formato: 'media',
          cantidad: 12,
          fecha: '2026-10-01T18:00:00Z',
        ),
      ],
    );
    await abrirEnvases(tester, api);

    await tester.tap(find.text('Préstamos (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Préstamos de Envases Activos'), findsOneWidget);
    expect(find.text('55 9876 5432'), findsOneWidget);

    await tester.ensureVisible(find.text('Recibir'));
    await tester.tap(find.text('Recibir'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pump();
    await tester.tap(find.text('Recibir 11'));
    await tester.pumpAndSettle();

    final p = api.prestamos.single;
    expect((p.cantidad, p.devueltos), (1, 11));
    expect(api.envases['media']!.bodega, 251);
    expect(api.envases['media']!.prestados, 1);
    expect(find.textContaining('le faltan 1'), findsOneWidget);
  });

  testWidgets('recibir vacíos sin venta los suma a bodega', (tester) async {
    final api = ApiFalsa();
    await abrirEnvases(tester, api);

    await tester.tap(find.text('Recibir Vacíos'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    await tester.tap(find.text('Recibir 3 vacíos'));
    await tester.pumpAndSettle();

    expect(api.envases['media']!.bodega, 243);
    expect(find.text('495'), findsOneWidget);
  });

  testWidgets('sacar vacíos pide el motivo', (tester) async {
    final api = ApiFalsa();
    await abrirEnvases(tester, api);

    await tester.tap(find.text('Sacar vacíos'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ElevatedButton>(
            find.ancestor(
              of: find.text('Sacar 1 vacíos'),
              matching: find.byWidgetPredicate((w) => w is ElevatedButton),
            ),
          )
          .onPressed,
      isNull,
    );
    await tester.enterText(find.byType(TextField), 'Rotos');
    await tester.pump();
    await tester.tap(find.text('Sacar 1 vacíos'));
    await tester.pumpAndSettle();

    expect(api.envases['media']!.bodega, 239);
    expect(find.text('Salida de vacíos: Rotos'), findsOneWidget);
  });

  testWidgets('devolver depósito entrega efectivo de la caja', (tester) async {
    final api = ApiFalsa();
    await abrirEnvases(tester, api);

    await tester.tap(find.text('Devolver Depósito'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    await tester.tap(find.text(r'Confirmar y Entregar Efectivo ($6)'));
    await tester.pumpAndSettle();

    expect(api.envases['media']!.bodega, 242);
    final turno = (await api.turnoActual()).turno!;
    expect(turno.resumen.retiros, 600);
    expect(find.text('Devolución de depósito en efectivo'), findsOneWidget);
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
