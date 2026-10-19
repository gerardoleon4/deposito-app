import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../core/formato/formato.dart';
import '../../../core/widgets/estados.dart';
import '../../../core/widgets/ilustracion_producto.dart';
import '../../catalogo/estado/productos.dart';
import '../../terminal/pantallas/escaner.dart';
import '../../envases/datos/modelos_envases.dart';
import '../../envases/pantallas/modal_recepcion_envases.dart';
import '../../envases/pantallas/modal_registro_prestamo.dart';
import '../../envases/pantallas/modal_salida_envases.dart';
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (contextoHoja) => _EdicionRenglon(
        clave: item.clave,
        alAvisar: (motivo) {
          Navigator.pop(contextoHoja);
          _mostrarAlertaInventario(motivo);
        },
      ),
    );
  }

  /// "+ Recibir Vacíos": vacíos extra que entrega el cliente; su depósito se
  /// descuenta del ticket.
  Future<void> _abrirRecepcionEnvases() async {
    final carrito = ref.read(carritoProvider);
    final r = await ModalRecepcionEnvases.mostrar(
      context,
      modo: ModoVacios.credito,
      formatoInicial: carrito.retornables.isEmpty
          ? FormatoEnvase.media
          : FormatoEnvase.de(carrito.retornables.keys.first),
    );
    if (r == null || !mounted) return;
    ref
        .read(carritoProvider.notifier)
        .agregarCredito(r.formato.clave, r.cantidad);
  }

  /// 5.3: antes de cobrar, si hay retornables, se decide qué pasa con sus
  /// envases (cobrar depósito, intercambio o préstamo).
  Future<void> _iniciarCobro({BuildContext? contextoHoja}) async {
    if (contextoHoja != null) Navigator.pop(contextoHoja);
    final carrito = ref.read(carritoProvider);
    if (carrito.vacio) return;
    if (carrito.envasesPendientes) {
      final precios = ref.read(preciosEnvasesProvider);
      final accion = await ModalSalidaEnvases.mostrar(
        context: context,
        cantidadRetornables: carrito.totalRetornables,
        formatos: [
          for (final f in carrito.retornables.keys)
            FormatoEnvase.de(f).etiqueta,
        ].join(', '),
        montoDeposito: carrito.retornables.entries.fold(
          0,
          (t, e) => t + e.value * (precios[e.key] ?? 0),
        ),
      );
      if (accion == null || !mounted) return;
      final notificador = ref.read(carritoProvider.notifier);
      switch (accion) {
        case AccionSalidaEnvases.cobrarDeposito:
          notificador.resolverEnvases(ModoEnvases.cobrar);
        case AccionSalidaEnvases.clienteTrajoVacios:
          notificador.resolverEnvases(ModoEnvases.trae);
        case AccionSalidaEnvases.prestarEnvases:
          final retornables = carrito.retornables;
          final prestamo = await ModalRegistroPrestamo.mostrar(
            context,
            cantidadEnvases: carrito.totalRetornables,
            formato: retornables.length == 1
                ? FormatoEnvase.de(retornables.keys.single)
                : null,
          );
          if (prestamo == null || !mounted) return;
          notificador.resolverEnvases(
            ModoEnvases.prestamo,
            cliente: prestamo.cliente,
          );
      }
    }
    if (!mounted) return;
    await Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute(builder: (_) => const ResumenCompra()));
  }

  /// En el teléfono: el carrito en una hoja, con "+ Vacíos" e "Ir al Pago".
  void _abrirCarritoMovil() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (contextoHoja) => Container(
        height: MediaQuery.of(contextoHoja).size.height * 0.75,
        decoration: BoxDecoration(
          color: contextoHoja.colores.superficie,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
        child: _PanelVenta(
          movil: true,
          itemReciente: _itemRecienteClave,
          alEditar: _mostrarEdicionCarrito,
          alRecibirVacios: _abrirRecepcionEnvases,
          alCobrar: () => _iniciarCobro(contextoHoja: contextoHoja),
          alCerrar: () => Navigator.pop(contextoHoja),
        ),
      ),
    );
  }

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
    final total = carrito.total(ref.watch(preciosEnvasesProvider));
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
              Container(
                width: 380,
                decoration: BoxDecoration(
                  color: c.superficie2,
                  border: Border(left: BorderSide(color: c.linea)),
                ),
                child: _PanelVenta(
                  itemReciente: _itemRecienteClave,
                  alEditar: _mostrarEdicionCarrito,
                  alRecibirVacios: _abrirRecepcionEnvases,
                  alCobrar: _iniciarCobro,
                ),
              ),
          ],
        ),
      ),

      // En pantallas angostas, el total en un botón que abre el carrito.
      floatingActionButton: (!esAncho && !carrito.vacio)
          ? ScaleTransition(
              scale: Tween<double>(begin: 1, end: 1.1).animate(
                CurvedAnimation(parent: _rebote, curve: Curves.elasticOut),
              ),
              child: FloatingActionButton.extended(
                onPressed: _abrirCarritoMovil,
                backgroundColor: c.azul,
                icon: const Icon(
                  Icons.shopping_cart_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  'Cobrar ${dinero(total)}',
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

/// La venta en curso (diseño de Pablo): renglones, crédito por vacíos,
/// depósito de envases y total. A la derecha en el iPad; en una hoja en el
/// teléfono.
class _PanelVenta extends ConsumerWidget {
  const _PanelVenta({
    required this.itemReciente,
    required this.alEditar,
    required this.alRecibirVacios,
    required this.alCobrar,
    this.movil = false,
    this.alCerrar,
  });

  final String? itemReciente;
  final void Function(ItemCarrito) alEditar;
  final VoidCallback alRecibirVacios;
  final VoidCallback alCobrar;
  final bool movil;
  final VoidCallback? alCerrar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colores;
    final carrito = ref.watch(carritoProvider);
    final precios = ref.watch(preciosEnvasesProvider);
    final deposito = carrito.deposito(precios);
    final credito = carrito.montoCredito(precios);
    final total = carrito.total(precios);
    final vacio = carrito.vacio && carrito.credito.isEmpty;

    Widget renglonTotal(String texto, String monto, Color color) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            monto,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    final botonVacios = TextButton.icon(
      onPressed: alRecibirVacios,
      icon: const Icon(Icons.recycling_rounded, size: 16),
      label: Text(movil ? '+ Vacíos' : '+ Recibir Vacíos'),
      style: TextButton.styleFrom(
        foregroundColor: c.verde,
        backgroundColor: c.verdeSuave,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    return Column(
      children: [
        if (movil) ...[
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: c.linea,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: movil ? 14 : 16,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: c.superficie,
            border: Border(bottom: BorderSide(color: c.linea)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  movil
                      ? 'Carrito (${carrito.articulos} items)'
                      : 'Venta Actual',
                  style: TextStyle(
                    fontSize: movil ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: c.tinta,
                  ),
                ),
              ),
              botonVacios,
              if (alCerrar != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Cerrar',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: alCerrar,
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: vacio
              ? _CarritoVacio(c: c)
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    for (final item in carrito.items) ...[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        color: item.clave == itemReciente
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
                              '${dinero(item.precioUnitario)} x ${item.cantidad}'
                              '${item.descuento > 0 ? ' (−${item.descuento}%)' : ''}',
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
                            onTap: () => alEditar(item),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                    for (final e in carrito.credito.entries)
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: c.verdeSuave,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: c.verde.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.recycling_rounded,
                              color: c.verde,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Crédito por Envase (${e.value} '
                                '${FormatoEnvase.de(e.key).etiqueta})',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: c.verde,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              '-${dinero(e.value * (precios[e.key] ?? 0))}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: c.verde,
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              tooltip: 'Quitar crédito',
                              icon: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: c.verde,
                              ),
                              onPressed: () => ref
                                  .read(carritoProvider.notifier)
                                  .quitarCredito(e.key),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    if (carrito.envModo != ModoEnvases.na)
                      _AvisoEnvases(
                        modo: carrito.envModo,
                        cliente: carrito.envCliente,
                        deposito: deposito,
                        alCambiar: () => ref
                            .read(carritoProvider.notifier)
                            .resolverEnvases(ModoEnvases.na),
                      ),
                  ],
                ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: c.superficie,
            border: Border(top: BorderSide(color: c.linea)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (credito > 0)
                  renglonTotal(
                    'Crédito por Envases',
                    '-${dinero(credito)}',
                    c.verde,
                  ),
                if (deposito > 0)
                  renglonTotal(
                    'Depósito de Envases',
                    '+${dinero(deposito)}',
                    c.alerta,
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        color: c.tinta,
                        fontSize: movil ? 20 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      dinero(total),
                      style: TextStyle(
                        color: total < 0 ? c.alerta : c.azul,
                        fontSize: movil ? 28 : 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                if (total < 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'El crédito pasa del total: quita vacíos o usa '
                      '"Devolver depósito" en Envases',
                      style: TextStyle(fontSize: 12, color: c.alerta),
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: carrito.vacio || total < 0 ? null : alCobrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.azul,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: c.linea,
                      padding: EdgeInsets.symmetric(vertical: movil ? 18 : 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      movil ? 'Ir al Pago' : 'Cobrar',
                      style: TextStyle(
                        fontSize: movil ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

/// Qué se decidió con los envases de la venta, con opción de cambiarlo.
class _AvisoEnvases extends StatelessWidget {
  const _AvisoEnvases({
    required this.modo,
    required this.cliente,
    required this.deposito,
    required this.alCambiar,
  });

  final ModoEnvases modo;
  final String? cliente;
  final int deposito;
  final VoidCallback alCambiar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final (texto, color) = switch (modo) {
      ModoEnvases.cobrar => (
        'Depósito de Envases (+${dinero(deposito)})',
        c.alerta,
      ),
      ModoEnvases.trae => ('Envases: el cliente entrega vacíos', c.verde),
      ModoEnvases.prestamo => (
        'Envases prestados a ${cliente ?? 'cliente'}',
        const Color(0xFFD97706),
      ),
      ModoEnvases.na => ('', c.tinta),
    };
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: c.tinta,
                fontSize: 13,
              ),
            ),
          ),
          TextButton(onPressed: alCambiar, child: const Text('Cambiar')),
        ],
      ),
    );
  }
}

/// Edición de un renglón (diseño de Pablo): cantidad, descuento y quitar.
class _EdicionRenglon extends ConsumerStatefulWidget {
  const _EdicionRenglon({required this.clave, required this.alAvisar});

  final String clave;
  final ValueChanged<String> alAvisar;

  @override
  ConsumerState<_EdicionRenglon> createState() => _EdicionRenglonState();
}

class _EdicionRenglonState extends ConsumerState<_EdicionRenglon> {
  late final _descuento = TextEditingController(
    text: () {
      final d = _actual?.descuento ?? 0;
      return d == 0 ? '' : '$d';
    }(),
  );

  ItemCarrito? get _actual => ref
      .read(carritoProvider)
      .items
      .where((i) => i.clave == widget.clave)
      .firstOrNull;

  @override
  void dispose() {
    _descuento.dispose();
    super.dispose();
  }

  void _cambiar(ItemCarrito actual, int n) {
    final motivo = ref
        .read(carritoProvider.notifier)
        .cambiarCantidad(actual, n);
    if (motivo != null) {
      widget.alAvisar(motivo);
    } else if (n == 0) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final actual = ref
        .watch(carritoProvider)
        .items
        .where((i) => i.clave == widget.clave)
        .firstOrNull;
    if (actual == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
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
                  onPressed: () => _cambiar(actual, actual.cantidad - 1),
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
                  onPressed: () => _cambiar(actual, actual.cantidad + 1),
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 48,
                  color: c.azul,
                ),
              ],
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _descuento,
              keyboardType: TextInputType.number,
              maxLength: 2,
              onChanged: (t) => ref
                  .read(carritoProvider.notifier)
                  .ponerDescuento(actual, int.tryParse(t) ?? 0),
              decoration: InputDecoration(
                labelText: 'Aplicar descuento (%)',
                counterText: '',
                helperText: actual.descuento > 0
                    ? '${dinero(actual.precioLista)} → '
                          '${dinero(actual.precioUnitario)} c/u'
                    : 'De 0 a 99 %',
                filled: true,
                fillColor: c.fondo,
                prefixIcon: const Icon(Icons.discount_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _cambiar(actual, 0),
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: IlustracionProducto(producto: producto, radio: 0),
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
