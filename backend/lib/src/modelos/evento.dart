/// Tipos de evento del WebSocket (docs/API.md, sección WebSocket).
abstract final class TiposEvento {
  static const conexionLista = 'conexion.lista';
  static const productoActualizado = 'producto.actualizado';
}

/// Mensaje del servidor: `{ "tipo", "datos", "fecha" }`.
class Evento {
  const Evento({required this.tipo, required this.datos, required this.fecha});

  final String tipo;
  final Map<String, Object?> datos;

  /// ISO 8601 UTC.
  final String fecha;

  factory Evento.fromJson(Map<String, Object?> j) => Evento(
    tipo: j['tipo'] as String,
    datos: (j['datos'] as Map).cast<String, Object?>(),
    fecha: j['fecha'] as String,
  );

  Map<String, Object?> toJson() => {
    'tipo': tipo,
    'datos': datos,
    'fecha': fecha,
  };
}
