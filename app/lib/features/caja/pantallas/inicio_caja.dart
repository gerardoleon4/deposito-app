import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/tema/colores.dart';
import '../../../core/formato/formato.dart';
import '../../../core/servidor/servidor_embebido.dart';
import '../../../core/widgets/estados.dart';
import '../../../core/widgets/ilustracion_producto.dart';
import '../../catalogo/estado/productos.dart';
import '../../catalogo/pantallas/detalle_producto.dart';
import '../estado/terminales.dart';
import 'conectar_terminal.dart';

/// Tablero de la caja. Las cifras de ventas llegan en el Sprint 4; por ahora
/// muestra lo que ya existe: catálogo, alertas calculadas y terminales.
class InicioCaja extends ConsumerWidget {
  const InicioCaja({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productos = ref.watch(productosProvider);
    return switch (productos) {
      AsyncData(:final value) => _Tablero(productos: value),
      AsyncError(:final error) => EstadoError(
        error: error,
        alReintentar: () => ref.invalidate(productosProvider),
      ),
      _ => const Cargando(),
    };
  }
}

class _Tablero extends ConsumerWidget {
  const _Tablero({required this.productos});

  final List<Producto> productos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colores;
    final textos = Theme.of(context).textTheme;
    final ahora = DateTime.now();
    final terminales =
        ref.watch(terminalesProvider).value ?? const <Terminal>[];
    final ip = ref.watch(direccionLocalProvider).value;

    final bajoMinimo = productos.where((p) => p.bajoMinimo).toList()
      ..sort(
        (a, b) => (a.existenciaPiezas / (a.minimo == 0 ? 1 : a.minimo))
            .compareTo(b.existenciaPiezas / (b.minimo == 0 ? 1 : b.minimo)),
      );
    final porCaducar =
        productos
            .where(
              (p) =>
                  p.caducidad != null && diasHasta(p.caducidad!, ahora) <= 15,
            )
            .toList()
          ..sort((a, b) => a.caducidad!.compareTo(b.caducidad!));
    final atencion = {...bajoMinimo, ...porCaducar}.toList();
    final conectadas = terminales.where((t) => t.conectada).length;
    final piezas = productos.fold<int>(0, (s, p) => s + p.existenciaPiezas);

    final saludo = switch (ahora.hour) {
      < 12 => 'Buenos días',
      < 19 => 'Buenas tardes',
      _ => 'Buenas noches',
    };

    return LayoutBuilder(
      builder: (context, medidas) {
        final ancho = medidas.maxWidth;
        final columnasKpi = ancho > 1000 ? 4 : 2;
        final dosColumnas = ancho > 900;
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.end,
              runSpacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(saludo, style: textos.displaySmall),
                    const SizedBox(height: 4),
                    Text(
                      ip == null
                          ? 'La caja está lista. Conéctala a la Wi-Fi para recibir terminales.'
                          : 'La caja está lista en $ip. ${_textoTerminales(conectadas)}',
                      style: textos.bodyLarge?.copyWith(color: c.tinta2),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: () => context.go('/caja/vender'),
                  icon: const Icon(Icons.shopping_cart_rounded),
                  label: const Text('Nueva venta'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 60),
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    textStyle: textos.titleMedium?.copyWith(fontSize: 19),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // Alto fijo: con proporción, una ventana angosta las aplasta.
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnasKpi,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                mainAxisExtent: 112,
              ),
              children: [
                _Kpi(
                  icono: Icons.inventory_2_outlined,
                  etiqueta: 'Productos',
                  valor: '${productos.length}',
                  detalle: '$piezas piezas en existencia',
                  fondo: c.lagerSuave,
                  tinta: c.tinta,
                ),
                _Kpi(
                  icono: Icons.trending_down_rounded,
                  etiqueta: 'Bajo el mínimo',
                  valor: '${bajoMinimo.length}',
                  detalle: bajoMinimo.isEmpty
                      ? 'Todo en orden'
                      : 'por resurtir',
                  fondo: c.alertaSuave,
                  tinta: c.alerta,
                ),
                _Kpi(
                  icono: Icons.event_busy_outlined,
                  etiqueta: 'Caducan en 15 días',
                  valor: '${porCaducar.length}',
                  detalle: porCaducar.isEmpty ? 'Ninguno' : 'vender primero',
                  fondo: c.superficie3,
                  tinta: c.azul,
                ),
                _Kpi(
                  icono: Icons.smartphone_rounded,
                  etiqueta: 'Terminales',
                  valor: '$conectadas',
                  detalle: '${terminales.length} vinculadas',
                  fondo: c.verdeSuave,
                  tinta: c.verde,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Flex(
              direction: dosColumnas ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 18,
              children: [
                _envolver(
                  dosColumnas,
                  3,
                  _Tarjeta(
                    titulo: 'Necesita atención',
                    accion: TextButton(
                      onPressed: () => context.go('/caja/catalogo'),
                      child: const Text('Ver catálogo'),
                    ),
                    child: atencion.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: EstadoVacio(
                              icono: Icons.check_circle_outline_rounded,
                              titulo: 'Todo en orden',
                              mensaje: 'Ningún producto está bajo su mínimo ni por caducar.',
                            ),
                          )
                        : Column(
                            children: [
                              for (final p in atencion.take(6))
                                _FilaAtencion(producto: p, hoy: ahora),
                            ],
                          ),
                  ),
                ),
                _envolver(
                  dosColumnas,
                  2,
                  _Tarjeta(
                    titulo: 'Terminales',
                    accion: TextButton.icon(
                      onPressed: () => mostrarConectarTerminal(context),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('Conectar'),
                    ),
                    child: terminales.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Text(
                              'Conecta el S24 o el iPhone para escanear productos en los pasillos.',
                              style: TextStyle(color: c.tinta2),
                            ),
                          )
                        : Column(
                            children: [
                              for (final t in terminales)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    Icons.smartphone_rounded,
                                    color: c.tinta2,
                                  ),
                                  title: Text(
                                    t.nombre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 9,
                                        height: 9,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: t.conectada
                                              ? const Color(0xFF46C281)
                                              : c.linea,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        t.conectada
                                            ? 'En línea'
                                            : 'Fuera de línea',
                                        style: TextStyle(color: c.tinta2),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _envolver(bool fila, int flex, Widget hijo) =>
      fila ? Expanded(flex: flex, child: hijo) : hijo;

  static String _textoTerminales(int n) => switch (n) {
    0 => 'Ninguna terminal conectada.',
    1 => 'Una terminal conectada.',
    _ => '$n terminales conectadas.',
  };
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.detalle,
    required this.fondo,
    required this.tinta,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;
  final String detalle;
  final Color fondo;
  final Color tinta;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final textos = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.linea),
        boxShadow: c.sombra,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: fondo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: tinta, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  etiqueta,
                  style: textos.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(valor, style: textos.headlineLarge),
                Text(
                  detalle,
                  style: textos.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({required this.titulo, required this.child, this.accion});

  final String titulo;
  final Widget child;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.linea),
        boxShadow: c.sombra,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ?accion,
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _FilaAtencion extends StatelessWidget {
  const _FilaAtencion({required this.producto, required this.hoy});

  final Producto producto;
  final DateTime hoy;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final p = producto;
    final dias = p.caducidad == null ? null : diasHasta(p.caducidad!, hoy);
    final (motivo, color, fondo) = p.bajoMinimo
        ? ('Bajo el mínimo', c.alerta, c.alertaSuave)
        : (
            'Caduca ${dias! <= 0 ? 'hoy' : 'en $dias días'}',
            c.azul,
            c.superficie3,
          );
    return InkWell(
      onTap: () => mostrarDetalleProducto(context, p),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: c.linea)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 46,
              height: 46,
              child: IlustracionProducto(producto: p, radio: 10),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${existenciaLegible(p)} · mínimo ${p.minimo} pz',
                    style: TextStyle(color: c.tinta2, fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: fondo,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                motivo,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
