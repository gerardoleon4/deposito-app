import 'package:flutter/material.dart';
import '../../../../app/tema/colores.dart';
import '../../auth/pantallas/login_diario.dart';

class VinculacionTerminal extends StatefulWidget {
  const VinculacionTerminal({super.key});

  @override
  State<VinculacionTerminal> createState() => _VinculacionTerminalState();
}

class _VinculacionTerminalState extends State<VinculacionTerminal> {
  bool _mostrandoInputManual = false;
  final _ipCtrl = TextEditingController();

  @override
  void dispose() {
    _ipCtrl.dispose();
    super.dispose();
  }

  void _simularConexionExitosa() {
    // Muestra carga y luego va al Login
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Cierra dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginDiario()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo simulando cámara
          Container(
            color: Colors.grey[900],
            child: const Center(
              child: Text('Cámara Activa\n(Buscando QR...)', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 18)),
            ),
          ),
          
          // Capa oscura semi-transparente con agujero (simulada)
          Container(color: Colors.black.withValues(alpha: 0.5)),
          
          SafeArea(
            child: Column(
              children: [
                // AppBar transparente
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        iconSize: 28,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Vincular Terminal',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Apunta la cámara al código QR que muestra el Servidor Host (Caja Principal).',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 48),
                
                // Marco del QR
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: c.azul, width: 3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      // Animación de escaneo (simulada con un contenedor semi transparente)
                      AnimatedPositioned(
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOutSine,
                        top: 125, // En un caso real esto se animaría arriba y abajo
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          color: c.azul,
                          boxShadow: [
                            BoxShadow(color: c.azul.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Input manual
                if (_mostrandoInputManual) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ipCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Ej. 192.168.1.100',
                              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: _simularConexionExitosa,
                          icon: const Icon(Icons.arrow_forward_ios_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: c.azul,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  TextButton(
                    onPressed: () => setState(() => _mostrandoInputManual = true),
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: const Text('Ingresar IP Manualmente', style: TextStyle(decoration: TextDecoration.underline)),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Botón de prueba
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: ElevatedButton.icon(
                    onPressed: _simularConexionExitosa,
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: const Text('Simular QR Detectado'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
