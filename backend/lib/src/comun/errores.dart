/// Error que la API devuelve al cliente con el formato del contrato.
///
/// Las rutas y servicios lanzan [ErrorApi]; el middleware de errores lo
/// convierte en `{ "error": { "codigo", "mensaje", "campos"? } }`.
class ErrorApi implements Exception {
  ErrorApi(this.estado, this.codigo, this.mensaje, {this.campos});

  final int estado;
  final String codigo;
  final String mensaje;

  /// Campo → explicación, solo en `datos_invalidos`.
  final Map<String, String>? campos;

  factory ErrorApi.datosInvalidos(Map<String, String> campos) => ErrorApi(
    400,
    'datos_invalidos',
    'Revisa los campos marcados',
    campos: campos,
  );

  factory ErrorApi.jsonInvalido() => ErrorApi(
    400,
    'json_invalido',
    'El cuerpo de la petición no es JSON válido',
  );

  factory ErrorApi.noAutorizado() => ErrorApi(
    401,
    'no_autorizado',
    'Falta la clave de terminal o ya no es válida',
  );

  factory ErrorApi.codigoInvalido() => ErrorApi(
    401,
    'codigo_invalido',
    'El código de emparejamiento es incorrecto o ya venció',
  );

  factory ErrorApi.soloCaja() => ErrorApi(
    403,
    'solo_caja',
    'Esta acción solo se puede hacer desde la caja',
  );

  factory ErrorApi.noEncontrado(String que) =>
      ErrorApi(404, 'no_encontrado', 'No existe $que');

  factory ErrorApi.codigoDuplicado(String codigo) => ErrorApi(
    409,
    'codigo_duplicado',
    'Ya existe un producto con el código $codigo',
  );

  factory ErrorApi.stockInsuficiente(String nombre, int disponibles) =>
      ErrorApi(
        409,
        'stock_insuficiente',
        'No hay suficiente $nombre: quedan $disponibles piezas',
      );

  factory ErrorApi.interno() => ErrorApi(
    500,
    'error_interno',
    'Ocurrió un error inesperado. Quedó registrado en el log',
  );

  Map<String, Object?> toJson() => {
    'error': {
      'codigo': codigo,
      'mensaje': mensaje,
      if (campos != null) 'campos': campos,
    },
  };

  @override
  String toString() => 'ErrorApi($estado $codigo: $mensaje)';
}
