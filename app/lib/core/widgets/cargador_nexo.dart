import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../app/tema/colores.dart';

/// Cargador fluido animado con efecto metaball de dos gotas que interactúan.
class CargadorNexo extends StatefulWidget {
  const CargadorNexo({
    super.key,
    this.tamano = 60.0,
    this.color,
  });

  final double tamano;
  final Color? color;

  @override
  State<CargadorNexo> createState() => _CargadorNexoState();
}

class _CargadorNexoState extends State<CargadorNexo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorEfectivo = widget.color ?? context.colores.azul;

    return AnimatedBuilder(
      animation: _controlador,
      builder: (context, child) {
        final progreso = CurvedAnimation(
          parent: _controlador,
          curve: Curves.easeInOutQuad,
        ).value;

        return CustomPaint(
          size: Size(widget.tamano * 2.4, widget.tamano),
          painter: _MetaballPainter(
            progreso: progreso,
            color: colorEfectivo,
          ),
        );
      },
    );
  }
}

class _MetaballPainter extends CustomPainter {
  _MetaballPainter({
    required this.progreso,
    required this.color,
  });

  final double progreso;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final centerY = size.height / 2;
    final centerX = size.width / 2;

    // Radio de la gota central fija y de la gota viajera
    final r1 = size.height * 0.28;
    final r2 = size.height * 0.20;

    // Centro fijo (gota principal)
    final c1 = Offset(centerX, centerY);

    // Centro móvil (viaja de izquierda a derecha)
    final amplitud = size.width * 0.35;
    final x2 = centerX - amplitud + (amplitud * 2 * progreso);
    final c2 = Offset(x2, centerY);

    final dx = c2.dx - c1.dx;
    final dy = c2.dy - c1.dy;
    final d = math.sqrt(dx * dx + dy * dy);

    final maxBridgeDistance = r1 + r2 + (size.height * 0.15);

    // Dibujar circulo 1 y 2 siempre
    final pathCombinado = Path();
    pathCombinado.addOval(Rect.fromCircle(center: c1, radius: r1));
    pathCombinado.addOval(Rect.fromCircle(center: c2, radius: r2));

    // Si están lo suficientemente cerca, dibujamos el cuello de interacción (puente fluido)
    if (d < maxBridgeDistance && d > 0.001) {
      final t = (1.0 - ((d - (r1 + r2)) / (maxBridgeDistance - (r1 + r2))))
          .clamp(0.0, 1.0);

      if (t > 0.01) {
        final angle = math.atan2(dy, dx);
        final spread1 = t * 0.82;
        final spread2 = t * 0.92;

        final a1 = angle + spread1;
        final a2 = angle - spread1;
        final b1 = angle + math.pi - spread2;
        final b2 = angle + math.pi + spread2;

        final p1a = Offset(c1.dx + r1 * math.cos(a1), c1.dy + r1 * math.sin(a1));
        final p1b = Offset(c1.dx + r1 * math.cos(a2), c1.dy + r1 * math.sin(a2));

        final p2a = Offset(c2.dx + r2 * math.cos(b1), c2.dy + r2 * math.sin(b1));
        final p2b = Offset(c2.dx + r2 * math.cos(b2), c2.dy + r2 * math.sin(b2));

        final midX = (c1.dx + c2.dx) / 2;
        final midY = (c1.dy + c2.dy) / 2;

        final nx = -math.sin(angle);
        final ny = math.cos(angle);

        final pinch = (1.0 - t) * (r1 + r2) * 0.4;

        final ctrl1 = Offset(midX + nx * pinch, midY + ny * pinch);
        final ctrl2 = Offset(midX - nx * pinch, midY - ny * pinch);

        final puente = Path()
          ..moveTo(p1a.dx, p1a.dy)
          ..quadraticBezierTo(ctrl1.dx, ctrl1.dy, p2a.dx, p2a.dy)
          ..lineTo(p2b.dx, p2b.dy)
          ..quadraticBezierTo(ctrl2.dx, ctrl2.dy, p1b.dx, p1b.dy)
          ..close();

        pathCombinado.addPath(puente, Offset.zero);
      }
    }

    canvas.drawPath(pathCombinado, paint);
  }

  @override
  bool shouldRepaint(_MetaballPainter oldDelegate) {
    return oldDelegate.progreso != progreso || oldDelegate.color != color;
  }
}
