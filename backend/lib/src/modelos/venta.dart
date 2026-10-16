/// Una línea de lo que se cobra (`POST /api/v1/ventas`).
class LineaVenta {
  const LineaVenta({
    required this.productoId,
    required this.porCaja,
    required this.cantidad,
  });

  final String productoId;

  /// `true` vende cajas completas; `false`, piezas sueltas.
  final bool porCaja;
  final int cantidad;

  Map<String, Object?> toJson() => {
    'productoId': productoId,
    'unidad': porCaja ? 'caja' : 'pieza',
    'cantidad': cantidad,
  };
}

/// Lo que responde el servidor al registrar una venta.
class VentaRegistrada {
  const VentaRegistrada({
    required this.id,
    required this.folio,
    required this.fecha,
    required this.diaNegocio,
    required this.total,
    required this.metodo,
    required this.recibido,
    required this.cambio,
  });

  final String id;
  final int folio;

  /// ISO 8601 UTC.
  final String fecha;

  /// `AAAA-MM-DD` en la hora del negocio.
  final String diaNegocio;

  /// Centavos.
  final int total;

  /// `efectivo` o `tarjeta`.
  final String metodo;
  final int recibido;
  final int cambio;

  factory VentaRegistrada.fromJson(Map<String, Object?> j) => VentaRegistrada(
    id: j['id'] as String,
    folio: j['folio'] as int,
    fecha: j['fecha'] as String,
    diaNegocio: j['diaNegocio'] as String,
    total: j['total'] as int,
    metodo: j['metodo'] as String,
    recibido: j['recibido'] as int,
    cambio: j['cambio'] as int,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'folio': folio,
    'fecha': fecha,
    'diaNegocio': diaNegocio,
    'total': total,
    'metodo': metodo,
    'recibido': recibido,
    'cambio': cambio,
  };
}
