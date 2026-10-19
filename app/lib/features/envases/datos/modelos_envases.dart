import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';

/// Formatos de envase retornable, con lo que la pantalla necesita para
/// mostrarlos. El depósito (precio) viene del servidor en el balance.
enum FormatoEnvase {
  mega('mega', 'Mega 1.2 L', Icons.sports_bar_rounded),
  media('media', 'Media 355 ml', Icons.sports_bar_outlined),
  cuarto('cuarto', 'Cuarto 210 ml', Icons.wine_bar_rounded);

  const FormatoEnvase(this.clave, this.etiqueta, this.icono);

  /// Como lo nombra la API: `mega`, `media` o `cuarto`.
  final String clave;
  final String etiqueta;
  final IconData icono;

  static FormatoEnvase de(String clave) =>
      values.firstWhere((f) => f.clave == clave);
}

/// Un préstamo con más de estos días se resalta para cobrarlo.
const diasPrestamoVencido = 7;

/// Días completos desde [fechaIso] (ISO 8601 UTC) hasta [ahora].
int diasDesde(String fechaIso, DateTime ahora) =>
    ahora.toUtc().difference(DateTime.parse(fechaIso)).inDays;

/// Cómo se lee un movimiento de la bitácora de envases en pantalla.
extension LecturaMovimientoEnvase on MovimientoEnvase {
  /// Entra al depósito: sube bodega o baja lo prestado sin pasar por bodega.
  bool get esEntrada => bodega > 0 || (bodega == 0 && prestados < 0);

  /// Piezas que se movieron, sin signo.
  int get piezas => bodega != 0 ? bodega.abs() : prestados.abs();

  String get concepto => switch (tipo) {
    'entrada' => 'Recepción de vacíos',
    'salida' => 'Salida de vacíos${referencia == null ? '' : ': $referencia'}',
    'prestamo' => 'Préstamo a cliente',
    'devolucion_prestamo' => 'Retorno de envases prestados',
    'venta_trae' => 'Vacíos recibidos en venta',
    'venta_prestamo' => 'Préstamo en venta',
    'credito' => 'Crédito por vacíos en venta',
    'venta_vacios' => 'Venta de vacíos',
    'devolucion_deposito' => 'Devolución de depósito en efectivo',
    'cancelacion' => 'Cancelación o devolución de venta',
    _ => tipo,
  };
}
