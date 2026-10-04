import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../core/formato/formato.dart';
import '../../../core/widgets/estados.dart';
import '../../catalogo/estado/productos.dart';
import '../../terminal/pantallas/escaner.dart';
import '../estado/carrito.dart';
import 'flujo_cobro.dart';

/// Sección "Vender" de la caja: catálogo real a la izquierda y la venta en
/// curso a la derecha (en pantallas angostas, en un botón flotante).
class PuntoVenta extends ConsumerStatefulWidget {
  const PuntoVenta({super.key});

  @override
  ConsumerState<PuntoVenta> createState() => _PuntoVentaState();
}

class _PuntoVentaState extends ConsumerState<PuntoVenta>
    with SingleTickerProviderStateMixin {
  final _busqueda = TextEditingController();
  String? _categoria;
  String? _itemRecienteClave;

  late final AnimationController _rebote = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  @override
  void dispose() {
    _rebote.dispose();
    _busqueda.dispose();
    super.dispose();
  }

  void _mostrarAlertaInventario(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mensaje,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.amber[800],
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  void _agregarAlCarrito(Producto prod, {bool porCaja = false}) {
    final motivo = ref
        .read(carritoProvider.notifier)
        .agregar(prod, porCaja: porCaja);
    if (motivo != null) {
      _mostrarAlertaInventario(motivo);
      return;
    }
    final clave = '${prod.id}_${porCaja ? 'caja' : 'pieza'}';
    setState(() => _itemRecienteClave = clave);
    _rebote.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && _itemRecienteClave == clave) {
        setState(() => _itemRecienteClave = null);
      }
    });
  }

  void _alTocarProducto(Producto prod) {
    if (prod.precioCaja != null && prod.piezasPorCaja != null) {
      _mostrarModalVariante(prod);
    } else {
      _agregarAlCarrito(prod);
    }
  }

  /// Un código exacto (lector de código de barras o Enter) va directo al
  /// carrito; si no, el texto queda como búsqueda.
  void _alEnviarBusqueda(List<Producto> productos, String texto) {
    final p = porCodigo(productos, texto);
    if (p == null) return;
    _agregarAlCarrito(p);
    _busqueda.clear();
    setState(() {});
  }

  Future<void> _abrirEscaner(List<Producto> productos) async {
    final codigo = await escanearCodigo(
      context,
      titulo: 'Escanear producto',
      ayuda: 'Apunta al código de barras',
    );
    if (codigo == null || !mounted) return;
    final p = porCodigo(productos, codigo);
    if (p == null) {
      _mostrarAlertaInventario('El código $codigo no está en el catálogo');
    } else {
      _agregarAlCarrito(p);
    }
  }

  void _mostrarModalVariante(Producto prod) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (contextoHoja) {
        final c = context.colores;
        return Container(
          decoration: BoxDecoration(
            color: c.superficie,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.linea,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  prod.nombre,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: c.tinta,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _BotonVariante(
                        icono: Icons.sports_bar_outlined,
                        texto: 'Vender 1 pieza',
                        precio: prod.precio,
                        alPresionar: () {
                          Navigator.pop(contextoHoja);
                          _agregarAlCarrito(prod);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _BotonVariante(
                        icono: Icons.inventory_2_outlined,
                        texto: 'Vender 1 caja (${prod.piezasPorCaja} pz)',
                        precio: prod.precioCaja!,
                        alPresionar: () {
                          Navigator.pop(contextoHoja);
                          _agregarAlCarrito(prod, porCaja: true);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarEdicionCarrito(ItemCarrito item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (contextoHoja) => Consumer(
        builder: (context, ref, _) {
          final c = context.colores;
          final actual = ref
              .watch(carritoProvider)
              .items
              .where((i) => i.clave == item.clave)
              .firstOrNull;
          if (actual == null) return const SizedBox.shrink();
          void cambiar(int n) {
            final motivo = ref
                .read(carritoProvider.notifier)
                .cambiarCantidad(actual, n);
            if (motivo != null) {
              Navigator.pop(contextoHoja);
              _mostrarAlertaInventario(motivo);
            } else if (n == 0) {
              Navigator.pop(contextoHoja);
            }
          }

          return Container(
            decoration: BoxDecoration(
              color: c.superficie,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: c.linea,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _nombreItem(actual),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: c.tinta,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: 'Quitar uno',
                        onPressed: () => cambiar(actual.cantidad - 1),
                        icon: const Icon(Icons.remove_circle_outline),
                        iconSize: 48,
                        color: c.tinta2,
                      ),
                      const SizedBox(width: 24),
                      Text(
                        '${actual.cantidad}',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: c.tinta,
                        ),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        tooltip: 'Agregar uno',
                        onPressed: () => cambiar(actual.cantidad + 1),
                        icon: const Icon(Icons.add_circle_outline),
                        iconSize: 48,
                        color: c.azul,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => cambiar(0),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.alerta.withValues(alpha: 0.1),
                        foregroundColor: c.alerta,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Eliminar producto',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _irACobrar() => Navigator.of(
    context,
    rootNavigator: true,
  ).push(MaterialPageRoute(builder: (_) => const ResumenCompra()));

  @override
  Widget build(BuildContext context) {
    final productos = ref.watch(productosProvider);
    return switch (productos) {
      AsyncData(:final value) => _venta(context, value),
      AsyncError(:final error) => EstadoError(
        error: error,
        alReintentar: () => ref.invalidate(productosProvider),
      ),
      _ => const Cargando(mensaje: 'Cargando productos'),
    };
  }

  Widget _venta(BuildContext context, List<Producto> todos) {
    final c = context.colores;
    final carrito = ref.watch(carritoProvider);
    final esAncho = MediaQuery.sizeOf(context).width > 900;
    final categorias = categoriasDe(todos);
    final visibles = filtrarProductos(
      todos,
      busqueda: _busqueda.text,
      categoria: _categoria,
    );

    return Scaffold(
      backgroundColor: c.fondo,
      body: SafeArea(
        child: Row(
          children: [
            // Catálogo
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _busqueda,
                                onChanged: (_) => setState(() {}),
                                onSubmitted: (t) => _alEnviarBusqueda(todos, t),
                                decoration: InputDecoration(
                                  hintText: 'Buscar o escanear código...',
                                  prefixIcon: const Icon(Icons.search),
                                  filled: true,
                                  fillColor: c.superficie,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              tooltip: 'Escanear con la cámara',
                              onPressed: () => _abrirEscaner(todos),
                              icon: const Icon(Icons.qr_code_scanner_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor: c.azul.withValues(alpha: 0.1),
                                foregroundColor: c.azul,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final cat in [null, ...categorias])
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _Filtro(
                                    texto: cat == null
                                        ? 'Todas'
                                        : capitalizar(cat),
                                    activo: _categoria == cat,
                                    alElegir: () =>
                                        setState(() => _categoria = cat),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: visibles.isEmpty
                        ? const EstadoVacio(
                            icono: Icons.search_off_rounded,
                            titulo: 'Sin productos',
                            mensaje: 'Prueba con otra búsqueda o categoría.',
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 220,
                                  childAspectRatio: 0.85,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            itemCount: visibles.length,
                            itemBuilder: (context, i) {
                              final prod = visibles[i];
                              return _TarjetaProducto(
                                producto: prod,
                                enCarrito: carrito.piezasDe(prod.id),
                                alTocar: () => _alTocarProducto(prod),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),

            // Venta actual (en pantallas anchas)
            if (esAncho)
              SizedBox(
                width: 380,
                child: Container(
                  decoration: BoxDecoration(
                    color: c.superficie2,
                    border: Border(left: BorderSide(color: c.linea)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: c.superficie,
                          border: Border(bottom: BorderSide(color: c.linea)),
                        ),
                        child: Text(
                          'Venta actual',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: c.tinta,
                          ),
                        ),
                      ),
                      Expanded(
                        child: carrito.vacio
                            ? _CarritoVacio(c: c)
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                itemCount: carrito.items.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, i) {
                                  final item = carrito.items[i];
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    color: item.clave == _itemRecienteClave
                                        ? c.azul.withValues(alpha: 0.1)
                                        : Colors.transparent,
                                    child: Material(
                                      type: MaterialType.transparency,
                                      child: ListTile(
                                        title: Text(
                                          _nombreItem(item),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: c.tinta,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${dinero(item.precioUnitario)} x ${item.cantidad}',
                                          style: TextStyle(color: c.tinta2),
                                        ),
                                        trailing: Text(
                                          dinero(item.subtotal),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: c.tinta,
                                          ),
                                        ),
                                        onTap: () =>
                                            _mostrarEdicionCarrito(item),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: c.superficie,
                          border: Border(top: BorderSide(color: c.linea)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    color: c.tinta,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  dinero(carrito.total),
                                  style: TextStyle(
                                    color: c.azul,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: carrito.vacio ? null : _irACobrar,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: c.azul,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: c.linea,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Cobrar',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
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
              ),
          ],
        ),
      ),

      // En pantallas angostas, el total en un botón que lleva al cobro.
      floatingActionButton: (!esAncho && !carrito.vacio)
          ? ScaleTransition(
              scale: Tween<double>(begin: 1, end: 1.1).animate(
                CurvedAnimation(parent: _rebote, curve: Curves.elasticOut),
              ),
              child: FloatingActionButton.extended(
                onPressed: _irACobrar,
                backgroundColor: c.azul,
                icon: const Icon(
                  Icons.shopping_cart_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  'Cobrar ${dinero(carrito.total)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

String _nombreItem(ItemCarrito i) =>
    i.porCaja ? '${i.producto.nombre} (caja)' : i.producto.nombre;

class _Filtro extends StatelessWidget {
  const _Filtro({
    required this.texto,
    required this.activo,
    required this.alElegir,
  });

  final String texto;
  final bool activo;
  final VoidCallback alElegir;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return ChoiceChip(
      label: Text(texto),
      selected: activo,
      onSelected: (_) => alElegir(),
      selectedColor: c.azul,
      showCheckmark: false,
      labelStyle: TextStyle(
        color: activo ? Colors.white : c.tinta,
        fontWeight: activo ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: c.superficie,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: activo ? Colors.transparent : c.linea),
      ),
    );
  }
}

class _CarritoVacio extends StatelessWidget {
  const _CarritoVacio({required this.c});
  final ColoresAnaquel c;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_basket_outlined, size: 80, color: c.linea),
        const SizedBox(height: 16),
        Text(
          'Aún no hay productos en la venta',
          style: TextStyle(color: c.tinta2, fontSize: 16),
        ),
      ],
    );
  }
}

class _TarjetaProducto extends StatelessWidget {
  const _TarjetaProducto({
    required this.producto,
    required this.enCarrito,
    required this.alTocar,
  });

  final Producto producto;

  /// Piezas de este producto que ya están en la venta.
  final int enCarrito;
  final VoidCallback alTocar;

  IconData get _icono => switch (producto.categoria) {
    'cerveza' => Icons.sports_bar_rounded,
    'botana' => Icons.fastfood_rounded,
    'hielo' => Icons.ac_unit_rounded,
    'refresco' => Icons.local_drink_rounded,
    _ => Icons.inventory_2_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final agotado = producto.existenciaPiezas - enCarrito <= 0;
    return Opacity(
      opacity: agotado ? 0.5 : 1,
      child: Material(
        color: c.superficie,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: alTocar,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: enCarrito > 0 ? c.azul : c.linea),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: c.superficie2,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _icono,
                        size: 48,
                        color: c.azul.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombre,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: c.tinta,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        agotado ? 'Agotado' : existenciaLegible(producto),
                        style: TextStyle(
                          fontSize: 12,
                          color: agotado ? c.alerta : c.tinta2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dinero(producto.precio),
                            style: TextStyle(
                              color: c.azul,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (producto.precioCaja != null)
                            Icon(
                              Icons.layers_outlined,
                              size: 16,
                              color: c.tinta2,
                            ),
                        ],
                      ),
                    ],
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

class _BotonVariante extends StatelessWidget {
  const _BotonVariante({
    required this.icono,
    required this.texto,
    required this.precio,
    required this.alPresionar,
  });

  final IconData icono;
  final String texto;

  /// Centavos.
  final int precio;
  final VoidCallback alPresionar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return InkWell(
      onTap: alPresionar,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: c.linea),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icono, size: 40, color: c.azul),
            const SizedBox(height: 12),
            Text(
              texto,
              style: TextStyle(fontWeight: FontWeight.bold, color: c.tinta),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(dinero(precio), style: TextStyle(color: c.tinta2)),
          ],
        ),
      ),
    );
  }
}
