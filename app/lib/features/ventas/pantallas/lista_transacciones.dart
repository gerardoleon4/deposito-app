import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../core/formato/formato.dart';
import '../../../core/widgets/estados.dart';
import '../datos/modelos_ventas.dart';
import '../estado/ventas_provider.dart';
import 'detalle_ticket.dart';

/// 6.1 Transacciones (diseño de Pablo): buscador por folio o monto, filtro
/// por método de pago, cancelados atenuados y vista dividida en el iPad.
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
    final esIpad = MediaQuery.of(context).size.width >= 850;

    final cuerpo = switch (ref.watch(ventasProvider)) {
      AsyncData(:final value) => _contenido(value, esIpad),
      AsyncError(:final error) => EstadoError(
        error: error,
        alReintentar: () => ref.read(ventasProvider.notifier).refrescar(),
      ),
      _ => const Cargando(mensaje: 'Cargando ventas'),
    };

    return Scaffold(
      backgroundColor: c.fondo,
      body: SafeArea(child: cuerpo),
    );
  }

  Widget _contenido(EstadoVentas estado, bool esIpad) {
    final c = context.colores;
    final tickets = filtrarVentas(
      estado.ventas,
      busqueda: _busqueda.text,
      metodo: _metodo?.clave,
    );
    final seleccionada = esIpad && tickets.any((t) => t.id == _seleccionada)
        ? _seleccionada
        : null;

    final lista = Column(
      children: [
        // Cabecera: título, buscador y filtro por método de pago
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
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          estado.delTurno
                              ? 'Transacciones del Turno'
                              : 'Últimas Transacciones',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: c.tinta,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          estado.delTurno
                              ? 'Historial de tickets cobrados y devoluciones '
                                    'del turno'
                              : 'La caja está cerrada: se muestran las últimas '
                                    '100 ventas',
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
                  IconButton(
                    tooltip: 'Actualizar',
                    onPressed: () =>
                        ref.read(ventasProvider.notifier).refrescar(),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _busqueda,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: r'Buscar por folio (#1042) o monto ($58)...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _busqueda.text.isNotEmpty
                      ? IconButton(
                          tooltip: 'Limpiar',
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => setState(_busqueda.clear),
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ChipFiltroMetodo(
                      etiqueta: 'Todos los pagos',
                      icono: Icons.all_inclusive_rounded,
                      seleccionado: _metodo == null,
                      alSeleccionar: () => setState(() => _metodo = null),
                    ),
                    for (final m in MetodoPago.values) ...[
                      const SizedBox(width: 8),
                      _ChipFiltroMetodo(
                        etiqueta: m.etiqueta,
                        icono: m.icono,
                        color: m.color,
                        seleccionado: _metodo == m,
                        alSeleccionar: () => setState(() => _metodo = m),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // Lista de tickets
        Expanded(
          child: tickets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: c.tinta2),
                      const SizedBox(height: 12),
                      Text(
                        estado.ventas.isEmpty
                            ? 'Todavía no hay ventas'
                            : 'No se encontraron transacciones',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: c.tinta,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        estado.ventas.isEmpty
                            ? 'Las ventas cobradas en Vender aparecen aquí.'
                            : 'Prueba cambiando el término de búsqueda o el '
                                  'filtro.',
                        style: TextStyle(fontSize: 13, color: c.tinta2),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: tickets.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _TarjetaTicket(
                    venta: tickets[i],
                    seleccionado: tickets[i].id == seleccionada,
                    mostrarFlecha: esIpad,
                    alTocar: () {
                      if (esIpad) {
                        setState(() => _seleccionada = tickets[i].id);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DetalleTicket(ventaId: tickets[i].id),
                          ),
                        );
                      }
                    },
                  ),
                ),
        ),
      ],
    );

    if (!esIpad) return lista;
    return Row(
      children: [
        Expanded(flex: 5, child: lista),
        VerticalDivider(width: 1, color: c.linea),
        Expanded(
          flex: 5,
          child: seleccionada != null
              ? DetalleTicket(
                  key: ValueKey(seleccionada),
                  ventaId: seleccionada,
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
    );
  }
}

class _TarjetaTicket extends StatelessWidget {
  const _TarjetaTicket({
    required this.venta,
    required this.seleccionado,
    required this.mostrarFlecha,
    required this.alTocar,
  });

  final ResumenVenta venta;
  final bool seleccionado;
  final bool mostrarFlecha;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final t = venta;
    final metodo = MetodoPago.de(t.metodo);
    final cancelado = t.cancelada;
    final parcial = !cancelado && t.devuelto > 0;

    Widget punto() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text('•', style: TextStyle(fontSize: 12, color: c.tinta2)),
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: cancelado ? 0.6 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: alTocar,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: seleccionado
                  ? c.azul.withValues(alpha: 0.08)
                  : (cancelado ? c.superficie2 : c.superficie),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: seleccionado
                    ? c.azul
                    : (cancelado
                          ? rojoCancelacion.withValues(alpha: 0.25)
                          : c.linea),
                width: seleccionado ? 2 : 1,
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
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cancelado
                        ? Colors.grey.withValues(alpha: 0.2)
                        : metodo.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    cancelado ? Icons.cancel_outlined : metodo.icono,
                    color: cancelado ? rojoCancelacion : metodo.color,
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
                            '#${t.folio}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: cancelado ? c.tinta2 : c.tinta,
                              decoration: cancelado
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (cancelado || parcial)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: rojoCancelacion.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                cancelado ? 'Cancelado' : 'Devolución',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: rojoCancelacion,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            hora(t.fecha),
                            style: TextStyle(fontSize: 12, color: c.tinta2),
                          ),
                          punto(),
                          Text(
                            metodo.etiqueta,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: cancelado ? c.tinta2 : metodo.color,
                            ),
                          ),
                          punto(),
                          Text(
                            t.usuario?.nombre ?? t.origen,
                            style: TextStyle(fontSize: 12, color: c.tinta2),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      dinero(t.total),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: cancelado ? rojoCancelacion : c.tinta,
                        decoration: cancelado
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (parcial)
                      Text(
                        '-${dinero(t.devuelto)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: rojoCancelacion,
                        ),
                      ),
                    if (mostrarFlecha)
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: seleccionado ? c.azul : c.tinta2,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
    this.color,
  });

  final String etiqueta;
  final IconData icono;
  final bool seleccionado;
  final VoidCallback alSeleccionar;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
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
