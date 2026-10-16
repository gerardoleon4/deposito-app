import 'package:flutter/material.dart';
import '../../../../app/tema/colores.dart';
import '../datos/modelos_envases.dart';

/// 5.4 Modal de Registro de Préstamo (Fiao)
/// Formulario modal centrado para registrar el préstamo de envases al cliente.
class ModalRegistroPrestamo extends StatefulWidget {
  const ModalRegistroPrestamo({
    super.key,
    required this.cantidadEnvases,
    this.formato = TipoFormatoEnvase.media,
    required this.alGuardar,
  });

  final int cantidadEnvases;
  final TipoFormatoEnvase formato;
  final void Function(String cliente, String? telefono) alGuardar;

  static Future<bool?> mostrar({
    required BuildContext context,
    required int cantidadEnvases,
    TipoFormatoEnvase formato = TipoFormatoEnvase.media,
    required void Function(String cliente, String? telefono) alGuardar,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ModalRegistroPrestamo(
        cantidadEnvases: cantidadEnvases,
        formato: formato,
        alGuardar: alGuardar,
      ),
    );
  }

  @override
  State<ModalRegistroPrestamo> createState() => _ModalRegistroPrestamoState();
}

class _ModalRegistroPrestamoState extends State<ModalRegistroPrestamo> {
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  bool _nombreValido = false;
  bool _intentoGuardar = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl.addListener(() {
      final valido = _nombreCtrl.text.trim().isNotEmpty;
      if (valido != _nombreValido) {
        setState(() => _nombreValido = valido);
      }
    });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    setState(() => _intentoGuardar = true);
    if (!_nombreValido) return;

    Navigator.pop(context, true);
    widget.alGuardar(
      _nombreCtrl.text.trim(),
      _telefonoCtrl.text.trim().isEmpty ? null : _telefonoCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final mostrarError = _intentoGuardar && !_nombreValido;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            decoration: BoxDecoration(
              color: c.superficie,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cabecera con icono
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.handshake_outlined,
                          color: Color(0xFFD97706),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Registro de Préstamo',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: c.tinta,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Fiado / Envases pendientes de devolver',
                              style: TextStyle(fontSize: 13, color: c.tinta2),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        color: c.tinta2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Resumen del préstamo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: c.superficie2,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: c.linea),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: c.azul,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Préstamo de ${widget.cantidadEnvases} envases (${widget.formato.etiqueta}) asociado a esta compra.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: c.tinta,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Input Nombre o Apodo
                  Text(
                    'Nombre o Apodo del Cliente *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: mostrarError ? c.alerta : c.tinta,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nombreCtrl,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Ej. Don Pedro, Compadre Juan, Taquería...',
                      filled: true,
                      fillColor: mostrarError ? c.alertaSuave : c.superficie2,
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        color: mostrarError ? c.alerta : c.tinta2,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: mostrarError ? c.alerta : c.linea,
                          width: mostrarError ? 1.5 : 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: mostrarError ? c.alerta : c.azul,
                          width: 2.0,
                        ),
                      ),
                      errorText: mostrarError
                          ? 'Ingresa el nombre para guardar el préstamo'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Input Teléfono (opcional)
                  Text(
                    'Teléfono o WhatsApp (opcional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.tinta,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _telefonoCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Ej. 55 1234 5678',
                      filled: true,
                      fillColor: c.superficie2,
                      prefixIcon: Icon(Icons.phone_outlined, color: c.tinta2),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: c.linea),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: c.azul, width: 2.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Botón Acción: "Guardar Préstamo"
                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _nombreValido ? _guardar : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.azul,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: c.linea,
                        disabledForegroundColor: c.tinta2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.check_rounded, size: 22),
                      label: const Text(
                        'Guardar Préstamo',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
