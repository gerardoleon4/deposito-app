import 'package:flutter_riverpod/flutter_riverpod.dart';

class MovimientoCaja {
  final String id;
  final DateTime hora;
  final bool esIngreso;
  final String motivo;
  final double monto;

  MovimientoCaja(this.id, this.hora, this.esIngreso, this.motivo, this.monto);
}

class EstadoCajaMovimientos {
  final double saldoEstimado;
  final List<MovimientoCaja> movimientos;

  const EstadoCajaMovimientos({
    required this.saldoEstimado,
    required this.movimientos,
  });

  EstadoCajaMovimientos copyWith({
    double? saldoEstimado,
    List<MovimientoCaja>? movimientos,
  }) {
    return EstadoCajaMovimientos(
      saldoEstimado: saldoEstimado ?? this.saldoEstimado,
      movimientos: movimientos ?? this.movimientos,
    );
  }
}

class MovimientosCajaNotifier extends Notifier<EstadoCajaMovimientos> {
  @override
  EstadoCajaMovimientos build() {
    return EstadoCajaMovimientos(
      saldoEstimado: 1500.0,
      movimientos: [
        MovimientoCaja(
          '1',
          DateTime.now().subtract(const Duration(hours: 2)),
          true,
          'Apertura de caja',
          1000.0,
        ),
        MovimientoCaja(
          '2',
          DateTime.now().subtract(const Duration(minutes: 45)),
          false,
          'Pago proveedor hielo',
          250.0,
        ),
        MovimientoCaja(
          '3',
          DateTime.now().subtract(const Duration(minutes: 10)),
          true,
          'Venta efectivo',
          750.0,
        ),
      ],
    );
  }

  void registrar({
    required bool esIngreso,
    required String motivo,
    required double monto,
  }) {
    final nuevoMovimiento = MovimientoCaja(
      DateTime.now().millisecondsSinceEpoch.toString(),
      DateTime.now(),
      esIngreso,
      motivo,
      monto,
    );

    final nuevoSaldo = esIngreso
        ? state.saldoEstimado + monto
        : state.saldoEstimado - monto;

    state = state.copyWith(
      saldoEstimado: nuevoSaldo,
      movimientos: [nuevoMovimiento, ...state.movimientos],
    );
  }
}

final movimientosCajaProvider =
    NotifierProvider<MovimientosCajaNotifier, EstadoCajaMovimientos>(
      MovimientosCajaNotifier.new,
    );
