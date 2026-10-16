import 'package:deposito_app/app/tema/tema.dart';
import 'package:deposito_app/features/ventas/datos/modelos_ventas.dart';
import 'package:deposito_app/features/ventas/estado/ventas_provider.dart';
import 'package:deposito_app/features/ventas/pantallas/detalle_ticket.dart';
import 'package:deposito_app/features/ventas/pantallas/lista_transacciones.dart';
import 'package:deposito_app/features/ventas/pantallas/modal_autorizacion_numpad.dart';
import 'package:deposito_app/features/ventas/pantallas/modal_destino_stock.dart';
import 'package:deposito_app/features/ventas/pantallas/modal_reimpresion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _envoltura({required Widget child, ProviderContainer? container}) {
  return UncontrolledProviderScope(
    container: container ?? ProviderContainer(),
    child: MaterialApp(
      theme: temaClaro(),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('6. Ventas y Transacciones - Pruebas de Estado y Lógica', () {
    test('Estado inicial contiene tickets de ejemplo ordenados', () {
      final container = ProviderContainer();
      final estado = container.read(ventasProvider);

      expect(estado.tickets.isNotEmpty, isTrue);
      expect(estado.tickets.first.folio, '#T-1042');
      expect(estado.ticketSeleccionado?.folio, '#T-1042');
    });

    test('Filtro por método de pago funciona correctamente', () {
      final container = ProviderContainer();

      // Filtrar por tarjeta
      container
          .read(ventasProvider.notifier)
          .filtrarPorMetodo(MetodoPagoTicket.tarjeta);
      var estado = container.read(ventasProvider);
      expect(
        estado.ticketsFiltrados.every(
          (t) => t.metodoPago == MetodoPagoTicket.tarjeta,
        ),
        isTrue,
      );

      // Filtrar por efectivo
      container
          .read(ventasProvider.notifier)
          .filtrarPorMetodo(MetodoPagoTicket.efectivo);
      estado = container.read(ventasProvider);
      expect(
        estado.ticketsFiltrados.every(
          (t) => t.metodoPago == MetodoPagoTicket.efectivo,
        ),
        isTrue,
      );
    });

    test('Búsqueda por folio y monto filtra la lista en tiempo real', () {
      final container = ProviderContainer();

      container.read(ventasProvider.notifier).buscar('#T-1041');
      var estado = container.read(ventasProvider);
      expect(estado.ticketsFiltrados.length, 1);
      expect(estado.ticketsFiltrados.first.folio, '#T-1041');

      container.read(ventasProvider.notifier).buscar('88');
      estado = container.read(ventasProvider);
      expect(estado.ticketsFiltrados.any((t) => t.folio == '#T-1041'), isTrue);
    });

    test(
      'cancelarTicket actualiza estado a cancelado y registra destino y reembolso',
      () {
        final container = ProviderContainer();

        container
            .read(ventasProvider.notifier)
            .cancelarTicket(
              ticketId: 't-1042',
              destino: DestinoStock.regresarInventario,
              montoReembolso: 58.0,
              motivo: 'Cliente solicitó devolución',
            );

        final estado = container.read(ventasProvider);
        final ticketCancelado = estado.tickets.firstWhere(
          (t) => t.id == 't-1042',
        );

        expect(ticketCancelado.esCancelado, isTrue);
        expect(ticketCancelado.destinoStock, DestinoStock.regresarInventario);
        expect(ticketCancelado.montoReembolsado, 58.0);
      },
    );
  });

  group('6.1 Lista de Transacciones - Widget Tests', () {
    testWidgets(
      'Muestra cabecera, buscador, chips de pago y tickets con badges',
      (tester) async {
        await tester.pumpWidget(_envoltura(child: const ListaTransacciones()));
        await tester.pumpAndSettle();

        expect(find.text('Transacciones del Día'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Todos los pagos'), findsOneWidget);
        expect(find.text('Efectivo'), findsWidgets);
        expect(find.text('Tarjeta'), findsWidgets);
        expect(find.text('#T-1042'), findsWidgets);
        expect(find.text('Cancelado'), findsWidgets);
      },
    );
  });

  group('6.2 Detalle de Ticket - Widget Tests', () {
    testWidgets('Muestra desglose de productos y botones fijos inferiores', (
      tester,
    ) async {
      final ticketPrueba = TicketTransaccion(
        id: 'test-1',
        folio: '#T-9999',
        fecha: DateTime.now(),
        metodoPago: MetodoPagoTicket.efectivo,
        subtotal: 40.0,
        total: 40.0,
        cajero: 'Cajero Prueba',
        items: [
          ItemTicket(
            id: 'item-1',
            nombre: 'Corona Extra',
            precioUnitario: 20.0,
            cantidad: 2,
          ),
        ],
      );

      await tester.pumpWidget(
        _envoltura(child: DetalleTicket(ticket: ticketPrueba)),
      );
      await tester.pumpAndSettle();

      expect(find.text('#T-9999'), findsOneWidget);
      expect(find.text('Corona Extra'), findsOneWidget);
      expect(find.text('Re-imprimir Recibo'), findsOneWidget);
      expect(find.text('Cancelar Venta'), findsOneWidget);
    });
  });

  group('6.3 Modal de Re-impresión - Widget Tests', () {
    testWidgets('Muestra opciones de terminal térmica y compartir PDF', (
      tester,
    ) async {
      final ticketPrueba = TicketTransaccion(
        id: 'test-1',
        folio: '#T-9999',
        fecha: DateTime.now(),
        metodoPago: MetodoPagoTicket.efectivo,
        subtotal: 40.0,
        total: 40.0,
        cajero: 'Cajero Prueba',
        items: [],
      );

      await tester.pumpWidget(
        _envoltura(
          child: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => ModalReimpresion.mostrar(
                  context: ctx,
                  ticket: ticketPrueba,
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Opciones de recibo'), findsOneWidget);
      expect(find.text('Imprimir en terminal térmica'), findsOneWidget);
      expect(find.text('Compartir PDF / WhatsApp'), findsOneWidget);
    });
  });

  group('6.5 Modal Destino de Stock - Widget Tests', () {
    testWidgets('Muestra opciones forzosas de Regresar al Inventario y Merma', (
      tester,
    ) async {
      await tester.pumpWidget(
        _envoltura(child: const ModalDestinoStock(totalArticulosDevueltos: 3)),
      );
      await tester.pumpAndSettle();

      expect(find.text('¿Qué pasará con estos artículos?'), findsOneWidget);
      expect(find.text('Regresar al Inventario'), findsOneWidget);
      expect(find.text('Registrar como Merma'), findsOneWidget);
    });
  });

  group('6.6 Modal Autorización Numpad - Widget Tests', () {
    testWidgets('Muestra título de Gerente o Dueño y numpad numérico', (
      tester,
    ) async {
      await tester.pumpWidget(
        _envoltura(child: ModalAutorizacionNumpad(alAutorizar: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('Autorización Requerida'), findsOneWidget);
      expect(
        find.text('Esta acción requiere permisos de Gerente o Dueño'),
        findsOneWidget,
      );
      expect(find.text('5'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
    });
  });
}
