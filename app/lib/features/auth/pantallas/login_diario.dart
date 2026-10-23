import 'dart:async';

import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/tema/colores.dart';
import '../../../../core/api/fallo_api.dart';
import '../../../../core/api/proveedores.dart';
import '../../../../core/widgets/estados.dart';
import '../../../../core/widgets/teclado_numerico.dart';
import '../../personal/estado/personal_provider.dart';

class _Avatar extends StatelessWidget {
  const _Avatar({required this.empleado, required this.radio});

  final Usuario empleado;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return CircleAvatar(
      radius: radio,
      backgroundColor: c.azul.withValues(alpha: 0.12),
      child: Text(
        inicialesDe(empleado.nombre),
        style: TextStyle(
          color: c.azul,
          fontWeight: FontWeight.bold,
          fontSize: radio * 0.7,
        ),
      ),
    );
  }
}

/// Inicio de turno (diseño de Pablo): cada quien elige su nombre y escribe
/// su PIN. Quien entra queda en las ventas y la caja.
class LoginDiario extends StatefulWidget {
  const LoginDiario({
    super.key,
    required this.usuarios,
    required this.alEntrar,
  });

  /// Solo los activos.
  final List<Usuario> usuarios;
  final ValueChanged<Usuario> alEntrar;

  @override
  State<LoginDiario> createState() => _LoginDiarioState();
}

class _LoginDiarioState extends State<LoginDiario> {
  late Timer _timer;
  DateTime _ahora = DateTime.now();

  List<Usuario> get _empleados => widget.usuarios;

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

  Future<void> _abrirNumpad(Usuario emp) async {
    final entro = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ModalNumpad(empleado: emp),
    );
    if (entro == true) widget.alEntrar(emp);
  }

  @override
  Widget build(BuildContext context) {
    final hora = DateFormat('HH:mm').format(_ahora);

    // Fallback simple si intl no tiene es_MX. Usaremos código propio para asegurar.
    final List<String> dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    final List<String> meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
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
            Text(
              hora,
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w300,
                color: Colors.black,
                letterSpacing: -2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              fechaStr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Selecciona tu usuario para comenzar',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),

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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.blue[100]!,
                                  width: 4,
                                ),
                              ),
                              child: _Avatar(empleado: emp, radio: 40),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              emp.nombre,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              etiquetaRol(emp.rol),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
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
                        onPressed: () => avisar(
                          context,
                          'El reloj checador llega en una siguiente versión',
                        ),
                        icon: const Icon(
                          Icons.access_time_rounded,
                          color: Colors.black87,
                        ),
                        label: const Text(
                          'Reloj Checador',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => avisar(
                          context,
                          'Entra con tu PIN para abrir los ajustes',
                        ),
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Colors.black87,
                        ),
                        label: const Text(
                          'Ajustes',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Desarrollado por Equipo Umizommi',
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModalNumpad extends ConsumerStatefulWidget {
  const _ModalNumpad({required this.empleado});

  final Usuario empleado;

  @override
  ConsumerState<_ModalNumpad> createState() => _ModalNumpadState();
}

class _ModalNumpadState extends ConsumerState<_ModalNumpad> {
  static const _maximo = 6;
  String _pin = '';
  bool _error = false;
  String? _mensaje;
  bool _verificando = false;

  void _teclear(String tecla) {
    if (_pin.length >= _maximo || _verificando) return;
    setState(() {
      _pin += tecla;
      _error = false;
      _mensaje = null;
    });
  }

  /// El servidor revisa el PIN; tras cinco errores se bloquea un minuto.
  Future<void> _entrar() async {
    setState(() => _verificando = true);
    try {
      final api = await ref.read(apiProvider.future);
      await api.verificarPin(_pin, usuarioId: widget.empleado.id);
      if (mounted) Navigator.pop(context, true);
    } on FalloApi catch (e) {
      if (!mounted) return;
      setState(() {
        _verificando = false;
        _error = true;
        _mensaje = e.codigo == 'pin_invalido'
            ? 'PIN Incorrecto'
            : mensajeDeError(e);
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _pin = '');
      });
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
            _Avatar(empleado: widget.empleado, radio: 32),
            const SizedBox(height: 16),
            Text(
              'Hola, ${widget.empleado.nombre.split(' ')[0]}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ingresa tu PIN',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),

            // Dots PIN
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_maximo, (i) {
                final activo = i < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _error
                        ? Colors.red
                        : (activo ? Colors.blue : Colors.grey[200]),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),

            if (_error)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _mensaje ?? 'PIN Incorrecto',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 48),

            // Teclado
            SizedBox(
              width: 300,
              child: TecladoNumerico(
                alPresionarTecla: _teclear,
                alBorrar: _borrar,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 300,
              height: 52,
              child: FilledButton(
                onPressed: _pin.length >= 4 && !_verificando ? _entrar : null,
                child: const Text(
                  'Entrar',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
