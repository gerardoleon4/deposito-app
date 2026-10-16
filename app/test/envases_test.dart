import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deposito_app/app/tema/tema.dart';
import 'package:deposito_app/features/caja/estado/movimientos_caja_provider.dart';
import 'package:deposito_app/features/envases/datos/modelos_envases.dart';
import 'package:deposito_app/features/envases/estado/envases_provider.dart';
import 'package:deposito_app/features/envases/pantallas/dashboard_envases.dart';
import 'package:deposito_app/features/envases/pantallas/historial_prestamos.dart';
import 'package:deposito_app/features/envases/pantallas/modal_recepcion_envases.dart';
import 'package:deposito_app/features/envases/pantallas/modal_registro_prestamo.dart';
import 'package:deposito_app/features/envases/pantallas/modal_retorno_deposito.dart';
import 'package:deposito_app/features/envases/pantallas/modal_salida_envases.dart';

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
  group('5. Control de Envases - Pruebas de Estado y Lógica', () {
    test(
      'Estado inicial calcula métricas de almacén y calle correctamente',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final estado = container.read(envasesProvider);

        expect(estado.totalAlmacen, greaterThan(0));
        expect(estado.totalCalle, greaterThan(0));
        expect(
          estado.totalGlobal,
          equals(estado.totalAlmacen + estado.totalCalle),
        );
        expect(estado.porcentajeCirculante, inInclusiveRange(0.0, 1.0));
        expect(estado.prestamosActivos.isNotEmpty, isTrue);
      },
    );

    test('registrarRecepcionVacios incrementa inventario en almacén', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(envasesProvider.notifier);
      final antes = container
          .read(envasesProvider)
          .stocks[TipoFormatoEnvase.media]!
          .enAlmacen;

      notifier.registrarRecepcionVacios(
        cantidad: 10,
        formato: TipoFormatoEnvase.media,
        creditoTotal: 50.0,
      );

      final despues = container
          .read(envasesProvider)
          .stocks[TipoFormatoEnvase.media]!
          .enAlmacen;
      expect(despues, equals(antes + 10));
    });

    test(
      'registrarPrestamo añade préstamo y actualiza existencias en calle',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(envasesProvider.notifier);
        final calleAntes = container
            .read(envasesProvider)
            .stocks[TipoFormatoEnvase.mega]!
            .enCalle;

        notifier.registrarPrestamo(
          cliente: 'Carlos Slim',
          telefono: '55 0000 1111',
          cantidad: 5,
          formato: TipoFormatoEnvase.mega,
        );

        final estado = container.read(envasesProvider);
        final calleDespues = estado.stocks[TipoFormatoEnvase.mega]!.enCalle;

        expect(calleDespues, equals(calleAntes + 5));
        expect(
          estado.prestamosActivos.any(
            (p) => p.cliente == 'Carlos Slim' && p.cantidad == 5,
          ),
          isTrue,
        );
      },
    );

    test(
      'registrarDevolucionDeposito impacta Movimientos de Caja como retiro',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final saldoCajaAntes = container
            .read(movimientosCajaProvider)
            .saldoEstimado;
        final envasesNotifier = container.read(envasesProvider.notifier);

        envasesNotifier.registrarRetornoYReembolso(
          cantidad: 6,
          formato: TipoFormatoEnvase.media,
          montoReembolso: 30.0,
        );

        final saldoCajaDespues = container
            .read(movimientosCajaProvider)
            .saldoEstimado;
        expect(saldoCajaDespues, equals(saldoCajaAntes - 30.0));

        final ultimoMovimiento = container
            .read(movimientosCajaProvider)
            .movimientos
            .first;
        expect(ultimoMovimiento.esIngreso, isFalse);
        expect(ultimoMovimiento.monto, equals(30.0));
        expect(ultimoMovimiento.motivo, contains('Devolución'));
      },
    );
  });

  group('5.1 Dashboard de Envases - Widget Tests', () {
    testWidgets(
      'Muestra cabecera, métricas de almacén y calle, y movimientos',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_envoltura(child: const DashboardEnvases()));
        await tester.pumpAndSettle();

        expect(find.text('Control de Envases Retornables'), findsOneWidget);
        expect(find.text('Envases Físicos en Almacén'), findsOneWidget);
        expect(find.text('Envases en la Calle (Prestados)'), findsOneWidget);
        expect(
          find.text('Últimos Movimientos de Entrada y Salida'),
          findsOneWidget,
        );
        expect(find.textContaining('Préstamos'), findsWidgets);
        expect(find.text('Devolver Depósito'), findsOneWidget);
      },
    );
  });

  group('5.2 Modal Recepción de Vacíos - Widget Tests', () {
    testWidgets('Permite aumentar y disminuir cantidad y aplicar crédito', (
      tester,
    ) async {
      int? cantidadConfirmada;
      double? creditoConfirmado;

      await tester.pumpWidget(
        _envoltura(
          child: ModalRecepcionEnvases(
            cantidadInicial: 2,
            alConfirmar: (cant, form, cred) {
              cantidadConfirmada = cant;
              creditoConfirmado = cred;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recepción de Envases Vacíos'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // Tocar botón [+]
      final masBtn = find.byIcon(Icons.add_rounded);
      await tester.tap(masBtn);
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);

      // Confirmar crédito
      final btnAplicar = find.textContaining('Aplicar Crédito al Ticket');
      expect(btnAplicar, findsOneWidget);
      await tester.tap(btnAplicar);
      await tester.pumpAndSettle();

      expect(cantidadConfirmada, equals(3));
      expect(creditoConfirmado, greaterThan(0));
    });
  });

  group('5.3 Modal Salida de Envases - Widget Tests', () {
    testWidgets('Muestra las 3 opciones principales de manejo de envases', (
      tester,
    ) async {
      await tester.pumpWidget(
        _envoltura(child: const ModalSalidaEnvases(cantidadRetornables: 4)),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('¿Cómo se manejan los envases de esta compra?'),
        findsOneWidget,
      );
      expect(find.text('Cobrar depósito del envase'), findsOneWidget);
      expect(find.text('El cliente entregó vacíos'), findsOneWidget);
      expect(find.text('Prestar envases / Fiar'), findsOneWidget);
    });
  });

  group('5.4 Modal Registro de Préstamo (Fiao) - Widget Tests', () {
    testWidgets('Botón Guardar permanece bloqueado hasta ingresar nombre', (
      tester,
    ) async {
      await tester.pumpWidget(
        _envoltura(
          child: ModalRegistroPrestamo(
            cantidadEnvases: 6,
            alGuardar: (cliente, tel) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Registro de Préstamo'), findsOneWidget);
      expect(find.textContaining('Préstamo de 6 envases'), findsOneWidget);

      final btnGuardar = find.widgetWithText(
        ElevatedButton,
        'Guardar Préstamo',
      );
      expect(btnGuardar, findsOneWidget);

      // Verificar que al inicio está deshabilitado
      final botonInicial = tester.widget<ElevatedButton>(btnGuardar);
      expect(botonInicial.onPressed, isNull);

      // Ingresar nombre
      final campoNombre = find.byType(TextField).first;
      await tester.enterText(campoNombre, 'Don Rogelio');
      await tester.pumpAndSettle();

      // Ahora debe estar habilitado
      final botonHabilitado = tester.widget<ElevatedButton>(btnGuardar);
      expect(botonHabilitado.onPressed, isNotNull);
    });
  });

  group('5.5 Historial de Préstamos Activos - Widget Tests', () {
    testWidgets('Permite buscar clientes y muestra botón Recibir', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_envoltura(child: const HistorialPrestamos()));
      await tester.pumpAndSettle();

      expect(find.text('Préstamos de Envases Activos'), findsOneWidget);
      expect(
        find.widgetWithIcon(TextField, Icons.search_rounded),
        findsOneWidget,
      );

      // Verifica préstamos de ejemplo
      expect(find.textContaining('Don Pedro García'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Recibir'), findsWidgets);

      // Filtrar por búsqueda
      final campoBusqueda = find.byType(TextField);
      await tester.enterText(campoBusqueda, 'Taquería');
      await tester.pumpAndSettle();

      expect(find.textContaining('Taquería El Pastor'), findsOneWidget);
      expect(find.textContaining('Don Pedro García'), findsNothing);
    });
  });

  group('5.6 Modal Retorno y Liberación de Depósito - Widget Tests', () {
    testWidgets(
      'Calcula monto a reembolsar y muestra Confirmar y Entregar Efectivo',
      (tester) async {
        await tester.pumpWidget(
          _envoltura(child: const ModalRetornoDeposito(cantidadSugerida: 4)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Retorno de Envases'), findsOneWidget);
        expect(find.textContaining('Monto a reembolsar'), findsOneWidget);
        expect(
          find.textContaining('Confirmar y Entregar Efectivo'),
          findsOneWidget,
        );
      },
    );
  });
}
