import 'package:flutter/material.dart';

import '../../app/tema/colores.dart';

/// Logo de Anaquel: emblema de botella y anaquel sobre fondo pizarra mate.
class LogoAnaquel extends StatelessWidget {
  const LogoAnaquel({super.key, this.tamano = 42});

  final double tamano;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(tamano * 0.22),
      child: Image.asset(
        'assets/logo.png',
        width: tamano,
        height: tamano,
        fit: BoxFit.cover,
      ),
    );
  }
}

/// Logo de marca Nexo POS: "nexo" en oscuro y "POS" en azul.
class LogoNexo extends StatelessWidget {
  const LogoNexo({
    super.key,
    this.tamanoBase = 42,
    this.mostrarSubtitulo = true,
  });

  final double tamanoBase;
  final bool mostrarSubtitulo;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'nexo',
          style: TextStyle(
            fontSize: tamanoBase,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
            color: c.tinta,
          ),
        ),
        if (mostrarSubtitulo) ...[
          const SizedBox(width: 8),
          Text(
            'POS',
            style: TextStyle(
              fontSize: tamanoBase * 0.42,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: c.azul,
            ),
          ),
        ],
      ],
    );
  }
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
          Flexible(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: c.tinta2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
