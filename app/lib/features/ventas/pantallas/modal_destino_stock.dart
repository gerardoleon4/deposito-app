import 'package:flutter/material.dart';

import '../../../app/tema/colores.dart';
import '../datos/modelos_ventas.dart';

/// 6.5 Confirmación de Destino de Stock
/// Alerta modal centrada de alta jerarquía con selección forzosa entre
/// "Regresar al Inventario" o "Registrar como Merma".
class ModalDestinoStock extends StatelessWidget {
  const ModalDestinoStock({super.key, required this.totalArticulosDevueltos});

  final int totalArticulosDevueltos;

  static Future<DestinoStock?> mostrar({
    required BuildContext context,
    required int totalArticulosDevueltos,
  }) {
    return showDialog<DestinoStock>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          ModalDestinoStock(totalArticulosDevueltos: totalArticulosDevueltos),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            decoration: BoxDecoration(
              color: c.superficie,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 36,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icono e indicador de alta jerarquía
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.swap_vert_circle_rounded,
                          color: Color(0xFFD97706),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'CONTROL DE INVENTARIO',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFB45309),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '¿Qué pasará con estos artículos?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: c.tinta,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Se procesará la devolución de $totalArticulosDevueltos ${totalArticulosDevueltos == 1 ? 'artículo' : 'artículos'}. '
                    'Selecciona el destino físico para actualizar las existencias de forma obligatoria:',
                    style: TextStyle(
                      fontSize: 14,
                      color: c.tinta2,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Tarjeta 1: Regresar al Inventario
                  _TarjetaDestino(
                    destino: DestinoStock.regresarInventario,
                    c: c,
                    alSeleccionar: () =>
                        Navigator.pop(context, DestinoStock.regresarInventario),
                  ),
                  const SizedBox(height: 14),

                  // Tarjeta 2: Registrar como Merma
                  _TarjetaDestino(
                    destino: DestinoStock.merma,
                    c: c,
                    alSeleccionar: () =>
                        Navigator.pop(context, DestinoStock.merma),
                  ),
                  const SizedBox(height: 20),

                  // Botón Cancelar operación
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: Text(
                        'Cancelar y volver a la selección',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.tinta2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TarjetaDestino extends StatelessWidget {
  const _TarjetaDestino({
    required this.destino,
    required this.c,
    required this.alSeleccionar,
  });

  final DestinoStock destino;
  final ColoresAnaquel c;
  final VoidCallback alSeleccionar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: alSeleccionar,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: c.superficie,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: destino.color.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: destino.color.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: destino.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(destino.icono, color: destino.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destino.titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: c.tinta,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      destino.subtitulo,
                      style: TextStyle(
                        fontSize: 13,
                        color: c.tinta2,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: destino.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
