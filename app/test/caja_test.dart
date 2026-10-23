import 'package:deposito_app/core/api/api_falsa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudantes.dart';

/// Caja con las pantallas de Pablo (apertura, movimientos, corte, arqueo y
/// recibo de cierre), contra ApiFalsa.
void main() {
  Future<ApiFalsa> abrirCorte(
    WidgetTester tester, {
    bool abierta = false,
  }) async {
    final api = ApiFalsa(cajaAbierta: abierta);
    await montarApp(tester, preferencias: prefsCaja, api: api);
    await tester.tap(find.text('Corte de caja').first);
    await tester.pumpAndSettle();
    return api;
  }

  Future<void> teclear(WidgetTester tester, String digitos) async {
    for (final d in digitos.split('')) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
  }

  Future<void> abrirCon500(WidgetTester tester) async {
    expect(find.text('Apertura de Turno'), findsOneWidget);
    await teclear(tester, '500');
    await tester.tap(find.text('Abrir Caja y Comenzar'));
    await tester.pumpAndSettle();
  }

  testWidgets('abrir, retirar, contar y cerrar el turno', (tester) async {
    final api = await abrirCorte(tester);
    await abrirCon500(tester);
    expect((await api.turnoActual()).turno!.fondo, 50000);
    expect(find.text('Historial de Movimientos'), findsOneWidget);
    expect(find.text(r'$500'), findsWidgets);

    // Retiro de $100 para el hielo.
    await tester.tap(find.text('Registrar Movimiento'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retiro').last);
    await tester.pump();
    await teclear(tester, '100');
    await tester.enterText(find.byType(TextField).last, 'Pago hielo');
    await tester.pump();
    await tester.tap(find.text('Guardar Movimiento'));
    await tester.pumpAndSettle();
    expect(find.text('Pago hielo'), findsOneWidget);
    expect((await api.turnoActual()).turno!.resumen.retiros, 10000);

    // Corte: esperado $400, se cuentan 2 billetes de $200.
    await tester.tap(find.text('Corte de Caja'));
    await tester.pumpAndSettle();
    expect(find.text(r'$400'), findsWidgets);
    await tester.tap(find.text('Proceder a Conteo Físico'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(2), '2'); // $200
    await tester.pump();
    await tester.tap(find.text('Calcular Discrepancia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar y Cerrar Turno'));
    await tester.pumpAndSettle();

    expect(find.text('Ticket de Cierre de Turno'), findsOneWidget);
    final corte = (await api.listarCortes()).single;
    expect((corte.contado, corte.diferencia), (40000, 0));

    await tester.tap(find.text('Finalizar y Salir'));
    await tester.pumpAndSettle();
    expect(find.text('Apertura de Turno'), findsOneWidget);
  });

  testWidgets('con faltante pide la justificación', (tester) async {
    final api = await abrirCorte(tester);
    await abrirCon500(tester);

    await tester.tap(find.text('Corte de Caja'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Proceder a Conteo Físico'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(2), '2'); // $400 de $500
    await tester.pump();
    await tester.tap(find.text('Calcular Discrepancia'));
    await tester.pumpAndSettle();
    expect(find.text('Faltante detectado'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Justificación / Comentarios'),
      'Faltó cambio',
    );
    await tester.pump();
    await tester.tap(find.text('Confirmar y Cerrar Turno'));
    await tester.pumpAndSettle();

    final corte = (await api.listarCortes()).single;
    expect((corte.diferencia, corte.nota), (-10000, 'Faltó cambio'));
    expect(find.text('Faltó cambio'), findsOneWidget);
  });
}
