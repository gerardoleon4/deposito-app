/// Roles del personal: el dueño y el gerente autorizan cancelaciones.
const rolesUsuario = {'dueno', 'gerente', 'cajero'};

/// Persona del depósito (`GET /api/v1/usuarios`). El PIN nunca viaja.
class Usuario {
  const Usuario({
    required this.id,
    required this.nombre,
    required this.rol,
    required this.activo,
    required this.creado,
  });

  final String id;
  final String nombre;

  /// Uno de [rolesUsuario].
  final String rol;
  final bool activo;

  /// ISO 8601 UTC.
  final String creado;

  /// Puede autorizar cancelaciones, devoluciones y altas de personal.
  bool get autoriza => rol == 'dueno' || rol == 'gerente';

  factory Usuario.fromJson(Map<String, Object?> j) => Usuario(
    id: j['id'] as String,
    nombre: j['nombre'] as String,
    rol: j['rol'] as String,
    activo: j['activo'] as bool,
    creado: j['creado'] as String,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'nombre': nombre,
    'rol': rol,
    'activo': activo,
    'creado': creado,
  };
}

/// Referencia corta a un usuario dentro de otro objeto (venta, turno).
class UsuarioBreve {
  const UsuarioBreve({required this.id, required this.nombre});

  final String id;
  final String nombre;

  static UsuarioBreve? deJson(Object? j) => j == null
      ? null
      : UsuarioBreve(
          id: (j as Map)['id'] as String,
          nombre: j['nombre'] as String,
        );

  Map<String, Object?> toJson() => {'id': id, 'nombre': nombre};
}
