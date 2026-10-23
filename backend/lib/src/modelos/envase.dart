import 'producto.dart';

/// Existencias de un formato de envase retornable (`GET /api/v1/envases`).
class BalanceEnvase {
  const BalanceEnvase({
    required this.formato,
    required this.bodega,
    required this.prestados,
    required this.precio,
  });

  /// Uno de [formatosEnvase].
  final String formato;

  /// Vacíos en el depósito.
  final int bodega;

  /// Prestados a clientes y sin devolver.
  final int prestados;

  /// Depósito por envase, en centavos.
  final int precio;

  int get total => bodega + prestados;

  /// Todos los formatos de `{ "balance": { "mega": {...}, ... } }`.
  static Map<String, BalanceEnvase> deJson(Map<String, Object?> balance) => {
    for (final e in balance.entries)
      e.key: BalanceEnvase.fromJson(e.key, (e.value! as Map).cast()),
  };

  factory BalanceEnvase.fromJson(String formato, Map<String, Object?> j) =>
      BalanceEnvase(
        formato: formato,
        bodega: j['bodega'] as int,
        prestados: j['prestados'] as int,
        precio: j['precio'] as int,
      );

  Map<String, Object?> toJson() => {
    'bodega': bodega,
    'prestados': prestados,
    'precio': precio,
  };
}

/// Envases prestados a un cliente (`GET /api/v1/envases/prestamos`).
class PrestamoEnvase {
  const PrestamoEnvase({
    required this.id,
    required this.cliente,
    this.telefono,
    required this.formato,
    required this.cantidad,
    this.devueltos = 0,
    required this.fecha,
  });

  final String id;
  final String cliente;
  final String? telefono;

  /// Uno de [formatosEnvase].
  final String formato;

  /// Envases que faltan por devolver.
  final int cantidad;

  /// Envases que ya se devolvieron (devolución parcial).
  final int devueltos;

  /// ISO 8601 UTC.
  final String fecha;

  factory PrestamoEnvase.fromJson(Map<String, Object?> j) => PrestamoEnvase(
    id: j['id'] as String,
    cliente: j['cliente'] as String,
    telefono: j['telefono'] as String?,
    formato: j['formato'] as String,
    cantidad: j['cantidad'] as int,
    devueltos: j['devueltos'] as int? ?? 0,
    fecha: j['fecha'] as String,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'cliente': cliente,
    'telefono': telefono,
    'formato': formato,
    'cantidad': cantidad,
    'devueltos': devueltos,
    'fecha': fecha,
  };
}

/// Un cambio del balance de envases (`GET /api/v1/envases/movimientos`).
class MovimientoEnvase {
  const MovimientoEnvase({
    required this.id,
    required this.fecha,
    required this.formato,
    required this.tipo,
    required this.bodega,
    required this.prestados,
    this.cliente,
    this.monto,
    this.referencia,
  });

  final int id;

  /// ISO 8601 UTC.
  final String fecha;
  final String formato;

  /// `entrada`, `salida`, `prestamo`, `devolucion_prestamo`, `venta_trae`,
  /// `venta_prestamo`, `credito`, `venta_vacios`, `devolucion_deposito` o
  /// `cancelacion`.
  final String tipo;

  /// Cambio con signo.
  final int bodega;
  final int prestados;
  final String? cliente;

  /// Centavos que entraron (+) o salieron (−) de caja, o `null`.
  final int? monto;
  final String? referencia;

  factory MovimientoEnvase.fromJson(Map<String, Object?> j) => MovimientoEnvase(
    id: j['id'] as int,
    fecha: j['fecha'] as String,
    formato: j['formato'] as String,
    tipo: j['tipo'] as String,
    bodega: j['bodega'] as int,
    prestados: j['prestados'] as int,
    cliente: j['cliente'] as String?,
    monto: j['monto'] as int?,
    referencia: j['referencia'] as String?,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'fecha': fecha,
    'formato': formato,
    'tipo': tipo,
    'bodega': bodega,
    'prestados': prestados,
    'cliente': cliente,
    'monto': monto,
    'referencia': referencia,
  };
}
