import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../core/formato/formato.dart';
import '../../../core/widgets/estados.dart';
import '../datos/modelos_envases.dart';
import '../estado/envases_provider.dart';
import 'acciones_envases.dart';
import 'historial_prestamos.dart';

/// Tablero de envases retornables: cuántos hay en bodega y cuántos prestados,
/// por formato, y los préstamos más recientes.
class DashboardEnvases extends ConsumerWidget {
  const DashboardEnvases({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colores;
    final envases = ref.watch(envasesProvider);
    return Scaffold(
      backgroundColor: c.fondo,
      body: SafeArea(
        child: switch (envases) {
          AsyncData(:final value) => RefreshIndicator(
            onRefresh: () => ref.read(envasesProvider.notifier).refrescar(),
            child: _Contenido(estado: value),
          ),
          AsyncError(:final error) => EstadoError(
            error: error,
            alReintentar: () => ref.invalidate(envasesProvider),
          ),
          _ => const Cargando(mensaje: 'Cargando envases…'),
        },
      ),
    );
  }
}

class _Contenido extends ConsumerWidget {
  const _Contenido({required this.estado});

  final EstadoEnvases estado;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colores;
    final esCompacto = MediaQuery.sizeOf(context).width < 800;
    final total = estado.total;
    final pctBodega = total > 0 ? estado.totalBodega / total : 0.0;
    final pctPrestados = total > 0 ? estado.totalPrestados / total : 0.0;
    final recientes = estado.prestamos.take(5).toList();

    final bodega = _TarjetaMetrica(
      titulo: 'Envases en bodega',
      cantidad: estado.totalBodega,
      detalle: 'vacíos en el depósito',
      pie: '${(pctBodega * 100).round()}% del total',
      porcentaje: pctBodega,
      icono: Icons.warehouse_rounded,
      color: c.verde,
    );
    final prestados = _TarjetaMetrica(
      titulo: 'Prestados a clientes',
      cantidad: estado.totalPrestados,
      detalle: 'por regresar',
      pie: '${(pctPrestados * 100).round()}% del total',
      porcentaje: pctPrestados,
      icono: Icons.handshake_rounded,
      color: c.lagerTinta,
    );

    return ListView(
      padding: EdgeInsets.all(esCompacto ? 16 : 24),
      children: [
        _Cabecera(prestamosActivos: estado.prestamos.length),
        const SizedBox(height: 24),
        if (esCompacto) ...[
          bodega,
          const SizedBox(height: 16),
          prestados,
        ] else
          Row(
            children: [
              Expanded(child: bodega),
              const SizedBox(width: 20),
              Expanded(child: prestados),
            ],
          ),
        const SizedBox(height: 24),
        _Seccion(
          titulo: 'Por formato',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final f in FormatoEnvase.values)
                _TarjetaFormato(formato: f, balance: estado.de(f)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _Seccion(
          titulo: 'Préstamos recientes',
          accion: estado.prestamos.length > recientes.length
              ? TextButton(
                  onPressed: () => _abrirHistorial(context),
                  child: Text('Ver los ${estado.prestamos.length}'),
                )
              : null,
          child: recientes.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No hay envases prestados',
                      style: TextStyle(color: c.tinta2),
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (final p in recientes) ...[
                      _FilaPrestamo(prestamo: p),
                      if (p != recientes.last) const Divider(height: 1),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

void _abrirHistorial(BuildContext context) => Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const HistorialPrestamos()),
);

class _Cabecera extends ConsumerWidget {
  const _Cabecera({required this.prestamosActivos});

  final int prestamosActivos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colores;
    final titulo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Envases retornables',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: c.tinta,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Vacíos en bodega y préstamos a clientes',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
      ],
    );
    final estiloBoton = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    const relleno = EdgeInsets.symmetric(horizontal: 16, vertical: 14);
    final botones = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        OutlinedButton.icon(
          onPressed: () => _abrirHistorial(context),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: c.linea),
            padding: relleno,
            shape: estiloBoton,
          ),
          icon: const Icon(Icons.list_alt_rounded, size: 18),
          label: Text(
            'Préstamos ($prestamosActivos)',
            style: TextStyle(fontWeight: FontWeight.w700, color: c.tinta),
          ),
        ),
        FilledButton.icon(
          onPressed: () => prestarEnvases(context, ref),
          style: FilledButton.styleFrom(
            backgroundColor: c.azul,
            foregroundColor: Colors.white,
            padding: relleno,
            shape: estiloBoton,
          ),
          icon: const Icon(Icons.handshake_outlined, size: 18),
          label: const Text(
            'Prestar',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        FilledButton.icon(
          onPressed: () => recibirVacios(context, ref),
          style: FilledButton.styleFrom(
            backgroundColor: c.verde,
            foregroundColor: Colors.white,
            padding: relleno,
            shape: estiloBoton,
          ),
          icon: const Icon(Icons.recycling_rounded, size: 18),
          label: const Text(
            'Recibir vacíos',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, restricciones) => restricciones.maxWidth > 850
          ? Row(
              children: [
                Expanded(child: titulo),
                const SizedBox(width: 16),
                botones,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [titulo, const SizedBox(height: 16), botones],
            ),
    );
  }
}

class _TarjetaMetrica extends StatelessWidget {
  const _TarjetaMetrica({
    required this.titulo,
    required this.cantidad,
    required this.detalle,
    required this.pie,
    required this.porcentaje,
    required this.icono,
    required this.color,
  });

  final String titulo;
  final int cantidad;
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
              Icon(icono, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$cantidad',
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

class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.child, this.accion});

  final String titulo;
  final Widget child;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.linea),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: c.tinta,
                  ),
                ),
              ),
              ?accion,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _TarjetaFormato extends StatelessWidget {
  const _TarjetaFormato({required this.formato, required this.balance});

  final FormatoEnvase formato;
  final BalanceEnvase balance;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
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
      width: 220,
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
          fila('En bodega', '${balance.bodega} pz', c.verde),
          fila('Prestados', '${balance.prestados} pz', c.lagerTinta),
          fila('Depósito', '${dinero(balance.precio)} c/u', c.tinta),
        ],
      ),
    );
  }
}

class _FilaPrestamo extends ConsumerWidget {
  const _FilaPrestamo({required this.prestamo});

  final PrestamoEnvase prestamo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colores;
    final formato = FormatoEnvase.de(prestamo.formato);
    final dias = diasDesde(prestamo.fecha, DateTime.now());
    final vencido = dias >= diasPrestamoVencido;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: vencido ? c.lagerSuave : c.superficie2,
        child: Icon(formato.icono, color: vencido ? c.lagerTinta : c.azul),
      ),
      title: Text(
        prestamo.cliente,
        style: TextStyle(fontWeight: FontWeight.bold, color: c.tinta),
      ),
      subtitle: Text(
        '${prestamo.cantidad} ${formato.etiqueta} · '
        '${dias == 0 ? 'hoy' : 'hace $dias ${dias == 1 ? 'día' : 'días'}'}',
        style: TextStyle(
          fontSize: 13,
          color: vencido ? c.lagerTinta : c.tinta2,
          fontWeight: vencido ? FontWeight.w700 : null,
        ),
      ),
      trailing: OutlinedButton(
        onPressed: () => recibirPrestamo(context, ref, prestamo),
        child: const Text('Recibir'),
      ),
    );
  }
}
