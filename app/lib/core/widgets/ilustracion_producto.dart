import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';

import '../../app/tema/colores.dart';
import '../../app/tema/tema.dart';

/// Ilustración del producto mientras no tenga foto (Sprint 2): una botella,
/// lata, bolsa o bolsa de hielo según su envase y categoría, sobre el color
/// de su categoría. Se dibuja en código: no pesa ni necesita internet.
class IlustracionProducto extends StatelessWidget {
  const IlustracionProducto({
    super.key,
    required this.producto,
    this.radio = Radios.imagen,
  });

  final Producto producto;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radio),
      child: ColoredBox(
        color: c.fondoCategoria(producto.categoria),
        child: CustomPaint(
          painter: _Pintor(
            forma: _formaDe(producto),
            acento: _acentoDe(producto),
            oscuro: Theme.of(context).brightness == Brightness.dark,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

enum _Forma { mega, media, cuarto, pet, bolsa, hielo, caja }

_Forma _formaDe(Producto p) => switch ((p.envase, p.categoria)) {
  ('mega', _) => _Forma.mega,
  ('media', _) => _Forma.media,
  ('cuarto', _) => _Forma.cuarto,
  (_, 'cerveza') => _Forma.media,
  (_, 'refresco') => _Forma.pet,
  (_, 'botana') => _Forma.bolsa,
  (_, 'hielo') => _Forma.hielo,
  _ => _Forma.caja,
};

/// Color de la etiqueta, estable por producto para que cada uno se reconozca.
Color _acentoDe(Producto p) {
  const acentos = [
    Color(0xFFE0B04A),
    Color(0xFF2F5DA8),
    Color(0xFFD9722E),
    Color(0xFFC62828),
    Color(0xFF2E8B57),
    Color(0xFFF2C230),
  ];
  final h = p.codigo.codeUnits.fold<int>(
    7,
    (a, b) => (a * 31 + b) & 0x7fffffff,
  );
  return acentos[h % acentos.length];
}

class _Pintor extends CustomPainter {
  _Pintor({required this.forma, required this.acento, required this.oscuro});

  final _Forma forma;
  final Color acento;
  final bool oscuro;

  static const _vidrio = Color(0xFF7A3E12);
  static const _vidrioClaro = Color(0xFFB7892B);
  static const _tapa = Color(0xFFC9A44C);

  @override
  void paint(Canvas canvas, Size s) {
    final sombra = Paint()
      ..color = Colors.black.withValues(alpha: oscuro ? 0.35 : 0.12);
    final base = s.height * 0.88;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s.width / 2, base + 2),
        width: s.shortestSide * 0.42,
        height: 6,
      ),
      sombra,
    );
    switch (forma) {
      case _Forma.mega:
        _botella(canvas, s, alto: 0.80, ancho: 0.30);
      case _Forma.media:
        _botella(canvas, s, alto: 0.66, ancho: 0.26);
      case _Forma.cuarto:
        _botella(canvas, s, alto: 0.52, ancho: 0.24);
      case _Forma.pet:
        _pet(canvas, s);
      case _Forma.bolsa:
        _bolsa(canvas, s);
      case _Forma.hielo:
        _hielo(canvas, s);
      case _Forma.caja:
        _caja(canvas, s);
    }
  }

  void _botella(
    Canvas canvas,
    Size s, {
    required double alto,
    required double ancho,
  }) {
    final cx = s.width / 2;
    final base = s.height * 0.88;
    final h = s.height * alto;
    final bw = s.shortestSide * ancho;
    final nw = bw * 0.38;
    final arriba = base - h;
    final hombro = arriba + h * 0.42;
    final cuello = arriba + h * 0.10;

    final cuerpo = Path()
      ..moveTo(cx - nw / 2, cuello)
      ..lineTo(cx - nw / 2, hombro - h * 0.10)
      ..quadraticBezierTo(
        cx - bw / 2,
        hombro - h * 0.02,
        cx - bw / 2,
        hombro + h * 0.10,
      )
      ..lineTo(cx - bw / 2, base - 6)
      ..quadraticBezierTo(cx - bw / 2, base, cx - bw / 2 + 6, base)
      ..lineTo(cx + bw / 2 - 6, base)
      ..quadraticBezierTo(cx + bw / 2, base, cx + bw / 2, base - 6)
      ..lineTo(cx + bw / 2, hombro + h * 0.10)
      ..quadraticBezierTo(
        cx + bw / 2,
        hombro - h * 0.02,
        cx + nw / 2,
        hombro - h * 0.10,
      )
      ..lineTo(cx + nw / 2, cuello)
      ..close();
    canvas.drawPath(
      cuerpo,
      Paint()
        ..shader = const LinearGradient(
          colors: [_vidrioClaro, _vidrio, Color(0xFF4A2408)],
          stops: [0, 0.45, 1],
        ).createShader(Rect.fromLTRB(cx - bw / 2, arriba, cx + bw / 2, base)),
    );

    // Tapa corona.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(cx - nw / 2 - 1.5, arriba, cx + nw / 2 + 1.5, cuello + 1),
        const Radius.circular(2),
      ),
      Paint()..color = _tapa,
    );

    // Etiqueta.
    final etiqueta = Rect.fromLTRB(
      cx - bw / 2,
      hombro + h * 0.16,
      cx + bw / 2,
      hombro + h * 0.44,
    );
    canvas.drawRect(etiqueta, Paint()..color = acento);
    canvas.drawRect(
      Rect.fromLTRB(
        etiqueta.left,
        etiqueta.center.dy - 2,
        etiqueta.right,
        etiqueta.center.dy + 2,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
    // Cuello con etiqueta pequeña.
    canvas.drawRect(
      Rect.fromLTRB(
        cx - nw / 2,
        cuello + h * 0.10,
        cx + nw / 2,
        cuello + h * 0.17,
      ),
      Paint()..color = acento,
    );
    // Brillo del vidrio.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          cx - bw / 2 + bw * 0.16,
          hombro + h * 0.06,
          bw * 0.08,
          h * 0.44,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
  }

  void _pet(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final base = s.height * 0.88;
    final h = s.height * 0.72;
    final bw = s.shortestSide * 0.28;
    final arriba = base - h;
    final cuerpo = Path()
      ..moveTo(cx - bw * 0.2, arriba + h * 0.08)
      ..quadraticBezierTo(
        cx - bw / 2,
        arriba + h * 0.18,
        cx - bw / 2,
        arriba + h * 0.32,
      )
      ..lineTo(cx - bw / 2, base - 8)
      ..quadraticBezierTo(cx - bw / 2, base, cx - bw / 2 + 8, base)
      ..lineTo(cx + bw / 2 - 8, base)
      ..quadraticBezierTo(cx + bw / 2, base, cx + bw / 2, base - 8)
      ..lineTo(cx + bw / 2, arriba + h * 0.32)
      ..quadraticBezierTo(
        cx + bw / 2,
        arriba + h * 0.18,
        cx + bw * 0.2,
        arriba + h * 0.08,
      )
      ..close();
    canvas.drawPath(cuerpo, Paint()..color = const Color(0xFF3A1C10));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          cx - bw * 0.22,
          arriba,
          cx + bw * 0.22,
          arriba + h * 0.09,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = acento,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        cx - bw / 2,
        arriba + h * 0.42,
        cx + bw / 2,
        arriba + h * 0.66,
      ),
      Paint()..color = acento,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        cx - bw / 2,
        arriba + h * 0.52,
        cx + bw / 2,
        arriba + h * 0.56,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );
  }

  void _bolsa(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final base = s.height * 0.88;
    final w = s.shortestSide * 0.48;
    final h = s.height * 0.66;
    final r = Rect.fromLTRB(cx - w / 2, base - h, cx + w / 2, base);
    final bolsa = Path()..moveTo(r.left, r.top);
    const dientes = 7;
    for (var i = 0; i < dientes; i++) {
      final x0 = r.left + r.width * i / dientes;
      bolsa
        ..lineTo(x0 + r.width / dientes / 2, r.top + 5)
        ..lineTo(x0 + r.width / dientes, r.top);
    }
    bolsa
      ..quadraticBezierTo(r.right + 4, r.center.dy, r.right, r.bottom)
      ..lineTo(r.left, r.bottom)
      ..quadraticBezierTo(r.left - 4, r.center.dy, r.left, r.top)
      ..close();
    canvas.drawPath(bolsa, Paint()..color = acento);
    canvas.drawCircle(
      r.center.translate(0, h * 0.06),
      w * 0.22,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      r.center.translate(0, h * 0.06),
      w * 0.14,
      Paint()..color = const Color(0xFFE3B23C),
    );
    canvas.drawRect(
      Rect.fromLTRB(
        r.left + 6,
        r.top + h * 0.14,
        r.right - 6,
        r.top + h * 0.22,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.6),
    );
  }

  void _hielo(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final base = s.height * 0.88;
    final w = s.shortestSide * 0.52;
    final h = s.height * 0.62;
    final r = RRect.fromRectAndCorners(
      Rect.fromLTRB(cx - w / 2, base - h, cx + w / 2, base),
      topLeft: const Radius.circular(6),
      topRight: const Radius.circular(6),
      bottomLeft: const Radius.circular(14),
      bottomRight: const Radius.circular(14),
    );
    canvas.drawRRect(
      r,
      Paint()..color = const Color(0xFF6FB3D2).withValues(alpha: 0.55),
    );
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF3E86A8),
    );
    final cubo = Paint()..color = Colors.white.withValues(alpha: 0.75);
    final lado = w * 0.2;
    for (final (dx, dy) in [
      (-0.22, 0.30),
      (0.08, 0.36),
      (-0.08, 0.6),
      (0.2, 0.62),
      (-0.26, 0.74),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx + w * dx, r.top + h * dy, lado, lado),
          const Radius.circular(3),
        ),
        cubo,
      );
    }
    canvas.drawRect(
      Rect.fromLTRB(r.left, r.top + h * 0.08, r.right, r.top + h * 0.16),
      Paint()..color = const Color(0xFF3E86A8),
    );
  }

  void _caja(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final base = s.height * 0.88;
    final w = s.shortestSide * 0.5;
    final h = s.height * 0.5;
    final r = Rect.fromLTRB(cx - w / 2, base - h, cx + w / 2, base);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(6)),
      Paint()..color = const Color(0xFFB98B55),
    );
    canvas.drawRect(
      Rect.fromLTRB(cx - 5, r.top, cx + 5, r.bottom),
      Paint()..color = const Color(0xFFE3C08F),
    );
    canvas.drawRect(
      Rect.fromLTRB(r.left, r.top + h * 0.14, r.right, r.top + h * 0.18),
      Paint()..color = const Color(0xFF8C5A2B),
    );
  }

  @override
  bool shouldRepaint(_Pintor old) =>
      old.forma != forma || old.acento != acento || old.oscuro != oscuro;
}
