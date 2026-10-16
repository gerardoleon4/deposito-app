import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/tema/colores.dart';
import '../datos/modelos_ventas.dart';
import 'flujo_cancelacion.dart';
import 'modal_reimpresion.dart';

/// 6.2 Detalle de Ticket Pasado
/// Vista de detalle (utilizable tanto embebida en split-view para iPad como en pantalla completa para móviles).
class DetalleTicket extends StatelessWidget {
  const DetalleTicket({
    super.key,
    required this.ticket,
    this.esModalOEmbebido = false,
  });

  final TicketTransaccion ticket;
  final bool esModalOEmbebido;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final fechaFmt = DateFormat('dd/MM/yyyy • hh:mm a').format(ticket.fecha);

    final contenido = Scaffold(
      backgroundColor: c.superficie,
      appBar: esModalOEmbebido
          ? null
          : AppBar(
              backgroundColor: c.superficie,
              elevation: 0,
              title: Text(
                'Detalle de Venta ${ticket.folio}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: c.tinta,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: c.linea, height: 1),
              ),
            ),
      body: SafeArea(
        child: Column(
          children: [
            // Cabecera: Folio, Fecha, Cajero y Estado
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: c.superficie,
                border: Border(bottom: BorderSide(color: c.linea)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: ticket.esCancelado
                                  ? const Color(
                                      0xFFDC2626,
                                    ).withValues(alpha: 0.12)
                                  : c.azul.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ticket.folio,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: ticket.esCancelado
                                    ? const Color(0xFFDC2626)
                                    : c.azul,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ticket.metodoPago.color.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  ticket.metodoPago.icono,
                                  size: 14,
                                  color: ticket.metodoPago.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  ticket.metodoPago.etiqueta,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: ticket.metodoPago.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (ticket.esCancelado)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFDC2626,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(
                                0xFFDC2626,
                              ).withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.cancel_rounded,
                                size: 14,
                                color: Color(0xFFDC2626),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'CANCELADO',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFDC2626),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Fecha y Cajero
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: c.tinta2,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        fechaFmt,
                        style: TextStyle(fontSize: 13, color: c.tinta2),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.person_outline_rounded,
                        size: 16,
                        color: c.tinta2,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ticket.cajero,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: c.tinta,
                        ),
                      ),
                    ],
                  ),

                  // Banner de cancelación si aplica
                  if (ticket.esCancelado) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(
                            0xFFDC2626,
                          ).withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFDC2626),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Venta Cancelada / Reembolsada',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFDC2626),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Motivo: ${ticket.motivoCancelacion ?? 'Devolución'}'
                            '${ticket.destinoStock != null ? ' • Destino: ${ticket.destinoStock!.titulo}' : ''}'
                            '${ticket.montoReembolsado != null ? ' • Monto: -\$${ticket.montoReembolsado!.toStringAsFixed(2)}' : ''}',
                            style: TextStyle(fontSize: 12, color: c.tinta2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Desglose: Lista inamovible de productos vendidos
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'DESGLOSE DE ARTÍCULOS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: c.tinta2,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...ticket.items.map((it) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: c.superficie2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: c.linea),
                      ),
                      child: Row(
                        children: [
                          // Foto con fondo blanco puro
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: c.linea),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: it.urlImagen != null
                                ? Image.asset(
                                    it.urlImagen!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => Icon(
                                      Icons.inventory_2_rounded,
                                      color: c.tinta2,
                                    ),
                                  )
                                : Icon(
                                    Icons.inventory_2_rounded,
                                    color: c.tinta2,
                                  ),
                          ),
                          const SizedBox(width: 14),

                          // Nombre y detalle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  it.nombre,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: c.tinta,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${it.cantidad} ${it.esCaja ? 'cartón (24 pzs)' : 'pza(s)'} x \$${it.precioUnitario.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: c.tinta2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Subtotal por línea
                          Text(
                            '\$${it.subtotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: c.tinta,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Resumen de Subtotal, Envases y Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal productos',
                        style: TextStyle(color: c.tinta2),
                      ),
                      Text(
                        '\$${ticket.subtotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: c.tinta,
                        ),
                      ),
                    ],
                  ),
                  if (ticket.creditosEnvases > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Crédito por envases vacíos',
                          style: TextStyle(color: c.verde),
                        ),
                        Text(
                          '-\$${ticket.creditosEnvases.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: c.verde,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (ticket.cargoEnvases > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Depósito de envases',
                          style: TextStyle(color: Color(0xFFD97706)),
                        ),
                        Text(
                          '+\$${ticket.cargoEnvases.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total pagado',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: c.tinta,
                        ),
                      ),
                      Text(
                        '\$${ticket.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: ticket.esCancelado
                              ? const Color(0xFFDC2626)
                              : c.tinta,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Acciones Inferiores fijas (Sticky Bottom): Re-imprimir y Cancelar Venta
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: c.superficie,
                border: Border(top: BorderSide(color: c.linea)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Botón 1: Re-imprimir Recibo (Secundario/Gris)
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () => ModalReimpresion.mostrar(
                          context: context,
                          ticket: ticket,
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: c.linea),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.print_rounded, size: 20),
                        label: Text(
                          'Re-imprimir Recibo',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: c.tinta,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Botón 2: Cancelar Venta / Devolución (Primario destructivo / Rojo)
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: ticket.esCancelado
                            ? null
                            : () => FlujoCancelacion.mostrar(
                                context: context,
                                ticket: ticket,
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: c.linea,
                          disabledForegroundColor: c.tinta2,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.cancel_outlined, size: 20),
                        label: Text(
                          ticket.esCancelado
                              ? 'Ya Cancelado'
                              : 'Cancelar Venta',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
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
    );

    return contenido;
  }
}
