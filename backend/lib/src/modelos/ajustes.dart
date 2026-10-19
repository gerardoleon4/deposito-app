/// Datos del negocio para el ticket (`GET /api/v1/ajustes`).
class AjustesNegocio {
  const AjustesNegocio({
    this.nombreNegocio,
    this.direccion,
    this.telefono,
    this.mensajeTicket,
  });

  final String? nombreNegocio;
  final String? direccion;
  final String? telefono;
  final String? mensajeTicket;

  /// Claves que se guardan en la tabla `ajustes`.
  static const claves = [
    'nombreNegocio',
    'direccion',
    'telefono',
    'mensajeTicket',
  ];

  factory AjustesNegocio.fromJson(Map<String, Object?> j) => AjustesNegocio(
    nombreNegocio: j['nombreNegocio'] as String?,
    direccion: j['direccion'] as String?,
    telefono: j['telefono'] as String?,
    mensajeTicket: j['mensajeTicket'] as String?,
  );

  Map<String, Object?> toJson() => {
    'nombreNegocio': nombreNegocio,
    'direccion': direccion,
    'telefono': telefono,
    'mensajeTicket': mensajeTicket,
  };
}
