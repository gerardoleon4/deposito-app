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
    required this.formato,
    required this.cantidad,
    this.devueltos = 0,
    required this.fecha,
  });

  final String id;
  final String cliente;

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
    formato: j['formato'] as String,
    cantidad: j['cantidad'] as int,
    devueltos: j['devueltos'] as int? ?? 0,
    fecha: j['fecha'] as String,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'cliente': cliente,
    'formato': formato,
    'cantidad': cantidad,
    'devueltos': devueltos,
    'fecha': fecha,
  };
}
