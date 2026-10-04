import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/tema/colores.dart';
import '../../../../core/widgets/teclado_numerico.dart';
import '../../caja/pantallas/apertura_caja.dart';
import '../../pdv/pantallas/punto_venta.dart';

class EmpleadoLogin {
  final String id;
  final String nombre;
  final String rol;
  final String pinReal;
  final String avatarUrl;

  EmpleadoLogin(this.id, this.nombre, this.rol, this.pinReal, this.avatarUrl);
}

class LoginDiario extends StatefulWidget {
  const LoginDiario({super.key});

  @override
  State<LoginDiario> createState() => _LoginDiarioState();
}

class _LoginDiarioState extends State<LoginDiario> {
  late Timer _timer;
  DateTime _ahora = DateTime.now();

  final List<EmpleadoLogin> _empleados = [
    EmpleadoLogin('1', 'Ana Martínez', 'Cajera', '1234', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop'),
    EmpleadoLogin('2', 'Carlos Ruiz', 'Cajero', '0000', 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=200&auto=format&fit=crop'),
    EmpleadoLogin('3', 'Sofía Vega', 'Gerente', '1111', 'https://images.unsplash.com/photo-1531123897727-8f129e1bf98c?q=80&w=200&auto=format&fit=crop'),
    EmpleadoLogin('4', 'Diego López', 'Cajero', '2222', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop'),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _ahora = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _abrirNumpad(EmpleadoLogin emp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ModalNumpad(empleado: emp),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hora = DateFormat('HH:mm').format(_ahora);
    
    // Fallback simple si intl no tiene es_MX. Usaremos código propio para asegurar.
    final List<String> dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final List<String> meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    final diaSemana = dias[_ahora.weekday - 1];
    final mes = meses[_ahora.month - 1];
    final fechaStr = '$diaSemana, ${_ahora.day} De $mes';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Header Reloj
            Text(hora, style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w300, color: Colors.black, letterSpacing: -2)),
            const SizedBox(height: 8),
            Text(fechaStr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 32),
            const Text('Selecciona tu usuario para comenzar', style: TextStyle(fontSize: 18, color: Colors.black54)),
            
            const SizedBox(height: 48),
            
            // Grid de Usuarios
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: _empleados.length,
                  itemBuilder: (context, i) {
                    final emp = _empleados[i];
                    return GestureDetector(
                      onTap: () => _abrirNumpad(emp),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 16, offset: const Offset(0, 8))],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.blue[100]!, width: 4),
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(emp.avatarUrl),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(emp.nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                            const SizedBox(height: 4),
                            Text(emp.rol, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.access_time_rounded, color: Colors.black87),
                        label: const Text('Reloj Checador', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.settings_outlined, color: Colors.black87),
                        label: const Text('Ajustes', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Desarrollado por Equipo Umizommi', style: TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModalNumpad extends StatefulWidget {
  final EmpleadoLogin empleado;
  const _ModalNumpad({required this.empleado});

  @override
  State<_ModalNumpad> createState() => _ModalNumpadState();
}

class _ModalNumpadState extends State<_ModalNumpad> {
  String _pin = '';
  bool _error = false;

  void _teclear(String tecla) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += tecla;
      _error = false;
    });

    if (_pin.length == 4) {
      if (_pin == widget.empleado.pinReal) {
        Navigator.pop(context); // Cierra modal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AperturaCaja(
              nombreCajero: widget.empleado.nombre,
              inicialesCajero: widget.empleado.nombre.substring(0,2).toUpperCase(),
              alAbrir: (monto) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const PuntoVenta()),
                );
              },
            ),
          ),
        );
      } else {
        setState(() => _error = true);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _pin = '');
        });
      }
    }
  }

  void _borrar() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 32, backgroundImage: NetworkImage(widget.empleado.avatarUrl)),
            const SizedBox(height: 16),
            Text('Hola, ${widget.empleado.nombre.split(' ')[0]}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 8),
            const Text('Ingresa tu PIN', style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 24),
            
            // Dots PIN
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final activo = i < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _error ? Colors.red : (activo ? Colors.blue : Colors.grey[200]),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            
            if (_error)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('PIN Incorrecto', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
              
            const SizedBox(height: 48),
            
            // Teclado
            SizedBox(
              width: 300,
              child: TecladoNumerico(alPresionarTecla: _teclear, alBorrar: _borrar),
            ),
          ],
        ),
      ),
    );
  }
}
