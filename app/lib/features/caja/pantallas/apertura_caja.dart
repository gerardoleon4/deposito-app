import 'package:flutter/material.dart';

import '../../../../app/tema/colores.dart';
import '../../../../core/formato/formato.dart';
import '../../../../core/widgets/teclado_numerico.dart';

class AperturaCaja extends StatefulWidget {
  const AperturaCaja({
    super.key,
    required this.nombreCajero,
    required this.inicialesCajero,
    required this.alAbrir,
  });

  final String nombreCajero;
  final String inicialesCajero;

  /// Fondo de caja en centavos.
  final void Function(int centavos) alAbrir;

  @override
  State<AperturaCaja> createState() => _AperturaCajaState();
}

class _AperturaCajaState extends State<AperturaCaja> {
  String _montoText = '';

  /// Se teclean pesos enteros; el fondo se maneja en centavos.
  int get _centavos => _montoText.isEmpty ? 0 : int.parse(_montoText) * 100;

  void _teclear(String tecla) {
    setState(() {
      if (_montoText.length < 8) {
        _montoText += tecla;
      }
    });
  }

  void _borrar() {
    setState(() {
      if (_montoText.isNotEmpty) {
        _montoText = _montoText.substring(0, _montoText.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final bool puedeAbrir = _centavos > 0;

    return PopScope(
      canPop: false, // Evita cerrar el modal (sin botón back)
      child: Scaffold(
        backgroundColor: c.fondo,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Cabecera
              Text(
                'Apertura de Turno',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: c.azul,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: c.superficie,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: c.linea),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: c.azul.withValues(alpha: 0.1),
                      child: Text(
                        widget.inicialesCajero,
                        style: TextStyle(
                          color: c.azul,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.nombreCajero,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: c.tinta,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Input Principal Gigante
              Text(
                'Efectivo Inicial en Caja',
                style: TextStyle(fontSize: 16, color: c.tinta2),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '\$',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      color: _montoText.isEmpty ? c.linea : c.tinta,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    // El signo de pesos va aparte, más chico.
                    dinero(_centavos).replaceFirst(r'$', ''),
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w700,
                      color: _montoText.isEmpty ? c.linea : c.tinta,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Teclado
              SizedBox(
                width: 320,
                child: TecladoNumerico(
                  alPresionarTecla: _teclear,
                  alBorrar: _borrar,
                ),
              ),

              const SizedBox(height: 48),

              // Botón inferior
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: puedeAbrir
                        ? () => widget.alAbrir(_centavos)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.azul,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: c.linea,
                      disabledForegroundColor: c.tinta2.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Abrir Caja y Comenzar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
