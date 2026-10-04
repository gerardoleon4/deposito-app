import 'package:flutter/material.dart';
import '../../../../app/tema/colores.dart';

class ModalAltaEmpleado extends StatefulWidget {
  const ModalAltaEmpleado({super.key, required this.alGuardar});

  final void Function(String nombre, String rol, String pin) alGuardar;

  @override
  State<ModalAltaEmpleado> createState() => _ModalAltaEmpleadoState();
}

class _ModalAltaEmpleadoState extends State<ModalAltaEmpleado> {
  final _nombreCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  String _rol = 'Cajero';
  bool _errorFormulario = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    final nombre = _nombreCtrl.text.trim();
    final pin = _pinCtrl.text.trim();

    if (nombre.isEmpty || pin.length < 4) {
      setState(() => _errorFormulario = true);
      return;
    }

    Navigator.pop(context);
    widget.alGuardar(nombre, _rol, pin);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: c.superficie,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Alta de Empleado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: c.tinta,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Nombre
            Text(
              'Nombre o apodo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: c.tinta,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nombreCtrl,
              decoration: InputDecoration(
                filled: true,
                fillColor: c.fondo,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _errorFormulario && _nombreCtrl.text.trim().isEmpty
                        ? c.alerta
                        : c.linea,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _errorFormulario && _nombreCtrl.text.trim().isEmpty
                        ? c.alerta
                        : c.linea,
                  ),
                ),
              ),
              onChanged: (_) => setState(() => _errorFormulario = false),
            ),
            const SizedBox(height: 16),

            // Dropdown Rol
            Text(
              'Rol',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: c.tinta,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: c.fondo,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.linea),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _rol,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: c.tinta2,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Cajero', child: Text('Cajero')),
                    DropdownMenuItem(value: 'Gerente', child: Text('Gerente')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _rol = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // PIN Oculto nativo
            Text(
              'Crear PIN',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: c.tinta,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pinCtrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: InputDecoration(
                hintText: '4 dígitos numéricos',
                hintStyle: TextStyle(color: c.tinta2.withValues(alpha: 0.5)),
                counterText: '',
                filled: true,
                fillColor: c.fondo,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _errorFormulario && _pinCtrl.text.length < 4
                        ? c.alerta
                        : c.linea,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _errorFormulario && _pinCtrl.text.length < 4
                        ? c.alerta
                        : c.linea,
                  ),
                ),
              ),
              onChanged: (_) => setState(() => _errorFormulario = false),
            ),

            if (_errorFormulario)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Por favor completa todos los campos correctamente.',
                  style: TextStyle(color: c.alerta, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _guardar,
              style: ElevatedButton.styleFrom(
                backgroundColor: c.azul,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Guardar Empleado',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
