import 'package:flutter/material.dart';

/// Métodos de pago como los nombra la API, con lo que la pantalla muestra
/// (colores del diseño de Pablo).
enum MetodoPago {
  efectivo('efectivo', 'Efectivo', Icons.payments_rounded, Color(0xFF16A34A)),
  tarjeta('tarjeta', 'Tarjeta', Icons.credit_card_rounded, Color(0xFF2563EB));

  const MetodoPago(this.clave, this.etiqueta, this.icono, this.color);

  final String clave;
  final String etiqueta;
  final IconData icono;
  final Color color;

  static MetodoPago de(String clave) =>
      values.firstWhere((m) => m.clave == clave, orElse: () => efectivo);
}

/// A dónde va la mercancía que se devuelve (`destino` de la API).
enum DestinoStock {
  regresarInventario(
    'inventario',
    'Regresar al Inventario',
    'El producto está intacto y puede volver a venderse',
    Icons.inventory_2_rounded,
    Color(0xFF2563EB),
  ),
  merma(
    'merma',
    'Registrar como Merma',
    'El producto está roto, abierto o caducado',
    Icons.delete_sweep_rounded,
    Color(0xFFDC2626),
  );

  const DestinoStock(
    this.clave,
    this.titulo,
    this.subtitulo,
    this.icono,
    this.color,
  );

  final String clave;
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Color color;

  static DestinoStock de(String clave) => values.firstWhere(
    (d) => d.clave == clave,
    orElse: () => regresarInventario,
  );
}

/// Rojo de cancelaciones y devoluciones (diseño de Pablo).
const rojoCancelacion = Color(0xFFDC2626);
