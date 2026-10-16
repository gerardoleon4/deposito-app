import 'package:flutter/material.dart';
import '../../../../app/tema/colores.dart';
import '../datos/modelos_ventas.dart';

/// 6.3 Modal de Re-impresión
/// Panel inferior (Bottom Sheet) rápido y minimalista con opciones de impresión y compartir recibo.
class ModalReimpresion extends StatelessWidget {
  const ModalReimpresion({super.key, required this.ticket});

  final TicketTransaccion ticket;

  static Future<void> mostrar({
    required BuildContext context,
    required TicketTransaccion ticket,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ModalReimpresion(ticket: ticket),
    );
  }

  void _notificarAccion(BuildContext context, String mensaje) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              mensaje,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;

    return Container(
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Asa superior
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: c.linea,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Cabecera
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: c.azul.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: c.azul,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Opciones de recibo',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: c.tinta,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Folio ${ticket.folio} • \$${ticket.total.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 13, color: c.tinta2),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: c.tinta2,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Botón 1: Imprimir en terminal térmica
            Material(
              color: c.superficie2,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _notificarAccion(
                  context,
                  'Ticket ${ticket.folio} enviado a impresora térmica',
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: c.linea),
                        ),
                        child: Icon(
                          Icons.print_rounded,
                          color: c.azul,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Imprimir en terminal térmica',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: c.tinta,
                              ),
                            ),
                            Text(
                              'Envía el recibo por Bluetooth/Red a la impresora POS',
                              style: TextStyle(fontSize: 12, color: c.tinta2),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: c.tinta2),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Botón 2: Compartir PDF / WhatsApp
            Material(
              color: c.superficie2,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _notificarAccion(
                  context,
                  'PDF generado y listo para compartir por WhatsApp',
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: c.linea),
                        ),
                        child: Icon(
                          Icons.share_rounded,
                          color: c.verde,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Compartir PDF / WhatsApp',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: c.tinta,
                              ),
                            ),
                            Text(
                              'Generar comprobante digital para enviar al cliente',
                              style: TextStyle(fontSize: 12, color: c.tinta2),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: c.tinta2),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Botón 3: Cerrar
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: c.linea),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Cerrar',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: c.tinta,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
