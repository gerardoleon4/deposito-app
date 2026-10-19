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
    String? usuarioId,
  }) {
    _db.execute(
      'INSERT INTO turnos (id, apertura, dia_negocio, fondo, usuario_apertura) '
      'VALUES (?, ?, ?, ?, ?)',
      [id, apertura, diaNegocio, fondo, usuarioId],
    );
  }

  /// `{ id, nombre }` del usuario, o `null`.
  Map<String, Object?>? usuario(Object? id) {
    if (id == null) return null;
    final r = _db.select('SELECT nombre FROM usuarios WHERE id = ?', [id]);
    return {'id': id, 'nombre': r.isEmpty ? null : r.first['nombre']};
  }

  void cerrar({
    required String id,
    required String cierre,
    required int esperado,
    required int contado,
    required String? nota,
    String? usuarioId,
  }) {
    _db.execute(
      '''
      UPDATE turnos
      SET abierto = 0, cierre = ?, esperado = ?, contado = ?, diferencia = ?, nota = ?,
        usuario_cierre = ?
      WHERE id = ? AND abierto = 1
      ''',
      [cierre, esperado, contado, contado - esperado, nota, usuarioId, id],
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

  /// Totales del turno, calculados de sus ventas, devoluciones y
  /// movimientos.
  ResumenTurno resumen(String turnoId, int fondo) {
    int uno(String sql) => _db.select(sql, [turnoId]).first.values.first as int;
    final cobradoEfectivo = uno(
      "SELECT COALESCE(SUM(total), 0) FROM ventas "
      "WHERE turno_id = ? AND metodo = 'efectivo'",
    );
    final cobradoTarjeta = uno(
      "SELECT COALESCE(SUM(total), 0) FROM ventas "
      "WHERE turno_id = ? AND metodo = 'tarjeta'",
    );
    final devueltoEfectivo = uno(
      "SELECT COALESCE(SUM(monto), 0) FROM devoluciones "
      "WHERE turno_id = ? AND metodo = 'efectivo'",
    );
    final devueltoTarjeta = uno(
      "SELECT COALESCE(SUM(monto), 0) FROM devoluciones "
      "WHERE turno_id = ? AND metodo = 'tarjeta'",
    );
    final ingresos = uno(
      "SELECT COALESCE(SUM(monto), 0) FROM caja_movimientos "
      "WHERE turno_id = ? AND tipo = 'ingreso'",
    );
    final retiros = uno(
      "SELECT COALESCE(SUM(monto), 0) FROM caja_movimientos "
      "WHERE turno_id = ? AND tipo = 'retiro'",
    );
    final efectivo = cobradoEfectivo - devueltoEfectivo;
    return ResumenTurno(
      ventas: uno(
        'SELECT COUNT(*) FROM ventas WHERE turno_id = ? AND cancelada = 0',
      ),
      canceladas: uno(
        'SELECT COUNT(*) FROM ventas WHERE turno_id = ? AND cancelada = 1',
      ),
      ventasEfectivo: efectivo,
      ventasTarjeta: cobradoTarjeta - devueltoTarjeta,
      envases: uno(
        'SELECT COALESCE(SUM(env_monto - env_credito), 0) FROM ventas '
        'WHERE turno_id = ? AND cancelada = 0',
      ),
      devoluciones: devueltoEfectivo + devueltoTarjeta,
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
