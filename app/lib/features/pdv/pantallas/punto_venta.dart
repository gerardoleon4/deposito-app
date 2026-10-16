import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/tema/colores.dart';
import '../../envases/datos/modelos_envases.dart';
import '../../envases/estado/envases_provider.dart';
import '../../envases/pantallas/modal_recepcion_envases.dart';
import '../../envases/pantallas/modal_registro_prestamo.dart';
import '../../envases/pantallas/modal_salida_envases.dart';
import '../datos/modelos_pdv.dart';
import 'escaner_continuo.dart';
import 'flujo_cobro.dart';

class PuntoVenta extends ConsumerStatefulWidget {
  const PuntoVenta({super.key});

  @override
  ConsumerState<PuntoVenta> createState() => _PuntoVentaState();
}

class _PuntoVentaState extends ConsumerState<PuntoVenta>
    with SingleTickerProviderStateMixin {
  String _filtroActivo = 'Todas';
  final List<String> _filtros = ['Todas', 'Cervezas', 'Botanas', 'Hielo'];
  String _busqueda = '';

  final List<ItemCarrito> _carrito = [];
  final List<CreditoEnvase> _creditosEnvases = [];
  double _cargoDepositosEnvases = 0.0;
  bool _envasesResueltos = false;
  String? _clientePrestamo;
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
  double get _totalCreditosEnvases =>
      _creditosEnvases.fold(0.0, (sum, c) => sum + c.creditoTotal);
  double get _total =>
      (_subtotal + _cargoDepositosEnvases - _totalCreditosEnvases).clamp(
        0.0,
        999999.0,
      );

  int get _cantidadRetornablesEnCarrito => _carrito
      .where((i) => i.producto.esRetornable)
      .fold(0, (sum, i) => sum + i.piezasTotales);

  List<Producto> get _productosFiltrados {
    return productosDemo.where((p) {
      final coincideFiltro =
          _filtroActivo == 'Todas' || p.categoria == _filtroActivo;
      final coincideBusqueda =
          _busqueda.isEmpty ||
          p.nombre.toLowerCase().contains(_busqueda.toLowerCase());
      return coincideFiltro && coincideBusqueda;
    }).toList();
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

  void _abrirRecepcionEnvases({StateSetter? setStateModal}) {
    ModalRecepcionEnvases.mostrar(
      context: context,
      cantidadInicial: _cantidadRetornablesEnCarrito > 0
          ? _cantidadRetornablesEnCarrito
          : 1,
      alConfirmar: (cant, form, credito) {
        setState(() {
          _creditosEnvases.add(
            CreditoEnvase(
              id: 'cr-${DateTime.now().millisecondsSinceEpoch}',
              cantidad: cant,
              formato: form.etiqueta,
              creditoTotal: credito,
            ),
          );
          _envasesResueltos = true;
        });
        setStateModal?.call(() {});
      },
    );
  }

  Future<void> _iniciarCobro({BuildContext? ctxModal}) async {
    if (_carrito.isEmpty) return;

    if (ctxModal != null) {
      Navigator.pop(ctxModal);
    }

    // 5.3: Si hay productos retornables y no se han resuelto envases previos
    if (_cantidadRetornablesEnCarrito > 0 &&
        !_envasesResueltos &&
        _totalCreditosEnvases == 0) {
      final res = await ModalSalidaEnvases.mostrar(
        context: context,
        cantidadRetornables: _cantidadRetornablesEnCarrito,
      );

      if (res == null) return;

      if (res.accion == AccionSalidaEnvases.cobrarDeposito) {
        setState(() {
          _cargoDepositosEnvases = res.montoDeposito;
          _envasesResueltos = true;
        });
      } else if (res.accion == AccionSalidaEnvases.clienteTrajoVacios) {
        if (!mounted) return;
        bool confirmado = false;
        await ModalRecepcionEnvases.mostrar(
          context: context,
          cantidadInicial: _cantidadRetornablesEnCarrito,
          alConfirmar: (cant, form, credito) {
            confirmado = true;
            setState(() {
              _creditosEnvases.add(
                CreditoEnvase(
                  id: 'cr-${DateTime.now().millisecondsSinceEpoch}',
                  cantidad: cant,
                  formato: form.etiqueta,
                  creditoTotal: credito,
                ),
              );
              _envasesResueltos = true;
            });
          },
        );
        if (!confirmado) return;
      } else if (res.accion == AccionSalidaEnvases.prestarEnvases) {
        if (!mounted) return;
        String? clienteRegistrado;
        final guardado = await ModalRegistroPrestamo.mostrar(
          context: context,
          cantidadEnvases: _cantidadRetornablesEnCarrito,
          alGuardar: (cliente, tel) {
            clienteRegistrado = cliente;
            ref
                .read(envasesProvider.notifier)
                .registrarPrestamo(
                  cliente: cliente,
                  cantidad: _cantidadRetornablesEnCarrito,
                  formato: TipoFormatoEnvase.media,
                  telefono: tel,
                );
          },
        );
        if (guardado != true) return;
        setState(() {
          _clientePrestamo = clienteRegistrado;
          _envasesResueltos = true;
        });
      }
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResumenCompra(
          carrito: _carrito,
          total: _total,
          creditosEnvases: _creditosEnvases,
          cargoDepositos: _cargoDepositosEnvases,
          clientePrestamo: _clientePrestamo,
        ),
      ),
    );
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

  void _abrirCarritoMovil() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final c = context.colores;
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: c.superficie,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: c.linea,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Carrito (${_carrito.fold(0, (sum, i) => sum + i.cantidad)} items)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: c.tinta,
                          ),
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => _abrirRecepcionEnvases(
                                setStateModal: setStateModal,
                              ),
                              icon: const Icon(
                                Icons.recycling_rounded,
                                size: 16,
                              ),
                              label: const Text('+ Vacíos'),
                              style: TextButton.styleFrom(
                                foregroundColor: c.verde,
                                backgroundColor: c.verdeSuave,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: (_carrito.isEmpty && _creditosEnvases.isEmpty)
                        ? _EmptyStateCarrito(c: c)
                        : ListView(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            children: [
                              for (int i = 0; i < _carrito.length; i++) ...[
                                Builder(
                                  builder: (context) {
                                    final item = _carrito[i];
                                    return Material(
                                      color: Colors.transparent,
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
                                        onTap: () {
                                          _mostrarEdicionCarrito(item);
                                          setStateModal(() {});
                                        },
                                      ),
                                    );
                                  },
                                ),
                                const Divider(height: 1),
                              ],
                              for (final cred in _creditosEnvases) ...[
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
                                          'Crédito por Envase (${cred.cantidad} ${cred.formato})',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: c.verde,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '-\$${cred.creditoTotal.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: c.verde,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: Icon(
                                          Icons.close_rounded,
                                          size: 16,
                                          color: c.verde,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _creditosEnvases.remove(cred);
                                          });
                                          setStateModal(() {});
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (_cargoDepositosEnvases > 0)
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
                                    color: c.alerta.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Depósito de Envases',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: c.tinta,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        '+\$${_cargoDepositosEnvases.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: c.alerta,
                                        ),
                                      ),
                                    ],
                                  ),
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
                          if (_totalCreditosEnvases > 0) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Crédito por Envases',
                                  style: TextStyle(
                                    color: c.verde,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '-\$${_totalCreditosEnvases.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: c.verde,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                          ],
                          if (_cargoDepositosEnvases > 0) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Cargo Depósitos',
                                  style: TextStyle(
                                    color: c.alerta,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '+\$${_cargoDepositosEnvases.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: c.alerta,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                  color: c.tinta,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${_total.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: c.azul,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  (_carrito.isEmpty && _creditosEnvases.isEmpty)
                                  ? null
                                  : () => _iniciarCobro(ctxModal: ctx),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: c.azul,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: c.linea,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Ir al Pago',
                                style: TextStyle(
                                  fontSize: 18,
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
              ),
            );
          },
        );
      },
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
                                onChanged: (val) =>
                                    setState(() => _busqueda = val),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: c.superficie,
                          border: Border(bottom: BorderSide(color: c.linea)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Venta Actual',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: c.tinta,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _abrirRecepcionEnvases,
                              icon: const Icon(
                                Icons.recycling_rounded,
                                size: 16,
                              ),
                              label: const Text('+ Recibir Vacíos'),
                              style: TextButton.styleFrom(
                                foregroundColor: c.verde,
                                backgroundColor: c.verdeSuave,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: (_carrito.isEmpty && _creditosEnvases.isEmpty)
                            ? _EmptyStateCarrito(c: c)
                            : ListView(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                children: [
                                  for (int i = 0; i < _carrito.length; i++) ...[
                                    Builder(
                                      builder: (context) {
                                        final item = _carrito[i];
                                        final isHighlighted =
                                            item.id == _itemRecienteId;

                                        return AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
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
                                            onTap: () =>
                                                _mostrarEdicionCarrito(item),
                                          ),
                                        );
                                      },
                                    ),
                                    const Divider(height: 1),
                                  ],
                                  for (final cred in _creditosEnvases) ...[
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
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Crédito por Envase (${cred.cantidad} ${cred.formato})',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: c.verde,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                Text(
                                                  'Descontado del subtotal',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: c.verde.withValues(
                                                      alpha: 0.8,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '-\$${cred.creditoTotal.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: c.verde,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          IconButton(
                                            icon: Icon(
                                              Icons.close_rounded,
                                              size: 16,
                                              color: c.verde,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _creditosEnvases.remove(cred);
                                              });
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (_cargoDepositosEnvases > 0)
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
                                        color: c.alerta.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Depósito de Envases',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: c.tinta,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            '+\$${_cargoDepositosEnvases.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: c.alerta,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (_clientePrestamo != null)
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
                                        color: c.azul.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.handshake_outlined,
                                            color: c.azul,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Préstamo a: $_clientePrestamo',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: c.azul,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
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
                            if (_totalCreditosEnvases > 0) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Crédito Envases',
                                    style: TextStyle(
                                      color: c.verde,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '-\$${_totalCreditosEnvases.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: c.verde,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (_cargoDepositosEnvases > 0) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Depósito Envases',
                                    style: TextStyle(
                                      color: c.alerta,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '+\$${_cargoDepositosEnvases.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: c.alerta,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 12),
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
                                onPressed:
                                    (_carrito.isEmpty &&
                                        _creditosEnvases.isEmpty)
                                    ? null
                                    : () => _iniciarCobro(),
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
                onPressed: _abrirCarritoMovil,
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

  Widget _iconoFallback(ColoresAnaquel c) {
    return Center(
      child: Icon(
        producto.categoria == 'Cervezas'
            ? Icons.sports_bar_rounded
            : producto.categoria == 'Botanas'
            ? Icons.fastfood_rounded
            : Icons.ac_unit_rounded,
        size: 48,
        color: c.azul.withValues(alpha: 0.4),
      ),
    );
  }

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
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                clipBehavior: Clip.antiAlias,
                child: producto.urlImagen != null
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: producto.urlImagen!.startsWith('http')
                            ? Image.network(
                                producto.urlImagen!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => _iconoFallback(c),
                              )
                            : Image.asset(
                                producto.urlImagen!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => _iconoFallback(c),
                              ),
                      )
                    : _iconoFallback(c),
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
