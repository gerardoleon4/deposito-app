import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../core/widgets/estados.dart';
import '../datos/modelos_envases.dart';
import '../estado/envases_provider.dart';
import 'acciones_envases.dart';

/// Clientes que deben envases, con búsqueda por nombre. Los de más de
/// [diasPrestamoVencido] días se resaltan para cobrarlos.
class HistorialPrestamos extends ConsumerStatefulWidget {
  const HistorialPrestamos({super.key});

  @override
  ConsumerState<HistorialPrestamos> createState() => _HistorialPrestamosState();
}

class _HistorialPrestamosState extends ConsumerState<HistorialPrestamos> {
  var _busqueda = '';

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final envases = ref.watch(envasesProvider);
    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        backgroundColor: c.superficie,
        title: const Text('Préstamos de envases'),
        actions: [
          IconButton(
            tooltip: 'Prestar envases',
            onPressed: () => prestarEnvases(context, ref),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: c.linea, height: 1),
        ),
      ),
      body: SafeArea(
        child: switch (envases) {
          AsyncData(:final value) => _lista(value.prestamos),
          AsyncError(:final error) => EstadoError(
            error: error,
            alReintentar: () => ref.invalidate(envasesProvider),
          ),
          _ => const Cargando(),
        },
      ),
    );
  }

  Widget _lista(List<PrestamoEnvase> todos) {
    final c = context.colores;
    final q = normalizarBusqueda(_busqueda);
    final prestamos = q.isEmpty
        ? todos
        : todos
              .where((p) => normalizarBusqueda(p.cliente).contains(q))
              .toList();
    final esAncho = MediaQuery.sizeOf(context).width > 700;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: c.superficie,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _busqueda = v),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre del cliente',
                    prefixIcon: const Icon(Icons.search_rounded),
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
              ),
              const SizedBox(width: 12),
              Text(
                '${prestamos.length} pendientes',
                style: TextStyle(fontWeight: FontWeight.w700, color: c.tinta),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(envasesProvider.notifier).refrescar(),
            child: prestamos.isEmpty
                ? ListView(
                    children: [
                      EstadoVacio(
                        icono: Icons.check_circle_outline_rounded,
                        titulo: todos.isEmpty
                            ? 'No hay envases prestados'
                            : 'Ningún cliente coincide con "$_busqueda"',
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(esAncho ? 24 : 16),
                    itemCount: prestamos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _TarjetaPrestamo(
                      prestamo: prestamos[i],
                      alRecibir: () =>
                          recibirPrestamo(context, ref, prestamos[i]),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _TarjetaPrestamo extends StatelessWidget {
  const _TarjetaPrestamo({required this.prestamo, required this.alRecibir});

  final PrestamoEnvase prestamo;
  final VoidCallback alRecibir;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final formato = FormatoEnvase.de(prestamo.formato);
    final dias = diasDesde(prestamo.fecha, DateTime.now());
    final vencido = dias >= diasPrestamoVencido;
    final local = DateTime.parse(prestamo.fecha).toLocal();
    final fecha =
        '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: vencido ? c.lagerTinta : c.linea,
          width: vencido ? 1.8 : 1.0,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: vencido ? c.lagerSuave : c.superficie2,
            child: Text(
              prestamo.cliente.isEmpty
                  ? '?'
                  : prestamo.cliente[0].toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: vencido ? c.lagerTinta : c.azul,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prestamo.cliente,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: c.tinta,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${prestamo.cantidad} ${formato.etiqueta} · desde el $fecha',
                  style: TextStyle(fontSize: 13, color: c.tinta2),
                ),
                if (vencido)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: c.lagerTinta,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Hace $dias días',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: c.lagerTinta,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: alRecibir,
            style: FilledButton.styleFrom(
              backgroundColor: c.verde,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Recibir'),
          ),
        ],
      ),
    );
  }
}
