import 'package:sqlite3/sqlite3.dart';

import '../modelos/usuario.dart';

class RepositorioUsuarios {
  RepositorioUsuarios(this._db);
  final Database _db;

  /// Sal de los PIN de esta base (m006).
  String get sal =>
      _db
              .select("SELECT valor FROM ajustes WHERE clave = 'salPin'")
              .first['valor']
          as String;

  List<Usuario> listar() => [
    for (final f in _db.select(
      'SELECT * FROM usuarios ORDER BY nombre, creado',
    ))
      _usuario(f),
  ];

  Usuario? porId(String id) {
    final r = _db.select('SELECT * FROM usuarios WHERE id = ?', [id]);
    return r.isEmpty ? null : _usuario(r.first);
  }

  /// Usuario activo con ese hash de PIN.
  Usuario? activoPorPin(String pinHash) {
    final r = _db.select(
      'SELECT * FROM usuarios WHERE pin_hash = ? AND activo = 1',
      [pinHash],
    );
    return r.isEmpty ? null : _usuario(r.first);
  }

  int contar() =>
      _db.select('SELECT COUNT(*) AS n FROM usuarios').first['n'] as int;

  int contarActivos({required Set<String> roles}) =>
      _db
              .select(
                'SELECT COUNT(*) AS n FROM usuarios WHERE activo = 1 AND rol IN '
                '(${List.filled(roles.length, '?').join(', ')})',
                roles.toList(),
              )
              .first['n']
          as int;

  void insertar({
    required String id,
    required String nombre,
    required String rol,
    required String pinHash,
    required String creado,
  }) {
    _db.execute(
      'INSERT INTO usuarios (id, nombre, rol, pin_hash, creado) VALUES (?, ?, ?, ?, ?)',
      [id, nombre, rol, pinHash, creado],
    );
  }

  void actualizar(
    String id, {
    required String nombre,
    required String rol,
    required bool activo,
    String? pinHash,
  }) {
    _db.execute(
      'UPDATE usuarios SET nombre = ?, rol = ?, activo = ?, '
      'pin_hash = COALESCE(?, pin_hash) WHERE id = ?',
      [nombre, rol, activo ? 1 : 0, pinHash, id],
    );
  }

  Usuario _usuario(Row f) => Usuario(
    id: f['id'] as String,
    nombre: f['nombre'] as String,
    rol: f['rol'] as String,
    activo: (f['activo'] as int) == 1,
    creado: f['creado'] as String,
  );
}
