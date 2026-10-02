import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

final _aleatorio = Random.secure();
const _alfabetoId = '0123456789abcdefghijkmnpqrstuvwxyz';

/// ID con prefijo por tipo (`p_`, `t_`...) y 10 caracteres aleatorios.
String generarId(String prefijo) {
  final sufijo = List.generate(
    10,
    (_) => _alfabetoId[_aleatorio.nextInt(_alfabetoId.length)],
  ).join();
  return '${prefijo}_$sufijo';
}

/// Clave secreta de 32 bytes en base64 URL (43 caracteres, sin relleno).
String generarClave() {
  final bytes = List<int>.generate(32, (_) => _aleatorio.nextInt(256));
  return base64Url.encode(bytes).replaceAll('=', '');
}

/// Código numérico de [digitos] dígitos para emparejar terminales.
String generarCodigoNumerico(int digitos) =>
    List.generate(digitos, (_) => _aleatorio.nextInt(10)).join();

/// Hash que se guarda en la base de datos en lugar de la clave.
String hashClave(String clave) => sha256.convert(utf8.encode(clave)).toString();

/// Compara sin salir antes al primer carácter distinto, para no filtrar
/// información por el tiempo de respuesta.
bool igualesSeguro(String a, String b) {
  if (a.length != b.length) return false;
  var diferencia = 0;
  for (var i = 0; i < a.length; i++) {
    diferencia |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diferencia == 0;
}
