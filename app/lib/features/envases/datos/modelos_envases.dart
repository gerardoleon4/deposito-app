import 'package:flutter/material.dart';

/// Formatos de envases retornables en el depósito.
enum TipoFormatoEnvase {
  mega('Mega 1.2 L', 8.0, Icons.sports_bar_rounded),
  media('Media 355 ml', 5.0, Icons.sports_bar_outlined),
  cuarto('Cuarto 210 ml', 3.0, Icons.wine_bar_rounded);

  const TipoFormatoEnvase(this.etiqueta, this.precioDeposito, this.icono);

  final String etiqueta;
  final double precioDeposito;
  final IconData icono;
}

/// Registro de un préstamo activo o histórico de envases.
class PrestamoEnvase {
  final String id;
  final String cliente;
  final String? telefono;
  final DateTime fecha;
  final int cantidad;
  final TipoFormatoEnvase formato;
  final bool liquidado;
  final DateTime? fechaLiquidacion;

  PrestamoEnvase({
    required this.id,
    required this.cliente,
    this.telefono,
    required this.fecha,
    required this.cantidad,
    this.formato = TipoFormatoEnvase.media,
    this.liquidado = false,
    this.fechaLiquidacion,
  });

  /// Días transcurridos desde el préstamo.
  int get diasAntiguedad {
    return DateTime.now().difference(fecha).inDays;
  }

  /// Indica si tiene más de 7 días sin devolverse.
  bool get esVencido => !liquidado && diasAntiguedad >= 7;

  PrestamoEnvase copyWith({
    String? id,
    String? cliente,
    String? telefono,
    DateTime? fecha,
    int? cantidad,
    TipoFormatoEnvase? formato,
    bool? liquidado,
    DateTime? fechaLiquidacion,
  }) {
    return PrestamoEnvase(
      id: id ?? this.id,
      cliente: cliente ?? this.cliente,
      telefono: telefono ?? this.telefono,
      fecha: fecha ?? this.fecha,
      cantidad: cantidad ?? this.cantidad,
      formato: formato ?? this.formato,
      liquidado: liquidado ?? this.liquidado,
      fechaLiquidacion: fechaLiquidacion ?? this.fechaLiquidacion,
    );
  }
}

/// Movimiento en bitácora de envases (entradas y salidas).
class MovimientoEnvase {
  final String id;
  final DateTime fecha;
  final bool esEntrada; // true: entra al depósito, false: sale a la calle
  final int cantidad;
  final TipoFormatoEnvase formato;
  final String concepto;
  final String? cliente;
  final double? montoEfectivo; // Si involucró devolución de dinero

  MovimientoEnvase({
    required this.id,
    required this.fecha,
    required this.esEntrada,
    required this.cantidad,
    this.formato = TipoFormatoEnvase.media,
    required this.concepto,
    this.cliente,
    this.montoEfectivo,
  });
}

/// Métricas consolidadas del almacén y calle.
class StockEnvases {
  final TipoFormatoEnvase formato;
  final int enAlmacen;
  final int enCalle;

  const StockEnvases({
    required this.formato,
    required this.enAlmacen,
    required this.enCalle,
  });

  int get total => enAlmacen + enCalle;
  double get porcentajeCalle => total > 0 ? (enCalle / total) : 0.0;
}
