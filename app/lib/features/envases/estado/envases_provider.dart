import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../caja/estado/movimientos_caja_provider.dart';
import '../datos/modelos_envases.dart';

class EstadoEnvases {
  final Map<TipoFormatoEnvase, StockEnvases> stocks;
  final List<PrestamoEnvase> prestamos;
  final List<MovimientoEnvase> movimientos;

  const EstadoEnvases({
    required this.stocks,
    required this.prestamos,
    required this.movimientos,
  });

  int get totalAlmacen => stocks.values.fold(0, (sum, s) => sum + s.enAlmacen);

  int get totalCalle => stocks.values.fold(0, (sum, s) => sum + s.enCalle);

  int get totalGlobal => totalAlmacen + totalCalle;

  double get porcentajeCirculante =>
      totalGlobal > 0 ? (totalCalle / totalGlobal) : 0.0;

  List<PrestamoEnvase> get prestamosActivos =>
      prestamos.where((p) => !p.liquidado).toList();

  EstadoEnvases copyWith({
    Map<TipoFormatoEnvase, StockEnvases>? stocks,
    List<PrestamoEnvase>? prestamos,
    List<MovimientoEnvase>? movimientos,
  }) {
    return EstadoEnvases(
      stocks: stocks ?? this.stocks,
      prestamos: prestamos ?? this.prestamos,
      movimientos: movimientos ?? this.movimientos,
    );
  }
}

class EnvasesNotifier extends Notifier<EstadoEnvases> {
  @override
  EstadoEnvases build() {
    return EstadoEnvases(
      stocks: {
        TipoFormatoEnvase.mega: const StockEnvases(
          formato: TipoFormatoEnvase.mega,
          enAlmacen: 84,
          enCalle: 36,
        ),
        TipoFormatoEnvase.media: const StockEnvases(
          formato: TipoFormatoEnvase.media,
          enAlmacen: 240,
          enCalle: 48,
        ),
        TipoFormatoEnvase.cuarto: const StockEnvases(
          formato: TipoFormatoEnvase.cuarto,
          enAlmacen: 168,
          enCalle: 24,
        ),
      },
      prestamos: [
        PrestamoEnvase(
          id: 'p-1',
          cliente: 'Don Pedro García',
          telefono: '55 1234 5678',
          fecha: DateTime.now().subtract(const Duration(days: 10)),
          cantidad: 12,
          formato: TipoFormatoEnvase.media,
        ),
        PrestamoEnvase(
          id: 'p-2',
          cliente: 'Taquería El Pastor',
          telefono: '55 9876 5432',
          fecha: DateTime.now().subtract(const Duration(days: 8)),
          cantidad: 24,
          formato: TipoFormatoEnvase.mega,
        ),
        PrestamoEnvase(
          id: 'p-3',
          cliente: 'Juan Carlos Mendoza',
          telefono: '55 4567 8901',
          fecha: DateTime.now().subtract(const Duration(days: 2)),
          cantidad: 6,
          formato: TipoFormatoEnvase.media,
        ),
        PrestamoEnvase(
          id: 'p-4',
          cliente: 'Doña Martha Ruiz',
          telefono: '55 2345 6789',
          fecha: DateTime.now().subtract(const Duration(hours: 4)),
          cantidad: 4,
          formato: TipoFormatoEnvase.cuarto,
        ),
      ],
      movimientos: [
        MovimientoEnvase(
          id: 'm-1',
          fecha: DateTime.now().subtract(const Duration(minutes: 25)),
          esEntrada: true,
          cantidad: 6,
          formato: TipoFormatoEnvase.media,
          concepto: 'Recepción de vacíos en venta',
          cliente: 'Cliente Mostrador',
        ),
        MovimientoEnvase(
          id: 'm-2',
          fecha: DateTime.now().subtract(const Duration(hours: 4)),
          esEntrada: false,
          cantidad: 4,
          formato: TipoFormatoEnvase.cuarto,
          concepto: 'Préstamo de envases registrado',
          cliente: 'Doña Martha Ruiz',
        ),
        MovimientoEnvase(
          id: 'm-3',
          fecha: DateTime.now().subtract(const Duration(hours: 6)),
          esEntrada: true,
          cantidad: 12,
          formato: TipoFormatoEnvase.media,
          concepto: 'Devolución de depósito en efectivo',
          montoEfectivo: 60.0,
          cliente: 'Vecino Don José',
        ),
        MovimientoEnvase(
          id: 'm-4',
          fecha: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
          esEntrada: false,
          cantidad: 8,
          formato: TipoFormatoEnvase.mega,
          concepto: 'Cobro de depósito en venta',
        ),
        MovimientoEnvase(
          id: 'm-5',
          fecha: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
          esEntrada: true,
          cantidad: 24,
          formato: TipoFormatoEnvase.media,
          concepto: 'Recepción de vacíos por intercambio',
        ),
      ],
    );
  }

  /// 5.2: Aplica recepción de envases vacíos (sumando al almacén)
  void registrarRecepcionVacios({
    required int cantidad,
    TipoFormatoEnvase formato = TipoFormatoEnvase.media,
    double creditoTotal = 0.0,
    String? cliente,
  }) {
    if (cantidad <= 0) return;

    final actual =
        state.stocks[formato] ??
        StockEnvases(formato: formato, enAlmacen: 0, enCalle: 0);

    final nuevosStocks = Map<TipoFormatoEnvase, StockEnvases>.from(
      state.stocks,
    );
    nuevosStocks[formato] = StockEnvases(
      formato: formato,
      enAlmacen: actual.enAlmacen + cantidad,
      enCalle: actual.enCalle,
    );

    final nuevoMov = MovimientoEnvase(
      id: 'm-${DateTime.now().millisecondsSinceEpoch}',
      fecha: DateTime.now(),
      esEntrada: true,
      cantidad: cantidad,
      formato: formato,
      concepto:
          'Recepción de vacíos (Crédito ticket \$${creditoTotal.toStringAsFixed(2)})',
      cliente: cliente,
    );

    state = state.copyWith(
      stocks: nuevosStocks,
      movimientos: [nuevoMov, ...state.movimientos],
    );
  }

  /// 5.4: Registra préstamo de envases (disminuye almacén, suma a la calle)
  void registrarPrestamo({
    required String cliente,
    String? telefono,
    required int cantidad,
    TipoFormatoEnvase formato = TipoFormatoEnvase.media,
  }) {
    if (cantidad <= 0 || cliente.trim().isEmpty) return;

    final actual =
        state.stocks[formato] ??
        StockEnvases(formato: formato, enAlmacen: 0, enCalle: 0);

    final nuevosStocks = Map<TipoFormatoEnvase, StockEnvases>.from(
      state.stocks,
    );
    nuevosStocks[formato] = StockEnvases(
      formato: formato,
      enAlmacen: (actual.enAlmacen - cantidad).clamp(0, 999999),
      enCalle: actual.enCalle + cantidad,
    );

    final nuevoPrestamo = PrestamoEnvase(
      id: 'p-${DateTime.now().millisecondsSinceEpoch}',
      cliente: cliente.trim(),
      telefono: telefono?.trim(),
      fecha: DateTime.now(),
      cantidad: cantidad,
      formato: formato,
    );

    final nuevoMov = MovimientoEnvase(
      id: 'm-${DateTime.now().millisecondsSinceEpoch}',
      fecha: DateTime.now(),
      esEntrada: false,
      cantidad: cantidad,
      formato: formato,
      concepto: 'Préstamo a cliente',
      cliente: cliente.trim(),
    );

    state = state.copyWith(
      stocks: nuevosStocks,
      prestamos: [nuevoPrestamo, ...state.prestamos],
      movimientos: [nuevoMov, ...state.movimientos],
    );
  }

  /// 5.5 y 5.6: Recibir préstamo devuelto
  void liquidarPrestamo({
    required String prestamoId,
    required int cantidadDevuelta,
    bool devolverEfectivo = false,
  }) {
    final idx = state.prestamos.indexWhere((p) => p.id == prestamoId);
    if (idx < 0) return;

    final p = state.prestamos[idx];
    final cantidad = cantidadDevuelta.clamp(1, p.cantidad);

    final actual =
        state.stocks[p.formato] ??
        StockEnvases(formato: p.formato, enAlmacen: 0, enCalle: 0);

    final nuevosStocks = Map<TipoFormatoEnvase, StockEnvases>.from(
      state.stocks,
    );
    nuevosStocks[p.formato] = StockEnvases(
      formato: p.formato,
      enAlmacen: actual.enAlmacen + cantidad,
      enCalle: (actual.enCalle - cantidad).clamp(0, 999999),
    );

    final nuevosPrestamos = List<PrestamoEnvase>.from(state.prestamos);
    if (cantidad >= p.cantidad) {
      nuevosPrestamos[idx] = p.copyWith(
        liquidado: true,
        fechaLiquidacion: DateTime.now(),
      );
    } else {
      nuevosPrestamos[idx] = p.copyWith(cantidad: p.cantidad - cantidad);
    }

    final double monto = devolverEfectivo
        ? (cantidad * p.formato.precioDeposito)
        : 0.0;

    final nuevoMov = MovimientoEnvase(
      id: 'm-${DateTime.now().millisecondsSinceEpoch}',
      fecha: DateTime.now(),
      esEntrada: true,
      cantidad: cantidad,
      formato: p.formato,
      concepto: devolverEfectivo
          ? 'Retorno de préstamo y devolución efectivo (\$${monto.toStringAsFixed(2)})'
          : 'Retorno de envases prestados',
      cliente: p.cliente,
      montoEfectivo: devolverEfectivo ? monto : null,
    );

    if (devolverEfectivo && monto > 0) {
      ref
          .read(movimientosCajaProvider.notifier)
          .registrar(
            esIngreso: false,
            motivo:
                'Devolución de depósito envases ($cantidad pzs) - ${p.cliente}',
            monto: monto,
          );
    }

    state = state.copyWith(
      stocks: nuevosStocks,
      prestamos: nuevosPrestamos,
      movimientos: [nuevoMov, ...state.movimientos],
    );
  }

  /// 5.6: Retorno de envases directo con devolución de efectivo (impacta Movimientos de Caja 2.2)
  void registrarRetornoYReembolso({
    required int cantidad,
    required double montoReembolso,
    TipoFormatoEnvase formato = TipoFormatoEnvase.media,
    String? cliente,
  }) {
    if (cantidad <= 0) return;

    final actual =
        state.stocks[formato] ??
        StockEnvases(formato: formato, enAlmacen: 0, enCalle: 0);

    final nuevosStocks = Map<TipoFormatoEnvase, StockEnvases>.from(
      state.stocks,
    );
    nuevosStocks[formato] = StockEnvases(
      formato: formato,
      enAlmacen: actual.enAlmacen + cantidad,
      enCalle: (actual.enCalle - cantidad).clamp(0, 999999),
    );

    final nuevoMov = MovimientoEnvase(
      id: 'm-${DateTime.now().millisecondsSinceEpoch}',
      fecha: DateTime.now(),
      esEntrada: true,
      cantidad: cantidad,
      formato: formato,
      concepto:
          'Devolución de depósito en efectivo (\$${montoReembolso.toStringAsFixed(2)})',
      cliente: cliente,
      montoEfectivo: montoReembolso,
    );

    // Impacto directo e invisible en la Caja (Pantalla 2.2)
    ref
        .read(movimientosCajaProvider.notifier)
        .registrar(
          esIngreso: false,
          motivo:
              'Devolución depósito envases ($cantidad pzs${cliente != null ? ' - $cliente' : ''})',
          monto: montoReembolso,
        );

    state = state.copyWith(
      stocks: nuevosStocks,
      movimientos: [nuevoMov, ...state.movimientos],
    );
  }

  /// Cobro de depósito en venta (sale envase, cliente paga depósito)
  void registrarCobroDeposito({
    required int cantidad,
    TipoFormatoEnvase formato = TipoFormatoEnvase.media,
    required double montoCobrado,
  }) {
    if (cantidad <= 0) return;

    final actual =
        state.stocks[formato] ??
        StockEnvases(formato: formato, enAlmacen: 0, enCalle: 0);

    final nuevosStocks = Map<TipoFormatoEnvase, StockEnvases>.from(
      state.stocks,
    );
    nuevosStocks[formato] = StockEnvases(
      formato: formato,
      enAlmacen: (actual.enAlmacen - cantidad).clamp(0, 999999),
      enCalle: actual.enCalle + cantidad,
    );

    final nuevoMov = MovimientoEnvase(
      id: 'm-${DateTime.now().millisecondsSinceEpoch}',
      fecha: DateTime.now(),
      esEntrada: false,
      cantidad: cantidad,
      formato: formato,
      concepto:
          'Cobro de depósito en venta (\$${montoCobrado.toStringAsFixed(2)})',
    );

    state = state.copyWith(
      stocks: nuevosStocks,
      movimientos: [nuevoMov, ...state.movimientos],
    );
  }
}

final envasesProvider = NotifierProvider<EnvasesNotifier, EstadoEnvases>(
  EnvasesNotifier.new,
);
