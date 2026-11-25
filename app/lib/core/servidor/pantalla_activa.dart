import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Mantiene la pantalla encendida mientras la app funciona como Caja.
///
/// En iOS/iPadOS evita que el sistema suspenda el servidor embebido por
/// inactividad; en Android evita que se apague la pantalla de mostrador.
abstract final class PantallaActiva {
  static const _canal = MethodChannel('com.anaquel/pantalla');

  static Future<void> mantenerEncendida(bool activa) async {
    if (kIsWeb) return;
    try {
      await _canal.invokeMethod<void>('mantenerEncendida', {'activa': activa});
    } on MissingPluginException {
      // En pruebas unitarias o entornos sin canal nativo se ignora.
    }
  }
}
