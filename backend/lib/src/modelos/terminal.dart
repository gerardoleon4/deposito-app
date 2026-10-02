class Terminal {
  const Terminal({
    required this.id,
    required this.nombre,
    required this.registrada,
    required this.ultimaConexion,
    this.conectada = false,
  });

  final String id;
  final String nombre;

  /// ISO 8601 UTC.
  final String registrada;
  final String ultimaConexion;

  /// Tiene un WebSocket abierto en este momento.
  final bool conectada;

  Terminal conConexion(bool conectada) => Terminal(
    id: id,
    nombre: nombre,
    registrada: registrada,
    ultimaConexion: ultimaConexion,
    conectada: conectada,
  );

  factory Terminal.fromJson(Map<String, Object?> j) => Terminal(
    id: j['id'] as String,
    nombre: j['nombre'] as String,
    registrada: j['registrada'] as String,
    ultimaConexion: j['ultimaConexion'] as String,
    conectada: j['conectada'] as bool? ?? false,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'nombre': nombre,
    'registrada': registrada,
    'ultimaConexion': ultimaConexion,
    'conectada': conectada,
  };
}

/// Código de emparejamiento que la caja muestra en el QR.
class CodigoEmparejamiento {
  const CodigoEmparejamiento({required this.codigo, required this.expira});

  final String codigo;

  /// ISO 8601 UTC.
  final String expira;

  factory CodigoEmparejamiento.fromJson(Map<String, Object?> j) =>
      CodigoEmparejamiento(
        codigo: j['codigo'] as String,
        expira: j['expira'] as String,
      );

  Map<String, Object?> toJson() => {'codigo': codigo, 'expira': expira};
}
