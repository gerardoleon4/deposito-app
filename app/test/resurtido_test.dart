import 'package:deposito_app/core/api/api_falsa.dart';
import 'package:deposito_app/features/resurtido/datos/pedido_proveedor_pdf.dart';
import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudantes.dart';

void main() {
  testWidgets('Resurtido muestra sugerencias, permite ajustar y armar texto', (
    tester,
  ) async {
    final api = ApiFalsa(
      productos: [
        Producto(
          id: 'p_agotado',
          codigo: '7501',
          nombre: 'Corona Mega',
          categoria: 'cerveza',
          precio: 4500,
          precioCaja: 50000,
          piezasPorCaja: 12,
          existenciaPiezas: 0,
          minimo: 6,
          creado: '2026-10-01T12:00:00Z',
          actualizado: '2026-10-01T12:00:00Z',
        ),
      ],
    );

    await montarApp(tester, preferencias: prefsCaja, api: api);
    await tester.tap(find.text('Resurtido').first);
    await tester.pumpAndSettle();

    expect(find.text('Corona Mega'), findsOneWidget);
    expect(find.text('Agotado'), findsOneWidget);
    expect(find.text('1 producto en el pedido'), findsOneWidget);

    await tester.tap(find.byTooltip('Aumentar'));
    await tester.pump();

    expect(find.text('2'), findsOneWidget);

    final texto = textoPedidoProveedor(
      [
        (
          sugerencia: SugerenciaResurtido(
            producto: api.productos.first,
            vendidasPeriodo: 12,
            sugeridoPiezas: 6,
            sugeridoCajas: 2,
            urgencia: UrgenciaResurtido.agotado,
          ),
          cantidad: 2,
          porCaja: true,
        ),
      ],
      dia: '2026-11-24',
      negocio: const AjustesNegocio(nombreNegocio: 'Modelorama Oaxaca'),
    );
    expect(texto, contains('Corona Mega: 2 cajas'));
  });
}
