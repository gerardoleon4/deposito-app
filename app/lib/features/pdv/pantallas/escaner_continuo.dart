import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EscanerContinuo extends StatefulWidget {
  const EscanerContinuo({super.key, required this.alEscanear});
  final void Function(String idProducto) alEscanear;

  @override
  State<EscanerContinuo> createState() => _EscanerContinuoState();
}

class _EscanerContinuoState extends State<EscanerContinuo> {
  void _simularEscaneoExitoso() {
    HapticFeedback.vibrate();

    // Mostrar Toast flotante verde sin bloquear
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'Agregado: Modelo Especial',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 100, left: 24, right: 24),
        dismissDirection: DismissDirection.up,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    widget.alEscanear('1'); // Pasa el ID de Modelo Especial Demo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo simulando cámara
          Container(
            color: Colors.grey[900],
            child: const Center(
              child: Text(
                'Cámara Activa',
                style: TextStyle(color: Colors.white54, fontSize: 24),
              ),
            ),
          ),

          // Retícula central
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned(top: 0, left: 0, child: _Esquina(0)),
                  Positioned(top: 0, right: 0, child: _Esquina(1)),
                  Positioned(bottom: 0, right: 0, child: _Esquina(2)),
                  Positioned(bottom: 0, left: 0, child: _Esquina(3)),
                ],
              ),
            ),
          ),

          // Botón Cerrar Superior
          Positioned(
            top: 48,
            left: 24,
            child: SafeArea(
              child: FloatingActionButton.extended(
                onPressed: () => Navigator.pop(context),
                backgroundColor: Colors.black.withValues(alpha: 0.6),
                foregroundColor: Colors.white,
                elevation: 0,
                icon: const Icon(Icons.close_rounded),
                label: const Text('Cerrar'),
              ),
            ),
          ),

          // Botón Simular Escaneo
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _simularEscaneoExitoso,
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Simular Escaneo (Prueba)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Esquina extends StatelessWidget {
  final int index;
  const _Esquina(this.index);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: (index == 0 || index == 1)
              ? const BorderSide(color: Colors.greenAccent, width: 4)
              : BorderSide.none,
          bottom: (index == 2 || index == 3)
              ? const BorderSide(color: Colors.greenAccent, width: 4)
              : BorderSide.none,
          left: (index == 0 || index == 3)
              ? const BorderSide(color: Colors.greenAccent, width: 4)
              : BorderSide.none,
          right: (index == 1 || index == 2)
              ? const BorderSide(color: Colors.greenAccent, width: 4)
              : BorderSide.none,
        ),
      ),
    );
  }
}
