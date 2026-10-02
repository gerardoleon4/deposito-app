import 'dart:convert';

import 'package:shelf/shelf.dart';

import 'errores.dart';
import 'fechas.dart';

const _cabecerasJson = {'content-type': 'application/json; charset=utf-8'};

Response respuestaJson(Object? cuerpo, {int estado = 200}) =>
    Response(estado, body: jsonEncode(cuerpo), headers: _cabecerasJson);

/// Lee el cuerpo como objeto JSON o lanza `json_invalido`.
Future<Map<String, Object?>> leerObjetoJson(Request peticion) async {
  final texto = await peticion.readAsString();
  try {
    final valor = jsonDecode(texto);
    if (valor is Map<String, Object?>) return valor;
  } on FormatException {
    // Se responde abajo con el mismo error.
  }
  throw ErrorApi.jsonInvalido();
}

/// Junta los errores de todos los campos para responderlos de una vez.
///
/// ```dart
/// final v = Validador(cuerpo);
/// final nombre = v.texto('nombre', max: 80);
/// final precio = v.centavos('precio');
/// v.comprobar(); // lanza datos_invalidos si algo falló
/// ```
class Validador {
  Validador(this._datos);

  final Map<String, Object?> _datos;
  final errores = <String, String>{};

  bool presente(String campo) => _datos[campo] != null;

  void error(String campo, String mensaje) =>
      errores.putIfAbsent(campo, () => mensaje);

  String? texto(
    String campo, {
    bool requerido = true,
    int min = 1,
    required int max,
    RegExp? patron,
    String? mensajePatron,
  }) {
    final v = _datos[campo];
    if (v == null) {
      if (requerido) error(campo, 'Es obligatorio');
      return null;
    }
    if (v is! String) {
      error(campo, 'Debe ser texto');
      return null;
    }
    final t = v.trim();
    if (t.length < min || t.length > max) {
      error(
        campo,
        min == max
            ? 'Debe tener $max caracteres'
            : 'Debe tener de $min a $max caracteres',
      );
      return null;
    }
    if (patron != null && !patron.hasMatch(t)) {
      error(campo, mensajePatron ?? 'Formato no válido');
      return null;
    }
    return t;
  }

  int? entero(
    String campo, {
    bool requerido = true,
    int? min,
    String? mensaje,
  }) {
    final v = _datos[campo];
    if (v == null) {
      if (requerido) error(campo, 'Es obligatorio');
      return null;
    }
    if (v is! int || (min != null && v < min)) {
      error(
        campo,
        mensaje ??
            (min == null
                ? 'Debe ser un entero'
                : 'Debe ser un entero mayor o igual a $min'),
      );
      return null;
    }
    return v;
  }

  /// Dinero en centavos: entero mayor que 0. `42.5` es error, no se redondea.
  int? centavos(String campo, {bool requerido = true}) => entero(
    campo,
    requerido: requerido,
    min: 1,
    mensaje: 'Debe ser un entero mayor que 0 (centavos)',
  );

  String? opcion(String campo, Set<String> opciones, {bool requerido = true}) {
    final v = _datos[campo];
    if (v == null) {
      if (requerido) error(campo, 'Es obligatorio');
      return null;
    }
    if (v is! String || !opciones.contains(v)) {
      error(campo, 'Debe ser uno de: ${opciones.join(', ')}');
      return null;
    }
    return v;
  }

  /// Fecha de calendario `AAAA-MM-DD`.
  String? fecha(String campo, {bool requerido = true}) {
    final v = _datos[campo];
    if (v == null) {
      if (requerido) error(campo, 'Es obligatorio');
      return null;
    }
    if (v is! String || parsearFecha(v) == null) {
      error(campo, 'Debe ser una fecha válida AAAA-MM-DD');
      return null;
    }
    return v;
  }

  void comprobar() {
    if (errores.isNotEmpty) throw ErrorApi.datosInvalidos(errores);
  }
}
