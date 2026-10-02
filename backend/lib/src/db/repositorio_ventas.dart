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
    required String origen,
  }) {
    _db.execute(
      '''
      INSERT INTO ventas (id, folio, fecha, dia_negocio, total, metodo, tarjeta, recibido,
        cambio, env_modo, env_n, env_monto, env_cliente, origen)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
        origen,
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
  }) {
    _db.execute(
      '''
      INSERT INTO venta_lineas (venta_id, producto_id, nombre, unidad, cantidad, piezas, precio_unit, subtotal)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
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
      ],
    );
  }

  Row? obtenerPorId(String id) {
    final r = _db.select('SELECT * FROM ventas WHERE id = ?', [id]);
    return r.isEmpty ? null : r.first;
  }

  List<Row> obtenerLineas(String ventaId) {
    return _db.select('SELECT * FROM venta_lineas WHERE venta_id = ?', [
      ventaId,
    ]);
  }

  List<Row> listar({String? diaNegocio}) {
    if (diaNegocio != null) {
      return _db.select(
        'SELECT * FROM ventas WHERE dia_negocio = ? ORDER BY folio DESC',
        [diaNegocio],
      );
    }
    return _db.select('SELECT * FROM ventas ORDER BY folio DESC LIMIT 100');
  }

  void anularVenta(String id) {
    _db.execute('UPDATE ventas SET cancelada = 1 WHERE id = ?', [id]);
  }
}
