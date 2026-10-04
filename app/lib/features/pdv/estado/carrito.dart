import 'dart:math';

import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Un renglón del carrito: piezas sueltas o cajas completas de un producto.
class ItemCarrito {
  const ItemCarrito({
    required this.producto,
    required this.porCaja,
    required this.cantidad,
  });

  final Producto producto;
  final bool porCaja;
  final int cantidad;

  String get clave => '${producto.id}_${porCaja ? 'caja' : 'pieza'}';

  /// Centavos por pieza o por caja.
  int get precioUnitario => porCaja ? producto.precioCaja! : producto.precio;

  int get subtotal => precioUnitario * cantidad;

  int get piezas => porCaja ? producto.piezasPorCaja! * cantidad : cantidad;

  LineaVenta get linea =>
      LineaVenta(productoId: producto.id, porCaja: porCaja, cantidad: cantidad);

  ItemCarrito conCantidad(int n) =>
      ItemCarrito(producto: producto, porCaja: porCaja, cantidad: n);
}

class Carrito {
  const Carrito(this.items, this.claveCobro);

  final List<ItemCarrito> items;

  /// `X-Clave-Idempotencia` del cobro. Cambia cada vez que cambia el carrito:
  /// reintentar el mismo carrito no cobra dos veces, y uno distinto sí cobra.
  final String claveCobro;

  bool get vacio => items.isEmpty;

  /// Centavos.
  int get total => items.fold(0, (t, i) => t + i.subtotal);

  int get articulos => items.fold(0, (t, i) => t + i.cantidad);

  int piezasDe(String productoId) => items
      .where((i) => i.producto.id == productoId)
      .fold(0, (t, i) => t + i.piezas);

  List<LineaVenta> get lineas => [for (final i in items) i.linea];
}

final carritoProvider = NotifierProvider<CarritoNotifier, Carrito>(
  CarritoNotifier.new,
);

class CarritoNotifier extends Notifier<Carrito> {
  @override
  Carrito build() => Carrito(const [], _nuevaClave());

  /// Agrega uno. Regresa el motivo si no alcanza la existencia.
  String? agregar(Producto p, {bool porCaja = false}) {
    final actual = state.items.where(
      (i) => i.producto.id == p.id && i.porCaja == porCaja,
    );
    return cambiarCantidad(
      ItemCarrito(producto: p, porCaja: porCaja, cantidad: 0),
      (actual.isEmpty ? 0 : actual.first.cantidad) + 1,
    );
  }

  /// Pone [cantidad] en el renglón de [item]; `0` lo quita. Regresa el
  /// motivo si no alcanza la existencia.
  String? cambiarCantidad(ItemCarrito item, int cantidad) {
    final otros = state.items.where((i) => i.clave != item.clave).toList();
    if (cantidad > 0) {
      final nuevo = item.conCantidad(cantidad);
      final piezas =
          nuevo.piezas +
          otros
              .where((i) => i.producto.id == item.producto.id)
              .fold(0, (t, i) => t + i.piezas);
      if (piezas > item.producto.existenciaPiezas) {
        return item.producto.existenciaPiezas == 0
            ? 'No hay ${item.producto.nombre} en existencia'
            : 'Solo hay ${item.producto.existenciaPiezas} piezas de '
                  '${item.producto.nombre}';
      }
      final i = state.items.indexWhere((x) => x.clave == item.clave);
      final items = [...state.items];
      if (i < 0) {
        items.add(nuevo);
      } else {
        items[i] = nuevo;
      }
      state = Carrito(items, _nuevaClave());
    } else {
      state = Carrito(otros, _nuevaClave());
    }
    return null;
  }

  void vaciar() => state = Carrito(const [], _nuevaClave());
}

final _aleatorio = Random.secure();

String _nuevaClave() => [
  for (var i = 0; i < 4; i++)
    _aleatorio.nextInt(1 << 32).toRadixString(36).padLeft(7, '0'),
].join('-');
