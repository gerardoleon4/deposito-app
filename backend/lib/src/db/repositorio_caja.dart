import 'package:sqlite3/sqlite3.dart';

import '../modelos/caja.dart';

class RepositorioCaja {
  RepositorioCaja(this._db);
  final Database _db;

  Row? abierto() {
    final r = _db.select('SELECT * FROM turnos WHERE abierto = 1');
    return r.isEmpty ? null : r.first;
  }

  Row? porId(String id) {
    final r = _db.select('SELECT * FROM turnos WHERE id = ?', [id]);
    return r.isEmpty ? null : r.first;
  }

  int contar() =>
      _db.select('SELECT COUNT(*) AS n FROM turnos').first['n'] as int;

  void abrir({
    required String id,
    required String apertura,
    required String diaNegocio,
    required int fondo,
  }) {
    _db.execute(
      'INSERT INTO turnos (id, apertura, dia_negocio, fondo) VALUES (?, ?, ?, ?)',
      [id, apertura, diaNegocio, fondo],
    );
  }

  void cerrar({
    required String id,
    required String cierre,
    required int esperado,
    required int contado,
    required String? nota,
  }) {
    _db.execute(
      '''
      UPDATE turnos
      SET abierto = 0, cierre = ?, esperado = ?, contado = ?, diferencia = ?, nota = ?
      WHERE id = ? AND abierto = 1
      ''',
      [cierre, esperado, contado, contado - esperado, nota, id],
    );
  }

  /// Turnos cerrados, del más nuevo al más viejo. Sin rango, los últimos 30.
  List<Row> cortes({String? desde, String? hasta}) {
    if (desde == null && hasta == null) {
      return _db.select(
        'SELECT * FROM turnos WHERE abierto = 0 ORDER BY apertura DESC LIMIT 30',
      );
    }
    return _db.select(
      '''
      SELECT * FROM turnos
      WHERE abierto = 0 AND dia_negocio >= ? AND dia_negocio <= ?
      ORDER BY apertura DESC
      ''',
      [desde ?? '0000-01-01', hasta ?? '9999-12-31'],
    );
  }

  /// Totales del turno, calculados de sus ventas y movimientos.
  ResumenTurno resumen(String turnoId, int fondo) {
    final v = _db
        .select(
          '''
      SELECT
        COALESCE(SUM(cancelada = 0), 0) AS ventas,
        COALESCE(SUM(cancelada = 1), 0) AS canceladas,
        COALESCE(SUM(CASE WHEN cancelada = 0 AND metodo = 'efectivo' THEN total END), 0) AS efectivo,
        COALESCE(SUM(CASE WHEN cancelada = 0 AND metodo = 'tarjeta' THEN total END), 0) AS tarjeta,
        COALESCE(SUM(CASE WHEN cancelada = 0 THEN env_monto END), 0) AS envases
      FROM ventas WHERE turno_id = ?
      ''',
          [turnoId],
        )
        .first;
    final m = _db
        .select(
          '''
      SELECT
        COALESCE(SUM(CASE WHEN tipo = 'ingreso' THEN monto END), 0) AS ingresos,
        COALESCE(SUM(CASE WHEN tipo = 'retiro' THEN monto END), 0) AS retiros
      FROM caja_movimientos WHERE turno_id = ?
      ''',
          [turnoId],
        )
        .first;
    final efectivo = v['efectivo'] as int;
    final ingresos = m['ingresos'] as int;
    final retiros = m['retiros'] as int;
    return ResumenTurno(
      ventas: v['ventas'] as int,
      canceladas: v['canceladas'] as int,
      ventasEfectivo: efectivo,
      ventasTarjeta: v['tarjeta'] as int,
      envases: v['envases'] as int,
      ingresos: ingresos,
      retiros: retiros,
      esperado: fondo + efectivo + ingresos - retiros,
    );
  }

  void registrarMovimiento({
    required String id,
    required String turnoId,
    required String tipo,
    required int monto,
    required String motivo,
    required String fecha,
    required String origen,
  }) {
    _db.execute(
      '''
      INSERT INTO caja_movimientos (id, turno_id, tipo, monto, motivo, fecha, origen)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ''',
      [id, turnoId, tipo, monto, motivo, fecha, origen],
    );
  }

  List<MovimientoCaja> movimientos(String turnoId) => [
    for (final f in _db.select(
      'SELECT * FROM caja_movimientos WHERE turno_id = ? ORDER BY fecha, rowid',
      [turnoId],
    ))
      MovimientoCaja(
        id: f['id'] as String,
        tipo: f['tipo'] as String,
        monto: f['monto'] as int,
        motivo: f['motivo'] as String,
        fecha: f['fecha'] as String,
      ),
  ];
}
