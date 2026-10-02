import 'package:flutter/material.dart';

import '../../app/tema/colores.dart';

/// Logo de Anaquel: botella sobre un cuadro ámbar.
class LogoAnaquel extends StatelessWidget {
  const LogoAnaquel({super.key, this.tamano = 42});

  final double tamano;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        color: c.lager,
        borderRadius: BorderRadius.circular(tamano * 0.29),
      ),
      child: CustomPaint(painter: _Botella(c.lagerTinta)),
    );
  }
}

class _Botella extends CustomPainter {
  _Botella(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final p = Paint()..color = color;
    final cuerpo = Path()
      ..moveTo(w * 0.44, w * 0.18)
      ..lineTo(w * 0.56, w * 0.18)
      ..lineTo(w * 0.56, w * 0.36)
      ..quadraticBezierTo(w * 0.66, w * 0.42, w * 0.66, w * 0.52)
      ..lineTo(w * 0.66, w * 0.80)
      ..quadraticBezierTo(w * 0.66, w * 0.84, w * 0.62, w * 0.84)
      ..lineTo(w * 0.38, w * 0.84)
      ..quadraticBezierTo(w * 0.34, w * 0.84, w * 0.34, w * 0.80)
      ..lineTo(w * 0.34, w * 0.52)
      ..quadraticBezierTo(w * 0.34, w * 0.42, w * 0.44, w * 0.36)
      ..close();
    canvas.drawPath(cuerpo, p);
    canvas.drawRect(
      Rect.fromLTRB(w * 0.34, w * 0.56, w * 0.66, w * 0.68),
      Paint()..color = const Color(0xFFF0A500),
    );
  }

  @override
  bool shouldRepaint(_Botella old) => old.color != color;
}

/// Píldora gris con texto secundario (fecha, IP, versión).
class Pildora extends StatelessWidget {
  const Pildora({super.key, required this.texto, this.icono});

  final String texto;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.superficie2,
        border: Border.all(color: c.linea),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 16, color: c.tinta2),
            const SizedBox(width: 6),
          ],
          Text(
            texto,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: c.tinta2,
            ),
          ),
        ],
      ),
    );
  }
}
