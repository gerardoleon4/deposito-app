import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/tema/colores.dart';
import '../datos/modelos_pdv.dart';
import '../../../../core/widgets/teclado_numerico.dart';
import 'punto_venta.dart';

// ============================================================================
// 4.1 RESUMEN FINAL DE COMPRA
// ============================================================================
class ResumenCompra extends StatelessWidget {
  final List<ItemCarrito> carrito;
  final double total;
  final List<CreditoEnvase> creditosEnvases;
  final double cargoDepositos;
  final String? clientePrestamo;

  const ResumenCompra({
    super.key,
    required this.carrito,
    required this.total,
    this.creditosEnvases = const [],
    this.cargoDepositos = 0.0,
    this.clientePrestamo,
  });

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
    final ancho = MediaQuery.of(context).size.width;

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
                // Lista Rápida desplazable
                Expanded(
                  child: (carrito.isEmpty && creditosEnvases.isEmpty)
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
                            for (final item in carrito) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: c.azul.withValues(
                                                alpha: 0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                              '${item.producto.nombre} ${item.esCaja ? '(Caja)' : ''}',
                                              style: TextStyle(
                                                fontSize: 17,
                                                color: c.tinta,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '\$${item.subtotal.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: c.tinta,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                height: 24,
                                color: c.linea.withValues(alpha: 0.5),
                              ),
                            ],
                            if (cargoDepositos > 0) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.inventory_2_outlined,
                                          color: c.azul,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Cargo por Depósito de Envases',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: c.tinta,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '+\$${cargoDepositos.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: c.azul,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                height: 24,
                                color: c.linea.withValues(alpha: 0.5),
                              ),
                            ],
                            for (final cr in creditosEnvases) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.recycling_rounded,
                                          color: c.verde,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Crédito por Envases (${cr.cantidad} pzs)',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: c.verde,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '-\$${cr.creditoTotal.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: c.verde,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                height: 24,
                                color: c.linea.withValues(alpha: 0.5),
                              ),
                            ],
                            if (clientePrestamo != null) ...[
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
                                        'Envases asociados como préstamo a: $clientePrestamo',
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
                          ],
                        ),
                ),

                // Separador horizontal grueso y Bloque de Total Sticky
                Container(
                  decoration: BoxDecoration(
                    color: c.superficie,
                    border: Border(
                      top: BorderSide(
                        color: c.linea,
                        width: 3,
                      ), // Separador grueso
                    ),
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
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: c.azul,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => _irAMetodoPago(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: c.azul,
                            foregroundColor: Colors.white,
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
class MetodoPago extends StatelessWidget {
  final double total;
  final List<ItemCarrito> carrito;

  const MetodoPago({super.key, required this.total, required this.carrito});

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final ancho = MediaQuery.of(context).size.width;
    final esTablet = ancho >= 700;

    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: c.tinta),
        title: Text(
          'Total a Cobrar: \$${total.toStringAsFixed(2)}',
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

                  // Tres botones masivos y cuadrados con abundante espacio en blanco
                  if (esTablet)
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
                                builder: (_) => CobroEfectivo(
                                  total: total,
                                  carrito: carrito,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _BotonMetodo(
                            icono: Icons.point_of_sale_rounded,
                            texto: 'Tarjeta',
                            c: c,
                            alTocar: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CobroTarjeta(
                                  total: total,
                                  carrito: carrito,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _BotonMetodo(
                            icono: Icons.liquor_outlined,
                            texto: 'Saldo por Envases',
                            c: c,
                            alTocar: () => _mostrarModalEnvases(context, c),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _BotonMetodoMovil(
                          icono: Icons.payments_outlined,
                          texto: 'Efectivo',
                          descripcion: 'Cobro con billetes y monedas físicas',
                          c: c,
                          alTocar: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CobroEfectivo(total: total, carrito: carrito),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _BotonMetodoMovil(
                          icono: Icons.point_of_sale_rounded,
                          texto: 'Tarjeta',
                          descripcion:
                              'Terminal bancaria física (Débito / Crédito)',
                          c: c,
                          alTocar: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CobroTarjeta(total: total, carrito: carrito),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _BotonMetodoMovil(
                          icono: Icons.liquor_outlined,
                          texto: 'Saldo por Envases',
                          descripcion:
                              'Descuento por botellas retornables recibidas',
                          c: c,
                          alTocar: () => _mostrarModalEnvases(context, c),
                        ),
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

  void _mostrarModalEnvases(BuildContext context, ColoresAnaquel c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: c.superficie,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: c.linea,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Icon(Icons.liquor_rounded, size: 48, color: c.azul),
              const SizedBox(height: 16),
              Text(
                'Saldo a Favor por Envases',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: c.tinta,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'El cliente entregó 12 botellas retornables (Mega).\nSaldo disponible: \$96.00',
                textAlign: TextAlign.center,
                style: TextStyle(color: c.tinta2, fontSize: 15),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CobroEfectivo(
                          total: (total - 96.0) > 0 ? (total - 96.0) : 0,
                          carrito: carrito,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.azul,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Aplicar \$96.00 y pagar resto',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Botón cuadrado para iPad / Desktop con efecto de hundimiento instantáneo (0.95)
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

  void _ejecutarAccion() {
    setState(() => _presionado = true);
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() => _presionado = false);
        widget.alTocar();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _presionado = true),
      onTapUp: (_) => _ejecutarAccion(),
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

// Botón amplio responsivo para Móvil con efecto hundimiento (0.95)
class _BotonMetodoMovil extends StatefulWidget {
  final IconData icono;
  final String texto;
  final String descripcion;
  final ColoresAnaquel c;
  final VoidCallback alTocar;

  const _BotonMetodoMovil({
    required this.icono,
    required this.texto,
    required this.descripcion,
    required this.c,
    required this.alTocar,
  });

  @override
  State<_BotonMetodoMovil> createState() => _BotonMetodoMovilState();
}

class _BotonMetodoMovilState extends State<_BotonMetodoMovil> {
  bool _presionado = false;

  void _ejecutarAccion() {
    setState(() => _presionado = true);
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() => _presionado = false);
        widget.alTocar();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _presionado = true),
      onTapUp: (_) => _ejecutarAccion(),
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
// 4.3 PANTALLA DE COBRO EN EFECTIVO
// ============================================================================
class CobroEfectivo extends StatefulWidget {
  final double total;
  final List<ItemCarrito> carrito;

  const CobroEfectivo({super.key, required this.total, required this.carrito});

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
      _entregadoText = monto.toInt().toString();
    });
  }

  void _cobrar() {
    final cambio = _entregado - widget.total;
    // Mostrar 4.4 Modal de Cambio a Entregar
    final nav = Navigator.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ModalCambio(
        recibido: _entregado,
        cambio: cambio,
        alCerrarVenta: () {
          nav.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) =>
                  VentaExitosa(total: widget.total, carrito: widget.carrito),
            ),
            (route) => false,
          );
        },
      ),
    );
  }

  List<double> _calcularBilletesInteligentes(double total) {
    final res = <double>[total]; // Monto exacto
    // Siguiente múltiplo de 50
    final sig50 = ((total / 50).ceil() * 50).toDouble();
    if (sig50 > total && !res.contains(sig50)) res.add(sig50);
    // Siguiente múltiplo de 100
    final sig100 = ((total / 100).ceil() * 100).toDouble();
    if (sig100 > total && !res.contains(sig100)) res.add(sig100);
    // Billetes estándar
    for (final b in [200.0, 500.0, 1000.0]) {
      if (b > total && !res.contains(b)) {
        res.add(b);
      }
    }
    return res.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final ancho = MediaQuery.of(context).size.width;
    final esTablet = ancho >= 700;
    final rapidos = _calcularBilletesInteligentes(widget.total);

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
            // Layout Asimétrico de Dos Columnas para iPad
            ? Row(
                children: [
                  // Lado Izquierdo: Numpad y display
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
                          const SizedBox(height: 4),
                          Text(
                            '\$${widget.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: c.tinta,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildDisplayEntregado(c),
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

                  // Lado Derecho: Columna de Botones Inteligentes y Botón Cobrar
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: c.superficie,
                      padding: const EdgeInsets.all(32),
                      child: _buildPanelDerecho(c, rapidos),
                    ),
                  ),
                ],
              )
            // Layout Responsivo Móvil
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
                          '\$${widget.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: c.azul,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDisplayEntregado(c),
                    const SizedBox(height: 20),
                    // Fila rápida horizontal en móvil
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: rapidos.map((monto) {
                          final esExacto = monto == widget.total;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: Text(
                                esExacto
                                    ? 'Exacto (\$${monto.toStringAsFixed(0)})'
                                    : '\$${monto.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: c.azul,
                                ),
                              ),
                              backgroundColor: c.azul.withValues(alpha: 0.1),
                              side: BorderSide(
                                color: c.azul.withValues(alpha: 0.3),
                              ),
                              onPressed: () => _setMonto(monto),
                            ),
                          );
                        }).toList(),
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
                    _buildBotonCobrar(c),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDisplayEntregado(ColoresAnaquel c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _puedeCobrar ? const Color(0xFF10B981) : c.linea,
          width: _puedeCobrar ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Dinero Recibido',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
          const SizedBox(height: 6),
          Text(
            '\$${_entregadoText.isEmpty ? '0' : _entregadoText}',
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.bold,
              color: _puedeCobrar ? const Color(0xFF10B981) : c.tinta,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPanelDerecho(ColoresAnaquel c, List<double> rapidos) {
    return Column(
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
        ...rapidos.map((monto) {
          final esExacto = monto == widget.total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton(
              onPressed: () => _setMonto(monto),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: BorderSide(color: c.azul.withValues(alpha: 0.5)),
              ),
              child: Text(
                esExacto
                    ? 'Monto Exacto (\$${monto.toStringAsFixed(2)})'
                    : 'Entregar \$${monto.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 18,
                  color: c.azul,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
        const Spacer(),
        _buildBotonCobrar(c),
      ],
    );
  }

  Widget _buildBotonCobrar(ColoresAnaquel c) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _puedeCobrar ? _cobrar : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          disabledBackgroundColor: c.linea,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          _puedeCobrar
              ? 'Cobrar (\$${_entregado.toStringAsFixed(2)})'
              : 'Faltan \$${(widget.total - _entregado).toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ============================================================================
// 4.4 MODAL DE CAMBIO A ENTREGAR (FULLSCREEN MODAL)
// ============================================================================
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
      backgroundColor: const Color(0xFF0F172A), // Fondo ultra oscuro
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
                // Texto secundario superior
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
                    'Pago recibido: \$${recibido.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Texto principal central en tamaño colosal
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
                    '\$${cambio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 110,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -2,
                    ),
                  ),
                ),
                const Spacer(),

                // Acción: Botón primario muy ancho "Cerrar Venta"
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: alCerrarVenta,
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
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 4.5 PANTALLA DE COBRO CON TARJETA Y 4.6 TRANSACCIÓN RECHAZADA
// ============================================================================
class CobroTarjeta extends StatefulWidget {
  final double total;
  final List<ItemCarrito> carrito;

  const CobroTarjeta({super.key, required this.total, required this.carrito});

  @override
  State<CobroTarjeta> createState() => _CobroTarjetaState();
}

class _CobroTarjetaState extends State<CobroTarjeta>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _mostrarModalRechazo = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _simularExito() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            VentaExitosa(total: widget.total, carrito: widget.carrito),
      ),
      (route) => false,
    );
  }

  void _simularRechazo() {
    // 4.6 Vibración háptica fuerte (doble pulso)
    HapticFeedback.heavyImpact();
    Future.delayed(
      const Duration(milliseconds: 180),
      () => HapticFeedback.heavyImpact(),
    );

    setState(() => _mostrarModalRechazo = true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;

    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: c.tinta),
        title: Text(
          'Total a Cobrar: \$${widget.total.toStringAsFixed(2)}',
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
          // 4.5 Pantalla de espera con animación continua
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    AnimatedBuilder(
                      animation: _ctrl,
                      builder: (context, child) {
                        return Stack(
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
                            Container(
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
                          ],
                        );
                      },
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
                      style: TextStyle(fontSize: 15, color: c.tinta2),
                    ),
                    const Spacer(),

                    // Botones de prueba interactiva para Chrome
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: c.superficie,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: c.linea),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _simularExito,
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Simular Aprobada'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: _simularRechazo,
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: Color(0xFFEF4444),
                            ),
                            label: const Text(
                              'Simular Declinada',
                              style: TextStyle(color: Color(0xFFEF4444)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFEF4444)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botón secundario inferior para cancelar
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
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // 4.6 Modal Flotante de Transacción Rechazada
          if (_mostrarModalRechazo)
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
                          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 52,
                          color: Color(0xFFEF4444),
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
                        'La tarjeta fue rechazada por el banco emisor. Verifique fondos o intente con otra tarjeta.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: c.tinta2),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _mostrarModalRechazo = false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
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
// 4.7 PANTALLA DE VENTA EXITOSA Y 4.8 OPCIONES DE RECIBO
// ============================================================================
class VentaExitosa extends StatefulWidget {
  final double total;
  final List<ItemCarrito> carrito;

  const VentaExitosa({super.key, this.total = 0, this.carrito = const []});

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
      duration: const Duration(milliseconds: 700),
    )..forward();

    HapticFeedback.mediumImpact();

    // Salto automático tras 1 segundo sin interacción del usuario
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _mostrarOpciones = true);
    });
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    super.dispose();
  }

  void _reiniciarPDV() {
    HapticFeedback.lightImpact();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const PuntoVenta()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final ancho = MediaQuery.of(context).size.width;

    // 4.8 Opciones de Recibo
    if (_mostrarOpciones) {
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
                        color: Color(0xFF10B981),
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
                      'Folio #00452 • Total: \$${widget.total > 0 ? widget.total.toStringAsFixed(2) : "564.00"}',
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

                    // Tres opciones limpias
                    if (ancho >= 650)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _BotonRecibo(
                              icono: Icons.print_rounded,
                              texto: 'Imprimir Ticket',
                              colorIcono: c.azul,
                              alTocar: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => VistaTicketPdf(
                                    total: widget.total,
                                    carrito: widget.carrito,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _BotonRecibo(
                              icono: Icons.chat_rounded,
                              texto: 'WhatsApp',
                              colorIcono: const Color(0xFF25D366),
                              alTocar: () => _mostrarEnvioWhatsApp(context, c),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _BotonRecibo(
                              icono: Icons.do_not_disturb_alt_rounded,
                              texto: 'Sin Recibo',
                              colorIcono: c.tinta2,
                              alTocar: _reiniciarPDV,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _BotonReciboHorizontal(
                            icono: Icons.print_rounded,
                            texto: 'Imprimir Ticket',
                            colorIcono: c.azul,
                            alTocar: () {
                              showDialog(
                                context: context,
                                builder: (_) => VistaTicketPdf(
                                  total: widget.total,
                                  carrito: widget.carrito,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _BotonReciboHorizontal(
                            icono: Icons.chat_rounded,
                            texto: 'Enviar por WhatsApp',
                            colorIcono: const Color(0xFF25D366),
                            alTocar: () => _mostrarEnvioWhatsApp(context, c),
                          ),
                          const SizedBox(height: 12),
                          _BotonReciboHorizontal(
                            icono: Icons.do_not_disturb_alt_rounded,
                            texto: 'Sin Recibo (Listo)',
                            colorIcono: c.tinta2,
                            alTocar: _reiniciarPDV,
                          ),
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

    // 4.7 Pantalla de Venta Exitosa (Limpia, Checkmark animado)
    return Scaffold(
      backgroundColor: Colors.white,
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
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 180,
                    color: Color(0xFF10B981),
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
                color: Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarEnvioWhatsApp(BuildContext context, ColoresAnaquel c) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Enviar ticket por WhatsApp'),
          content: TextField(
            autofocus: true,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Número a 10 dígitos (ej. 9611234567)',
              prefixIcon: const Icon(Icons.phone_outlined),
              filled: true,
              fillColor: c.fondo,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Ticket enviado por WhatsApp'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
                _reiniciarPDV();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
              ),
              child: const Text(
                'Enviar Ticket',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BotonRecibo extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color colorIcono;
  final VoidCallback alTocar;

  const _BotonRecibo({
    required this.icono,
    required this.texto,
    required this.colorIcono,
    required this.alTocar,
  });

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
  final IconData icono;
  final String texto;
  final Color colorIcono;
  final VoidCallback alTocar;

  const _BotonReciboHorizontal({
    required this.icono,
    required this.texto,
    required this.colorIcono,
    required this.alTocar,
  });

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
// 4.9 VISTA PREVIA DEL TICKET PDF
// ============================================================================
class VistaTicketPdf extends StatelessWidget {
  final double total;
  final List<ItemCarrito> carrito;

  const VistaTicketPdf({super.key, this.total = 0, this.carrito = const []});

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;
    final esTablet = ancho >= 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Container(
        // Fondo negro al 40% de opacidad
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(
          child: SingleChildScrollView(
            child: esTablet
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTicketCard(context),
                      const SizedBox(width: 24),
                      _buildBarraAcciones(context),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTicketCard(context),
                      const SizedBox(height: 16),
                      _buildBarraAccionesHorizontal(context),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context) {
    final items = carrito.isNotEmpty
        ? carrito
        : [
            ItemCarrito(
              id: 'demo_1',
              producto: Producto('1', 'Modelo Especial', 22.0, 'Cervezas', 50),
              cantidad: 1,
              esCaja: true,
            ),
            ItemCarrito(
              id: 'demo_2',
              producto: Producto('4', 'Doritos Nacho', 18.0, 'Botanas', 15),
              cantidad: 2,
            ),
          ];

    final displayTotal = total > 0 ? total : 564.0;

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
              // Encabezado
              const Text(
                'DEPÓSITO DE CERVEZA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'NEXO POS • SISTEMA LOCAL',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              const Text(
                'Av. Central Poniente #120',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.black87, thickness: 1.2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Folio: #00452',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text('16/10/2026 00:45', style: TextStyle(fontSize: 12)),
                ],
              ),
              const Divider(color: Colors.black87, thickness: 1.2),
              const SizedBox(height: 8),

              // Lista de artículos
              ...items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.cantidad}x ${item.producto.nombre} ${item.esCaja ? '(Caja)' : ''}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${item.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 8),
              const Divider(color: Colors.black87, thickness: 1.2),

              // Totales
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal:', style: TextStyle(fontSize: 13)),
                  Text(
                    '\$${displayTotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Envases retornables:', style: TextStyle(fontSize: 13)),
                  Text('\$0.00', style: TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    '\$${displayTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.black87, thickness: 1.2),
              const SizedBox(height: 16),

              // QR y pie
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey[100],
                  child: const Icon(
                    Icons.qr_code_2_rounded,
                    size: 84,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '¡Gracias por su compra!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
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

  // Barra de acciones vertical (Tablet)
  Widget _buildBarraAcciones(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AccionFlotante(
          icono: Icons.print_rounded,
          etiqueta: 'Imprimir',
          alTocar: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🖨️ Enviando a impresora térmica POS...'),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _AccionFlotante(
          icono: Icons.share_rounded,
          etiqueta: 'Compartir',
          alTocar: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('📤 Compartiendo ticket PDF...')),
            );
          },
        ),
        const SizedBox(height: 24),
        FloatingActionButton(
          heroTag: 'cerrar_ticket',
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const PuntoVenta()),
              (route) => false,
            );
          },
          backgroundColor: Colors.white,
          foregroundColor: Colors.redAccent,
          elevation: 4,
          child: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }

  // Barra de acciones horizontal (Móvil)
  Widget _buildBarraAccionesHorizontal(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🖨️ Enviando a impresora térmica POS...'),
              ),
            );
          },
          icon: const Icon(Icons.print_rounded, size: 18),
          label: const Text('Imprimir'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const PuntoVenta()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.close_rounded, size: 18),
          label: const Text('Cerrar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _AccionFlotante extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final VoidCallback alTocar;

  const _AccionFlotante({
    required this.icono,
    required this.etiqueta,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: etiqueta,
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
