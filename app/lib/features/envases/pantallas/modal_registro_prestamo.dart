import 'package:flutter/material.dart';

import '../../../app/tema/colores.dart';
import '../datos/modelos_envases.dart';
import 'selector_envases.dart';

/// Datos de un préstamo nuevo.
typedef NuevoPrestamo = ({String cliente, FormatoEnvase formato, int cantidad});

/// Registro de préstamo de envases (fiado) a un cliente.
class ModalRegistroPrestamo extends StatefulWidget {
  const ModalRegistroPrestamo({super.key});

  /// Regresa el préstamo a registrar, o `null` si se cerró sin guardar.
  static Future<NuevoPrestamo?> mostrar(BuildContext context) => showDialog(
    context: context,
    builder: (_) => const ModalRegistroPrestamo(),
  );

  @override
  State<ModalRegistroPrestamo> createState() => _ModalRegistroPrestamoState();
}

class _ModalRegistroPrestamoState extends State<ModalRegistroPrestamo> {
  final _nombre = TextEditingController();
  var _formato = FormatoEnvase.media;
  var _cantidad = 1;

  /// El contrato pide de 1 a 80 caracteres.
  bool get _nombreValido {
    final n = _nombre.text.trim().length;
    return n >= 1 && n <= 80;
  }

  @override
  void initState() {
    super.initState();
    _nombre.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_nombreValido) return;
    Navigator.pop<NuevoPrestamo>(context, (
      cliente: _nombre.text.trim(),
      formato: _formato,
      cantidad: _cantidad,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: c.lagerSuave,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.handshake_outlined,
                          color: c.lagerTinta,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prestar envases',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: c.tinta,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Se los lleva sin pagar depósito y los regresa después',
                              style: TextStyle(fontSize: 13, color: c.tinta2),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Cerrar',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        color: c.tinta2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Nombre o apodo del cliente',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: c.tinta,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nombre,
                    autofocus: true,
                    maxLength: 80,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _guardar(),
                    decoration: InputDecoration(
                      hintText: 'Ej. Don Pedro, Taquería El Pastor…',
                      counterText: '',
                      filled: true,
                      fillColor: c.superficie2,
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        color: c.tinta2,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: c.linea),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: c.azul, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SelectorEnvases(
                    formato: _formato,
                    cantidad: _cantidad,
                    etiquetaCantidad: _cantidad == 1
                        ? 'envase prestado'
                        : 'envases prestados',
                    alCambiarFormato: (f) => setState(() => _formato = f),
                    alCambiarCantidad: (n) => setState(() => _cantidad = n),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: _nombreValido ? _guardar : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: c.azul,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 22),
                      label: const Text(
                        'Guardar préstamo',
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
