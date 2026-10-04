import 'package:flutter/material.dart';

import '../../../../app/tema/colores.dart';
import '../../../../core/widgets/campo_pin.dart';
import '../../../../core/widgets/teclado_numerico.dart';
import '../../../../core/widgets/cargador_nexo.dart';

class RestaurarRespaldo extends StatefulWidget {
  const RestaurarRespaldo({super.key});

  @override
  State<RestaurarRespaldo> createState() => _RestaurarRespaldoState();
}

class _RestaurarRespaldoState extends State<RestaurarRespaldo> {
  bool _archivoSeleccionado = false;
  bool _restaurando = false;
  String _pin = '';
  bool _errorPin = false;

  void _seleccionarArchivo() {
    // Simula abrir el selector nativo y cargar un archivo
    setState(() {
      _archivoSeleccionado = true;
    });
  }

  void _teclear(String tecla) {
    if (_restaurando || _pin.length >= 6) return;

    setState(() {
      _pin += tecla;
      _errorPin = false;
    });

    if (_pin.length == 6) {
      _validarPin();
    }
  }

  void _borrar() {
    if (_restaurando || _pin.isEmpty) return;

    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _errorPin = false;
    });
  }

  void _validarPin() {
    // Simulación de validación
    if (_pin == '123456') {
      setState(() => _restaurando = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          // En la vida real aquí redirigiría al sistema (Login)
          Navigator.pop(context);
        }
      });
    } else {
      setState(() => _errorPin = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _pin = '';
            _errorPin = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;

    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _restaurando
            ? null
            : TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                label: const Text(
                  'Volver',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: c.azul,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
        leadingWidth: 100,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: _restaurando
                ? _ConstruirEstadoRestaurando(c: c)
                : (!_archivoSeleccionado)
                ? _ConstruirPaso1(c: c, alSeleccionar: _seleccionarArchivo)
                : _ConstruirPaso2(
                    c: c,
                    pin: _pin,
                    errorPin: _errorPin,
                    alTeclear: _teclear,
                    alBorrar: _borrar,
                  ),
          ),
        ),
      ),
    );
  }
}

class _ConstruirPaso1 extends StatelessWidget {
  const _ConstruirPaso1({required this.c, required this.alSeleccionar});
  final ColoresAnaquel c;
  final VoidCallback alSeleccionar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: c.azul.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(Icons.description_outlined, size: 48, color: c.azul),
          ),
          const SizedBox(height: 32),
          Text(
            'Selecciona tu archivo de respaldo .sqlite',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: c.tinta,
              letterSpacing: -0.5,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'El archivo será verificado antes de modificar este dispositivo.',
            style: TextStyle(fontSize: 16, color: c.tinta2, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: alSeleccionar,
            style: ElevatedButton.styleFrom(
              backgroundColor: c.azul,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Explorar Archivos del iPad',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConstruirPaso2 extends StatelessWidget {
  const _ConstruirPaso2({
    required this.c,
    required this.pin,
    required this.errorPin,
    required this.alTeclear,
    required this.alBorrar,
  });
  final ColoresAnaquel c;
  final String pin;
  final bool errorPin;
  final void Function(String) alTeclear;
  final VoidCallback alBorrar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Desencriptar Respaldo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: c.tinta,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ingresa el PIN Maestro original para desencriptar',
                style: TextStyle(fontSize: 16, color: c.tinta2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              CampoPin(longitud: 6, valor: pin, conError: errorPin),
              const SizedBox(height: 24),
              if (errorPin)
                Text(
                  'PIN incorrecto',
                  style: TextStyle(
                    color: c.alerta,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        TecladoNumerico(alPresionarTecla: alTeclear, alBorrar: alBorrar),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _ConstruirEstadoRestaurando extends StatelessWidget {
  const _ConstruirEstadoRestaurando({required this.c});
  final ColoresAnaquel c;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CargadorNexo(tamano: 40),
        const SizedBox(height: 48),
        Text(
          'Restaurando servidor...',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: c.tinta,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Por favor no cierres la aplicación',
          style: TextStyle(fontSize: 16, color: c.tinta2),
        ),
      ],
    );
  }
}
