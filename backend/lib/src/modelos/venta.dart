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

/// Una venta en el historial (`GET /api/v1/ventas`).
class ResumenVenta {
  const ResumenVenta({
    required this.id,
    required this.folio,
    required this.fecha,
    required this.total,
    required this.metodo,
    required this.origen,
    required this.cancelada,
  });

  final String id;
  final int folio;

  /// ISO 8601 UTC.
  final String fecha;

  /// Centavos.
  final int total;

  /// `efectivo` o `tarjeta`.
  final String metodo;

  /// "Caja" o el nombre de la terminal.
  final String origen;
  final bool cancelada;

  factory ResumenVenta.fromJson(Map<String, Object?> j) => ResumenVenta(
    id: j['id'] as String,
    folio: j['folio'] as int,
    fecha: j['fecha'] as String,
    total: j['total'] as int,
    metodo: j['metodo'] as String,
    origen: j['origen'] as String,
    cancelada: j['cancelada'] as bool,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'folio': folio,
    'fecha': fecha,
    'total': total,
    'metodo': metodo,
    'origen': origen,
    'cancelada': cancelada,
  };
}

/// Una línea del ticket (`GET /api/v1/ventas/{id}`).
class LineaTicket {
  const LineaTicket({
    required this.productoId,
    required this.nombre,
    required this.unidad,
    required this.cantidad,
    required this.piezas,
    required this.precioUnit,
    required this.subtotal,
  });

  final String productoId;

  /// Nombre del producto al momento de la venta.
  final String nombre;

  /// `pieza` o `caja`.
  final String unidad;
  final int cantidad;
  final int piezas;

  /// Centavos por pieza o por caja, según [unidad].
  final int precioUnit;

  /// Centavos.
  final int subtotal;

  bool get porCaja => unidad == 'caja';

  factory LineaTicket.fromJson(Map<String, Object?> j) => LineaTicket(
    productoId: j['productoId'] as String,
    nombre: j['nombre'] as String,
    unidad: j['unidad'] as String,
    cantidad: j['cantidad'] as int,
    piezas: j['piezas'] as int,
    precioUnit: j['precioUnit'] as int,
    subtotal: j['subtotal'] as int,
  );

  Map<String, Object?> toJson() => {
    'productoId': productoId,
    'nombre': nombre,
    'unidad': unidad,
    'cantidad': cantidad,
    'piezas': piezas,
    'precioUnit': precioUnit,
    'subtotal': subtotal,
  };
}

/// La venta completa para ver o reimprimir el ticket.
class DetalleVenta {
  const DetalleVenta({
    required this.id,
    required this.folio,
    required this.fecha,
    required this.diaNegocio,
    required this.total,
    required this.metodo,
    this.tarjeta,
    required this.recibido,
    required this.cambio,
    required this.envModo,
    required this.envN,
    required this.envMonto,
    required this.origen,
    required this.cancelada,
    required this.lineas,
  });

  final String id;
  final int folio;

  /// ISO 8601 UTC.
  final String fecha;

  /// `AAAA-MM-DD` en la hora del negocio.
  final String diaNegocio;

  /// Centavos, con el depósito de envases si se cobró.
  final int total;
  final String metodo;
  final String? tarjeta;
  final int recibido;
  final int cambio;

  /// `na`, `cobrar`, `trae` o `prestamo`.
  final String envModo;

  /// Envases retornables de la venta.
  final int envN;

  /// Centavos cobrados por depósito de envases.
  final int envMonto;
  final String origen;
  final bool cancelada;

  /// Vacía en una venta de envases vacíos.
  final List<LineaTicket> lineas;

  /// Total de los productos, sin el depósito de envases.
  int get subtotalProductos => total - envMonto;

  factory DetalleVenta.fromJson(Map<String, Object?> j) => DetalleVenta(
    id: j['id'] as String,
    folio: j['folio'] as int,
    fecha: j['fecha'] as String,
    diaNegocio: j['diaNegocio'] as String,
    total: j['total'] as int,
    metodo: j['metodo'] as String,
    tarjeta: j['tarjeta'] as String?,
    recibido: j['recibido'] as int,
    cambio: j['cambio'] as int,
    envModo: j['envModo'] as String,
    envN: j['envN'] as int,
    envMonto: j['envMonto'] as int,
    origen: j['origen'] as String,
    cancelada: j['cancelada'] as bool,
    lineas: [
      for (final l in j['lineas'] as List)
        LineaTicket.fromJson((l as Map).cast()),
    ],
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'folio': folio,
    'fecha': fecha,
    'diaNegocio': diaNegocio,
    'total': total,
    'metodo': metodo,
    'tarjeta': tarjeta,
    'recibido': recibido,
    'cambio': cambio,
    'envModo': envModo,
    'envN': envN,
    'envMonto': envMonto,
    'origen': origen,
    'cancelada': cancelada,
    'lineas': [for (final l in lineas) l.toJson()],
  };
}
