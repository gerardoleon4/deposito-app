import 'package:sqlite3/sqlite3.dart';

class RepositorioEnvases {
  RepositorioEnvases(this._db);
  final Database _db;

  Map<String, Map<String, int>> obtenerBalance() {
    final filas = _db.select(
      'SELECT formato, bodega, prestados, precio FROM balance_envases',
    );
    return {
      for (final f in filas)
        f['formato'] as String: {
          'bodega': f['bodega'] as int,
          'prestados': f['prestados'] as int,
          'precio': f['precio'] as int,
        },
    };
  }

  void actualizarBodega(String formato, int delta) {
    _db.execute(
      'UPDATE balance_envases SET bodega = bodega + ? WHERE formato = ?',
      [delta, formato],
    );
  }

  void actualizarPrestados(String formato, int delta) {
    _db.execute(
      'UPDATE balance_envases SET prestados = prestados + ? WHERE formato = ?',
      [delta, formato],
    );
  }

  void registrarPrestamo({
    required String id,
    required String cliente,
    required String formato,
    required int cantidad,
    required String fecha,
  }) {
    _db.execute(
      'INSERT INTO prestamos_envases (id, cliente, formato, cantidad, fecha) VALUES (?, ?, ?, ?, ?)',
      [id, cliente, formato, cantidad, fecha],
    );
  }

  List<Map<String, Object?>> listarPrestamosActivos() {
    return _db
        .select(
          'SELECT * FROM prestamos_envases WHERE devuelto = 0 ORDER BY fecha DESC',
        )
        .map(
          (f) => {
            'id': f['id'],
            'cliente': f['cliente'],
            'formato': f['formato'],
            'cantidad': f['cantidad'],
            'fecha': f['fecha'],
          },
        )
        .toList();
  }

  bool devolverPrestamo(String id) {
    _db.execute(
      'UPDATE prestamos_envases SET devuelto = 1 WHERE id = ? AND devuelto = 0',
      [id],
    );
    return _db.updatedRows > 0;
  }

  Row? obtenerPrestamo(String id) {
    final f = _db.select('SELECT * FROM prestamos_envases WHERE id = ?', [id]);
    return f.isEmpty ? null : f.first;
  }
}
