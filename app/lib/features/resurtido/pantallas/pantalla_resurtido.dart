import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../core/api/fallo_api.dart';
import '../../../core/formato/formato.dart';
import '../../../core/ticket/ticket_pdf.dart';
import '../../../core/widgets/estados.dart';
import '../../../core/widgets/ilustracion_producto.dart';
import '../../../core/widgets/origen_compartir.dart';
import '../datos/pedido_proveedor_pdf.dart';
import '../estado/resurtido_provider.dart';

/// Sugerencias de resurtido al proveedor según existencias, mínimos y ventas.
class PantallaResurtido extends ConsumerWidget {
  const PantallaResurtido({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(resurtidoProvider);
    final cobertura = ref.watch(coberturaResurtidoProvider);

    return switch (estado) {
      AsyncData(:final value) => _ContenidoResurtido(
        reporte: value,
        cobertura: cobertura,
        alCambiarCobertura: (c) =>
            ref.read(coberturaResurtidoProvider.notifier).cambiar(c),
        alRefrescar: () => ref.read(resurtidoProvider.notifier).refrescar(),
      ),
      AsyncError(:final error) => EstadoError(
        error: error,
        alReintentar: () => ref.invalidate(resurtidoProvider),
      ),
      _ => const Cargando(mensaje: 'Calculando sugerencias de resurtido'),
    };
  }
}

class _ContenidoResurtido extends ConsumerStatefulWidget {
  const _ContenidoResurtido({
    required this.reporte,
    required this.cobertura,
    required this.alCambiarCobertura,
    required this.alRefrescar,
  });

  final ReporteResurtido reporte;
  final int cobertura;
  final ValueChanged<int> alCambiarCobertura;
  final Future<void> Function() alRefrescar;

  @override
  ConsumerState<_ContenidoResurtido> createState() =>
      _ContenidoResurtidoState();
}

class _ContenidoResurtidoState extends ConsumerState<_ContenidoResurtido> {
  final Map<String, int> _cantidades = {};
  String _filtroUrgencia = 'todas';

  @override
  void didUpdateWidget(covariant _ContenidoResurtido oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cobertura != widget.cobertura ||
        oldWidget.reporte.dia != widget.reporte.dia) {
      _cantidades.clear();
    }
  }

  int _cantidadPara(SugerenciaResurtido s) {
    return _cantidades[s.producto.id] ??
        (s.sugeridoCajas > 0 ? s.sugeridoCajas : s.sugeridoPiezas);
  }

  bool _usaCajas(SugerenciaResurtido s) =>
      (s.producto.piezasPorCaja ?? 0) > 1 && s.sugeridoCajas > 0;

  void _ajustar(SugerenciaResurtido s, int delta) {
    final actual = _cantidadPara(s);
    final siguiente = (actual + delta).clamp(0, 9999);
    setState(() => _cantidades[s.producto.id] = siguiente);
  }

  List<RenglonResurtido> _renglonesActivos() => [
    for (final s in widget.reporte.sugerencias)
      (sugerencia: s, cantidad: _cantidadPara(s), porCaja: _usaCajas(s)),
  ];

  Future<void> _enviarWhatsApp(BuildContext context) async {
    final origen = origenCompartir(context);
    final renglones = _renglonesActivos();
    if (!renglones.any((r) => r.cantidad > 0)) {
      avisar(context, 'Selecciona al menos un producto para el pedido');
      return;
    }
    try {
      final negocio = await ref.read(ajustesNegocioProvider.future);
      await compartirPedidoWhatsApp(
        renglones,
        dia: widget.reporte.dia,
        negocio: negocio,
        origen: origen,
      );
    } catch (e) {
      if (context.mounted) {
        avisar(context, 'No se pudo compartir: ${mensajeDeError(e)}');
      }
    }
  }

  Future<void> _generarPdf(
    BuildContext context, {
    required bool imprimir,
  }) async {
    final origen = origenCompartir(context);
    final renglones = _renglonesActivos();
    if (!renglones.any((r) => r.cantidad > 0)) {
      avisar(context, 'Selecciona al menos un producto para el pedido');
      return;
    }
    try {
      final negocio = await ref.read(ajustesNegocioProvider.future);
      if (imprimir) {
        await imprimirPedidoProveedor(
          renglones,
          dia: widget.reporte.dia,
          negocio: negocio,
        );
      } else {
        await compartirPedidoProveedorPdf(
          renglones,
          dia: widget.reporte.dia,
          negocio: negocio,
          origen: origen,
        );
      }
    } catch (e) {
      if (context.mounted) {
        avisar(context, 'No se pudo generar el PDF: ${mensajeDeError(e)}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final textos = Theme.of(context).textTheme;
    final todas = widget.reporte.sugerencias;
    final filtradas = _filtroUrgencia == 'todas'
        ? todas
        : todas.where((s) => s.urgencia == _filtroUrgencia).toList();

    final renglones = _renglonesActivos();
    final seleccionados = renglones.where((r) => r.cantidad > 0).length;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.alRefrescar,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cobertura de inventario',
                          style: textos.titleMedium,
                        ),
                        Text(
                          'Calculado con las ventas de los últimos '
                          '${widget.reporte.dias} días',
                          style: textos.bodySmall,
                        ),
                      ],
                    ),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 7, label: Text('7 días')),
                        ButtonSegment(value: 15, label: Text('15 días')),
                        ButtonSegment(value: 30, label: Text('30 días')),
                      ],
                      selected: {widget.cobertura},
                      onSelectionChanged: (v) =>
                          widget.alCambiarCobertura(v.first),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ChipFiltro(
                      etiqueta: 'Todos (${todas.length})',
                      seleccionado: _filtroUrgencia == 'todas',
                      alTocar: () => setState(() => _filtroUrgencia = 'todas'),
                    ),
                    _ChipFiltro(
                      etiqueta:
                          'Agotados (${todas.where((s) => s.urgencia == UrgenciaResurtido.agotado).length})',
                      seleccionado:
                          _filtroUrgencia == UrgenciaResurtido.agotado,
                      alTocar: () => setState(
                        () => _filtroUrgencia = UrgenciaResurtido.agotado,
                      ),
                    ),
                    _ChipFiltro(
                      etiqueta:
                          'Bajo mínimo (${todas.where((s) => s.urgencia == UrgenciaResurtido.bajoMinimo).length})',
                      seleccionado:
                          _filtroUrgencia == UrgenciaResurtido.bajoMinimo,
                      alTocar: () => setState(
                        () => _filtroUrgencia = UrgenciaResurtido.bajoMinimo,
                      ),
                    ),
                    _ChipFiltro(
                      etiqueta:
                          'Por cubrir (${todas.where((s) => s.urgencia == UrgenciaResurtido.porCubrir).length})',
                      seleccionado:
                          _filtroUrgencia == UrgenciaResurtido.porCubrir,
                      alTocar: () => setState(
                        () => _filtroUrgencia = UrgenciaResurtido.porCubrir,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (filtradas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: EstadoVacio(
                      icono: Icons.check_circle_outline_rounded,
                      titulo: 'Inventario cubierto',
                      mensaje:
                          'No hay productos que requieran resurtido con estos '
                          'criterios.',
                    ),
                  )
                else
                  for (final s in filtradas)
                    _TarjetaSugerencia(
                      sugerencia: s,
                      cantidad: _cantidadPara(s),
                      porCaja: _usaCajas(s),
                      alRestar: () => _ajustar(s, -1),
                      alSumar: () => _ajustar(s, 1),
                    ),
              ],
            ),
          ),
        ),
        if (todas.isNotEmpty)
          Container(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
            decoration: BoxDecoration(
              color: c.superficie,
              border: Border(top: BorderSide(color: c.linea)),
            ),
            child: SafeArea(
              top: false,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '$seleccionados ${seleccionados == 1 ? 'producto' : 'productos'} en el pedido',
                    style: textos.titleMedium,
                  ),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _generarPdf(context, imprimir: true),
                        icon: const Icon(Icons.print_rounded, size: 18),
                        label: const Text('Imprimir'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _generarPdf(context, imprimir: false),
                        icon: const Icon(
                          Icons.picture_as_pdf_rounded,
                          size: 18,
                        ),
                        label: const Text('Compartir PDF'),
                      ),
                      FilledButton.icon(
                        onPressed: () => _enviarWhatsApp(context),
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text('Enviar pedido'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ChipFiltro extends StatelessWidget {
  const _ChipFiltro({
    required this.etiqueta,
    required this.seleccionado,
    required this.alTocar,
  });

  final String etiqueta;
  final bool seleccionado;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(etiqueta),
      selected: seleccionado,
      onSelected: (_) => alTocar(),
    );
  }
}

class _TarjetaSugerencia extends StatelessWidget {
  const _TarjetaSugerencia({
    required this.sugerencia,
    required this.cantidad,
    required this.porCaja,
    required this.alRestar,
    required this.alSumar,
  });

  final SugerenciaResurtido sugerencia;
  final int cantidad;
  final bool porCaja;
  final VoidCallback alRestar;
  final VoidCallback alSumar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final p = sugerencia.producto;
    final (etiqueta, color, fondo) = switch (sugerencia.urgencia) {
      UrgenciaResurtido.agotado => ('Agotado', c.alerta, c.alertaSuave),
      UrgenciaResurtido.bajoMinimo => (
        'Bajo mínimo',
        const Color(0xFFD97706),
        c.lagerSuave,
      ),
      _ => ('Por cubrir', c.azul, c.superficie3),
    };

    final unidad = porCaja
        ? (cantidad == 1 ? 'caja' : 'cajas')
        : (cantidad == 1 ? 'pieza' : 'piezas');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.linea),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: IlustracionProducto(producto: p, radio: 10),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      p.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: fondo,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        etiqueta,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${existenciaLegible(p)} · mínimo ${p.minimo} pz · '
                  '${sugerencia.vendidasPeriodo} vendidas en el periodo',
                  style: TextStyle(color: c.tinta2, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton.outlined(
                tooltip: 'Disminuir',
                onPressed: cantidad > 0 ? alRestar : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              SizedBox(
                width: 78,
                child: Column(
                  children: [
                    Text(
                      '$cantidad',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      unidad,
                      style: TextStyle(fontSize: 12, color: c.tinta2),
                    ),
                  ],
                ),
              ),
              IconButton.outlined(
                tooltip: 'Aumentar',
                onPressed: alSumar,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
