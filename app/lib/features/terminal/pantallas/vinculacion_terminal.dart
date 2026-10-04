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
  bool _detectado = false;

  @override
  void dispose() {
    _ipCtrl.dispose();
    super.dispose();
  }

  void _simularConexionExitosa() {
    setState(() => _detectado = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
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
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo oscurecido (simulando cámara apuntando a estantes)
          Container(
            color: Colors.black87,
            child: Opacity(
              opacity: 0.3,
              child: Image.network(
                'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?q=80&w=1000&auto=format&fit=crop',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header blanco
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
                        iconSize: 20,
                      ),
                      const Expanded(
                        child: Text(
                          'Vincular Terminal',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 40), // Balancear el header
                    ],
                  ),
                ),
                
                // Zona del escáner
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            // Simulando los corchetes en las esquinas con un Stack o Border modificado.
                            // Para simplificar y hacerlo idéntico sin un CustomPainter complejo, usaré un Stack con las 4 esquinas.
                          ),
                          child: Stack(
                            children: [
                              _EsquinaBrackets(esquina: 0, color: c.azul), // Arriba-Izquierda
                              _EsquinaBrackets(esquina: 1, color: c.azul), // Arriba-Derecha
                              _EsquinaBrackets(esquina: 2, color: c.azul), // Abajo-Derecha
                              _EsquinaBrackets(esquina: 3, color: c.azul), // Abajo-Izquierda
                              
                              if (_detectado)
                                Center(
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: c.azul,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _detectado ? 'Código detectado' : '',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Sheet blanco
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    children: [
                      // Indicador de pasos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _PasoIndicador(activo: true, c: c),
                          const SizedBox(width: 8),
                          _PasoIndicador(activo: true, c: c),
                          const SizedBox(width: 8),
                          _PasoIndicador(activo: false, c: c),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Icon(Icons.qr_code_2_rounded, size: 40, color: c.azul),
                      const SizedBox(height: 16),
                      const Text(
                        'Escanea el código QR',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'En el Servidor Host, ve a Configuración > Emparejar\nTerminal.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
                      ),
                      const SizedBox(height: 32),
                      
                      if (_mostrandoInputManual) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _ipCtrl,
                                decoration: InputDecoration(
                                  hintText: 'Ej. 192.168.1.100',
                                  filled: true,
                                  fillColor: c.fondo,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                      ] else ...[
                        TextButton(
                          onPressed: () => setState(() => _mostrandoInputManual = true),
                          child: Text('Ingresar IP manualmente', style: TextStyle(color: c.azul, fontWeight: FontWeight.w600, fontSize: 14)),
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                      // Botón oculto para simular en el prototipo
                      GestureDetector(
                        onTap: _simularConexionExitosa,
                        child: const Text(
                          'Desarrollado por Equipo Umizommi',
                          style: TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
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

class _PasoIndicador extends StatelessWidget {
  final bool activo;
  final ColoresAnaquel c;
  const _PasoIndicador({required this.activo, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: activo ? c.azul : Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _EsquinaBrackets extends StatelessWidget {
  final int esquina;
  final Color color;
  const _EsquinaBrackets({required this.esquina, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: (esquina == 0 || esquina == 1) ? 0 : null,
      bottom: (esquina == 2 || esquina == 3) ? 0 : null,
      left: (esquina == 0 || esquina == 3) ? 0 : null,
      right: (esquina == 1 || esquina == 2) ? 0 : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: (esquina == 0 || esquina == 1) ? BorderSide(color: color, width: 4) : BorderSide.none,
            bottom: (esquina == 2 || esquina == 3) ? BorderSide(color: color, width: 4) : BorderSide.none,
            left: (esquina == 0 || esquina == 3) ? BorderSide(color: color, width: 4) : BorderSide.none,
            right: (esquina == 1 || esquina == 2) ? BorderSide(color: color, width: 4) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: esquina == 0 ? const Radius.circular(12) : Radius.zero,
            topRight: esquina == 1 ? const Radius.circular(12) : Radius.zero,
            bottomRight: esquina == 2 ? const Radius.circular(12) : Radius.zero,
            bottomLeft: esquina == 3 ? const Radius.circular(12) : Radius.zero,
          ),
        ),
      ),
    );
  }
}
