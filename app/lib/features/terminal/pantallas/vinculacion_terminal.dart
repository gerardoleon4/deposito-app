import 'dart:async';
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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Iniciar timer de 5 segundos para simular escaneo exitoso
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_mostrandoInputManual) {
        _simularConexionExitosa();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
          // Fondo oscurecido
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
                      const SizedBox(width: 40),
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
                          decoration: const BoxDecoration(),
                          child: Stack(
                            children: [
                              _EsquinaBrackets(esquina: 0, color: c.azul),
                              _EsquinaBrackets(esquina: 1, color: c.azul),
                              _EsquinaBrackets(esquina: 2, color: c.azul),
                              _EsquinaBrackets(esquina: 3, color: c.azul),
                              
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
                      
                      if (_mostrandoInputManual) ...[
                        // ESTADO: CONEXIÓN MANUAL
                        const Text(
                          'Conexión manual',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Escribe la dirección IP que aparece en el Servidor Host.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 24),
                        
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Dirección IP',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _ipCtrl,
                                decoration: InputDecoration(
                                  hintText: '192.168.1.100',
                                  hintStyle: const TextStyle(color: Colors.black38),
                                  filled: false,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: c.azul, width: 2),
                                  ),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(color: Colors.black87, fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                onPressed: _simularConexionExitosa,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6), // Azul vibrante del botón
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Conectar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () => setState(() => _mostrandoInputManual = false),
                          child: const Text('Volver al escáner', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ] else ...[
                        // ESTADO: ESCÁNER QR
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
                        TextButton(
                          onPressed: () {
                            _timer?.cancel();
                            setState(() => _mostrandoInputManual = true);
                          },
                          child: const Text('Ingresar IP manualmente', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w600, fontSize: 14)),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      const Text(
                        'Desarrollado por Equipo Umizommi',
                        style: TextStyle(color: Colors.black45, fontSize: 14, fontWeight: FontWeight.w500),
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
