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

  /// Desfase de la zona del negocio respecto a UTC, para [diaNegocio].
  Duration get zonaHoraria =>
      parsearDesfase(leer('zonaHoraria') ?? '') ?? const Duration(hours: -6);
}
