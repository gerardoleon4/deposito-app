import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/tema/colores.dart';
import '../datos/modelos_ventas.dart';
import '../estado/ventas_provider.dart';
import 'modal_autorizacion_numpad.dart';
import 'modal_destino_stock.dart';

/// 6.4 Flujo de Cancelación / Reembolso
/// Pantalla modal interactiva para seleccionar qué artículos y qué cantidad devolver,
/// recalculando el monto en tiempo real, antes de pasar a la selección de destino y PIN.
class FlujoCancelacion extends ConsumerStatefulWidget {
  const FlujoCancelacion({super.key, required this.ticket});

  final TicketTransaccion ticket;

  static Future<bool?> mostrar({
    required BuildContext context,
    required TicketTransaccion ticket,
  }) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => FlujoCancelacion(ticket: ticket),
      ),
    );
  }

  @override
  ConsumerState<FlujoCancelacion> createState() => _FlujoCancelacionState();
}

class _FlujoCancelacionState extends ConsumerState<FlujoCancelacion> {
  late Map<String, int> _cantidadesDevolver;
  late Map<String, bool> _seleccionados;

  @override
  void initState() {
    super.initState();
    _cantidadesDevolver = {
      for (final it in widget.ticket.items) it.id: it.cantidad,
    };
    _seleccionados = {for (final it in widget.ticket.items) it.id: true};
  }

  double get _montoReembolsar {
    double total = 0.0;
    for (final it in widget.ticket.items) {
      final estaSeleccionado = _seleccionados[it.id] ?? false;
      final cant = _cantidadesDevolver[it.id] ?? 0;
      if (estaSeleccionado && cant > 0) {
        final factor = it.esCaja ? 24 : 1;
        total += it.precioUnitario * (cant * factor);
      }
    }
    // Si cancela todo y hubo crédito por envases o cargos, prorratear o aplicar al total
    final totalArticulos = widget.ticket.items.fold<int>(
      0,
      (acc, it) => acc + it.cantidad,
    );
    final articulosDevueltos = _totalArticulosDevueltos;
    if (articulosDevueltos == totalArticulos && totalArticulos > 0) {
      return widget.ticket.total;
    }
    return total.clamp(0.0, widget.ticket.total);
  }

  int get _totalArticulosDevueltos {
    int total = 0;
    for (final it in widget.ticket.items) {
      if (_seleccionados[it.id] == true) {
        total += _cantidadesDevolver[it.id] ?? 0;
      }
    }
    return total;
  }

  Future<void> _continuarCancelacion() async {
    if (_totalArticulosDevueltos == 0 || _montoReembolsar <= 0) return;

    // Paso 6.5: Destino de Stock (Selección obligatoria)
    final destino = await ModalDestinoStock.mostrar(
      context: context,
      totalArticulosDevueltos: _totalArticulosDevueltos,
    );
    if (destino == null || !mounted) return;

    // Paso 6.6: Autorización con Numpad (Requiere PIN de Gerente o Dueño)
    final autorizado = await ModalAutorizacionNumpad.mostrar(
      context: context,
      tituloAccion: 'Autorizar Cancelación de Venta',
    );
    if (autorizado != true || !mounted) return;

    // Ejecutar cancelación en el provider
    ref
        .read(ventasProvider.notifier)
        .cancelarTicket(
          ticketId: widget.ticket.id,
          destino: destino,
          montoReembolso: _montoReembolsar,
          motivo: 'Devolución de $_totalArticulosDevueltos artículos',
        );

    Navigator.pop(context, true);

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
              'Ticket ${widget.ticket.folio} cancelado exitosamente. Reembolso: \$${_montoReembolsar.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final totalDevuelto = _totalArticulosDevueltos;
    final puedeContinuar = totalDevuelto > 0 && _montoReembolsar > 0;

    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        backgroundColor: c.superficie,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cancelar Venta / Devolución',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: c.tinta,
              ),
            ),
            Text(
              'Folio ${widget.ticket.folio} • Total original: \$${widget.ticket.total.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 12, color: c.tinta2),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
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
            // Instrucción superior
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              color: c.superficie,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.assignment_return_rounded,
                      color: Color(0xFFDC2626),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seleccione los artículos a devolver',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: c.tinta,
                          ),
                        ),
                        Text(
                          'Puedes desmarcar productos o reducir cantidades para devoluciones parciales',
                          style: TextStyle(fontSize: 12, color: c.tinta2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Lista interactiva de artículos del ticket
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: widget.ticket.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final it = widget.ticket.items[i];
                  final seleccionado = _seleccionados[it.id] ?? false;
                  final cantActual = _cantidadesDevolver[it.id] ?? 0;
                  final cantOriginal = it.cantidad;
                  final estaAtenuado = !seleccionado || cantActual == 0;

                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: estaAtenuado ? 0.45 : 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: c.superficie,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: seleccionado && cantActual > 0
                              ? const Color(0xFFDC2626).withValues(alpha: 0.4)
                              : c.linea,
                          width: seleccionado && cantActual > 0 ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Casilla de verificación (Checkbox)
                          Checkbox(
                            value: seleccionado,
                            activeColor: const Color(0xFFDC2626),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            onChanged: (val) {
                              setState(() {
                                final nuevo = val ?? false;
                                _seleccionados[it.id] = nuevo;
                                if (nuevo && cantActual == 0) {
                                  _cantidadesDevolver[it.id] = cantOriginal;
                                }
                              });
                            },
                          ),
                          const SizedBox(width: 8),

                          // Foto o icono de producto con fondo blanco
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
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

                          // Nombre y precio
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  it.nombre,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: c.tinta,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '\$${it.precioUnitario.toStringAsFixed(2)} c/u • Original: ${it.cantidad} pzs',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: c.tinta2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Controles de cantidad [-] [+]
                          Container(
                            decoration: BoxDecoration(
                              color: c.superficie2,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: c.linea),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_rounded,
                                    size: 18,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints(),
                                  onPressed: cantActual > 0 && seleccionado
                                      ? () {
                                          setState(() {
                                            final nuevo = cantActual - 1;
                                            _cantidadesDevolver[it.id] = nuevo;
                                            if (nuevo == 0) {
                                              _seleccionados[it.id] = false;
                                            }
                                          });
                                        }
                                      : null,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    '$cantActual',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: c.tinta,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints(),
                                  onPressed:
                                      cantActual < cantOriginal && seleccionado
                                      ? () {
                                          setState(() {
                                            _cantidadesDevolver[it.id] =
                                                cantActual + 1;
                                          });
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Resumen Inferior fijo (Sticky Bottom)
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: c.superficie,
                border: Border(top: BorderSide(color: c.linea)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Monto a Reembolsar',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                          Text(
                            '$totalDevuelto artículos seleccionados',
                            style: TextStyle(fontSize: 12, color: c.tinta2),
                          ),
                        ],
                      ),
                      Text(
                        '\$${_montoReembolsar.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFDC2626),
                          letterSpacing: -1,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Botón primario: Continuar Cancelación
                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: puedeContinuar ? _continuarCancelacion : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: c.linea,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                      label: const Text(
                        'Continuar Cancelación',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
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
  }
}
