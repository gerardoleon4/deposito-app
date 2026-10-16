import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/tema/colores.dart';
import '../datos/modelos_envases.dart';
import '../estado/envases_provider.dart';
import 'historial_prestamos.dart';
import 'modal_recepcion_envases.dart';
import 'modal_retorno_deposito.dart';

/// 5.1 Dashboard de Envases (Control de Envases Retornables)
/// Panel principal con tarjetas de métricas de almacén y calle, proporción circulante,
/// acciones rápidas y tabla de movimientos recientes.
class DashboardEnvases extends ConsumerWidget {
  const DashboardEnvases({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colores;
    final estado = ref.watch(envasesProvider);
    final ancho = MediaQuery.of(context).size.width;
    final esCompacto = ancho < 800;

    final totalAlmacen = estado.totalAlmacen;
    final totalCalle = estado.totalCalle;
    final totalGlobal = estado.totalGlobal;
    final pctCalle = totalGlobal > 0 ? (totalCalle / totalGlobal) : 0.0;
    final pctAlmacen = totalGlobal > 0 ? (totalAlmacen / totalGlobal) : 0.0;

    return Scaffold(
      backgroundColor: c.fondo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera: Título "Control de Envases Retornables" y botones de acción
              LayoutBuilder(
                builder: (context, constraints) {
                  final esAncho = constraints.maxWidth > 850;
                  final titulo = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Control de Envases Retornables',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: c.tinta,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Monitoreo en tiempo real de botellas en almacén y en la calle',
                        style: TextStyle(fontSize: 14, color: c.tinta2),
                      ),
                    ],
                  );

                  final botones = Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HistorialPrestamos(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: c.linea),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.handshake_outlined, size: 18),
                        label: Text(
                          'Préstamos (${estado.prestamosActivos.length})',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: c.tinta,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          ModalRetornoDeposito.mostrar(context: context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.azul,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.payments_outlined, size: 18),
                        label: const Text(
                          'Devolver Depósito',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          ModalRecepcionEnvases.mostrar(
                            context: context,
                            alConfirmar: (cant, form, credito) {
                              ref
                                  .read(envasesProvider.notifier)
                                  .registrarRecepcionVacios(
                                    cantidad: cant,
                                    formato: form,
                                    creditoTotal: credito,
                                  );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.verde,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.recycling_rounded, size: 18),
                        label: const Text(
                          'Recibir Vacíos',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  );

                  if (esAncho) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: titulo),
                        const SizedBox(width: 16),
                        botones,
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [titulo, const SizedBox(height: 16), botones],
                    );
                  }
                },
              ),
              const SizedBox(height: 24),

              // Layout de Métricas: Métrica 1 (Izquierda) y Métrica 2 (Derecha)
              if (esCompacto) ...[
                _TarjetaMetricaAlmacen(
                  totalAlmacen: totalAlmacen,
                  porcentaje: pctAlmacen,
                  c: c,
                ),
                const SizedBox(height: 16),
                _TarjetaMetricaCalle(
                  totalCalle: totalCalle,
                  porcentaje: pctCalle,
                  c: c,
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: _TarjetaMetricaAlmacen(
                        totalAlmacen: totalAlmacen,
                        porcentaje: pctAlmacen,
                        c: c,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _TarjetaMetricaCalle(
                        totalCalle: totalCalle,
                        porcentaje: pctCalle,
                        c: c,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // Desglose por Formatos (Mega, Media, Cuarto)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: c.superficie,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.linea),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Existencias por Formato',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: c.tinta,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: TipoFormatoEnvase.values.map((f) {
                        final st =
                            estado.stocks[f] ??
                            StockEnvases(formato: f, enAlmacen: 0, enCalle: 0);
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: c.superficie2,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: c.linea),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(f.icono, size: 18, color: c.azul),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        f.etiqueta,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: c.tinta,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Almacén:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: c.tinta2,
                                      ),
                                    ),
                                    Text(
                                      '${st.enAlmacen} pzs',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: c.verde,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Prestados:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: c.tinta2,
                                      ),
                                    ),
                                    Text(
                                      '${st.enCalle} pzs',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: Color(0xFFD97706),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Tabla Inferior: Últimos movimientos de entrada y salida
              Container(
                decoration: BoxDecoration(
                  color: c.superficie,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.linea),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.history_rounded,
                                size: 22,
                                color: c.azul,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Últimos Movimientos de Entrada y Salida',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: c.tinta,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${estado.movimientos.length} registros',
                            style: TextStyle(fontSize: 13, color: c.tinta2),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    if (estado.movimientos.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No hay movimientos registrados',
                            style: TextStyle(color: c.tinta2),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: estado.movimientos.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final m = estado.movimientos[i];
                          final fechaStr = DateFormat(
                            'dd/MM/yyyy • hh:mm a',
                          ).format(m.fecha);

                          return ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: m.esEntrada
                                    ? c.verde.withValues(alpha: 0.12)
                                    : Colors.amber.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                m.esEntrada
                                    ? Icons.arrow_downward_rounded
                                    : Icons.arrow_upward_rounded,
                                color: m.esEntrada
                                    ? c.verde
                                    : const Color(0xFFD97706),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              m.concepto,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: c.tinta,
                              ),
                            ),
                            subtitle: Text(
                              '${m.formato.etiqueta}${m.cliente != null ? ' • ${m.cliente}' : ''} — $fechaStr',
                              style: TextStyle(fontSize: 13, color: c.tinta2),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: m.esEntrada
                                    ? c.verdeSuave
                                    : Colors.amber.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${m.esEntrada ? '+' : '-'}${m.cantidad} pzs',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: m.esEntrada
                                      ? c.verde
                                      : const Color(0xFFB45309),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Métrica 1 (Izquierda): Tarjeta grande "Envases Físicos en Almacén"
class _TarjetaMetricaAlmacen extends StatelessWidget {
  const _TarjetaMetricaAlmacen({
    required this.totalAlmacen,
    required this.porcentaje,
    required this.c,
  });

  final int totalAlmacen;
  final double porcentaje;
  final ColoresAnaquel c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.linea),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Envases Físicos en Almacén',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: c.tinta2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      value: porcentaje.clamp(0.0, 1.0),
                      strokeWidth: 4,
                      backgroundColor: c.superficie2,
                      valueColor: AlwaysStoppedAnimation(c.verde),
                    ),
                  ),
                  Icon(Icons.warehouse_rounded, color: c.verde, size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$totalAlmacen',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: c.verde,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'piezas listas para llenado',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.tinta2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barra sutil de progreso / proporción
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: porcentaje.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: c.superficie2,
              valueColor: AlwaysStoppedAnimation(c.verde),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(porcentaje * 100).toStringAsFixed(0)}% del inventario total bajo resguardo',
            style: TextStyle(fontSize: 12, color: c.tinta2),
          ),
        ],
      ),
    );
  }
}

/// Métrica 2 (Derecha): Tarjeta grande "Envases en la Calle (Prestados)"
class _TarjetaMetricaCalle extends StatelessWidget {
  const _TarjetaMetricaCalle({
    required this.totalCalle,
    required this.porcentaje,
    required this.c,
  });

  final int totalCalle;
  final double porcentaje;
  final ColoresAnaquel c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.linea),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Envases en la Calle (Prestados)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: c.tinta2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      value: porcentaje.clamp(0.0, 1.0),
                      strokeWidth: 4,
                      backgroundColor: c.superficie2,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFFD97706),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.handshake_rounded,
                    color: Color(0xFFD97706),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$totalCalle',
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFD97706),
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'piezas en poder de clientes',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.tinta2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barra sutil de progreso / proporción
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: porcentaje.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: c.superficie2,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFD97706)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(porcentaje * 100).toStringAsFixed(0)}% del inventario en circulación externa',
            style: TextStyle(fontSize: 12, color: c.tinta2),
          ),
        ],
      ),
    );
  }
}
