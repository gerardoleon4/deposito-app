import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/tema/colores.dart';
import '../../../core/api/fallo_api.dart';
import '../../../core/formato/formato.dart';
import '../../../core/widgets/estados.dart';
import '../datos/modelos_ventas.dart';
import '../estado/ventas_provider.dart';

/// Ticket de una venta pasada, con la opción de cancelarla. Va a pantalla
/// completa en el teléfono o [embebido] a la derecha de la lista en el iPad.
class DetalleTicket extends ConsumerWidget {
  const DetalleTicket({
    super.key,
    required this.ventaId,
    this.embebido = false,
  });

  final String ventaId;
  final bool embebido;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colores;
    final detalle = ref.watch(detalleVentaProvider(ventaId));
    final cuerpo = switch (detalle) {
      AsyncData(:final value) => _Ticket(venta: value),
      AsyncError(:final error) => EstadoError(
        error: error,
        alReintentar: () => ref.invalidate(detalleVentaProvider(ventaId)),
      ),
      _ => const Cargando(),
    };
    return Scaffold(
      backgroundColor: c.superficie,
      appBar: embebido
          ? null
          : AppBar(
              backgroundColor: c.superficie,
              title: Text(
                detalle.value == null
                    ? 'Venta'
                    : 'Folio ${detalle.value!.folio}',
              ),
            ),
      body: SafeArea(child: cuerpo),
    );
  }
}

class _Ticket extends ConsumerWidget {
  const _Ticket({required this.venta});

  final DetalleVenta venta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colores;
    final metodo = MetodoPago.de(venta.metodo);
    final fecha = DateFormat('dd/MM/yyyy · HH:mm')
        .format(DateTime.parse(venta.fecha).toLocal());
    final textoFila = TextStyle(fontSize: 15, color: c.tinta2);

    Widget fila(String etiqueta, int centavos, {bool fuerte = false}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                etiqueta,
                style: fuerte
                    ? TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: c.tinta,
                      )
                    : textoFila,
              ),
              Text(
                dinero(centavos),
                style: TextStyle(
                  fontSize: fuerte ? 22 : 15,
                  fontWeight: fuerte ? FontWeight.w900 : FontWeight.w700,
                  color: c.tinta,
                ),
              ),
            ],
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Folio ${venta.folio}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: venta.cancelada ? c.alerta : c.tinta,
              ),
            ),
            Chip(
              avatar: Icon(metodo.icono, size: 16),
              label: Text(
                venta.tarjeta == null
                    ? metodo.etiqueta
                    : '${metodo.etiqueta} ${venta.tarjeta}',
              ),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '$fecha · ${venta.origen}',
          style: TextStyle(fontSize: 13, color: c.tinta2),
        ),
        if (venta.cancelada) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.alertaSuave,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.cancel_rounded, color: c.alerta, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Venta cancelada: las existencias y los envases regresaron.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: c.alerta,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          venta.lineas.isEmpty ? 'ENVASES VACÍOS' : 'ARTÍCULOS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: c.tinta2,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        if (venta.lineas.isEmpty)
          Text(
            '${venta.envN} envases vendidos al precio de depósito',
            style: textoFila,
          ),
        for (final l in venta.lineas)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              l.nombre,
              style: TextStyle(fontWeight: FontWeight.w700, color: c.tinta),
            ),
            subtitle: Text(
              '${l.cantidad} ${l.porCaja ? (l.cantidad == 1 ? 'caja' : 'cajas') : 'pz'}'
              ' × ${dinero(l.precioUnit)}'
              '${l.porCaja ? ' (${l.piezas} pz)' : ''}',
            ),
            trailing: Text(
              dinero(l.subtotal),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: c.tinta,
              ),
            ),
          ),
        const Divider(height: 32),
        if (venta.envMonto > 0) ...[
          fila('Productos', venta.subtotalProductos),
          fila('Depósito de envases (${venta.envN})', venta.envMonto),
        ],
        fila('Total', venta.total, fuerte: true),
        if (venta.metodo == 'efectivo') ...[
          fila('Recibido', venta.recibido),
          fila('Cambio', venta.cambio),
        ],
        if (!venta.cancelada) ...[
          const SizedBox(height: 28),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _cancelar(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: c.alerta,
                side: BorderSide(color: c.alerta),
              ),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancelar venta'),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _cancelar(BuildContext context, WidgetRef ref) async {
    final ok = await confirmar(
      context,
      titulo: '¿Cancelar el folio ${venta.folio}?',
      mensaje:
          'Se devuelven ${dinero(venta.total)} al cliente, las piezas regresan '
          'al inventario y los envases se revierten. La venta queda registrada '
          'como cancelada.',
      accion: 'Cancelar venta',
      peligrosa: true,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(ventasProvider.notifier).cancelar(venta.id);
      if (context.mounted) avisar(context, 'Folio ${venta.folio} cancelado');
    } on FalloApi catch (e) {
      if (context.mounted) {
        avisar(context, e.campos.values.firstOrNull ?? mensajeDeError(e));
      }
    }
  }
}
