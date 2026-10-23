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
    String? telefono,
    String? ventaId,
  }) {
    _db.execute(
      'INSERT INTO prestamos_envases (id, cliente, telefono, formato, cantidad, fecha, venta_id) '
      'VALUES (?, ?, ?, ?, ?, ?, ?)',
      [id, cliente, telefono, formato, cantidad, fecha, ventaId],
    );
  }

  /// Baja lo pendiente de un préstamo sin pasarlo a bodega (la venta que lo
  /// originó se devolvió). Si queda en 0, el préstamo se cierra.
  void reducirPrestamo(String id, int cantidad) {
    _db.execute(
      'UPDATE prestamos_envases SET devuelto = CASE WHEN cantidad = ? THEN 1 ELSE 0 END, '
      'cantidad = CASE WHEN cantidad = ? THEN cantidad ELSE cantidad - ? END '
      'WHERE id = ?',
      [cantidad, cantidad, cantidad, id],
    );
  }

  /// Anota un cambio del balance en la bitácora de envases.
  void registrarMovimiento({
    required String fecha,
    required String formato,
    required String tipo,
    int bodega = 0,
    int prestados = 0,
    String? cliente,
    int? monto,
    String? referencia,
    required String origen,
  }) {
    _db.execute(
      'INSERT INTO envase_movimientos (fecha, formato, tipo, bodega, prestados, '
      'cliente, monto, referencia, origen) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        fecha,
        formato,
        tipo,
        bodega,
        prestados,
        cliente,
        monto,
        referencia,
        origen,
      ],
    );
  }

  List<Map<String, Object?>> movimientos(int limite) => [
    for (final f in _db.select(
      'SELECT * FROM envase_movimientos ORDER BY id DESC LIMIT ?',
      [limite],
    ))
      {
        'id': f['id'],
        'fecha': f['fecha'],
        'formato': f['formato'],
        'tipo': f['tipo'],
        'bodega': f['bodega'],
        'prestados': f['prestados'],
        'cliente': f['cliente'],
        'monto': f['monto'],
        'referencia': f['referencia'],
      },
  ];

  /// Préstamos sin devolver que salieron con esa venta.
  List<Row> prestamosPendientesDeVenta(String ventaId) => _db.select(
    'SELECT * FROM prestamos_envases WHERE venta_id = ? AND devuelto = 0',
    [ventaId],
  );

  /// Marca devuelto un préstamo sin tocar sus cantidades (al cancelar la
  /// venta de un préstamo con devoluciones parciales).
  void cerrarPrestamo(String id) {
    _db.execute('UPDATE prestamos_envases SET devuelto = 1 WHERE id = ?', [id]);
  }

  void borrarPrestamo(String id) {
    _db.execute('DELETE FROM prestamos_envases WHERE id = ?', [id]);
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
            'telefono': f['telefono'],
            'formato': f['formato'],
            'cantidad': f['cantidad'],
            'devueltos': f['devueltos'],
            'fecha': f['fecha'],
          },
        )
        .toList();
  }

  /// Devuelve [cantidad] envases. Si es todo lo pendiente, el préstamo queda
  /// devuelto; si no, `cantidad` baja a lo que falta.
  void devolverPrestamo(String id, int cantidad, {required bool completo}) {
    _db.execute(
      completo
          ? 'UPDATE prestamos_envases SET devuelto = 1, devueltos = devueltos + ? '
                'WHERE id = ? AND devuelto = 0'
          : 'UPDATE prestamos_envases SET cantidad = cantidad - ?, '
                'devueltos = devueltos + ? WHERE id = ? AND devuelto = 0',
      completo ? [cantidad, id] : [cantidad, cantidad, id],
    );
  }

  Row? obtenerPrestamo(String id) {
    final f = _db.select('SELECT * FROM prestamos_envases WHERE id = ?', [id]);
    return f.isEmpty ? null : f.first;
  }
}
