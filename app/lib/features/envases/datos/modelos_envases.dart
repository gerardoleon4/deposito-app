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
