import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import '../comun/seguridad.dart';

/// Qué tan listo está un archivo para restaurarse.
enum EstadoRespaldo {
  /// No es una base de Anaquel (o está dañada).
  noEsRespaldo,

  /// Tiene dueño: hay que pedir su PIN.
  requierePin,

  /// El PIN no es del dueño de ese respaldo.
  pinIncorrecto,

  /// Se puede restaurar.
  valido,
}

/// Revisa el respaldo en [ruta] sin modificarlo. Con [pin], comprueba que
/// sea el de un dueño activo de ESE respaldo (no el de la base actual).
EstadoRespaldo verificarRespaldo(String ruta, {String? pin}) {
  final Database db;
  try {
    db = sqlite3.open(ruta, mode: OpenMode.readOnly);
  } catch (_) {
    return EstadoRespaldo.noEsRespaldo;
  }
  try {
    final tablas = {
      for (final f in db.select(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      ))
        f['name'] as String,
    };
    if (!tablas.containsAll({'esquema_migraciones', 'productos'})) {
      return EstadoRespaldo.noEsRespaldo;
    }
    if (!tablas.contains('usuarios')) return EstadoRespaldo.valido;
    final duenos = db.select(
      "SELECT pin_hash FROM usuarios WHERE rol = 'dueno' AND activo = 1",
    );
    if (duenos.isEmpty) return EstadoRespaldo.valido;
    if (pin == null) return EstadoRespaldo.requierePin;
    final sal =
        db
                .select("SELECT valor FROM ajustes WHERE clave = 'salPin'")
                .first['valor']
            as String;
    final hash = hashClave('$sal:$pin');
    return duenos.any((f) => igualesSeguro(f['pin_hash'] as String, hash))
        ? EstadoRespaldo.valido
        : EstadoRespaldo.pinIncorrecto;
  } on SqliteException {
    return EstadoRespaldo.noEsRespaldo;
  } finally {
    db.close();
  }
}

/// Reemplaza la base [destino] con el respaldo [origen]. Solo con el
/// servidor detenido. Antes guarda la base actual como `destino.antes`.
void restaurarRespaldo(String origen, String destino) {
  final actual = File(destino);
  if (actual.existsSync()) actual.copySync('$destino.antes');
  for (final extra in ['-wal', '-shm']) {
    final f = File('$destino$extra');
    if (f.existsSync()) f.deleteSync();
  }
  File(origen).copySync(destino);
}
