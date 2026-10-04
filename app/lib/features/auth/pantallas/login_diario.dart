import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/tema/colores.dart';
import '../../../../core/widgets/teclado_numerico.dart';

class EmpleadoLogin {
  final String id;
  final String nombre;
  final String iniciales;
  final String rol;
  final String pinReal; // En la vida real esto estaría encriptado

  EmpleadoLogin(this.id, this.nombre, this.iniciales, this.rol, this.pinReal);
}

class LoginDiario extends StatefulWidget {
  const LoginDiario({super.key});

  @override
  State<LoginDiario> createState() => _LoginDiarioState();
}

class _LoginDiarioState extends State<LoginDiario> {
  late Timer _timer;
  DateTime _ahora = DateTime.now();

  EmpleadoLogin? _empleadoSeleccionado;
  String _pin = '';
  bool _errorPin = false;

  final List<EmpleadoLogin> _empleados = [
    EmpleadoLogin('1', 'Pablo Torres', 'PT', 'Admin (Dueño)', '1234'),
    EmpleadoLogin('2', 'Ana García', 'AG', 'Gerente', '0000'),
    EmpleadoLogin('3', 'Luis Martínez', 'LM', 'Cajero', '1111'),
    EmpleadoLogin('4', 'Sofía López', 'SL', 'Cajero', '2222'),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _ahora = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _seleccionarEmpleado(EmpleadoLogin emp) {
    setState(() {
      _empleadoSeleccionado = emp;
      _pin = '';
      _errorPin = false;
    });
  }

  void _cerrarNumpad() {
    setState(() {
      _empleadoSeleccionado = null;
      _pin = '';
      _errorPin = false;
    });
  }

  void _teclear(String tecla) {
    if (_empleadoSeleccionado == null || _pin.length >= 4) return;

    setState(() {
      _pin += tecla;
      _errorPin = false;
    });

    if (_pin.length == 4) {
      // Auto-validar en milisegundos
      if (_pin == _empleadoSeleccionado!.pinReal) {
        // Correcto -> entrar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bienvenido, ${_empleadoSeleccionado!.nombre}')),
        );
        _cerrarNumpad();
      } else {
        // Incorrecto
        setState(() => _errorPin = true);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _pin = '';
              _errorPin = false;
            });
          }
        });
      }
    }
  }

  void _borrar() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorPin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final formatHora = DateFormat('hh:mm');
    final formatAmPm = DateFormat('a');

    return Scaffold(
      backgroundColor: c.fondo,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 48),
                // Cabecera: Reloj
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formatHora.format(_ahora),
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.w700,
                        color: c.tinta,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatAmPm.format(_ahora),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: c.tinta2,
                      ),
                    ),
                  ],
                ),
                Text(
                  DateFormat('EEEE, d MMMM', 'es').format(_ahora).toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: c.tinta2,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 64),
                
                // Cuadrícula de empleados
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _empleados.length,
                      itemBuilder: (context, index) {
                        final emp = _empleados[index];
                        return _TarjetaEmpleado(
                          empleado: emp,
                          alPresionar: () => _seleccionarEmpleado(emp),
                          c: c,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Overlay Oscuro y Numpad
          if (_empleadoSeleccionado != null) ...[
            GestureDetector(
              onTap: _cerrarNumpad,
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.only(top: 32, bottom: 48, left: 24, right: 24),
                decoration: BoxDecoration(
                  color: c.superficie,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ingresa tu PIN',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: c.tinta2),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _empleadoSeleccionado!.nombre,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: c.tinta),
                      ),
                      const SizedBox(height: 32),
                      
                      // 4 Indicadores circulares (no se usa CampoPin porque es de 4 y sin borde rojo explícito según diseño, pero podemos simularlo)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final lleno = index < _pin.length;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: lleno ? c.azul : Colors.transparent,
                              border: Border.all(
                                color: _errorPin ? c.alerta : (lleno ? c.azul : c.linea),
                                width: 2,
                              ),
                            ),
                          );
                        }),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      SizedBox(
                        width: 320,
                        child: TecladoNumerico(
                          alPresionarTecla: _teclear,
                          alBorrar: _borrar,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class _TarjetaEmpleado extends StatelessWidget {
  const _TarjetaEmpleado({
    required this.empleado,
    required this.alPresionar,
    required this.c,
  });

  final EmpleadoLogin empleado;
  final VoidCallback alPresionar;
  final ColoresAnaquel c;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: alPresionar,
      child: Container(
        decoration: BoxDecoration(
          color: c.superficie,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.linea),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: c.azul.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  empleado.iniciales,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: c.azul),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              empleado.nombre,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: c.tinta),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              empleado.rol,
              style: TextStyle(fontSize: 13, color: c.tinta2),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
