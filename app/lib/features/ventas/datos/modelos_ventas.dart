import 'package:flutter/material.dart';

/// Métodos de pago como los nombra la API, con lo que la pantalla muestra.
enum MetodoPago {
  efectivo('efectivo', 'Efectivo', Icons.payments_rounded),
  tarjeta('tarjeta', 'Tarjeta', Icons.credit_card_rounded);

  const MetodoPago(this.clave, this.etiqueta, this.icono);

  final String clave;
  final String etiqueta;
  final IconData icono;

  static MetodoPago de(String clave) =>
      values.firstWhere((m) => m.clave == clave, orElse: () => efectivo);
}
