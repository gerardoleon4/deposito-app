class Producto {
  final String id;
  final String nombre;
  final double precio;
  final String categoria;
  final int stock;
  final bool tieneVariantes;
  final String? urlImagen;
  final bool esRetornable;
  final double valorEnvase;

  Producto(
    this.id,
    this.nombre,
    this.precio,
    this.categoria,
    this.stock, {
    this.tieneVariantes = false,
    this.urlImagen,
    this.esRetornable = false,
    this.valorEnvase = 5.0,
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
  int get piezasTotales => (esCaja ? 24 : 1) * cantidad;
}

class CreditoEnvase {
  final String id;
  final int cantidad;
  final String formato;
  final double creditoTotal;

  CreditoEnvase({
    required this.id,
    required this.cantidad,
    this.formato = 'Media 355 ml',
    required this.creditoTotal,
  });
}

// Repositorio de prueba
final List<Producto> productosDemo = [
  Producto(
    '1',
    'Modelo Especial',
    22.0,
    'Cervezas',
    50,
    tieneVariantes: true,
    urlImagen: 'assets/productos/modelo_especial.webp',
    esRetornable: true,
    valorEnvase: 5.0,
  ),
  Producto(
    '2',
    'Corona Extra',
    20.0,
    'Cervezas',
    100,
    tieneVariantes: true,
    urlImagen: 'assets/productos/corona_extra.webp',
    esRetornable: true,
    valorEnvase: 5.0,
  ),
  Producto(
    '3',
    'Victoria',
    21.0,
    'Cervezas',
    30,
    tieneVariantes: true,
    urlImagen: 'assets/productos/victoria.webp',
    esRetornable: true,
    valorEnvase: 5.0,
  ),
  Producto(
    '4',
    'Doritos Nacho',
    18.0,
    'Botanas',
    15,
    urlImagen: 'assets/productos/doritos_nacho.webp',
    esRetornable: false,
  ),
  Producto(
    '5',
    'Cacahuates Japoneses',
    15.0,
    'Botanas',
    20,
    urlImagen: 'assets/productos/cacahuates_japoneses.webp',
    esRetornable: false,
  ),
  Producto(
    '6',
    'Bolsa Hielo 5kg',
    35.0,
    'Hielo',
    10,
    urlImagen: 'assets/productos/hielo_5kg.webp',
    esRetornable: false,
  ),
];
