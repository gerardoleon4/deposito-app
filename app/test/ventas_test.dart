import 'package:deposito_app/core/api/api_falsa.dart';
import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudantes.dart';

/// Ventas con el diseño de Pablo, contra ApiFalsa.
void main() {
  /// Cobra 2 hielos (p_4, $35 c/u) en efectivo como lo haría la caja.
  Future<ApiFalsa> conUnaVenta([ApiFalsa? api]) async {
    api ??= ApiFalsa();
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

  int existenciaHielo(ApiFalsa api) =>
      api.productos.singleWhere((p) => p.id == 'p_4').existenciaPiezas;

  Future<void> abrirVentas(WidgetTester tester, ApiFalsa api) async {
    await montarApp(tester, preferencias: prefsCaja, api: api);
    await tester.tap(find.text('Ventas').first);
    await tester.pumpAndSettle();
  }

  Future<void> abrirTicket(WidgetTester tester) async {
    await tester.tap(find.text('#1001').first);
    await tester.pumpAndSettle();
  }

  testWidgets('sin ventas lo dice', (tester) async {
    await abrirVentas(tester, ApiFalsa());
    expect(find.text('Transacciones del Turno'), findsOneWidget);
    expect(find.text('Todavía no hay ventas'), findsOneWidget);
  });

  testWidgets('lista las ventas del turno y muestra su ticket', (tester) async {
    await abrirVentas(tester, await conUnaVenta());
    expect(find.text('1 tickets'), findsOneWidget);

    await abrirTicket(tester);
    expect(find.text('DESGLOSE DE ARTÍCULOS'), findsOneWidget);
    expect(find.text('Hielo en bolsa'), findsOneWidget);
    expect(find.text(r'$100'), findsOneWidget); // recibido
    expect(find.text(r'$30'), findsOneWidget); // cambio

    await tester.tap(find.text('Tarjeta'));
    await tester.pumpAndSettle();
    expect(find.text('No se encontraron transacciones'), findsOneWidget);

    await tester.tap(find.text('Todos los pagos'));
    await tester.enterText(find.byType(TextField), '999');
    await tester.pumpAndSettle();
    expect(find.text('No se encontraron transacciones'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '#1001');
    await tester.pumpAndSettle();
    expect(find.text('No se encontraron transacciones'), findsNothing);
  });

  testWidgets('devolver un hielo a merma y luego cancelar el resto', (
    tester,
  ) async {
    final api = await conUnaVenta();
    await abrirVentas(tester, api);
    await abrirTicket(tester);
    expect(existenciaHielo(api), 16);

    // Devolución parcial: 1 de 2, como merma (no regresa a existencias).
    await tester.tap(find.text('Cancelar Venta'));
    await tester.pumpAndSettle();
    expect(find.text('Seleccione los artículos a devolver'), findsOneWidget);
    expect(find.text(r'$70'), findsWidgets);
    await tester.tap(find.byTooltip('Menos'));
    await tester.pump();
    expect(find.text(r'$35'), findsWidgets);
    await tester.tap(find.text('Continuar Cancelación'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registrar como Merma'));
    await tester.pumpAndSettle();

    expect(api.detalles.single.devuelto, 3500);
    expect(api.detalles.single.cancelada, isFalse);
    expect(existenciaHielo(api), 16, reason: 'la merma no regresa');
    expect(find.text('DEVOLUCIÓN PARCIAL'), findsOneWidget);

    // Cancelar lo que falta: regresa al inventario. Antes se va el aviso,
    // que tapa los botones de abajo.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar Venta'));
    await tester.pumpAndSettle();
    expect(find.text('Cancelación completa'), findsOneWidget);
    await tester.tap(find.text('Continuar Cancelación'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Regresar al Inventario'));
    await tester.pumpAndSettle();

    expect(api.detalles.single.cancelada, isTrue);
    expect(api.detalles.single.devuelto, 7000);
    expect(existenciaHielo(api), 17);
    expect(find.text('Ya Cancelado'), findsOneWidget);
  });

  testWidgets('con un dueño registrado, cancelar pide su PIN', (tester) async {
    final api = ApiFalsa();
    await api.crearUsuario(nombre: 'Don Beto', rol: 'dueno', pin: '9999');
    await api.crearUsuario(
      nombre: 'Ana',
      rol: 'cajero',
      pin: '1111',
      pinAutoriza: '9999',
    );
    await conUnaVenta(api);
    await montarApp(tester, preferencias: prefsCaja, api: api);
    // Hay personal: primero el inicio de turno.
    expect(find.text('Selecciona tu usuario para comenzar'), findsOneWidget);
    await tester.tap(find.text('Ana'));
    await tester.pumpAndSettle();
    for (final d in '1111'.split('')) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ventas').first);
    await tester.pumpAndSettle();
    await abrirTicket(tester);

    await tester.tap(find.text('Cancelar Venta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar Cancelación'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Regresar al Inventario'));
    await tester.pumpAndSettle();
    expect(find.text('Autorización Requerida'), findsOneWidget);

    Future<void> teclear(String pin) async {
      for (final d in pin.split('')) {
        await tester.tap(find.text(d).last);
        await tester.pump();
      }
      await tester.tap(find.text('Autorizar'));
      await tester.pumpAndSettle();
    }

    await teclear('1111');
    expect(find.textContaining('PIN de cajero'), findsOneWidget);
    expect(api.detalles.single.cancelada, isFalse);

    await teclear('9999');
    expect(api.detalles.single.cancelada, isTrue);
    expect(
      api.detalles.single.devoluciones.single.autorizo?.nombre,
      'Don Beto',
    );
  });

  testWidgets('en el teléfono la lista abre el ticket en otra pantalla', (
    tester,
  ) async {
    await montarApp(
      tester,
      preferencias: prefsCaja,
      api: await conUnaVenta(),
      tamano: const Size(390, 844),
    );
    await tester.tap(find.text('Ventas').last);
    await tester.pumpAndSettle();
    await abrirTicket(tester);
    expect(find.text('Detalle de Venta #1001'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
