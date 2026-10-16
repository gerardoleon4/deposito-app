/// Tipos de movimiento de inventario (tabla `movimientos`).
const tiposMovimiento = {
  'inicial',
  'entrada',
  'venta',
  'cancelacion',
  'ajuste',
  'merma',
};

/// Un cambio de existencia de un producto, como lo describe docs/API.md.
class Movimiento {
  const Movimiento({
    required this.id,
    required this.tipo,
    required this.piezas,
    required this.existenciaResultante,
    this.referencia,
    required this.origen,
    this.nota,
    required this.fecha,
  });

  final int id;

  /// Uno de [tiposMovimiento].
  final String tipo;

  /// Con signo: `-3` en una venta, `24` en una entrada.
  final int piezas;
  final int existenciaResultante;

  /// Por ejemplo `Folio 1001`.
  final String? referencia;

  /// "Caja" o el nombre de la terminal.
  final String origen;
  final String? nota;

  /// ISO 8601 UTC.
  final String fecha;

  factory Movimiento.fromJson(Map<String, Object?> j) => Movimiento(
    id: j['id'] as int,
    tipo: j['tipo'] as String,
    piezas: j['piezas'] as int,
    existenciaResultante: j['existenciaResultante'] as int,
    referencia: j['referencia'] as String?,
    origen: j['origen'] as String,
    nota: j['nota'] as String?,
    fecha: j['fecha'] as String,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'tipo': tipo,
    'piezas': piezas,
    'existenciaResultante': existenciaResultante,
    'referencia': referencia,
    'origen': origen,
    'nota': nota,
    'fecha': fecha,
  };
}
