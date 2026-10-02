import 'package:sqlite3/sqlite3.dart';

import '../modelos/terminal.dart';

class RepositorioTerminales {
  RepositorioTerminales(this._db);

  final Database _db;

  void insertar(Terminal t, {required String claveHash}) {
    _db.execute(
      'INSERT INTO terminales (id, nombre, clave_hash, registrada, ultima_conexion) '
      'VALUES (?, ?, ?, ?, ?)',
      [t.id, t.nombre, claveHash, t.registrada, t.ultimaConexion],
    );
  }

  List<Terminal> listarActivas() => _db
      .select('SELECT * FROM terminales WHERE revocada = 0 ORDER BY registrada')
      .map(_desdeFila)
      .toList();

  Terminal? activaPorHash(String claveHash) {
    final filas = _db.select(
      'SELECT * FROM terminales WHERE clave_hash = ? AND revocada = 0',
      [claveHash],
    );
    return filas.isEmpty ? null : _desdeFila(filas.first);
  }

  void marcarConexion(String id, String fecha) {
    _db.execute('UPDATE terminales SET ultima_conexion = ? WHERE id = ?', [
      fecha,
      id,
    ]);
  }

  /// Regresa `false` si no existía o ya estaba revocada.
  bool revocar(String id) {
    _db.execute(
      'UPDATE terminales SET revocada = 1 WHERE id = ? AND revocada = 0',
      [id],
    );
    return _db.updatedRows > 0;
  }

  static Terminal _desdeFila(Row f) => Terminal(
    id: f['id'] as String,
    nombre: f['nombre'] as String,
    registrada: f['registrada'] as String,
    ultimaConexion: f['ultima_conexion'] as String,
  );
}
