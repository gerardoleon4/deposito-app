import 'package:deposito_backend/deposito_backend.dart';

import 'api.dart';

/// Datos de prueba con la forma exacta del contrato. Sirve para pruebas de
/// widgets y para programar pantallas antes de que exista su endpoint.
class ApiFalsa implements Api {
  ApiFalsa({List<Producto>? productos, List<Terminal>? terminales})
    : productos = productos ?? productosDePrueba(),
      terminales = terminales ?? [];

  final List<Producto> productos;
  final List<Terminal> terminales;

  @override
  Uri get base => Uri.parse('http://127.0.0.1:8080');

  @override
  String get clave => 'clave-falsa';

  @override
  Future<List<Producto>> listarProductos() async => List.of(productos);

  @override
  Future<Producto> crearProducto(Map<String, Object?> datos) async {
    final p = Producto.fromJson({
      'id': 'p_${productos.length + 1}',
      'existenciaPiezas': 0,
      'minimo': 0,
      'creado': '2026-10-02T18:30:00Z',
      'actualizado': '2026-10-02T18:30:00Z',
      ...datos,
    });
    productos.add(p);
    return p;
  }

  @override
  Future<CodigoEmparejamiento> crearCodigoEmparejamiento() async =>
      CodigoEmparejamiento(
        codigo: '482913',
        expira: instanteIso(DateTime.now().add(const Duration(minutes: 10))),
      );

  @override
  Future<List<Terminal>> listarTerminales() async => List.of(terminales);

  @override
  Future<void> revocarTerminal(String id) async =>
      terminales.removeWhere((t) => t.id == id);
}

List<Producto> productosDePrueba() {
  Producto p(
    String id,
    String codigo,
    String nombre,
    String categoria,
    String presentacion,
    int precio,
    int existencia,
    int minimo, {
    int? precioCaja,
    int? piezasPorCaja,
    String? envase,
    String? caducidad,
  }) => Producto(
    id: id,
    codigo: codigo,
    nombre: nombre,
    categoria: categoria,
    presentacion: presentacion,
    precio: precio,
    precioCaja: precioCaja,
    piezasPorCaja: piezasPorCaja,
    existenciaPiezas: existencia,
    minimo: minimo,
    envase: envase,
    caducidad: caducidad,
    creado: '2026-10-02T18:30:00Z',
    actualizado: '2026-10-02T18:30:00Z',
  );

  return [
    p(
      'p_1',
      '7501064191015',
      'Victoria Mega',
      'cerveza',
      'Mega 1.2 L',
      4200,
      66,
      36,
      precioCaja: 48000,
      piezasPorCaja: 12,
      envase: 'mega',
      caducidad: '2027-01-29',
    ),
    p(
      'p_2',
      '7501064191022',
      'Corona Mega',
      'cerveza',
      'Mega 1.2 L',
      4400,
      30,
      36,
      precioCaja: 50000,
      piezasPorCaja: 12,
      envase: 'mega',
      caducidad: '2027-01-04',
    ),
    p(
      'p_3',
      '7501064191046',
      'Corona Cuarto',
      'cerveza',
      'Cuarto 210 ml',
      1700,
      200,
      48,
      precioCaja: 38000,
      piezasPorCaja: 24,
      envase: 'cuarto',
      caducidad: '2026-10-21',
    ),
    p(
      'p_4',
      '7502000000017',
      'Hielo en bolsa',
      'hielo',
      'Bolsa 5 kg',
      3500,
      18,
      10,
    ),
    p(
      'p_5',
      '7502000000024',
      'Coca-Cola',
      'refresco',
      'Botella 600 ml',
      2200,
      40,
      24,
      caducidad: '2027-02-28',
    ),
    p(
      'p_6',
      '7502000000048',
      'Papas adobadas',
      'botana',
      'Bolsa 45 g',
      2000,
      25,
      20,
      caducidad: '2026-10-13',
    ),
  ];
}
