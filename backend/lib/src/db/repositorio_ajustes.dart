import 'package:sqlite3/sqlite3.dart';

import '../comun/fechas.dart';

class RepositorioAjustes {
  RepositorioAjustes(this._db);

  final Database _db;

  String? leer(String clave) {
    final filas = _db.select('SELECT valor FROM ajustes WHERE clave = ?', [
      clave,
    ]);
    return filas.isEmpty ? null : filas.first['valor'] as String;
  }

  /// Guarda [valor] en [clave]; `null` la borra.
  void escribir(String clave, String? valor) {
    if (valor == null) {
      _db.execute('DELETE FROM ajustes WHERE clave = ?', [clave]);
    } else {
      _db.execute(
        'INSERT INTO ajustes (clave, valor) VALUES (?, ?) '
        'ON CONFLICT (clave) DO UPDATE SET valor = excluded.valor',
        [clave, valor],
      );
    }
  }

  /// Desfase de la zona del negocio respecto a UTC, para [diaNegocio].
  Duration get zonaHoraria =>
      parsearDesfase(leer('zonaHoraria') ?? '') ?? const Duration(hours: -6);
}
