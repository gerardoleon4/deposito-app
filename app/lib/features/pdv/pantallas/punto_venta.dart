import 'package:flutter/material.dart';
import '../../../../app/tema/colores.dart';
import '../datos/modelos_pdv.dart';
import 'escaner_continuo.dart';
import 'flujo_cobro.dart';

class PuntoVenta extends StatefulWidget {
  const PuntoVenta({super.key});

  @override
  State<PuntoVenta> createState() => _PuntoVentaState();
}

class _PuntoVentaState extends State<PuntoVenta>
    with SingleTickerProviderStateMixin {
  String _filtroActivo = 'Todas';
  final List<String> _filtros = ['Todas', 'Cervezas', 'Botanas', 'Hielo'];

  final List<ItemCarrito> _carrito = [];
  String? _itemRecienteId;

  late AnimationController _bounceCtrl;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  double get _subtotal => _carrito.fold(0, (sum, item) => sum + item.subtotal);
  double get _total => _subtotal;

  List<Producto> get _productosFiltrados {
    if (_filtroActivo == 'Todas') return productosDemo;
    return productosDemo.where((p) => p.categoria == _filtroActivo).toList();
  }

  void _mostrarAlertaInventario(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _agregarAlCarrito(Producto prod, {bool esCaja = false}) {
    if (prod.stock <= 0) {
      _mostrarAlertaInventario('Sin stock disponible de ${prod.nombre}');
      return;
    }

    final idItem = '${prod.id}_${esCaja ? 'caja' : 'pieza'}';
    final index = _carrito.indexWhere((i) => i.id == idItem);

    setState(() {
      if (index >= 0) {
        if (_carrito[index].cantidad >= prod.stock) {
          _mostrarAlertaInventario(
            'Solo quedan ${prod.stock} en stock, no puedes agregar más.',
          );
          return;
        }
        _carrito[index].cantidad++;
      } else {
        _carrito.add(ItemCarrito(id: idItem, producto: prod, esCaja: esCaja));
      }

      // Feedback visual carrito
      _itemRecienteId = idItem;
    });

    _bounceCtrl.forward(from: 0.0);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && _itemRecienteId == idItem) {
        setState(() => _itemRecienteId = null);
      }
    });
  }

  void _alTocarProducto(Producto prod) {
    if (prod.tieneVariantes) {
      _mostrarModalVariante(prod);
    } else {
      _agregarAlCarrito(prod);
    }
  }

  void _mostrarModalVariante(Producto prod) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
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
                        texto: 'Vender 1 Pieza',
                        precio: prod.precio,
                        alPresionar: () {
                          Navigator.pop(context);
                          _agregarAlCarrito(prod, esCaja: false);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _BotonVariante(
                        icono: Icons.inventory_2_outlined,
                        texto: 'Vender 1 Caja/Cartón',
                        precio: prod.precio * 24,
                        alPresionar: () {
                          Navigator.pop(context);
                          _agregarAlCarrito(prod, esCaja: true);
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
      builder: (ctxBottomSheet) {
        final c = context.colores;
        return StatefulBuilder(
          builder: (context, setStateModal) {
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
                      '${item.producto.nombre} ${item.esCaja ? '(Caja)' : ''}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: c.tinta,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Controles de cantidad
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (item.cantidad > 1) {
                              setState(() => item.cantidad--);
                              setStateModal(() {});
                            } else {
                              setState(() => _carrito.remove(item));
                              Navigator.pop(ctxBottomSheet);
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                          iconSize: 48,
                          color: c.tinta2,
                        ),
                        const SizedBox(width: 24),
                        Text(
                          item.cantidad.toString(),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: c.tinta,
                          ),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          onPressed: () {
                            if (item.cantidad < item.producto.stock) {
                              setState(() => item.cantidad++);
                              setStateModal(() {});
                            } else {
                              Navigator.pop(ctxBottomSheet);
                              _mostrarAlertaInventario(
                                'Límite de stock alcanzado',
                              );
                            }
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          iconSize: 48,
                          color: c.azul,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Aplicar descuento (%)',
                        filled: true,
                        fillColor: c.fondo,
                        prefixIcon: const Icon(Icons.discount_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _carrito.remove(item));
                          Navigator.pop(ctxBottomSheet);
                        },
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
        );
      },
    );
  }

  void _abrirEscaner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EscanerContinuo(
          alEscanear: (prodId) {
            final prod = productosDemo.firstWhere(
              (p) => p.id == prodId,
              orElse: () => productosDemo.first,
            );
            _agregarAlCarrito(prod);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final ancho = MediaQuery.of(context).size.width;
    final esIpad = ancho > 600;

    return Scaffold(
      backgroundColor: c.fondo,
      body: SafeArea(
        child: Row(
          children: [
            // Área Izquierda: Catálogo (60% en iPad, 100% en Móvil)
            Expanded(
              flex: esIpad ? 6 : 10,
              child: Column(
                children: [
                  // Buscador y Filtros
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Buscar productos...',
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
                              onPressed: _abrirEscaner,
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
                            children: _filtros.map((f) {
                              final activo = _filtroActivo == f;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(f),
                                  selected: activo,
                                  onSelected: (val) {
                                    if (val) setState(() => _filtroActivo = f);
                                  },
                                  selectedColor: c.azul,
                                  labelStyle: TextStyle(
                                    color: activo ? Colors.white : c.tinta,
                                    fontWeight: activo
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  backgroundColor: c.superficie,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: activo
                                          ? Colors.transparent
                                          : c.linea,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Grid de Productos
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: esIpad ? 3 : 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _productosFiltrados.length,
                      itemBuilder: (context, i) {
                        final prod = _productosFiltrados[i];
                        return _TarjetaProducto(
                          producto: prod,
                          alTocar: () => _alTocarProducto(prod),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Área Derecha: Carrito (40% en iPad, Oculto en Móvil -> Bottom Sheet o FAB)
            if (esIpad)
              Expanded(
                flex: 4,
                child: Container(
                  color: c.fondo.withValues(
                    alpha: 0.95,
                  ), // Fondo sutilmente diferente (o c.superficie2)
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
                          'Venta Actual',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: c.tinta,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _carrito.isEmpty
                            ? _EmptyStateCarrito(c: c)
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                itemCount: _carrito.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, i) {
                                  final item = _carrito[i];
                                  final isHighlighted =
                                      item.id == _itemRecienteId;

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    color: isHighlighted
                                        ? c.azul.withValues(alpha: 0.1)
                                        : Colors.transparent,
                                    child: ListTile(
                                      title: Text(
                                        '${item.producto.nombre} ${item.esCaja ? '(Caja)' : ''}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: c.tinta,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '\$${item.producto.precio.toStringAsFixed(2)} x ${item.cantidad}',
                                        style: TextStyle(color: c.tinta2),
                                      ),
                                      trailing: Text(
                                        '\$${item.subtotal.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: c.tinta,
                                        ),
                                      ),
                                      onTap: () => _mostrarEdicionCarrito(item),
                                    ),
                                  );
                                },
                              ),
                      ),

                      // Footer del carrito
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: c.superficie,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Subtotal',
                                  style: TextStyle(
                                    color: c.tinta2,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '\$${_subtotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: c.tinta,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
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
                                  '\$${_total.toStringAsFixed(2)}',
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
                                onPressed: _carrito.isEmpty
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ResumenCompra(
                                              carrito: _carrito,
                                              total: _total,
                                            ),
                                          ),
                                        );
                                      },
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

      // En móvil, mostramos un FAB gigante animado y un Bottom Navigation
      bottomNavigationBar: !esIpad
          ? BottomNavigationBar(
              selectedItemColor: c.azul,
              unselectedItemColor: c.tinta2,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.point_of_sale_rounded),
                  label: 'Venta',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_outlined),
                  label: 'Inventario',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  label: 'Ajustes',
                ),
              ],
            )
          : null,

      floatingActionButton: (!esIpad && _carrito.isNotEmpty)
          ? ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut),
              ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  // En móvil, abriría un Modal con el carrito
                },
                backgroundColor: c.azul,
                icon: const Icon(
                  Icons.shopping_cart_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  '\$${_total.toStringAsFixed(2)}',
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

class _EmptyStateCarrito extends StatelessWidget {
  const _EmptyStateCarrito({required this.c});
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
  const _TarjetaProducto({required this.producto, required this.alTocar});
  final Producto producto;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return GestureDetector(
      onTap: alTocar,
      child: Container(
        decoration: BoxDecoration(
          color: c.superficie,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.linea),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: c.fondo,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    producto.categoria == 'Cervezas'
                        ? Icons.sports_bar_rounded
                        : producto.categoria == 'Botanas'
                        ? Icons.fastfood_rounded
                        : Icons.ac_unit_rounded,
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
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${producto.precio.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: c.azul,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (producto.tieneVariantes)
                        Icon(Icons.layers_outlined, size: 16, color: c.tinta2),
                    ],
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

class _BotonVariante extends StatelessWidget {
  const _BotonVariante({
    required this.icono,
    required this.texto,
    required this.precio,
    required this.alPresionar,
  });

  final IconData icono;
  final String texto;
  final double precio;
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
            Text(
              '\$${precio.toStringAsFixed(2)}',
              style: TextStyle(color: c.tinta2),
            ),
          ],
        ),
      ),
    );
  }
}
