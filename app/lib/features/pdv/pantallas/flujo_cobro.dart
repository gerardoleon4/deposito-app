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

String _nombreItem(ItemCarrito i) =>
    '${i.cantidad}x ${i.producto.nombre}${i.porCaja ? ' (caja)' : ''}'
    '${i.descuento > 0 ? ' −${i.descuento}%' : ''}';

/// Renglones de envases del resumen: (texto, monto, color).
List<(String, String, Color?)> _renglonesEnvases(WidgetRef ref) {
  final carrito = ref.watch(carritoProvider);
  final precios = ref.watch(preciosEnvasesProvider);
  final deposito = carrito.deposito(precios);
  return [
    if (deposito > 0)
      ('Depósito de envases', '+${dinero(deposito)}', const Color(0xFFD97706)),
    if (carrito.envModo == ModoEnvases.trae)
      ('Envases: el cliente entrega vacíos', 'Sin costo', null),
    if (carrito.envModo == ModoEnvases.prestamo)
      (
        'Envases prestados a ${carrito.envCliente ?? 'cliente'}',
        'Préstamo',
        null,
      ),
    for (final e in carrito.credito.entries)
      (
        'Crédito por ${e.value} vacíos ${FormatoEnvase.de(e.key).etiqueta}',
        '-${dinero(e.value * (precios[e.key] ?? 0))}',
        const Color(0xFF16A34A),
      ),
  ];
}

// --- 4.1 RESUMEN FINAL DE COMPRA ---
class ResumenCompra extends ConsumerWidget {
  const ResumenCompra({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colores;
    final carrito = ref.watch(carritoProvider);
    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        backgroundColor: c.fondo,
        elevation: 0,
        title: Text(
          'Resumen de compra',
          style: TextStyle(color: c.tinta, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                itemCount: carrito.items.length + _renglonesEnvases(ref).length,
                separatorBuilder: (_, _) => const Divider(height: 32),
                itemBuilder: (context, i) {
                  if (i >= carrito.items.length) {
                    final (texto, monto, color) = _renglonesEnvases(
                      ref,
                    )[i - carrito.items.length];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            texto,
                            style: TextStyle(
                              fontSize: 16,
                              color: color ?? c.tinta2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          monto,
                          style: TextStyle(
                            fontSize: 18,
                            color: color ?? c.tinta2,
                          ),
                        ),
                      ],
                    );
                  }
                  final item = carrito.items[i];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _nombreItem(item),
                          style: TextStyle(
                            fontSize: 18,
                            color: c.tinta,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        dinero(item.subtotal),
                        style: TextStyle(fontSize: 18, color: c.tinta2),
                      ),
                    ],
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: c.superficie,
                border: Border(top: BorderSide(color: c.linea)),
              ),
              child: Column(
                children: [
                  Text(
                    'Total a pagar',
                    style: TextStyle(
                      fontSize: 18,
                      color: c.tinta2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dinero(ref.watch(totalCarritoProvider)),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: c.azul,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
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
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Confirmar y pagar',
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
    );
  }
}

// --- 4.2 SELECCIÓN DE MÉTODO DE PAGO ---
class MetodoPago extends ConsumerWidget {
  const MetodoPago({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colores;
    final total = ref.watch(totalCarritoProvider);
    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Total: ${dinero(total)}',
          style: TextStyle(color: c.tinta, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Selecciona un método',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: c.tinta,
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  children: [
                    Expanded(
                      child: _BotonMetodo(
                        icono: Icons.payments_outlined,
                        texto: 'Efectivo',
                        c: c,
                        alTocar: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CobroEfectivo(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _BotonMetodo(
                        icono: Icons.credit_card_outlined,
                        texto: 'Tarjeta',
                        c: c,
                        alTocar: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CobroTarjeta(),
                          ),
                        ),
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
}

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
        widget.alTocar();
      },
      onTapCancel: () => setState(() => _presionado = false),
      child: AnimatedScale(
        scale: _presionado ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 50),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: widget.c.superficie,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: widget.c.linea),
            boxShadow: _presionado ? null : widget.c.sombra,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icono, size: 64, color: widget.c.azul),
              const SizedBox(height: 24),
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
    );
  }
}

// --- 4.3 COBRO EN EFECTIVO ---
class CobroEfectivo extends ConsumerStatefulWidget {
  const CobroEfectivo({super.key});

  @override
  ConsumerState<CobroEfectivo> createState() => _CobroEfectivoState();
}

class _CobroEfectivoState extends ConsumerState<CobroEfectivo> {
  /// Centavos que entregó el cliente. Con el teclado se escriben pesos
  /// enteros; "Monto exacto" puede traer centavos.
  int _recibido = 0;

  void _teclear(String tecla) {
    final pesos = _recibido ~/ 100;
    if (pesos >= 1000000) return;
    setState(() => _recibido = (pesos * 10 + int.parse(tecla)) * 100);
  }

  void _borrar() => setState(() => _recibido = (_recibido ~/ 100) ~/ 10 * 100);

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

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final total = ref.watch(totalCarritoProvider);
    final puedeCobrar = _recibido >= total && total > 0;

    // Billetes comunes por encima del total (en centavos).
    final rapidos = [
      total,
      for (final b in [20000, 50000, 100000])
        if (b > total) b,
    ];

    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Cobrar en efectivo', style: TextStyle(color: c.tinta)),
      ),
      body: SafeArea(
        child: Row(
          children: [
            // Teclado
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Text(
                      'Total a pagar',
                      style: TextStyle(fontSize: 16, color: c.tinta2),
                    ),
                    Text(
                      dinero(total),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: c.tinta,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: c.superficie,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: c.linea),
                      ),
                      child: FittedBox(
                        child: Text(
                          dinero(_recibido),
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: puedeCobrar ? c.verde : c.tinta,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 350,
                      child: TecladoNumerico(
                        alPresionarTecla: _teclear,
                        alBorrar: _borrar,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Pagos rápidos y cobrar
            Expanded(
              flex: 2,
              child: Container(
                color: c.superficie,
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Pagos rápidos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: c.tinta,
                      ),
                    ),
                    const SizedBox(height: 24),
                    for (final monto in rapidos)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: OutlinedButton(
                          onPressed: () => setState(() => _recibido = monto),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(
                              color: c.azul.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            monto == total ? 'Monto exacto' : dinero(monto),
                            style: TextStyle(
                              fontSize: 24,
                              color: c.azul,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: puedeCobrar ? () => _cobrar(total) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.verde,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: c.linea,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Cobrar',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 4.4 MODAL DE CAMBIO ---
/// Muestra el cambio a entregar. Regresa `true` al confirmar.
class ModalCambio extends StatelessWidget {
  const ModalCambio({super.key, required this.recibido, required this.cambio});

  /// Centavos.
  final int recibido;
  final int cambio;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pago recibido: ${dinero(recibido)}',
              style: const TextStyle(fontSize: 24, color: Colors.white54),
            ),
            const SizedBox(height: 24),
            Text(
              'CAMBIO',
              style: TextStyle(
                fontSize: 32,
                color: Colors.green[400],
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            FittedBox(
              child: Text(
                dinero(cambio),
                style: const TextStyle(
                  fontSize: 120,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -2,
                ),
              ),
            ),
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Corregir',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Cerrar venta',
                        style: TextStyle(
                          fontSize: 32,
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
    );
  }
}

// --- 4.5 y 4.6 COBRO CON TARJETA ---
/// El cobro se hace en la terminal bancaria; aquí solo se confirma cuando
/// la terminal lo aprobó, para registrar la venta.
class CobroTarjeta extends ConsumerStatefulWidget {
  const CobroTarjeta({super.key});

  @override
  ConsumerState<CobroTarjeta> createState() => _CobroTarjetaState();
}

class _CobroTarjetaState extends ConsumerState<CobroTarjeta>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final total = ref.watch(totalCarritoProvider);
    return Scaffold(
      backgroundColor: c.fondo,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _ctrl,
                  builder: (context, child) => Transform.scale(
                    scale: 1.0 + (_ctrl.value * 0.1),
                    child: Icon(
                      Icons.contactless_outlined,
                      size: 150,
                      color: c.azul.withValues(alpha: 0.5 + _ctrl.value * 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  'Cobra ${dinero(total)} en la terminal bancaria',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: c.tinta,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Cuando la terminal apruebe el pago, confírmalo aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: c.tinta2),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 360,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _registrarVenta(context, ref, metodo: 'tarjeta');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.verde,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Pago aprobado',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Fue rechazado: cambiar método',
                    style: TextStyle(
                      color: c.tinta2,
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                    ),
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

// --- 4.7, 4.8 y 4.9 VENTA EXITOSA Y RECIBO ---
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
    duration: const Duration(milliseconds: 600),
  )..forward();
  bool _mostrarOpciones = false;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _mostrarOpciones = true);
    });
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    super.dispose();
  }

  void _nuevaVenta() => Navigator.of(context).popUntil((r) => r.isFirst);

  /// Pide el ticket completo y lo imprime o comparte en PDF.
  Future<void> _recibo(
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

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final v = widget.venta;
    if (!_mostrarOpciones) {
      return Scaffold(
        backgroundColor: c.fondo,
        body: Center(
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _checkCtrl,
              curve: Curves.elasticOut,
            ),
            child: Icon(Icons.check_circle_rounded, size: 250, color: c.verde),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: c.fondo,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, size: 64, color: c.verde),
              const SizedBox(height: 16),
              Text(
                'Venta ${v.folio} registrada',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: c.tinta,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                v.cambio > 0
                    ? 'Total ${dinero(v.total)} · Cambio ${dinero(v.cambio)}'
                    : 'Total ${dinero(v.total)} · ${capitalizar(v.metodo)}',
                style: TextStyle(fontSize: 18, color: c.tinta2),
              ),
              const SizedBox(height: 40),
              Text(
                '¿Cómo desea su recibo?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: c.tinta,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  _BotonRecibo(
                    icono: Icons.print_rounded,
                    texto: 'Imprimir',
                    alTocar: () => _recibo(imprimirTicket),
                  ),
                  _BotonRecibo(
                    icono: Icons.share_rounded,
                    texto: 'Compartir',
                    alTocar: () => _recibo(compartirTicket),
                  ),
                  _BotonRecibo(
                    icono: Icons.add_shopping_cart_rounded,
                    texto: 'Nueva venta',
                    alTocar: _nuevaVenta,
                  ),
                ],
              ),
            ],
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
    required this.alTocar,
  });

  final IconData icono;
  final String texto;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return InkWell(
      onTap: alTocar,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          border: Border.all(color: c.linea),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 56, color: c.tinta),
            const SizedBox(height: 16),
            Text(
              texto,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: c.tinta,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
