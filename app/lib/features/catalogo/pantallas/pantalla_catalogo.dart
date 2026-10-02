import 'package:flutter/material.dart';

import 'formulario_producto.dart';
import 'vista_catalogo.dart';

/// Catálogo de la caja: el mismo de la terminal, más el alta de productos.
class PantallaCatalogo extends StatelessWidget {
  const PantallaCatalogo({super.key});

  @override
  Widget build(BuildContext context) => VistaCatalogo(
    acciones: [
      FilledButton.icon(
        onPressed: () => abrirFormularioProducto(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo producto'),
        style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
      ),
    ],
  );
}
