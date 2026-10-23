import 'package:sqlite3/sqlite3.dart';

class RepositorioVentas {
  RepositorioVentas(this._db);
  final Database _db;

  int siguienteFolio() {
    final r = _db.select(
      'SELECT COALESCE(MAX(folio), 1000) + 1 AS f FROM ventas',
    );
    return r.first['f'] as int;
  }

  void insertarVenta({
    required String id,
    required int folio,
    required String fecha,
    required String diaNegocio,
    required int total,
    required String metodo,
    String? tarjeta,
    required int recibido,
    required int cambio,
    required String envModo,
    required int envN,
    required int envMonto,
    String? envCliente,
    String? envFormato,
    required String origen,
    required String turnoId,
    String? usuarioId,
    int envCredito = 0,
  }) {
    _db.execute(
      '''
      INSERT INTO ventas (id, folio, fecha, dia_negocio, total, metodo, tarjeta, recibido,
        cambio, env_modo, env_n, env_monto, env_cliente, env_formato, origen, turno_id,
        usuario_id, env_credito)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        id,
        folio,
        fecha,
        diaNegocio,
        total,
        metodo,
        tarjeta,
        recibido,
        cambio,
        envModo,
        envN,
        envMonto,
        envCliente,
        envFormato,
        origen,
        turnoId,
        usuarioId,
        envCredito,
      ],
    );
  }

  void insertarLinea({
    required String ventaId,
    required String productoId,
    required String nombre,
    required String unidad,
    required int cantidad,
    required int piezas,
    required int precioUnit,
    required int subtotal,
    required int precioLista,
    required int descuento,
    required int deposito,
  }) {
    _db.execute(
      '''
      INSERT INTO venta_lineas (venta_id, producto_id, nombre, unidad, cantidad, piezas,
        precio_unit, subtotal, precio_lista, descuento, deposito)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        ventaId,
        productoId,
        nombre,
        unidad,
        cantidad,
        piezas,
        precioUnit,
        subtotal,
        precioLista,
        descuento,
        deposito,
      ],
    );
  }

  void insertarCredito(String ventaId, String formato, int cantidad) {
    _db.execute(
      'INSERT INTO venta_creditos (venta_id, formato, cantidad) VALUES (?, ?, ?)',
      [ventaId, formato, cantidad],
    );
  }

  List<Row> creditos(String ventaId) =>
      _db.select('SELECT * FROM venta_creditos WHERE venta_id = ?', [ventaId]);

  void marcarDevueltas(int lineaId, int cantidad) {
    _db.execute(
      'UPDATE venta_lineas SET devueltas = devueltas + ? WHERE id = ?',
      [cantidad, lineaId],
    );
  }

  void sumarDevuelto(String ventaId, int monto) {
    _db.execute('UPDATE ventas SET devuelto = devuelto + ? WHERE id = ?', [
      monto,
      ventaId,
    ]);
  }

  void insertarDevolucion({
    required String id,
    required String ventaId,
    required String? turnoId,
    required String fecha,
    required int monto,
    required String metodo,
    required String destino,
    required String? motivo,
    required String? autorizoId,
    required String origen,
  }) {
    _db.execute(
      'INSERT INTO devoluciones (id, venta_id, turno_id, fecha, monto, metodo, '
      'destino, motivo, autorizo_id, origen) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        id,
        ventaId,
        turnoId,
        fecha,
        monto,
        metodo,
        destino,
        motivo,
        autorizoId,
        origen,
      ],
    );
  }

  List<Row> devoluciones(String ventaId) => _db.select(
    '''
    SELECT d.*, u.nombre AS autorizo_nombre FROM devoluciones d
    LEFT JOIN usuarios u ON u.id = d.autorizo_id
    WHERE d.venta_id = ? ORDER BY d.fecha, d.rowid
    ''',
    [ventaId],
  );

  String? nombreUsuario(String? id) => id == null
      ? null
      : _db.select('SELECT nombre FROM usuarios WHERE id = ?', [
              id,
            ]).firstOrNull?['nombre']
            as String?;

  Row? obtenerPorId(String id) {
    final r = _db.select(
      'SELECT v.*, u.nombre AS usuario_nombre FROM ventas v '
      'LEFT JOIN usuarios u ON u.id = v.usuario_id WHERE v.id = ?',
      [id],
    );
    return r.isEmpty ? null : r.first;
  }

  List<Row> obtenerLineas(String ventaId) {
    return _db.select(
      'SELECT * FROM venta_lineas WHERE venta_id = ? ORDER BY id',
      [ventaId],
    );
  }

  /// Del folio más nuevo al más viejo. Sin [diaNegocio] ni [turnoId], las
  /// últimas 100.
  List<Row> listar({String? diaNegocio, String? turnoId, String? usuarioId}) {
    final condiciones = <String>[];
    final valores = <Object?>[];
    if (turnoId != null) {
      condiciones.add('v.turno_id = ?');
      valores.add(turnoId);
    } else if (diaNegocio != null) {
      condiciones.add('v.dia_negocio = ?');
      valores.add(diaNegocio);
    }
    if (usuarioId != null) {
      condiciones.add('v.usuario_id = ?');
      valores.add(usuarioId);
    }
    final donde = condiciones.isEmpty
        ? ''
        : 'WHERE ${condiciones.join(' AND ')}';
    final limite = turnoId == null && diaNegocio == null ? 'LIMIT 100' : '';
    return _db.select(
      'SELECT v.*, u.nombre AS usuario_nombre FROM ventas v '
      'LEFT JOIN usuarios u ON u.id = v.usuario_id '
      '$donde ORDER BY v.folio DESC $limite',
      valores,
    );
  }

  void anularVenta(String id) {
    _db.execute('UPDATE ventas SET cancelada = 1 WHERE id = ?', [id]);
  }
}
