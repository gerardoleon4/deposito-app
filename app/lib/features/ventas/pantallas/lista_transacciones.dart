import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/tema/colores.dart';
import '../datos/modelos_ventas.dart';
import '../estado/ventas_provider.dart';
import 'detalle_ticket.dart';

/// 6.1 Lista de Transacciones del Día (Ventas)
/// Vista de lista o tabla estructurada con buscador superior, filtro rápido por método de pago,
/// atenuación visual de cancelados, y layout adaptativo (Split View en iPad / Push en Móviles).
class ListaTransacciones extends ConsumerStatefulWidget {
  const ListaTransacciones({super.key});

  @override
  ConsumerState<ListaTransacciones> createState() => _ListaTransaccionesState();
}

class _ListaTransaccionesState extends ConsumerState<ListaTransacciones> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final estado = ref.watch(ventasProvider);
    final ancho = MediaQuery.of(context).size.width;
    final esIpad = ancho >= 850;

    final tickets = estado.ticketsFiltrados;
    final ticketSeleccionado = estado.ticketSeleccionado;

    final listaWidget = Column(
      children: [
        // Cabecera: Buscador superior por "Folio de ticket" o "Monto" y Filtro de método de pago
        Container(
          padding: const EdgeInsets.all(20),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transacciones del Día',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: c.tinta,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Historial de tickets cobrados y devoluciones del turno',
                          style: TextStyle(fontSize: 13, color: c.tinta2),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: c.superficie2,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: c.linea),
                    ),
                    child: Text(
                      '${tickets.length} tickets',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: c.tinta,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Buscador de texto: "Folio de ticket" o "Monto"
              TextField(
                controller: _searchCtrl,
                onChanged: (val) =>
                    ref.read(ventasProvider.notifier).buscar(val),
                decoration: InputDecoration(
                  hintText: 'Buscar por folio (#T-1042) o monto (\$58)...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            ref.read(ventasProvider.notifier).buscar('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: c.superficie2,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: c.linea),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: c.linea),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: c.azul, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Filtro rápido por método de pago: Todos, Efectivo, Tarjeta
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ChipFiltroMetodo(
                      etiqueta: 'Todos los pagos',
                      icono: Icons.all_inclusive_rounded,
                      seleccionado: estado.filtroMetodoPago == null,
                      alSeleccionar: () => ref
                          .read(ventasProvider.notifier)
                          .filtrarPorMetodo(null),
                      c: c,
                    ),
                    const SizedBox(width: 8),
                    _ChipFiltroMetodo(
                      etiqueta: 'Efectivo',
                      icono: MetodoPagoTicket.efectivo.icono,
                      color: MetodoPagoTicket.efectivo.color,
                      seleccionado:
                          estado.filtroMetodoPago == MetodoPagoTicket.efectivo,
                      alSeleccionar: () => ref
                          .read(ventasProvider.notifier)
                          .filtrarPorMetodo(MetodoPagoTicket.efectivo),
                      c: c,
                    ),
                    const SizedBox(width: 8),
                    _ChipFiltroMetodo(
                      etiqueta: 'Tarjeta',
                      icono: MetodoPagoTicket.tarjeta.icono,
                      color: MetodoPagoTicket.tarjeta.color,
                      seleccionado:
                          estado.filtroMetodoPago == MetodoPagoTicket.tarjeta,
                      alSeleccionar: () => ref
                          .read(ventasProvider.notifier)
                          .filtrarPorMetodo(MetodoPagoTicket.tarjeta),
                      c: c,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Lista de Tickets ordenados cronológicamente
        Expanded(
          child: tickets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: c.tinta2),
                      const SizedBox(height: 12),
                      Text(
                        'No se encontraron transacciones',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: c.tinta,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Prueba cambiando el término de búsqueda o el filtro.',
                        style: TextStyle(fontSize: 13, color: c.tinta2),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: tickets.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final t = tickets[i];
                    final horaStr = DateFormat('hh:mm a').format(t.fecha);
                    final esSeleccionado =
                        esIpad && t.id == ticketSeleccionado?.id;
                    final esCancelado = t.esCancelado;

                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: esCancelado ? 0.6 : 1.0,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            ref
                                .read(ventasProvider.notifier)
                                .seleccionarTicket(t.id);
                            if (!esIpad) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetalleTicket(ticket: t),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: esSeleccionado
                                  ? c.azul.withValues(alpha: 0.08)
                                  : (esCancelado
                                        ? c.superficie2
                                        : c.superficie),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: esSeleccionado
                                    ? c.azul
                                    : (esCancelado
                                          ? const Color(
                                              0xFFDC2626,
                                            ).withValues(alpha: 0.25)
                                          : c.linea),
                                width: esSeleccionado ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Icono visual del método de pago
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: esCancelado
                                        ? Colors.grey.withValues(alpha: 0.2)
                                        : t.metodoPago.color.withValues(
                                            alpha: 0.12,
                                          ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    esCancelado
                                        ? Icons.cancel_outlined
                                        : t.metodoPago.icono,
                                    color: esCancelado
                                        ? const Color(0xFFDC2626)
                                        : t.metodoPago.color,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Hora y Folio (#T-1042)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            t.folio,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: esCancelado
                                                  ? c.tinta2
                                                  : c.tinta,
                                              decoration: esCancelado
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (esCancelado)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFFDC2626,
                                                ).withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'Cancelado',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFFDC2626),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            horaStr,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: c.tinta2,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '•',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: c.tinta2,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            t.metodoPago.etiqueta,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: esCancelado
                                                  ? c.tinta2
                                                  : t.metodoPago.color,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '•',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: c.tinta2,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${t.items.length} ${t.items.length == 1 ? 'art.' : 'arts.'}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: c.tinta2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Total pagado
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${t.total.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: esCancelado
                                            ? const Color(0xFFDC2626)
                                            : c.tinta,
                                        decoration: esCancelado
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    if (esIpad)
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        size: 18,
                                        color: esSeleccionado
                                            ? c.azul
                                            : c.tinta2,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: c.fondo,
      body: SafeArea(
        child: esIpad
            ? Row(
                children: [
                  // Panel izquierdo (50%): Lista de transacciones
                  Expanded(flex: 5, child: listaWidget),
                  VerticalDivider(width: 1, color: c.linea),

                  // Panel derecho (50%): Detalle del ticket seleccionado (6.2)
                  Expanded(
                    flex: 5,
                    child: ticketSeleccionado != null
                        ? DetalleTicket(
                            ticket: ticketSeleccionado,
                            esModalOEmbebido: true,
                          )
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.receipt_long_rounded,
                                  size: 48,
                                  color: c.tinta2,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Selecciona un ticket para ver su detalle',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: c.tinta2,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              )
            : listaWidget,
      ),
    );
  }
}

class _ChipFiltroMetodo extends StatelessWidget {
  const _ChipFiltroMetodo({
    required this.etiqueta,
    required this.icono,
    required this.seleccionado,
    required this.alSeleccionar,
    required this.c,
    this.color,
  });

  final String etiqueta;
  final IconData icono;
  final bool seleccionado;
  final VoidCallback alSeleccionar;
  final ColoresAnaquel c;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? c.azul;

    return ChoiceChip(
      selected: seleccionado,
      showCheckmark: false,
      avatar: Icon(
        icono,
        size: 16,
        color: seleccionado ? Colors.white : chipColor,
      ),
      label: Text(
        etiqueta,
        style: TextStyle(
          fontWeight: seleccionado ? FontWeight.w800 : FontWeight.w600,
          color: seleccionado ? Colors.white : c.tinta,
          fontSize: 13,
        ),
      ),
      selectedColor: chipColor,
      backgroundColor: c.superficie,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: seleccionado ? Colors.transparent : c.linea),
      ),
      onSelected: (_) => alSeleccionar(),
    );
  }
}
