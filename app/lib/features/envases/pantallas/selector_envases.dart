import 'package:flutter/material.dart';

import '../../../app/tema/colores.dart';
import '../datos/modelos_envases.dart';

/// Formato (chips) y cantidad con botones grandes [-] [n] [+]. Lo comparten
/// el préstamo y la recepción de vacíos.
class SelectorEnvases extends StatelessWidget {
  const SelectorEnvases({
    super.key,
    required this.formato,
    required this.cantidad,
    required this.alCambiarFormato,
    required this.alCambiarCantidad,
    this.etiquetaCantidad = 'envases',
    this.maximo = 9999,
    this.formatoFijo = false,
  });

  final FormatoEnvase formato;
  final int cantidad;
  final ValueChanged<FormatoEnvase> alCambiarFormato;
  final ValueChanged<int> alCambiarCantidad;
  final String etiquetaCantidad;

  /// Tope de la cantidad (por ejemplo, lo pendiente de un préstamo).
  final int maximo;

  /// El formato ya está decidido: no se muestran los chips.
  final bool formatoFijo;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!formatoFijo) ...[
          Text(
            'Formato de envase',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: c.tinta,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final f in FormatoEnvase.values)
                ChoiceChip(
                  selected: formato == f,
                  showCheckmark: false,
                  avatar: Icon(
                    f.icono,
                    size: 18,
                    color: formato == f ? Colors.white : c.azul,
                  ),
                  label: Text(
                    f.etiqueta,
                    style: TextStyle(
                      fontWeight: formato == f
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: formato == f ? Colors.white : c.tinta,
                      fontSize: 14,
                    ),
                  ),
                  selectedColor: c.azul,
                  backgroundColor: c.superficie2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: formato == f ? Colors.transparent : c.linea,
                    ),
                  ),
                  onSelected: (sel) {
                    if (sel) alCambiarFormato(f);
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: c.superficie2,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.linea),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BotonCantidad(
                icono: Icons.remove_rounded,
                principal: false,
                alTocar: cantidad > 1
                    ? () => alCambiarCantidad(cantidad - 1)
                    : null,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$cantidad',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: c.tinta,
                      height: 1.0,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    etiquetaCantidad,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: c.tinta2,
                    ),
                  ),
                ],
              ),
              _BotonCantidad(
                icono: Icons.add_rounded,
                principal: true,
                alTocar: cantidad < maximo
                    ? () => alCambiarCantidad(cantidad + 1)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BotonCantidad extends StatelessWidget {
  const _BotonCantidad({
    required this.icono,
    required this.principal,
    required this.alTocar,
  });

  final IconData icono;
  final bool principal;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final activo = alTocar != null;
    return Material(
      color: principal ? c.azul : c.superficie,
      borderRadius: BorderRadius.circular(16),
      elevation: activo ? (principal ? 2 : 1) : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: alTocar,
        child: SizedBox(
          width: 64,
          height: 64,
          child: Icon(
            icono,
            size: 36,
            color: principal ? Colors.white : (activo ? c.tinta : c.linea),
          ),
        ),
      ),
    );
  }
}
