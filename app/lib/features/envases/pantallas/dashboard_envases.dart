import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../core/formato/formato.dart';
import '../../../core/widgets/estados.dart';
import '../datos/modelos_envases.dart';
import '../estado/envases_provider.dart';
import 'acciones_envases.dart';
import 'historial_prestamos.dart';

/// Ámbar de lo prestado (diseño de Pablo).
const _ambar = Color(0xFFD97706);
const _ambarOscuro = Color(0xFFB45309);

/// 5.1 Dashboard de Envases (Control de Envases Retornables), diseño de
/// Pablo: métricas de almacén y calle, existencias por formato, acciones
/// rápidas y últimos movimientos, con los datos del servidor.
class DashboardEnvases extends ConsumerWidget {
  const DashboardEnvases({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colores;
    return Scaffold(
      backgroundColor: c.fondo,
      body: switch (ref.watch(envasesProvider)) {
        AsyncData(:final value) => _Tablero(estado: value),
        AsyncError(:final error) => EstadoError(
          error: error,
          alReintentar: () => ref.read(envasesProvider.notifier).refrescar(),
        ),
        _ => const Cargando(mensaje: 'Cargando envases'),
      },
    );
  }
}

class _Tablero extends ConsumerWidget {
  const _Tablero({required this.estado});

  final EstadoEnvases estado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colores;
    final esCompacto = MediaQuery.of(context).size.width < 800;

    final totalAlmacen = estado.totalBodega;
    final totalCalle = estado.totalPrestados;
    final totalGlobal = estado.total;
    final pctCalle = totalGlobal > 0 ? (totalCalle / totalGlobal) : 0.0;
    final pctAlmacen = totalGlobal > 0 ? (totalAlmacen / totalGlobal) : 0.0;

    ButtonStyle estiloLleno(Color fondo) => ElevatedButton.styleFrom(
      backgroundColor: fondo,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
    final estiloBorde = OutlinedButton.styleFrom(
      side: BorderSide(color: c.linea),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    return RefreshIndicator(
      onRefresh: () => ref.read(envasesProvider.notifier).refrescar(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(esCompacto ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: título y botones de acción
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
                      'Botellas vacías en almacén y prestadas a clientes',
                      style: TextStyle(fontSize: 14, color: c.tinta2),
                    ),
                  ],
                );

                final botones = Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistorialPrestamos(),
                        ),
                      ),
                      style: estiloBorde,
                      icon: const Icon(Icons.handshake_outlined, size: 18),
                      label: Text(
                        'Préstamos (${estado.prestamos.length})',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: c.tinta,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => prestarEnvases(context, ref),
                      style: estiloBorde,
                      icon: const Icon(Icons.outbound_outlined, size: 18),
                      label: Text(
                        'Prestar',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: c.tinta,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => sacarVacios(context, ref),
                      style: estiloBorde,
                      icon: const Icon(Icons.outbox_rounded, size: 18),
                      label: Text(
                        'Sacar vacíos',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: c.tinta,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => devolverDeposito(context, ref),
                      style: estiloLleno(c.azul),
                      icon: const Icon(Icons.payments_outlined, size: 18),
                      label: const Text(
                        'Devolver Depósito',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => recibirVacios(context, ref),
                      style: estiloLleno(c.verde),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: titulo),
                      const SizedBox(width: 16),
                      Flexible(child: botones),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [titulo, const SizedBox(height: 16), botones],
                );
              },
            ),
            const SizedBox(height: 24),

            // Métricas: almacén (izquierda) y calle (derecha)
            if (esCompacto) ...[
              _TarjetaMetrica(
                titulo: 'Envases Físicos en Almacén',
                total: totalAlmacen,
                detalle: 'piezas listas para llenado',
                pie:
                    '${(pctAlmacen * 100).toStringAsFixed(0)}% del inventario '
                    'total bajo resguardo',
                porcentaje: pctAlmacen,
                icono: Icons.warehouse_rounded,
                color: c.verde,
              ),
              const SizedBox(height: 16),
              _TarjetaMetrica(
                titulo: 'Envases en la Calle (Prestados)',
                total: totalCalle,
                detalle: 'piezas en poder de clientes',
                pie:
                    '${(pctCalle * 100).toStringAsFixed(0)}% del inventario '
                    'en circulación externa',
                porcentaje: pctCalle,
                icono: Icons.handshake_rounded,
                color: _ambar,
              ),
            ] else
              Row(
                children: [
                  Expanded(
                    child: _TarjetaMetrica(
                      titulo: 'Envases Físicos en Almacén',
                      total: totalAlmacen,
                      detalle: 'piezas listas para llenado',
                      pie:
                          '${(pctAlmacen * 100).toStringAsFixed(0)}% del '
                          'inventario total bajo resguardo',
                      porcentaje: pctAlmacen,
                      icono: Icons.warehouse_rounded,
                      color: c.verde,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _TarjetaMetrica(
                      titulo: 'Envases en la Calle (Prestados)',
                      total: totalCalle,
                      detalle: 'piezas en poder de clientes',
                      pie:
                          '${(pctCalle * 100).toStringAsFixed(0)}% del '
                          'inventario en circulación externa',
                      porcentaje: pctCalle,
                      icono: Icons.handshake_rounded,
                      color: _ambar,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Desglose por formatos (Mega, Media, Cuarto)
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
                  Flex(
                    direction: esCompacto ? Axis.vertical : Axis.horizontal,
                    children: [
                      for (final f in FormatoEnvase.values)
                        _envolver(
                          esCompacto,
                          _TarjetaFormato(formato: f, estado: estado),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Tabla inferior: últimos movimientos de entrada y salida
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
                      children: [
                        Icon(Icons.history_rounded, size: 22, color: c.azul),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Últimos Movimientos de Entrada y Salida',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: c.tinta,
                            ),
                          ),
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
                    for (final (i, m) in estado.movimientos.indexed) ...[
                      if (i > 0) const Divider(height: 1),
                      ListTile(
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
                            color: m.esEntrada ? c.verde : _ambar,
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
                          '${FormatoEnvase.de(m.formato).etiqueta}'
                          '${m.cliente != null ? ' • ${m.cliente}' : ''}'
                          '${m.monto != null ? ' • ${dinero(m.monto!.abs())}' : ''}'
                          ' — ${fechaHora(m.fecha)}',
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
                            '${m.esEntrada ? '+' : '-'}${m.piezas} pzs',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: m.esEntrada ? c.verde : _ambarOscuro,
                            ),
                          ),
                        ),
                      ),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _envolver(bool vertical, Widget hijo) => vertical
      ? Padding(padding: const EdgeInsets.only(bottom: 10), child: hijo)
      : Expanded(child: hijo);
}

/// Existencias de un formato: almacén, prestados y depósito.
class _TarjetaFormato extends StatelessWidget {
  const _TarjetaFormato({required this.formato, required this.estado});

  final FormatoEnvase formato;
  final EstadoEnvases estado;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final b = estado.de(formato);
    Widget fila(String etiqueta, String valor, Color color) => Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: TextStyle(fontSize: 12, color: c.tinta2)),
          Text(
            valor,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
    return Container(
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
              Icon(formato.icono, size: 18, color: c.azul),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  formato.etiqueta,
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
          const SizedBox(height: 6),
          fila('Almacén:', '${b.bodega} pzs', c.verde),
          fila('Prestados:', '${b.prestados} pzs', _ambar),
          fila('Depósito:', '${dinero(b.precio)} c/u', c.tinta),
        ],
      ),
    );
  }
}

/// Métrica grande con anillo y barra de proporción (diseño de Pablo).
class _TarjetaMetrica extends StatelessWidget {
  const _TarjetaMetrica({
    required this.titulo,
    required this.total,
    required this.detalle,
    required this.pie,
    required this.porcentaje,
    required this.icono,
    required this.color,
  });

  final String titulo;
  final int total;
  final String detalle;
  final String pie;
  final double porcentaje;
  final IconData icono;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
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
            children: [
              Expanded(
                child: Text(
                  titulo,
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
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                  Icon(icono, color: color, size: 20),
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
                '$total',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  detalle,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: porcentaje.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: c.superficie2,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(pie, style: TextStyle(fontSize: 12, color: c.tinta2)),
        ],
      ),
    );
  }
}
