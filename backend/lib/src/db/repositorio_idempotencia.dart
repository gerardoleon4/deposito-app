import 'package:sqlite3/sqlite3.dart';

/// Respuestas guardadas por `X-Clave-Idempotencia`: un reintento de la app
/// recibe la misma respuesta en lugar de repetir un cobro o un movimiento.
class RepositorioIdempotencia {
  RepositorioIdempotencia(this._db);
  final Database _db;

  /// Respuesta guardada para esa clave, o `null`.
  String? respuestaGuardada(String clave) {
    final r = _db.select('SELECT respuesta FROM idempotencia WHERE clave = ?', [
      clave,
    ]);
    return r.isEmpty ? null : r.first['respuesta'] as String;
  }

  void guardarRespuesta(String clave, String respuesta, String fecha) {
    _db.execute(
      'INSERT INTO idempotencia (clave, respuesta, creado) VALUES (?, ?, ?)',
      [clave, respuesta, fecha],
    );
  }
}
