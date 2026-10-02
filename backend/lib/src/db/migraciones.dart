import 'package:sqlite3/sqlite3.dart';

import '../comun/fechas.dart';
import 'base_datos.dart';
import 'migraciones/m001_inicial.dart';

class Migracion {
  const Migracion(this.numero, this.nombre, this.sql);

  final int numero;
  final String nombre;
  final String sql;
}

/// Todas las migraciones, en orden.
///
/// Reglas:
/// - Nunca se edita una migración ya publicada en un tag; se agrega otra.
/// - El número es consecutivo y no se repite (lo comprueba una prueba).
/// - Viven como texto en Dart y no como archivos .sql porque la app de
///   Flutter no puede leer archivos sueltos del paquete del backend.
const migraciones = <Migracion>[m001Inicial];

/// Aplica las migraciones pendientes, cada una en su transacción.
///
/// Si la base ya tenía datos y hay migraciones pendientes, antes guarda una
/// copia completa en [rutaRespaldo] (por ejemplo, al actualizar la app).
/// Regresa los números aplicados.
List<int> aplicarMigraciones(
  Database db, {
  String? Function(int versionActual)? rutaRespaldo,
  Reloj reloj = relojSistema,
}) {
  db.execute('''
    CREATE TABLE IF NOT EXISTS esquema_migraciones (
      numero  INTEGER PRIMARY KEY,
      nombre  TEXT NOT NULL,
      aplicada TEXT NOT NULL
    )
  ''');
  final actual = versionEsquema(db);
  final pendientes = migraciones.where((m) => m.numero > actual).toList();
  if (pendientes.isEmpty) return const [];

  if (actual > 0) {
    final ruta = rutaRespaldo?.call(actual);
    if (ruta != null) db.execute('VACUUM INTO ?', [ruta]);
  }

  for (final m in pendientes) {
    transaccion(db, () {
      db.execute(m.sql);
      db.execute(
        'INSERT INTO esquema_migraciones (numero, nombre, aplicada) VALUES (?, ?, ?)',
        [m.numero, m.nombre, instanteIso(reloj())],
      );
    });
  }
  return [for (final m in pendientes) m.numero];
}

int versionEsquema(Database db) =>
    db
            .select(
              'SELECT COALESCE(MAX(numero), 0) AS v FROM esquema_migraciones',
            )
            .first['v']
        as int;
