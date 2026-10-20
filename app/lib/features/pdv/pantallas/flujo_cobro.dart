import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../personal/estado/personal_provider.dart';
import '../../../app/tema/colores.dart';
import '../../../core/api/fallo_api.dart';
import '../../../core/api/proveedores.dart';
import '../../../core/formato/formato.dart';
import '../../../core/ticket/ticket_pdf.dart';
import '../../../core/widgets/estados.dart';
import '../../../core/widgets/teclado_numerico.dart';
import '../../catalogo/estado/productos.dart';
import '../../envases/datos/modelos_envases.dart';
import '../../envases/estado/envases_provider.dart';
import '../../envases/pantallas/modal_recepcion_envases.dart';
import '../estado/carrito.dart';

/// Registra el carrito actual en el servidor y abre la pantalla de éxito.
///
/// Usa la clave de cobro del carrito: si la red falla y la persona reintenta,
/// el servidor regresa la misma venta en lugar de cobrar dos veces.
Future<void> _registrarVenta(
  BuildContext context,
  WidgetRef ref, {
  required String metodo,
  int? recibido,
}) async {
  final carrito = ref.read(carritoProvider);
  final navegador = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: Center(child: CircularProgressIndicator()),
    ),
  );
  try {
    final api = await ref.read(apiProvider.future);
    final venta = await api.registrarVenta(
      lineas: carrito.lineas,
      metodo: metodo,
      recibido: recibido,
      envModo: carrito.envModo.name,
      envCliente: carrito.envCliente,
      envCredito: carrito.credito,
      usuarioId: ref.read(usuarioActualProvider)?.id,
      claveIdempotencia: carrito.claveCobro,
    );
    ref.read(carritoProvider.notifier).vaciar();
    ref.read(productosProvider.notifier).refrescar();
    if (carrito.envModo != ModoEnvases.na || carrito.credito.isNotEmpty) {
      ref.read(envasesProvider.notifier).refrescar();
    }
    navegador.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => VentaExitosa(venta: venta)),
      (ruta) => ruta.isFirst,
    );
  } catch (e) {
    navegador.pop();
    if (!context.mounted) return;
    final sinConexion = e is FalloApi && e.sinConexion;
    final reintentar = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('No se registró el cobro'),
        content: Text(
          sinConexion
              ? '${mensajeDeError(e)}\n\nSi reintentas no se cobra dos veces.'
              : mensajeDeError(e),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: const Text('Cerrar'),
          ),
          if (sinConexion)
            FilledButton(
              onPressed: () => Navigator.pop(contexto, true),
              child: const Text('Reintentar'),
            ),
        ],
      ),
    );
    if (reintentar == true && context.mounted) {
      await _registrarVenta(context, ref, metodo: metodo, recibido: recibido);
    }
  }
}

const _verdeExito = Color(0xFF10B981);
const _rojoRechazo = Color(0xFFEF4444);

String _nombreItem(ItemCarrito i) =>
    '${i.producto.nombre}${i.porCaja ? ' (Caja)' : ''}'
    '${i.descuento > 0 ? ' −${i.descuento}%' : ''}';

// ============================================================================
// 4.1 RESUMEN FINAL DE COMPRA
// ============================================================================
class ResumenCompra extends ConsumerWidget {
  const ResumenCompra({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colores;
    final ancho = MediaQuery.sizeOf(context).width;
    final carrito = ref.watch(carritoProvider);
    final precios = ref.watch(preciosEnvasesProvider);
    final deposito = carrito.deposito(precios);
    final divisor = Divider(height: 24, color: c.linea.withValues(alpha: 0.5));

    Widget renglonEnvase(
      IconData icono,
      String texto,
      String monto,
      Color co,
    ) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icono, color: co, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: co,
              ),
            ),
          ),
          Text(
            monto,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: co,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        backgroundColor: c.superficie,
        elevation: 0,
        title: Text(
          'Resumen de Compra',
          style: TextStyle(
            color: c.tinta,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: BackButton(color: c.tinta),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: c.linea, height: 1),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ancho > 700 ? 600 : double.infinity,
            ),
            child: Column(
              children: [
                Expanded(
                  child: carrito.vacio
                      ? Center(
                          child: Text(
                            'No hay artículos en la venta',
                            style: TextStyle(color: c.tinta2, fontSize: 16),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          children: [
                            for (final item in carrito.items) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: c.azul.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${item.cantidad}x',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: c.azul,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _nombreItem(item),
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: c.tinta,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      dinero(item.subtotal),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: c.tinta,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              divisor,
                            ],
                            if (deposito > 0) ...[
                              renglonEnvase(
                                Icons.inventory_2_outlined,
                                'Cargo por Depósito de Envases',
                                '+${dinero(deposito)}',
                                c.azul,
                              ),
                              divisor,
                            ],
                            if (carrito.envModo == ModoEnvases.trae) ...[
                              renglonEnvase(
                                Icons.swap_horiz_rounded,
                                'Intercambio: el cliente entrega vacíos',
                                'Sin costo',
                                c.verde,
                              ),
                              divisor,
                            ],
                            for (final e in carrito.credito.entries) ...[
                              renglonEnvase(
                                Icons.recycling_rounded,
                                'Crédito por Envases (${e.value} pzs '
                                    '${FormatoEnvase.de(e.key).etiqueta})',
                                '-${dinero(e.value * (precios[e.key] ?? 0))}',
                                c.verde,
                              ),
                              divisor,
                            ],
                            if (carrito.envModo == ModoEnvases.prestamo)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFF59E0B),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.handshake_outlined,
                                      color: Color(0xFFD97706),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Envases asociados como préstamo a: '
                                        '${carrito.envCliente ?? 'cliente'}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFB45309),
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

                // Bloque del total, fijo abajo.
                Container(
                  decoration: BoxDecoration(
                    color: c.superficie,
                    border: Border(top: BorderSide(color: c.linea, width: 3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total a Pagar',
                        style: TextStyle(
                          fontSize: 18,
                          color: c.tinta2,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        child: Text(
                          dinero(ref.watch(totalCarritoProvider)),
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            color: c.azul,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: carrito.vacio
                              ? null
                              : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MetodoPago(),
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: c.azul,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: c.linea,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Confirmar y Pagar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
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
      ),
    );
  }
}

// ============================================================================
// 4.2 SELECCIÓN DE MÉTODO DE PAGO
// ============================================================================
class MetodoPago extends ConsumerWidget {
  const MetodoPago({super.key});

  void _irA(BuildContext context, Widget pantalla) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));

  /// "Saldo por Envases": el cliente entrega vacíos extra, su depósito se
  /// descuenta del ticket y el resto se paga en efectivo.
  Future<void> _saldoEnvases(BuildContext context, WidgetRef ref) async {
    final carrito = ref.read(carritoProvider);
    final r = await ModalRecepcionEnvases.mostrar(
      context,
      modo: ModoVacios.credito,
      cantidadInicial: carrito.totalRetornables > 0
          ? carrito.totalRetornables
          : 1,
      formatoInicial: carrito.retornables.isEmpty
          ? FormatoEnvase.media
          : FormatoEnvase.de(carrito.retornables.keys.first),
    );
    if (r == null || !context.mounted) return;
    final precios = ref.read(preciosEnvasesProvider);
    final saldo = r.cantidad * (precios[r.formato.clave] ?? 0);
    final total = carrito.total(precios);
    if (saldo > total) {
      avisar(
        context,
        'El saldo (${dinero(saldo)}) pasa del total (${dinero(total)}): '
        'usa "Devolver depósito" en Envases',
      );
      return;
    }
    ref
        .read(carritoProvider.notifier)
        .agregarCredito(r.formato.clave, r.cantidad);
    _irA(context, const CobroEfectivo());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colores;
    final total = ref.watch(totalCarritoProvider);
    final esTablet = MediaQuery.sizeOf(context).width >= 700;

    final opciones = [
      (
        Icons.payments_outlined,
        'Efectivo',
        'Cobro con billetes y monedas físicas',
        () => _irA(context, const CobroEfectivo()),
      ),
      (
        Icons.point_of_sale_rounded,
        'Tarjeta',
        'Terminal bancaria física (Débito / Crédito)',
        () => _irA(context, const CobroTarjeta()),
      ),
      (
        Icons.liquor_outlined,
        'Saldo por Envases',
        'Descuento por botellas retornables recibidas',
        () => _saldoEnvases(context, ref),
      ),
    ];

    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: c.tinta),
        title: Text(
          'Total a Cobrar: ${dinero(total)}',
          style: TextStyle(
            color: c.tinta,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Selecciona el Método de Pago',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: c.tinta,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toca una opción para continuar la transacción',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: c.tinta2),
                  ),
                  const SizedBox(height: 48),
                  if (esTablet)
                    Row(
                      children: [
                        for (final (i, o) in opciones.indexed) ...[
                          if (i > 0) const SizedBox(width: 24),
                          Expanded(
                            child: _BotonMetodo(
                              icono: o.$1,
                              texto: o.$2,
                              c: c,
                              alTocar: o.$4,
                            ),
                          ),
                        ],
                      ],
                    )
                  else
                    Column(
                      children: [
                        for (final (i, o) in opciones.indexed) ...[
                          if (i > 0) const SizedBox(height: 16),
                          _BotonMetodoMovil(
                            icono: o.$1,
                            texto: o.$2,
                            descripcion: o.$3,
                            c: c,
                            alTocar: o.$4,
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón cuadrado para iPad, con efecto de hundimiento (0.95).
class _BotonMetodo extends StatefulWidget {
  const _BotonMetodo({
    required this.icono,
    required this.texto,
    required this.c,
    required this.alTocar,
  });

  final IconData icono;
  final String texto;
  final ColoresAnaquel c;
  final VoidCallback alTocar;

  @override
  State<_BotonMetodo> createState() => _BotonMetodoState();
}

class _BotonMetodoState extends State<_BotonMetodo> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _presionado = true),
      onTapUp: (_) {
        setState(() => _presionado = false);
        HapticFeedback.lightImpact();
        widget.alTocar();
      },
      onTapCancel: () => setState(() => _presionado = false),
      child: AnimatedScale(
        scale: _presionado ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutCubic,
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: widget.c.superficie,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _presionado ? widget.c.azul : widget.c.linea,
                width: _presionado ? 2 : 1,
              ),
              boxShadow: _presionado
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icono, size: 72, color: widget.c.azul),
                const SizedBox(height: 20),
                Text(
                  widget.texto,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.c.tinta,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón ancho para el teléfono, con efecto de hundimiento (0.95).
class _BotonMetodoMovil extends StatefulWidget {
  const _BotonMetodoMovil({
    required this.icono,
    required this.texto,
    required this.descripcion,
    required this.c,
    required this.alTocar,
  });

  final IconData icono;
  final String texto;
  final String descripcion;
  final ColoresAnaquel c;
  final VoidCallback alTocar;

  @override
  State<_BotonMetodoMovil> createState() => _BotonMetodoMovilState();
}

class _BotonMetodoMovilState extends State<_BotonMetodoMovil> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _presionado = true),
      onTapUp: (_) {
        setState(() => _presionado = false);
        HapticFeedback.lightImpact();
        widget.alTocar();
      },
      onTapCancel: () => setState(() => _presionado = false),
      child: AnimatedScale(
        scale: _presionado ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 90),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: widget.c.superficie,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _presionado ? widget.c.azul : widget.c.linea,
              width: _presionado ? 2 : 1,
            ),
            boxShadow: _presionado
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: widget.c.azul.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(widget.icono, size: 34, color: widget.c.azul),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.texto,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.c.tinta,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.descripcion,
                      style: TextStyle(fontSize: 13, color: widget.c.tinta2),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: widget.c.tinta2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 4.3 COBRO EN EFECTIVO
// ============================================================================
class CobroEfectivo extends ConsumerStatefulWidget {
  const CobroEfectivo({super.key});

  @override
  ConsumerState<CobroEfectivo> createState() => _CobroEfectivoState();
}

class _CobroEfectivoState extends ConsumerState<CobroEfectivo> {
  /// Centavos que entregó el cliente. Con el teclado se escriben pesos
  /// enteros; "Monto Exacto" puede traer centavos.
  int _recibido = 0;

  void _teclear(String tecla) {
    final pesos = _recibido ~/ 100;
    if (pesos >= 1000000) return;
    setState(() => _recibido = (pesos * 10 + int.parse(tecla)) * 100);
  }

  void _borrar() => setState(() => _recibido = (_recibido ~/ 100) ~/ 10 * 100);

  void _ponerMonto(int monto) => setState(() => _recibido = monto);

  Future<void> _cobrar(int total) async {
    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          ModalCambio(recibido: _recibido, cambio: _recibido - total),
    );
    if (confirmar == true && mounted) {
      await _registrarVenta(
        context,
        ref,
        metodo: 'efectivo',
        recibido: _recibido,
      );
    }
  }

  /// Billetes inteligentes: exacto, siguiente múltiplo de $50 y de $100 y
  /// billetes comunes por encima del total. Centavos.
  static List<int> _billetesSugeridos(int total) {
    final res = <int>[total];
    void agregar(int monto) {
      if (monto > total && !res.contains(monto)) res.add(monto);
    }

    agregar((total + 4999) ~/ 5000 * 5000);
    agregar((total + 9999) ~/ 10000 * 10000);
    for (final b in [20000, 50000, 100000]) {
      agregar(b);
    }
    return res.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final total = ref.watch(totalCarritoProvider);
    final puedeCobrar = _recibido >= total && !ref.watch(carritoProvider).vacio;
    final esTablet = MediaQuery.sizeOf(context).width >= 700;
    final rapidos = _billetesSugeridos(total);

    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        backgroundColor: c.superficie,
        elevation: 0,
        leading: BackButton(color: c.tinta),
        title: Text(
          'Cobro en Efectivo',
          style: TextStyle(
            color: c.tinta,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: c.linea, height: 1),
        ),
      ),
      body: SafeArea(
        child: esTablet
            // Dos columnas en el iPad: teclado a la izquierda, billetes y
            // cobrar a la derecha.
            ? Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: LayoutBuilder(
                      builder: (context, medidas) => SingleChildScrollView(
                        padding: const EdgeInsets.all(32),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: medidas.maxHeight - 64,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Total a Pagar',
                                style: TextStyle(fontSize: 16, color: c.tinta2),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dinero(total),
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: c.tinta,
                                ),
                              ),
                              const SizedBox(height: 24),
                              _displayRecibido(c, puedeCobrar),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: 360,
                                child: TecladoNumerico(
                                  alPresionarTecla: _teclear,
                                  alBorrar: _borrar,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: c.superficie,
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Botones Inteligentes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: c.tinta,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView(
                              children: [
                                for (final monto in rapidos)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: OutlinedButton(
                                      onPressed: () => _ponerMonto(monto),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: c.azul.withValues(alpha: 0.5),
                                        ),
                                      ),
                                      child: Text(
                                        monto == total
                                            ? 'Monto Exacto (${dinero(monto)})'
                                            : 'Entregar ${dinero(monto)}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: c.azul,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          _botonCobrar(c, total, puedeCobrar),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            // Teléfono: todo en una columna con billetes en chips.
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total a Pagar:',
                          style: TextStyle(fontSize: 16, color: c.tinta2),
                        ),
                        Text(
                          dinero(total),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: c.azul,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _displayRecibido(c, puedeCobrar),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final monto in rapidos)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                label: Text(
                                  monto == total
                                      ? 'Exacto (${dinero(monto)})'
                                      : dinero(monto),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: c.azul,
                                  ),
                                ),
                                backgroundColor: c.azul.withValues(alpha: 0.1),
                                side: BorderSide(
                                  color: c.azul.withValues(alpha: 0.3),
                                ),
                                onPressed: () => _ponerMonto(monto),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: TecladoNumerico(
                        alPresionarTecla: _teclear,
                        alBorrar: _borrar,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _botonCobrar(c, total, puedeCobrar),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _displayRecibido(ColoresAnaquel c, bool puedeCobrar) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    decoration: BoxDecoration(
      color: c.superficie,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: puedeCobrar ? _verdeExito : c.linea,
        width: puedeCobrar ? 2 : 1,
      ),
    ),
    child: Column(
      children: [
        Text(
          'Dinero Recibido',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        const SizedBox(height: 6),
        FittedBox(
          child: Text(
            dinero(_recibido),
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.bold,
              color: puedeCobrar ? _verdeExito : c.tinta,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );

  Widget _botonCobrar(ColoresAnaquel c, int total, bool puedeCobrar) =>
      SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: puedeCobrar ? () => _cobrar(total) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _verdeExito,
            foregroundColor: Colors.white,
            disabledBackgroundColor: c.linea,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: FittedBox(
            child: Text(
              puedeCobrar
                  ? 'Cobrar (${dinero(_recibido)})'
                  : 'Faltan ${dinero(total - _recibido)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
}

// ============================================================================
// 4.4 MODAL DE CAMBIO A ENTREGAR
// ============================================================================
/// Muestra el cambio a entregar a pantalla completa. Regresa `true` al
/// cerrar la venta y `false` para corregir el monto.
class ModalCambio extends StatelessWidget {
  const ModalCambio({super.key, required this.recibido, required this.cambio});

  /// Centavos.
  final int recibido;
  final int cambio;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Pago recibido: ${dinero(recibido)}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  'CAMBIO',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.greenAccent[400],
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    dinero(cambio),
                    style: const TextStyle(
                      fontSize: 110,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -2,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4285F4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Cerrar Venta',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Corregir monto',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
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

// ============================================================================
// 4.5 COBRO CON TARJETA Y 4.6 TRANSACCIÓN RECHAZADA
// ============================================================================
/// El cobro se hace en la terminal bancaria; aquí se confirma lo que
/// respondió para registrar la venta.
class CobroTarjeta extends ConsumerStatefulWidget {
  const CobroTarjeta({super.key});

  @override
  ConsumerState<CobroTarjeta> createState() => _CobroTarjetaState();
}

class _CobroTarjetaState extends ConsumerState<CobroTarjeta>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);
  bool _mostrarRechazo = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _aprobado() {
    HapticFeedback.mediumImpact();
    _registrarVenta(context, ref, metodo: 'tarjeta');
  }

  void _rechazado() {
    // Vibración fuerte de doble pulso.
    HapticFeedback.heavyImpact();
    Future.delayed(
      const Duration(milliseconds: 180),
      HapticFeedback.heavyImpact,
    );
    setState(() => _mostrarRechazo = true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final total = ref.watch(totalCarritoProvider);

    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: c.tinta),
        title: Text(
          'Total a Cobrar: ${dinero(total)}',
          style: TextStyle(
            color: c.tinta,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 4.5 Espera con animación continua.
          SafeArea(
            child: LayoutBuilder(
              builder: (context, medidas) => SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: medidas.maxHeight - 64,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _ctrl,
                        builder: (context, child) => SizedBox(
                          width: 210,
                          height: 210,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 180 + (_ctrl.value * 30),
                                height: 180 + (_ctrl.value * 30),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: c.azul.withValues(
                                    alpha: 0.08 * (1 - _ctrl.value),
                                  ),
                                ),
                              ),
                              child!,
                            ],
                          ),
                        ),
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.azul.withValues(alpha: 0.12),
                          ),
                          child: Icon(
                            Icons.contactless_outlined,
                            size: 76,
                            color: c.azul,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Siga las instrucciones en la terminal física',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: c.tinta,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Inserte, deslice o acerque la tarjeta al lector',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: c.tinta2),
                      ),
                      const SizedBox(height: 40),

                      // Lo que respondió la terminal bancaria.
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: c.superficie,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: c.linea),
                        ),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _aprobado,
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Pago aprobado'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _verdeExito,
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _rechazado,
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                                color: _rojoRechazo,
                              ),
                              label: const Text(
                                'Pago rechazado',
                                style: TextStyle(color: _rojoRechazo),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: _rojoRechazo),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancelar pago con tarjeta',
                          style: TextStyle(
                            color: c.tinta2,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4.6 Transacción rechazada.
          if (_mostrarRechazo)
            Container(
              color: Colors.black.withValues(alpha: 0.65),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: c.superficie,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _rojoRechazo.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 52,
                          color: _rojoRechazo,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Transacción Declinada',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: c.tinta,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'La tarjeta fue rechazada por el banco emisor. '
                        'Verifique fondos o intente con otra tarjeta.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: c.tinta2),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () =>
                              setState(() => _mostrarRechazo = false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _rojoRechazo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Reintentar',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: c.linea),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Cambiar método de pago',
                            style: TextStyle(fontSize: 16, color: c.tinta),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// 4.7 VENTA EXITOSA Y 4.8 OPCIONES DE RECIBO
// ============================================================================
class VentaExitosa extends ConsumerStatefulWidget {
  const VentaExitosa({super.key, required this.venta});

  final VentaRegistrada venta;

  @override
  ConsumerState<VentaExitosa> createState() => _VentaExitosaState();
}

class _VentaExitosaState extends ConsumerState<VentaExitosa>
    with SingleTickerProviderStateMixin {
  late final AnimationController _checkCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();
  bool _mostrarOpciones = false;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    // Pasa sola a las opciones de recibo.
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _mostrarOpciones = true);
    });
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    super.dispose();
  }

  void _nuevaVenta() {
    HapticFeedback.lightImpact();
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  /// Pide el ticket completo y los datos del negocio para [accion].
  Future<void> _conTicket(
    Future<void> Function(DetalleVenta, AjustesNegocio) accion,
  ) async {
    try {
      final api = await ref.read(apiProvider.future);
      final detalle = await api.obtenerVenta(widget.venta.id);
      final negocio = await ref.read(ajustesNegocioProvider.future);
      await accion(detalle, negocio);
    } catch (e) {
      if (mounted) {
        avisar(context, 'No se pudo generar el recibo: ${mensajeDeError(e)}');
      }
    }
  }

  /// 4.9: vista previa del ticket, con imprimir y compartir.
  void _verTicket() => _conTicket(
    (detalle, negocio) => showDialog<void>(
      context: context,
      builder: (_) => VistaTicketPdf(venta: detalle, negocio: negocio),
    ),
  );

  /// La hoja de compartir del sistema, donde está WhatsApp.
  void _whatsApp() => _conTicket(compartirTicket);

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final v = widget.venta;

    // 4.7 Cobro exitoso: palomita animada.
    if (!_mostrarOpciones) {
      return Scaffold(
        backgroundColor: c.fondo,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: _checkCtrl,
                  curve: Curves.elasticOut,
                ),
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _verdeExito.withValues(alpha: 0.12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 180,
                      color: _verdeExito,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '¡Cobro Exitoso!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: _verdeExito,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4.8 Opciones de recibo.
    final opciones = [
      (
        Icons.print_rounded,
        'Imprimir Ticket',
        'Imprimir Ticket',
        c.azul,
        _verTicket,
      ),
      (
        Icons.chat_rounded,
        'WhatsApp',
        'Enviar por WhatsApp',
        const Color(0xFF25D366),
        _whatsApp,
      ),
      (
        Icons.do_not_disturb_alt_rounded,
        'Sin Recibo',
        'Sin Recibo (Listo)',
        c.tinta2,
        _nuevaVenta,
      ),
    ];
    final ancho = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: c.fondo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: _verdeExito,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '¡Venta Registrada con Éxito!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: c.tinta,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Folio #${v.folio} • Total: ${dinero(v.total)}'
                    '${v.cambio > 0 ? ' • Cambio: ${dinero(v.cambio)}' : ''}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: c.tinta2),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    '¿Cómo desea su recibo?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: c.tinta,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (ancho >= 650)
                    Row(
                      children: [
                        for (final (i, o) in opciones.indexed) ...[
                          if (i > 0) const SizedBox(width: 16),
                          Expanded(
                            child: _BotonRecibo(
                              icono: o.$1,
                              texto: o.$2,
                              colorIcono: o.$4,
                              alTocar: o.$5,
                            ),
                          ),
                        ],
                      ],
                    )
                  else
                    Column(
                      children: [
                        for (final (i, o) in opciones.indexed) ...[
                          if (i > 0) const SizedBox(height: 12),
                          _BotonReciboHorizontal(
                            icono: o.$1,
                            texto: o.$3,
                            colorIcono: o.$4,
                            alTocar: o.$5,
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BotonRecibo extends StatelessWidget {
  const _BotonRecibo({
    required this.icono,
    required this.texto,
    required this.colorIcono,
    required this.alTocar,
  });

  final IconData icono;
  final String texto;
  final Color colorIcono;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return InkWell(
      onTap: alTocar,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: c.superficie,
          border: Border.all(color: c.linea),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 54, color: colorIcono),
            const SizedBox(height: 14),
            Text(
              texto,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: c.tinta,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonReciboHorizontal extends StatelessWidget {
  const _BotonReciboHorizontal({
    required this.icono,
    required this.texto,
    required this.colorIcono,
    required this.alTocar,
  });

  final IconData icono;
  final String texto;
  final Color colorIcono;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return InkWell(
      onTap: alTocar,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: c.superficie,
          border: Border.all(color: c.linea),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icono, size: 30, color: colorIcono),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: c.tinta,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: c.tinta2),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 4.9 VISTA PREVIA DEL TICKET
// ============================================================================
/// El ticket como sale en el PDF (ticket_pdf.dart), con imprimir, compartir
/// y cerrar para la siguiente venta.
class VistaTicketPdf extends StatelessWidget {
  const VistaTicketPdf({super.key, required this.venta, required this.negocio});

  final DetalleVenta venta;
  final AjustesNegocio negocio;

  void _nuevaVenta(BuildContext context) =>
      Navigator.of(context).popUntil((r) => r.isFirst);

  Future<void> _accion(
    BuildContext context,
    Future<void> Function(DetalleVenta, AjustesNegocio) accion,
  ) async {
    try {
      await accion(venta, negocio);
    } catch (e) {
      if (context.mounted) {
        avisar(context, 'No se pudo generar el recibo: ${mensajeDeError(e)}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esTablet = MediaQuery.sizeOf(context).width >= 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(
          child: SingleChildScrollView(
            child: esTablet
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(child: _ticket()),
                      const SizedBox(width: 24),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _AccionFlotante(
                            icono: Icons.print_rounded,
                            etiqueta: 'Imprimir',
                            alTocar: () => _accion(context, imprimirTicket),
                          ),
                          const SizedBox(height: 12),
                          _AccionFlotante(
                            icono: Icons.share_rounded,
                            etiqueta: 'Compartir',
                            alTocar: () => _accion(context, compartirTicket),
                          ),
                          const SizedBox(height: 24),
                          FloatingActionButton(
                            heroTag: 'cerrar_ticket',
                            tooltip: 'Cerrar',
                            onPressed: () => _nuevaVenta(context),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.redAccent,
                            elevation: 4,
                            child: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ticket(),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _accion(context, imprimirTicket),
                            icon: const Icon(Icons.print_rounded, size: 18),
                            label: const Text('Imprimir'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _accion(context, compartirTicket),
                            icon: const Icon(Icons.share_rounded, size: 18),
                            label: const Text('Compartir'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _nuevaVenta(context),
                            icon: const Icon(Icons.close_rounded, size: 18),
                            label: const Text('Cerrar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _rojoRechazo,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _ticket() {
    const chica = TextStyle(fontSize: 11, color: Colors.black54);
    const renglon = TextStyle(fontSize: 13, color: Colors.black87);
    const divisor = Divider(color: Colors.black87, thickness: 1.2);
    final v = venta;

    Widget fila(String izq, String der, {TextStyle estilo = renglon}) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Expanded(child: Text(izq, style: estilo)),
              Text(der, style: estilo),
            ],
          ),
        );

    return Container(
      width: 340,
      constraints: const BoxConstraints(maxHeight: 580),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                (negocio.nombreNegocio ?? 'Depósito').toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Colors.black,
                ),
              ),
              if (negocio.direccion != null) ...[
                const SizedBox(height: 4),
                Text(
                  negocio.direccion!,
                  textAlign: TextAlign.center,
                  style: chica,
                ),
              ],
              if (negocio.telefono != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Tel. ${negocio.telefono}',
                  textAlign: TextAlign.center,
                  style: chica,
                ),
              ],
              const SizedBox(height: 12),
              divisor,
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Folio: #${v.folio}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    fechaHora(v.fecha),
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
              if (v.usuario != null)
                Text(
                  'Atendió: ${v.usuario!.nombre}',
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              divisor,
              const SizedBox(height: 8),
              for (final l in v.lineas)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${l.cantidad}x ${l.nombre}'
                          '${l.porCaja ? ' (Caja)' : ''}'
                          '${l.descuento > 0 ? ' −${l.descuento}%' : ''}',
                          style: renglon,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        dinero(l.subtotal),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              if (v.lineas.isEmpty) fila('Envases vacíos (${v.envN})', ''),
              const SizedBox(height: 8),
              divisor,
              fila('Subtotal:', dinero(v.subtotalProductos)),
              if (v.envMonto > 0)
                fila('Depósito de envases:', '+${dinero(v.envMonto)}'),
              if (v.envCredito > 0)
                fila('Crédito por vacíos:', '-${dinero(v.envCredito)}'),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    dinero(v.total),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              fila(
                v.metodo == 'tarjeta' ? 'Tarjeta:' : 'Efectivo:',
                dinero(v.recibido),
              ),
              if (v.cambio > 0) fila('Cambio:', dinero(v.cambio)),
              const SizedBox(height: 16),
              divisor,
              const SizedBox(height: 12),
              Text(
                negocio.mensajeTicket ?? '¡Gracias por su compra!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const Text(
                'Conserve este comprobante para devoluciones',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccionFlotante extends StatelessWidget {
  const _AccionFlotante({
    required this.icono,
    required this.etiqueta,
    required this.alTocar,
  });

  final IconData icono;
  final String etiqueta;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: etiqueta,
          tooltip: etiqueta,
          onPressed: alTocar,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 4,
          child: Icon(icono),
        ),
        const SizedBox(height: 4),
        Text(
          etiqueta,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
