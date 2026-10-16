import 'package:flutter/material.dart';

import '../../../app/tema/colores.dart';
import '../datos/modelos_envases.dart';
import 'selector_envases.dart';

/// Recepción de vacíos sin venta (por ejemplo, los que deja el proveedor).
/// Suben a bodega; no hay cobro ni crédito.
class ModalRecepcionEnvases extends StatefulWidget {
  const ModalRecepcionEnvases({super.key});

  /// Regresa lo que se recibió, o `null` si se cerró sin confirmar.
  static Future<({FormatoEnvase formato, int cantidad})?> mostrar(
    BuildContext context,
  ) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const ModalRecepcionEnvases(),
  );

  @override
  State<ModalRecepcionEnvases> createState() => _ModalRecepcionEnvasesState();
}

class _ModalRecepcionEnvasesState extends State<ModalRecepcionEnvases> {
  var _formato = FormatoEnvase.media;
  var _cantidad = 1;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        14,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: c.linea,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: c.verde.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.recycling_rounded,
                      color: c.verde,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recibir envases vacíos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: c.tinta,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Entran a bodega sin cobro. Los vacíos de un cliente '
                          'que compra se registran al cobrar.',
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
              SelectorEnvases(
                formato: _formato,
                cantidad: _cantidad,
                etiquetaCantidad: _cantidad == 1
                    ? 'envase recibido'
                    : 'envases recibidos',
                alCambiarFormato: (f) => setState(() => _formato = f),
                alCambiarCantidad: (n) => setState(() => _cantidad = n),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context, (
                    formato: _formato,
                    cantidad: _cantidad,
                  )),
                  style: FilledButton.styleFrom(
                    backgroundColor: c.verde,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_downward_rounded, size: 22),
                  label: Text(
                    'Recibir $_cantidad a bodega',
                    style: const TextStyle(
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
    );
  }
}
