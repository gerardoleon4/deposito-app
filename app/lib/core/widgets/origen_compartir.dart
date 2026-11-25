import 'package:flutter/material.dart';

/// Posición desde la que se abre la hoja de compartir en iPadOS.
///
/// Sin `bounds` / `sharePositionOrigin`, iPadOS lanza una excepción fatal de
/// `UIPopoverPresentationController`.
Rect origenCompartir(BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  if (box != null && box.hasSize) {
    final pos = box.localToGlobal(Offset.zero);
    if (box.size.width > 0 && box.size.height > 0) {
      return pos & box.size;
    }
  }
  final size = MediaQuery.maybeSizeOf(context);
  final ancho = size?.width ?? 800;
  return Rect.fromLTWH(ancho / 2 - 1, 80, 2, 2);
}
