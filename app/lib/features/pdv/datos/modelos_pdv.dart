class Producto {
  final String id;
  final String nombre;
  final double precio;
  final String categoria;
  final int stock;
  final bool tieneVariantes;
  final String? urlImagen;

  Producto(
    this.id,
    this.nombre,
    this.precio,
    this.categoria,
    this.stock, {
    this.tieneVariantes = false,
    this.urlImagen,
  });
}

class ItemCarrito {
  final String id;
  final Producto producto;
  int cantidad;
  final bool esCaja;

  ItemCarrito({
    required this.id,
    required this.producto,
    this.cantidad = 1,
    this.esCaja = false,
  });

  double get subtotal => (producto.precio * (esCaja ? 24 : 1)) * cantidad;
}

// Repositorio de prueba
final List<Producto> productosDemo = [
  Producto('1', 'Modelo Especial', 22.0, 'Cervezas', 50, tieneVariantes: true),
  Producto('2', 'Corona Extra', 20.0, 'Cervezas', 100, tieneVariantes: true),
  Producto('3', 'Victoria', 21.0, 'Cervezas', 30, tieneVariantes: true),
  Producto('4', 'Doritos Nacho', 18.0, 'Botanas', 15),
  Producto('5', 'Cacahuates Japoneses', 15.0, 'Botanas', 20),
  Producto('6', 'Bolsa Hielo 5kg', 35.0, 'Hielo', 10),
];
