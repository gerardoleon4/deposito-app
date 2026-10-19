/// Totales de un turno de caja. Todo en centavos salvo los conteos.
class ResumenTurno {
  const ResumenTurno({
    required this.ventas,
    required this.canceladas,
    required this.ventasEfectivo,
    required this.ventasTarjeta,
    required this.envases,
    required this.ingresos,
    required this.retiros,
    required this.esperado,
  });

  /// Ventas no canceladas, incluidas las de vacíos.
  final int ventas;
  final int canceladas;

  /// Suma de `total` de las ventas no canceladas por método. Ya incluye el
  /// depósito de envases.
  final int ventasEfectivo;
  final int ventasTarjeta;

  /// Parte de las ventas que fue depósito de envases o venta de vacíos.
  /// Informativo: ya está dentro de [ventasEfectivo] y [ventasTarjeta].
  final int envases;

  /// Movimientos de caja.
  final int ingresos;
  final int retiros;

  /// `fondo + ventasEfectivo + ingresos - retiros`.
  final int esperado;

  factory ResumenTurno.fromJson(Map<String, Object?> j) => ResumenTurno(
    ventas: j['ventas'] as int,
    canceladas: j['canceladas'] as int,
    ventasEfectivo: j['ventasEfectivo'] as int,
    ventasTarjeta: j['ventasTarjeta'] as int,
    envases: j['envases'] as int,
    ingresos: j['ingresos'] as int,
    retiros: j['retiros'] as int,
    esperado: j['esperado'] as int,
  );

  Map<String, Object?> toJson() => {
    'ventas': ventas,
    'canceladas': canceladas,
    'ventasEfectivo': ventasEfectivo,
    'ventasTarjeta': ventasTarjeta,
    'envases': envases,
    'ingresos': ingresos,
    'retiros': retiros,
    'esperado': esperado,
  };
}

/// Un turno de caja (`GET /api/v1/caja/turno`). Cerrado, es un corte.
class Turno {
  const Turno({
    required this.id,
    required this.estado,
    required this.apertura,
    this.cierre,
    required this.diaNegocio,
    required this.fondo,
    required this.resumen,
    this.contado,
    this.diferencia,
    this.nota,
  });

  final String id;

  /// `abierto` o `cerrado`.
  final String estado;

  /// ISO 8601 UTC.
  final String apertura;
  final String? cierre;

  /// `AAAA-MM-DD` de la apertura en la hora del negocio.
  final String diaNegocio;

  /// Centavos con que se abrió.
  final int fondo;
  final ResumenTurno resumen;

  /// Centavos contados al cerrar; `null` mientras está abierto.
  final int? contado;

  /// `contado - esperado`: negativo es faltante. `null` mientras está abierto.
  final int? diferencia;
  final String? nota;

  bool get abierto => estado == 'abierto';

  factory Turno.fromJson(Map<String, Object?> j) => Turno(
    id: j['id'] as String,
    estado: j['estado'] as String,
    apertura: j['apertura'] as String,
    cierre: j['cierre'] as String?,
    diaNegocio: j['diaNegocio'] as String,
    fondo: j['fondo'] as int,
    resumen: ResumenTurno.fromJson((j['resumen'] as Map).cast()),
    contado: j['contado'] as int?,
    diferencia: j['diferencia'] as int?,
    nota: j['nota'] as String?,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'estado': estado,
    'apertura': apertura,
    'cierre': cierre,
    'diaNegocio': diaNegocio,
    'fondo': fondo,
    'resumen': resumen.toJson(),
    'contado': contado,
    'diferencia': diferencia,
    'nota': nota,
  };
}

/// Efectivo que entra o sale del cajón sin ser venta.
class MovimientoCaja {
  const MovimientoCaja({
    required this.id,
    required this.tipo,
    required this.monto,
    required this.motivo,
    required this.fecha,
  });

  final String id;

  /// `ingreso` o `retiro`.
  final String tipo;

  /// Centavos, siempre positivo.
  final int monto;
  final String motivo;

  /// ISO 8601 UTC.
  final String fecha;

  factory MovimientoCaja.fromJson(Map<String, Object?> j) => MovimientoCaja(
    id: j['id'] as String,
    tipo: j['tipo'] as String,
    monto: j['monto'] as int,
    motivo: j['motivo'] as String,
    fecha: j['fecha'] as String,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'tipo': tipo,
    'monto': monto,
    'motivo': motivo,
    'fecha': fecha,
  };
}

/// Un turno con sus movimientos (`GET /caja/turno`, `GET /caja/cortes/{id}`).
class DetalleTurno {
  const DetalleTurno({required this.turno, required this.movimientos});

  /// `null` si la caja está cerrada (solo en `GET /caja/turno`).
  final Turno? turno;
  final List<MovimientoCaja> movimientos;

  factory DetalleTurno.fromJson(Map<String, Object?> j) => DetalleTurno(
    turno: j['turno'] == null
        ? null
        : Turno.fromJson((j['turno'] as Map).cast()),
    movimientos: [
      for (final m in j['movimientos'] as List)
        MovimientoCaja.fromJson((m as Map).cast()),
    ],
  );

  Map<String, Object?> toJson() => {
    'turno': turno?.toJson(),
    'movimientos': [for (final m in movimientos) m.toJson()],
  };
}
