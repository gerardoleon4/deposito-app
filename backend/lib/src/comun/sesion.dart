import 'package:shelf/shelf.dart';

import 'errores.dart';

enum Rol { caja, terminal }

/// Quién hace la petición. La pone el middleware de autenticación.
class Sesion {
  const Sesion.caja() : rol = Rol.caja, terminalId = null, nombre = 'Caja';

  const Sesion.terminal({required String id, required this.nombre})
    : rol = Rol.terminal,
      terminalId = id;

  final Rol rol;
  final String? terminalId;

  /// Se guarda como `origen` en movimientos, ventas y pedidos.
  final String nombre;

  bool get esCaja => rol == Rol.caja;
}

const _llave = 'anaquel.sesion';

Request conSesion(Request peticion, Sesion sesion) =>
    peticion.change(context: {_llave: sesion});

Sesion sesionDe(Request peticion) {
  final sesion = peticion.context[_llave];
  if (sesion is! Sesion) throw ErrorApi.noAutorizado();
  return sesion;
}

/// Para endpoints marcados "Solo caja" en el contrato.
Sesion exigirCaja(Request peticion) {
  final sesion = sesionDe(peticion);
  if (!sesion.esCaja) throw ErrorApi.soloCaja();
  return sesion;
}
