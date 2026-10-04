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
    skip: true,
  );
}
