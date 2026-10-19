import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/tema/colores.dart';
import '../../../../core/formato/formato.dart';
import '../../../../core/ticket/ticket_pdf.dart';
import '../../../../core/widgets/estados.dart';

/// 2.5 Ticket de cierre de turno (diseño de Pablo), con el corte real.
class ReciboCierre extends ConsumerWidget {
  const ReciboCierre({
    super.key,
    required this.corte,
    required this.alFinalizar,
  });

  final Turno corte;
  final VoidCallback alFinalizar;

  void _finalizar(BuildContext context) => alFinalizar();

  Future<void> _pdf(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function(Turno, AjustesNegocio) accion,
  ) async {
    try {
      await accion(corte, await ref.read(ajustesNegocioProvider.future));
    } catch (_) {
      if (context.mounted) {
        avisar(context, 'No se pudo generar el PDF del corte');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colores;
    final r = corte.resumen;
    final negocio = ref.watch(ajustesNegocioProvider).value;
    final diferencia = corte.diferencia ?? 0;
    final cajero = (corte.usuarioCierre ?? corte.usuarioApertura)?.nombre;

    return Scaffold(
      backgroundColor: c.fondo,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // Borde ligero para simular ticket
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            (negocio?.nombreNegocio ?? 'Depósito de cerveza')
                                .toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ticket de Cierre de Turno',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),

                          _FilaTicket(
                            etiqueta: 'Fecha:',
                            valor: corte.diaNegocio,
                          ),
                          _FilaTicket(
                            etiqueta: 'Turno:',
                            valor:
                                '${hora(corte.apertura)} - '
                                '${corte.cierre == null ? '' : hora(corte.cierre!)}',
                          ),
                          if (cajero != null)
                            _FilaTicket(etiqueta: 'Cajero:', valor: cajero),

                          const SizedBox(height: 16),
                          const Divider(
                            color: Colors.black54,
                          ), // No hay estilo dash nativo simple, uso solid
                          const SizedBox(height: 16),

                          const Text(
                            'DESGLOSE DE VENTAS',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          _FilaTicket(
                            etiqueta: 'Efectivo (${r.ventas} ventas)',
                            valor: dinero(r.ventasEfectivo),
                          ),
                          _FilaTicket(
                            etiqueta: 'Tarjeta',
                            valor: dinero(r.ventasTarjeta),
                          ),
                          _FilaTicket(
                            etiqueta: 'Envases / Extra',
                            valor: dinero(r.envases),
                          ),
                          if (r.devoluciones > 0)
                            _FilaTicket(
                              etiqueta: 'Devoluciones',
                              valor: '-${dinero(r.devoluciones)}',
                            ),

                          const SizedBox(height: 16),
                          const Divider(color: Colors.black54),
                          const SizedBox(height: 16),

                          const Text(
                            'ARQUEO',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          _FilaTicket(
                            etiqueta: 'Fondo Inicial',
                            valor: dinero(corte.fondo),
                          ),
                          _FilaTicket(
                            etiqueta: 'Ventas en Efectivo',
                            valor: dinero(r.ventasEfectivo),
                          ),
                          if (r.ingresos > 0)
                            _FilaTicket(
                              etiqueta: 'Ingresos',
                              valor: dinero(r.ingresos),
                            ),
                          _FilaTicket(
                            etiqueta: 'Retiros',
                            valor: '-${dinero(r.retiros)}',
                          ),
                          const SizedBox(height: 8),
                          _FilaTicket(
                            etiqueta: 'Total Esperado',
                            valor: dinero(r.esperado),
                            bold: true,
                          ),
                          _FilaTicket(
                            etiqueta: 'Total Contado',
                            valor: dinero(corte.contado ?? 0),
                            bold: true,
                          ),

                          const SizedBox(height: 16),
                          const Divider(color: Colors.black54),
                          const SizedBox(height: 16),

                          _FilaTicket(
                            etiqueta: 'DIFERENCIA',
                            valor:
                                '${diferencia < 0 ? '-' : ''}${dinero(diferencia.abs())}',
                            bold: true,
                          ),
                          const SizedBox(height: 8),
                          if (corte.nota != null) ...[
                            const Text(
                              'Justificación:',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              corte.nota!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[800],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],

                          const SizedBox(height: 48),
                          Text(
                            '------------------------',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            'Firma del Cajero',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Botones
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _pdf(context, ref, imprimirCorte),
                              icon: const Icon(Icons.print_rounded, size: 20),
                              label: const Text('Imprimir'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                foregroundColor: c.tinta,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _pdf(context, ref, compartirCorte),
                              icon: const Icon(
                                Icons.picture_as_pdf_rounded,
                                size: 20,
                              ),
                              label: const Text('PDF'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                foregroundColor: c.tinta,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _finalizar(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: c.azul,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Finalizar y Salir',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilaTicket extends StatelessWidget {
  const _FilaTicket({
    required this.etiqueta,
    required this.valor,
    this.bold = false,
  });
  final String etiqueta;
  final String valor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              etiqueta,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
