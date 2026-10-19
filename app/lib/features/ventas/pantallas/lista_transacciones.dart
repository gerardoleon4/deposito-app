import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/tema/colores.dart';
import '../../../core/formato/formato.dart';
import '../../../core/widgets/estados.dart';
import '../datos/modelos_ventas.dart';
import '../estado/ventas_provider.dart';
import 'detalle_ticket.dart';

/// Ventas recientes con búsqueda por folio o total y filtro por método de
/// pago. En iPad, el detalle del ticket queda a la derecha.
class ListaTransacciones extends ConsumerStatefulWidget {
  const ListaTransacciones({super.key});

  @override
  ConsumerState<ListaTransacciones> createState() => _ListaTransaccionesState();
}

class _ListaTransaccionesState extends ConsumerState<ListaTransacciones> {
  final _busqueda = TextEditingController();
  MetodoPago? _metodo;
  String? _seleccionada;

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final ventas = ref.watch(ventasProvider);
    final esAncho = MediaQuery.sizeOf(context).width >= 850;

    final lista = switch (ventas) {
      AsyncData(:final value) => _lista(value, esAncho),
      AsyncError(:final error) => EstadoError(
        error: error,
        alReintentar: () => ref.invalidate(ventasProvider),
      ),
      _ => const Cargando(mensaje: 'Cargando ventas…'),
    };

    final seleccionada = _seleccionada ?? ventas.value?.firstOrNull?.id;
    return Scaffold(
      backgroundColor: c.fondo,
      body: SafeArea(
        child: esAncho
            ? Row(
                children: [
                  Expanded(flex: 5, child: lista),
                  VerticalDivider(width: 1, color: c.linea),
                  Expanded(
                    flex: 5,
                    child: seleccionada == null
                        ? const EstadoVacio(
                            icono: Icons.receipt_long_rounded,
                            titulo: 'Selecciona una venta',
                          )
                        : DetalleTicket(
                            key: ValueKey(seleccionada),
                            ventaId: seleccionada,
                            embebido: true,
                          ),
                  ),
                ],
              )
            : lista,
      ),
    );
  }

  Widget _lista(List<ResumenVenta> todas, bool esAncho) {
    final c = context.colores;
    final ventas = filtrarVentas(
      todas,
      busqueda: _busqueda.text,
      metodo: _metodo?.clave,
    );
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.superficie,
            border: Border(bottom: BorderSide(color: c.linea)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ventas',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: c.tinta,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Las últimas 100, de la más nueva a la más vieja',
                          style: TextStyle(fontSize: 13, color: c.tinta2),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Actualizar',
                    onPressed: () =>
                        ref.read(ventasProvider.notifier).refrescar(),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _busqueda,
                onChanged: (_) => setState(() {}),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Buscar por folio o total',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _busqueda.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Borrar',
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => setState(_busqueda.clear),
                        ),
                  filled: true,
                  fillColor: c.superficie2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: c.linea),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: c.linea),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Todas'),
                    selected: _metodo == null,
                    onSelected: (_) => setState(() => _metodo = null),
                  ),
                  for (final m in MetodoPago.values)
                    ChoiceChip(
                      avatar: Icon(m.icono, size: 16),
                      label: Text(m.etiqueta),
                      selected: _metodo == m,
                      onSelected: (_) => setState(() => _metodo = m),
                    ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(ventasProvider.notifier).refrescar(),
            child: ventas.isEmpty
                ? ListView(
                    children: [
                      EstadoVacio(
                        icono: todas.isEmpty
                            ? Icons.receipt_long_outlined
                            : Icons.search_off_rounded,
                        titulo: todas.isEmpty
                            ? 'Todavía no hay ventas'
                            : 'Ninguna venta coincide',
                        mensaje: todas.isEmpty
                            ? 'Las ventas cobradas en Vender aparecen aquí.'
                            : 'Prueba con otro folio, total o método de pago.',
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: ventas.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final v = ventas[i];
                      return _FilaVenta(
                        venta: v,
                        seleccionada:
                            esAncho &&
                            v.id == (_seleccionada ?? todas.first.id),
                        alTocar: () {
                          if (esAncho) {
                            setState(() => _seleccionada = v.id);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalleTicket(ventaId: v.id),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _FilaVenta extends StatelessWidget {
  const _FilaVenta({
    required this.venta,
    required this.seleccionada,
    required this.alTocar,
  });

  final ResumenVenta venta;
  final bool seleccionada;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final metodo = MetodoPago.de(venta.metodo);
    final cancelada = venta.cancelada;
    final hora = DateFormat('HH:mm')
        .format(DateTime.parse(venta.fecha).toLocal());
    return Opacity(
      opacity: cancelada ? 0.6 : 1,
      child: Material(
        color: seleccionada ? c.seleccion : c.superficie,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: alTocar,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: seleccionada
                    ? c.azul
                    : (cancelada ? c.alerta.withValues(alpha: 0.3) : c.linea),
                width: seleccionada ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cancelada ? c.alertaSuave : c.superficie2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    cancelada ? Icons.cancel_outlined : metodo.icono,
                    color: cancelada ? c.alerta : c.azul,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Folio ${venta.folio}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: cancelada ? c.tinta2 : c.tinta,
                              decoration: cancelada
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          if (cancelada) ...[
                            const SizedBox(width: 8),
                            Text(
                              'Cancelada',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: c.alerta,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$hora · ${metodo.etiqueta} · ${venta.origen}',
                        style: TextStyle(fontSize: 12, color: c.tinta2),
                      ),
                    ],
                  ),
                ),
                Text(
                  dinero(venta.total),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: cancelada ? c.alerta : c.tinta,
                    decoration: cancelada ? TextDecoration.lineThrough : null,
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
