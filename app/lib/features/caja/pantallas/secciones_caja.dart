import 'package:flutter/material.dart';

import '../../ajustes/ajustes.dart';
import '../../catalogo/pantallas/pantalla_catalogo.dart';
import '../../proximamente/proximamente.dart';
import '../../pdv/pantallas/punto_venta.dart';
import 'inicio_caja.dart';

/// Secciones de la caja, en el orden del menú. Las que no están construidas
/// muestran en qué sprint llegan y quién las hace (docs/PLAN_DE_TRABAJO.md).
class SeccionCaja {
  const SeccionCaja(
    this.ruta,
    this.titulo,
    this.icono,
    this.iconoActivo,
    this.construir,
  );

  final String ruta;
  final String titulo;
  final IconData icono;
  final IconData iconoActivo;
  final Widget Function() construir;
}

final seccionesCaja = <SeccionCaja>[
  SeccionCaja(
    'inicio',
    'Inicio',
    Icons.home_outlined,
    Icons.home_rounded,
    InicioCaja.new,
  ),
  SeccionCaja(
    'vender',
    'Vender',
    Icons.shopping_cart_outlined,
    Icons.shopping_cart_rounded,
    PuntoVenta.new,
  ),
  SeccionCaja(
    'ventas',
    'Ventas',
    Icons.receipt_long_outlined,
    Icons.receipt_long_rounded,
    () => const Proximamente(
      icono: Icons.receipt_long_outlined,
      titulo: 'Ventas',
      descripcion: 'Historial del turno, tickets en PDF y cancelaciones.',
      sprint: 3,
      responsable: 'Daniel',
    ),
  ),
  SeccionCaja(
    'catalogo',
    'Catálogo',
    Icons.grid_view_outlined,
    Icons.grid_view_rounded,
    PantallaCatalogo.new,
  ),
  SeccionCaja(
    'envases',
    'Envases',
    Icons.liquor_outlined,
    Icons.liquor_rounded,
    () => const Proximamente(
      icono: Icons.liquor_outlined,
      titulo: 'Envases',
      descripcion:
          'Existencias por formato, préstamos a clientes y devoluciones.',
      sprint: 2,
      responsable: 'Luis',
    ),
  ),
  SeccionCaja(
    'corte',
    'Corte de caja',
    Icons.point_of_sale_outlined,
    Icons.point_of_sale_rounded,
    () => const Proximamente(
      icono: Icons.point_of_sale_outlined,
      titulo: 'Corte de caja',
      descripcion: 'Apertura con fondo, arqueo y cierre del turno con respaldo automático.',
      sprint: 3,
      responsable: 'Daniel',
    ),
  ),
  SeccionCaja(
    'alertas',
    'Alertas',
    Icons.notifications_none_rounded,
    Icons.notifications_rounded,
    () => const Proximamente(
      icono: Icons.notifications_none_rounded,
      titulo: 'Alertas',
      descripcion: 'Productos bajo su mínimo y próximos a caducar. Mientras tanto, el Inicio ya los muestra.',
      sprint: 4,
      responsable: 'Luis',
    ),
  ),
  SeccionCaja(
    'resurtido',
    'Resurtido',
    Icons.local_shipping_outlined,
    Icons.local_shipping_rounded,
    () => const Proximamente(
      icono: Icons.local_shipping_outlined,
      titulo: 'Resurtido',
      descripcion: 'Cuánto comprar según lo vendido, con pedido al proveedor por WhatsApp.',
      sprint: 4,
      responsable: 'Luis',
    ),
  ),
  SeccionCaja(
    'ajustes',
    'Ajustes',
    Icons.settings_outlined,
    Icons.settings_rounded,
    PantallaAjustes.new,
  ),
];

SeccionCaja seccionCaja(String ruta) => seccionesCaja.firstWhere(
  (s) => s.ruta == ruta,
  orElse: () => seccionesCaja.first,
);
