import 'package:flutter/material.dart';

import '../../app/tema/colores.dart';

/// Sección planeada pero todavía no construida. Dice en qué sprint llega y
/// quién la hace, según docs/PLAN_DE_TRABAJO.md.
class Proximamente extends StatelessWidget {
  const Proximamente({
    super.key,
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.sprint,
    required this.responsable,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;
  final int sprint;
  final String responsable;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final textos = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: c.lagerSuave,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icono, size: 40, color: c.tinta),
              ),
              const SizedBox(height: 20),
              Text(
                titulo,
                style: textos.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                descripcion,
                style: textos.bodyLarge?.copyWith(color: c.tinta2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: c.superficie,
                  border: Border.all(color: c.linea),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Llega en el Sprint $sprint · $responsable',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: c.tinta2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
