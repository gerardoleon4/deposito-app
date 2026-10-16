import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../app/tema/colores.dart';
import '../../../core/widgets/teclado_numerico.dart';

/// 6.6 Modal de Autorización (Numpad)
/// Superposición oscura total (Overlay) que bloquea la interfaz requiriendo
/// PIN de 4 dígitos con permisos de Gerente o Dueño para aprobar la cancelación.
class ModalAutorizacionNumpad extends StatefulWidget {
  const ModalAutorizacionNumpad({
    super.key,
    required this.alAutorizar,
    this.tituloAccion = 'Cancelar Venta',
  });

  final VoidCallback alAutorizar;
  final String tituloAccion;

  static Future<bool?> mostrar({
    required BuildContext context,
    String tituloAccion = 'Cancelar Venta',
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => ModalAutorizacionNumpad(
        tituloAccion: tituloAccion,
        alAutorizar: () {},
      ),
    );
  }

  @override
  State<ModalAutorizacionNumpad> createState() =>
      _ModalAutorizacionNumpadState();
}

class _ModalAutorizacionNumpadState extends State<ModalAutorizacionNumpad>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  String? _mensajeError;
  bool _estaVerificando = false;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  // PINs válidos para prueba:
  // 9999 = Dueño
  // 8888 = Gerente
  // 1234 = Cajero (sin permisos)
  static const _pinDueno = '9999';
  static const _pinGerente = '8888';

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onTecla(String val) {
    if (_estaVerificando || _pin.length >= 4) return;
    setState(() {
      _mensajeError = null;
      _pin += val;
    });

    if (_pin.length == 4) {
      _verificarPin();
    }
  }

  void _onBorrar() {
    if (_estaVerificando || _pin.isEmpty) return;
    setState(() {
      _mensajeError = null;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _verificarPin() async {
    setState(() => _estaVerificando = true);
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    if (_pin == _pinDueno || _pin == _pinGerente) {
      // Autorización concedida
      widget.alAutorizar();
      Navigator.pop(context, true);
    } else {
      // Rechazado: Cajero u otro PIN
      final esCajero = _pin == '1234';
      _shakeCtrl.forward(from: 0.0);

      setState(() {
        _estaVerificando = false;
        _mensajeError = esCajero
            ? 'PIN de Cajero: Sin permisos de cancelación.'
            : 'PIN incorrecto. Acceso no autorizado.';
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Barra superior con botón Cancelar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                      ),
                      label: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 16,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'MODO SEGURIDAD',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Caja central de autenticación
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
                    decoration: BoxDecoration(
                      color: c.superficie,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar neutro
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: c.superficie2,
                            shape: BoxShape.circle,
                            border: Border.all(color: c.linea),
                          ),
                          child: Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 34,
                            color: c.tinta,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Título: Autorización Requerida
                        Text(
                          'Autorización Requerida',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: c.tinta,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Subtítulo en rojo
                        const Text(
                          'Esta acción requiere permisos de Gerente o Dueño',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Indicadores circulares de PIN con animación Shake
                        AnimatedBuilder(
                          animation: _shakeAnim,
                          builder: (context, child) {
                            final shakeOffset =
                                math.sin(_shakeAnim.value * math.pi * 4) *
                                (1 - _shakeAnim.value) *
                                14;
                            return Transform.translate(
                              offset: Offset(shakeOffset, 0),
                              child: child,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(4, (i) {
                              final lleno = i < _pin.length;
                              final tieneError = _mensajeError != null;

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: tieneError
                                      ? const Color(0xFFDC2626)
                                      : (lleno ? c.azul : Colors.transparent),
                                  border: Border.all(
                                    color: tieneError
                                        ? const Color(0xFFDC2626)
                                        : (lleno
                                              ? c.azul
                                              : c.tinta2.withValues(
                                                  alpha: 0.4,
                                                )),
                                    width: 2,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Mensaje de error
                        if (_mensajeError != null)
                          Text(
                            _mensajeError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFDC2626),
                            ),
                          )
                        else
                          Text(
                            'Ingresa PIN de 4 dígitos (Demo: 9999 o 8888)',
                            style: TextStyle(fontSize: 12, color: c.tinta2),
                          ),
                        const SizedBox(height: 20),

                        // Teclado numérico amplio y espaciado
                        TecladoNumerico(
                          alPresionarTecla: _onTecla,
                          alBorrar: _onBorrar,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
