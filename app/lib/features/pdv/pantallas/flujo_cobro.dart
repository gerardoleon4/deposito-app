import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/tema/colores.dart';
import '../datos/modelos_pdv.dart';
import '../../../../core/widgets/teclado_numerico.dart';
import 'punto_venta.dart';

// --- 4.1 RESUMEN FINAL DE COMPRA ---
class ResumenCompra extends StatelessWidget {
  final List<ItemCarrito> carrito;
  final double total;

  const ResumenCompra({super.key, required this.carrito, required this.total});

  void _irAMetodoPago(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MetodoPago(total: total, carrito: carrito),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        backgroundColor: c.fondo,
        elevation: 0,
        title: Text(
          'Resumen de Compra',
          style: TextStyle(color: c.tinta, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.black),
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
                itemCount: carrito.length,
                separatorBuilder: (_, _) => const Divider(height: 32),
                itemBuilder: (context, i) {
                  final item = carrito[i];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.cantidad}x ${item.producto.nombre} ${item.esCaja ? '(Caja)' : ''}',
                          style: TextStyle(
                            fontSize: 18,
                            color: c.tinta,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '\$${item.subtotal.toStringAsFixed(2)}',
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
                  Text(
                    'Total a Pagar',
                    style: TextStyle(
                      fontSize: 18,
                      color: c.tinta2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
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
                      onPressed: () => _irAMetodoPago(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.azul,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Confirmar y Pagar',
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
class MetodoPago extends StatelessWidget {
  final double total;
  final List<ItemCarrito> carrito;

  const MetodoPago({super.key, required this.total, required this.carrito});

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          'Total: \$${total.toStringAsFixed(2)}',
          style: TextStyle(color: c.tinta, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
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
                          builder: (_) => CobroEfectivo(total: total),
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
                        MaterialPageRoute(builder: (_) => const CobroTarjeta()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _BotonMetodo(
                      icono: Icons.liquor_outlined,
                      texto: 'Saldo por Envases',
                      c: c,
                      alTocar: () {},
                    ),
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

class _BotonMetodo extends StatefulWidget {
  final IconData icono;
  final String texto;
  final ColoresAnaquel c;
  final VoidCallback alTocar;

  const _BotonMetodo({
    required this.icono,
    required this.texto,
    required this.c,
    required this.alTocar,
  });

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
            boxShadow: _presionado
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
class CobroEfectivo extends StatefulWidget {
  final double total;
  const CobroEfectivo({super.key, required this.total});

  @override
  State<CobroEfectivo> createState() => _CobroEfectivoState();
}

class _CobroEfectivoState extends State<CobroEfectivo> {
  String _entregadoText = '';

  double get _entregado =>
      _entregadoText.isEmpty ? 0 : (double.tryParse(_entregadoText) ?? 0);
  bool get _puedeCobrar => _entregado >= widget.total;

  void _teclear(String tecla) {
    setState(() {
      if (_entregadoText.length < 8) _entregadoText += tecla;
    });
  }

  void _borrar() {
    setState(() {
      if (_entregadoText.isNotEmpty) {
        _entregadoText = _entregadoText.substring(0, _entregadoText.length - 1);
      }
    });
  }

  void _setMonto(double monto) {
    setState(() {
      _entregadoText = monto
          .toInt()
          .toString(); // Asume sin centavos para el demo rápido
    });
  }

  void _cobrar() {
    final cambio = _entregado - widget.total;
    // Mostrar 4.4 Modal de Cambio
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ModalCambio(
        recibido: _entregado,
        cambio: cambio,
        alCerrarVenta: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const VentaExitosa()),
            (route) => false,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;

    // Calcular billetes redondos rápidos (ej. si es 135 -> 150, 200, 500)
    List<double> rapidos = [widget.total];
    if (widget.total < 200) rapidos.add(200);
    if (widget.total < 500) rapidos.add(500);
    if (widget.total < 1000) rapidos.add(1000);

    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Cobrar en Efectivo',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Row(
          children: [
            // Lado Izquierdo: Numpad
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total a Pagar',
                      style: TextStyle(fontSize: 16, color: c.tinta2),
                    ),
                    Text(
                      '\$${widget.total.toStringAsFixed(2)}',
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
                      child: Text(
                        '\$${_entregadoText.isEmpty ? '0' : _entregadoText}',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: _puedeCobrar ? Colors.green[600] : c.tinta,
                        ),
                        textAlign: TextAlign.center,
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

            // Lado Derecho: Accesos rápidos y Cobrar
            Expanded(
              flex: 2,
              child: Container(
                color: c.superficie,
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Pagos Rápidos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: c.tinta,
                      ),
                    ),
                    const SizedBox(height: 24),

                    ...rapidos.map((monto) {
                      final esExacto = monto == widget.total;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: OutlinedButton(
                          onPressed: () => _setMonto(monto),
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
                            esExacto
                                ? 'Monto Exacto'
                                : '\$${monto.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 24,
                              color: c.azul,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),

                    const Spacer(),

                    ElevatedButton(
                      onPressed: _puedeCobrar ? _cobrar : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
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
class ModalCambio extends StatelessWidget {
  final double recibido;
  final double cambio;
  final VoidCallback alCerrarVenta;

  const ModalCambio({
    super.key,
    required this.recibido,
    required this.cambio,
    required this.alCerrarVenta,
  });

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
              'Pago recibido: \$${recibido.toStringAsFixed(2)}',
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
            Text(
              '\$${cambio.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 120,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -2,
              ),
            ),
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: alCerrarVenta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Cerrar Venta',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 4.5 y 4.6 COBRO CON TARJETA ---
class CobroTarjeta extends StatefulWidget {
  const CobroTarjeta({super.key});
  @override
  State<CobroTarjeta> createState() => _CobroTarjetaState();
}

class _CobroTarjetaState extends State<CobroTarjeta>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _rechazado = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Simular resultado después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _rechazado = true);
        HapticFeedback.heavyImpact(); // Doble pulso
        Future.delayed(
          const Duration(milliseconds: 200),
          () => HapticFeedback.heavyImpact(),
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_rechazado) {
      return Scaffold(
        backgroundColor: Colors.black87,
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cancel_rounded,
                  color: Color(0xFFEF4444),
                  size: 100,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Transacción Declinada',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 64),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Cambiar método',
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // En un entorno real, reiniciaría el flujo. Para el demo, lo mandamos al éxito tras "reintentar".
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const VentaExitosa(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Reintentar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
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
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_ctrl.value * 0.1),
                  child: Icon(
                    Icons.contactless_outlined,
                    size: 150,
                    color: Colors.blueAccent.withValues(
                      alpha: 0.5 + (_ctrl.value * 0.5),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 48),
            const Text(
              'Siga las instrucciones en la terminal física',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar pago con tarjeta',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// --- 4.7, 4.8 y 4.9 VENTA EXITOSA Y RECIBO ---
class VentaExitosa extends StatefulWidget {
  const VentaExitosa({super.key});
  @override
  State<VentaExitosa> createState() => _VentaExitosaState();
}

class _VentaExitosaState extends State<VentaExitosa>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkCtrl;
  bool _mostrarOpciones = false;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
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

  void _reiniciarPDV() {
    // Aquí en la vida real haríamos pop hasta el PuntoVenta vaciando el carrito.
    // Como el PDV no está en el stack de forma que podamos vaciarlo fácil sin Riverpod, lo re-pusheamos vacío (está bien para demo).
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const PuntoVenta()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_mostrarOpciones) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¿Cómo desea su recibo?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 64),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _BotonRecibo(
                    icono: Icons.print_rounded,
                    texto: 'Imprimir Ticket',
                    alTocar: () {
                      showDialog(
                        context: context,
                        builder: (_) => const VistaTicketPdf(),
                      );
                    },
                  ),
                  const SizedBox(width: 32),
                  _BotonRecibo(
                    icono: Icons.chat_rounded,
                    texto: 'WhatsApp',
                    alTocar: () {},
                  ),
                  const SizedBox(width: 32),
                  _BotonRecibo(
                    icono: Icons.do_not_disturb_alt_rounded,
                    texto: 'Sin Recibo',
                    alTocar: _reiniciarPDV,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 250,
            color: Color(0xFF10B981),
          ),
        ),
      ),
    );
  }
}

class _BotonRecibo extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback alTocar;
  const _BotonRecibo({
    required this.icono,
    required this.texto,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: alTocar,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 64, color: Colors.black87),
            const SizedBox(height: 16),
            Text(
              texto,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VistaTicketPdf extends StatelessWidget {
  const VistaTicketPdf({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Render del Ticket
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'DEPÓSITO DE CERVEZA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ticket de Venta #00452',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.black54),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('1x Modelo Especial (Caja)'),
                      Text('\$528.00'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [Text('2x Doritos Nacho'), Text('\$36.00')],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.black54),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'TOTAL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '\$564.00',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Icon(
                    Icons.qr_code_2_rounded,
                    size: 100,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '¡Gracias por su compra!',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 32),
          // Barra de acciones flotante
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                child: const Icon(Icons.print_rounded),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                child: const Icon(Icons.share_rounded),
              ),
              const SizedBox(height: 48),
              FloatingActionButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const PuntoVenta()),
                    (route) => false,
                  );
                },
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                child: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
