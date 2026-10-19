import 'usuario.dart';

/// Una línea de lo que se cobra (`POST /api/v1/ventas`).
class LineaVenta {
  const LineaVenta({
    required this.productoId,
    required this.porCaja,
    required this.cantidad,
    this.descuento = 0,
  });

  final String productoId;

  /// `true` vende cajas completas; `false`, piezas sueltas.
  final bool porCaja;
  final int cantidad;

  /// Porcentaje de 0 a 99, por unidad y truncado al centavo (contrato).
  final int descuento;

  Map<String, Object?> toJson() => {
    'productoId': productoId,
    'unidad': porCaja ? 'caja' : 'pieza',
    'cantidad': cantidad,
    if (descuento > 0) 'descuento': descuento,
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
    this.turnoId,
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

  /// Turno de caja en que se cobró; `null` en ventas anteriores a la caja.
  final String? turnoId;

  factory VentaRegistrada.fromJson(Map<String, Object?> j) => VentaRegistrada(
    id: j['id'] as String,
    folio: j['folio'] as int,
    fecha: j['fecha'] as String,
    diaNegocio: j['diaNegocio'] as String,
    total: j['total'] as int,
    metodo: j['metodo'] as String,
    recibido: j['recibido'] as int,
    cambio: j['cambio'] as int,
    turnoId: j['turnoId'] as String?,
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
    'turnoId': turnoId,
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
    this.turnoId,
    this.devuelto = 0,
    this.usuario,
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

  /// Turno de caja en que se cobró; `null` en ventas anteriores a la caja.
  final String? turnoId;

  /// Centavos ya regresados por devoluciones o cancelación.
  final int devuelto;

  /// Quién cobró, si se indicó.
  final UsuarioBreve? usuario;

  factory ResumenVenta.fromJson(Map<String, Object?> j) => ResumenVenta(
    id: j['id'] as String,
    folio: j['folio'] as int,
    fecha: j['fecha'] as String,
    total: j['total'] as int,
    metodo: j['metodo'] as String,
    origen: j['origen'] as String,
    cancelada: j['cancelada'] as bool,
    turnoId: j['turnoId'] as String?,
    devuelto: j['devuelto'] as int? ?? 0,
    usuario: UsuarioBreve.deJson(j['usuario']),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'folio': folio,
    'fecha': fecha,
    'total': total,
    'metodo': metodo,
    'origen': origen,
    'cancelada': cancelada,
    'turnoId': turnoId,
    'devuelto': devuelto,
    'usuario': usuario?.toJson(),
  };
}

/// Una línea del ticket (`GET /api/v1/ventas/{id}`).
class LineaTicket {
  const LineaTicket({
    this.lineaId = 0,
    required this.productoId,
    required this.nombre,
    required this.unidad,
    required this.cantidad,
    required this.piezas,
    int? precioLista,
    this.descuento = 0,
    required this.precioUnit,
    required this.subtotal,
    this.devueltas = 0,
  }) : precioLista = precioLista ?? precioUnit;

  /// Para devolver esta línea (`POST /ventas/{id}/devolver`).
  final int lineaId;
  final String productoId;

  /// Nombre del producto al momento de la venta.
  final String nombre;

  /// `pieza` o `caja`.
  final String unidad;
  final int cantidad;
  final int piezas;

  /// Centavos por pieza o por caja antes del descuento.
  final int precioLista;

  /// Porcentaje de descuento (0 si no hubo).
  final int descuento;

  /// Centavos por pieza o por caja, ya con descuento.
  final int precioUnit;

  /// Centavos.
  final int subtotal;

  /// Unidades ya devueltas.
  final int devueltas;

  bool get porCaja => unidad == 'caja';

  /// Unidades que todavía se pueden devolver.
  int get porDevolver => cantidad - devueltas;

  factory LineaTicket.fromJson(Map<String, Object?> j) => LineaTicket(
    lineaId: j['lineaId'] as int? ?? 0,
    productoId: j['productoId'] as String,
    nombre: j['nombre'] as String,
    unidad: j['unidad'] as String,
    cantidad: j['cantidad'] as int,
    piezas: j['piezas'] as int,
    precioLista: j['precioLista'] as int?,
    descuento: j['descuento'] as int? ?? 0,
    precioUnit: j['precioUnit'] as int,
    subtotal: j['subtotal'] as int,
    devueltas: j['devueltas'] as int? ?? 0,
  );

  Map<String, Object?> toJson() => {
    'lineaId': lineaId,
    'productoId': productoId,
    'nombre': nombre,
    'unidad': unidad,
    'cantidad': cantidad,
    'piezas': piezas,
    'precioLista': precioLista,
    'descuento': descuento,
    'precioUnit': precioUnit,
    'subtotal': subtotal,
    'devueltas': devueltas,
  };
}

/// Dinero regresado de una venta: cancelación o devolución parcial.
class Devolucion {
  const Devolucion({
    required this.id,
    required this.fecha,
    required this.monto,
    required this.destino,
    this.motivo,
    this.autorizo,
  });

  final String id;

  /// ISO 8601 UTC.
  final String fecha;

  /// Centavos.
  final int monto;

  /// `inventario` o `merma`.
  final String destino;
  final String? motivo;

  /// Gerente o dueño que autorizó, si se pidió PIN.
  final UsuarioBreve? autorizo;

  factory Devolucion.fromJson(Map<String, Object?> j) => Devolucion(
    id: j['id'] as String,
    fecha: j['fecha'] as String,
    monto: j['monto'] as int,
    destino: j['destino'] as String,
    motivo: j['motivo'] as String?,
    autorizo: UsuarioBreve.deJson(j['autorizo']),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'fecha': fecha,
    'monto': monto,
    'destino': destino,
    'motivo': motivo,
    'autorizo': autorizo?.toJson(),
  };
}

/// Venta completa para el ticket (`GET /api/v1/ventas/{id}`).
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
    this.envCredito = 0,
    required this.origen,
    required this.cancelada,
    this.turnoId,
    this.devuelto = 0,
    this.usuario,
    required this.lineas,
    this.devoluciones = const [],
  });

  final String id;
  final int folio;

  /// ISO 8601 UTC.
  final String fecha;

  /// `AAAA-MM-DD` en la hora del negocio.
  final String diaNegocio;

  /// Centavos: productos + depósito de envases − crédito por vacíos.
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

  /// Centavos descontados por vacíos extra que entregó el cliente.
  final int envCredito;
  final String origen;
  final bool cancelada;

  /// Turno de caja en que se cobró; `null` en ventas anteriores a la caja.
  final String? turnoId;

  /// Centavos ya regresados por devoluciones o cancelación.
  final int devuelto;

  /// Quién cobró, si se indicó.
  final UsuarioBreve? usuario;

  /// Vacía en una venta de envases vacíos.
  final List<LineaTicket> lineas;
  final List<Devolucion> devoluciones;

  /// Total de los productos, sin depósito ni crédito de envases.
  int get subtotalProductos => total - envMonto + envCredito;

  /// Queda algo que devolver.
  bool get devolvible => !cancelada && devuelto < total;

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
    envCredito: j['envCredito'] as int? ?? 0,
    origen: j['origen'] as String,
    cancelada: j['cancelada'] as bool,
    turnoId: j['turnoId'] as String?,
    devuelto: j['devuelto'] as int? ?? 0,
    usuario: UsuarioBreve.deJson(j['usuario']),
    lineas: [
      for (final l in j['lineas'] as List)
        LineaTicket.fromJson((l as Map).cast()),
    ],
    devoluciones: [
      for (final d in j['devoluciones'] as List? ?? const [])
        Devolucion.fromJson((d as Map).cast()),
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
    'envCredito': envCredito,
    'origen': origen,
    'cancelada': cancelada,
    'turnoId': turnoId,
    'devuelto': devuelto,
    'usuario': usuario?.toJson(),
    'lineas': [for (final l in lineas) l.toJson()],
    'devoluciones': [for (final d in devoluciones) d.toJson()],
  };
}
