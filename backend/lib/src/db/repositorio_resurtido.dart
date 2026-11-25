import 'package:sqlite3/sqlite3.dart';

class RepositorioResurtido {
  RepositorioResurtido(this._db);

  final Database _db;

  /// Piezas netas vendidas por producto entre [desdeDia] y [hastaDia] (inclusivo),
  /// excluyendo ventas canceladas y unidades devueltas.
  Map<String, int> piezasVendidasPorProducto(String desdeDia, String hastaDia) {
    final filas = _db.select(
      '''
      SELECT
        vl.producto_id AS producto_id,
        SUM(
          CASE
            WHEN vl.cantidad > 0 THEN
              (vl.cantidad - vl.devueltas) * (vl.piezas / vl.cantidad)
            ELSE 0
          END
        ) AS piezas
      FROM venta_lineas vl
      INNER JOIN ventas v ON v.id = vl.venta_id
      WHERE v.cancelada = 0
        AND v.dia_negocio >= ?
        AND v.dia_negocio <= ?
      GROUP BY vl.producto_id
      ''',
      [desdeDia, hastaDia],
    );

    final resultado = <String, int>{};
    for (final fila in filas) {
      final piezas = fila['piezas'] as int? ?? 0;
      if (piezas > 0) {
        resultado[fila['producto_id'] as String] = piezas;
      }
    }
    return resultado;
  }
}
