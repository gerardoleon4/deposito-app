import 'dart:typed_data';

import 'package:deposito_backend/deposito_backend.dart';

import 'api.dart';
import 'fallo_api.dart';

/// Datos de prueba con la forma exacta del contrato. Sirve para pruebas de
/// widgets y para programar pantallas antes de que exista su endpoint.
class ApiFalsa implements Api {
  ApiFalsa({
    List<Producto>? productos,
    List<Terminal>? terminales,
    Map<String, BalanceEnvase>? envases,
    List<PrestamoEnvase>? prestamos,
  }) : productos = productos ?? productosDePrueba(),
       terminales = terminales ?? [],
       envases = envases ?? balanceDePrueba(),
       prestamos = prestamos ?? [];

  final List<Producto> productos;
  final List<Terminal> terminales;
  final Map<String, BalanceEnvase> envases;
  final List<PrestamoEnvase> prestamos;

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

  /// Movimientos registrados por las operaciones de esta API falsa.
  final movimientos = <String, List<Movimiento>>{};

  @override
  Future<Producto?> buscarPorCodigo(String codigo) async =>
      productos.where((p) => p.codigo == codigo).firstOrNull;

  @override
  Future<Producto> editarProducto(String id, Map<String, Object?> datos) async {
    final p = _producto(id);
    return _reemplazar({
      ...p.toJson(),
      ...datos,
      'id': id,
      'existenciaPiezas': p.existenciaPiezas,
      'foto': p.foto,
    });
  }

  @override
  Future<void> eliminarProducto(String id) async {
    _producto(id);
    productos.removeWhere((p) => p.id == id);
  }

  @override
  Future<Producto> registrarEntrada(
    String id, {
    int cajas = 0,
    int piezas = 0,
    String? caducidad,
    String? nota,
  }) async {
    final p = _producto(id);
    final total = cajas * (p.piezasPorCaja ?? 0) + piezas;
    if (total <= 0) {
      throw const FalloApi(
        'datos_invalidos',
        'Revisa los campos marcados',
        campos: {'piezas': 'La entrada debe tener al menos una pieza'},
        estado: 400,
      );
    }
    final antes = p.caducidad;
    final usarNueva =
        caducidad != null &&
        (p.existenciaPiezas == 0 ||
            antes == null ||
            caducidad.compareTo(antes) < 0);
    return _moverExistencia(
      p,
      'entrada',
      total,
      nota: nota,
      caducidad: usarNueva ? caducidad : antes,
    );
  }

  @override
  Future<Producto> registrarConteo(
    String id, {
    required int existenciaPiezas,
    String? nota,
  }) async {
    final p = _producto(id);
    final diferencia = existenciaPiezas - p.existenciaPiezas;
    if (diferencia == 0) return p;
    return _moverExistencia(p, 'ajuste', diferencia, nota: nota);
  }

  @override
  Future<Producto> registrarMerma(
    String id, {
    required int piezas,
    String? nota,
  }) async {
    final p = _producto(id);
    if (piezas > p.existenciaPiezas) {
      throw FalloApi(
        'stock_insuficiente',
        'No hay suficiente ${p.nombre}: quedan ${p.existenciaPiezas} piezas',
        estado: 409,
      );
    }
    return _moverExistencia(p, 'merma', -piezas, nota: nota);
  }

  @override
  Future<List<Movimiento>> listarMovimientos(String id) async {
    _producto(id);
    return List.of(movimientos[id] ?? const <Movimiento>[]).reversed.toList();
  }

  @override
  Future<Producto> subirFoto(String id, Uint8List bytes, String tipo) async =>
      _reemplazar({
        ..._producto(id).toJson(),
        'foto': '/api/v1/productos/$id/foto?v=${bytes.length}',
      });

  @override
  Future<Producto> borrarFoto(String id) async =>
      _reemplazar({..._producto(id).toJson(), 'foto': null});

  Producto _producto(String id) =>
      productos.where((p) => p.id == id).firstOrNull ??
      (throw const FalloApi(
        'no_encontrado',
        'No existe el producto',
        estado: 404,
      ));

  Producto _reemplazar(Map<String, Object?> json) {
    final p = Producto.fromJson(json);
    productos[productos.indexWhere((x) => x.id == p.id)] = p;
    return p;
  }

  Producto _moverExistencia(
    Producto p,
    String tipo,
    int piezas, {
    String? nota,
    String? caducidad,
  }) {
    final nueva = p.existenciaPiezas + piezas;
    final lista = movimientos.putIfAbsent(p.id, () => []);
    lista.add(
      Movimiento(
        id: lista.length + 1,
        tipo: tipo,
        piezas: piezas,
        existenciaResultante: nueva,
        origen: 'Caja',
        nota: nota,
        fecha: '2026-10-02T18:30:00Z',
      ),
    );
    return _reemplazar({
      ...p.toJson(),
      'existenciaPiezas': nueva,
      if (tipo == 'entrada') 'caducidad': caducidad,
    });
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

  /// Ventas cobradas, por clave de idempotencia.
  final ventas = <String, VentaRegistrada>{};

  @override
  Future<VentaRegistrada> registrarVenta({
    required List<LineaVenta> lineas,
    required String metodo,
    int? recibido,
    required String claveIdempotencia,
  }) async {
    final repetida = ventas[claveIdempotencia];
    if (repetida != null) return repetida;

    var total = 0;
    final piezas = <String, int>{};
    final lineasTicket = <LineaTicket>[];
    for (final l in lineas) {
      final p = productos.firstWhere((p) => p.id == l.productoId);
      final precio = l.porCaja ? p.precioCaja! : p.precio;
      final n = (l.porCaja ? p.piezasPorCaja! : 1) * l.cantidad;
      total += precio * l.cantidad;
      piezas[p.id] = (piezas[p.id] ?? 0) + n;
      lineasTicket.add(
        LineaTicket(
          productoId: p.id,
          nombre: p.nombre,
          unidad: l.porCaja ? 'caja' : 'pieza',
          cantidad: l.cantidad,
          piezas: n,
          precioUnit: precio,
          subtotal: precio * l.cantidad,
        ),
      );
    }
    for (final e in piezas.entries) {
      final i = productos.indexWhere((p) => p.id == e.key);
      final p = productos[i];
      if (p.existenciaPiezas < e.value) {
        throw FalloApi(
          'stock_insuficiente',
          'No hay suficiente ${p.nombre}: quedan ${p.existenciaPiezas} piezas',
          estado: 409,
        );
      }
      productos[i] = Producto.fromJson({
        ...p.toJson(),
        'existenciaPiezas': p.existenciaPiezas - e.value,
      });
    }
    final pagado = metodo == 'tarjeta' ? total : (recibido ?? total);
    final venta = VentaRegistrada(
      id: 'v_${ventas.length + 1}',
      folio: 1001 + ventas.length,
      fecha: '2026-10-02T18:30:00Z',
      diaNegocio: '2026-10-02',
      total: total,
      metodo: metodo,
      recibido: pagado,
      cambio: pagado - total,
    );
    ventas[claveIdempotencia] = venta;
    detalles.insert(
      0,
      DetalleVenta(
        id: venta.id,
        folio: venta.folio,
        fecha: venta.fecha,
        diaNegocio: venta.diaNegocio,
        total: total,
        metodo: metodo,
        recibido: pagado,
        cambio: pagado - total,
        envModo: 'na',
        envN: 0,
        envMonto: 0,
        origen: 'Caja',
        cancelada: false,
        lineas: lineasTicket,
      ),
    );
    return venta;
  }

  /// Tickets cobrados, del más nuevo al más viejo.
  final detalles = <DetalleVenta>[];

  @override
  Future<List<ResumenVenta>> listarVentas() async => [
    for (final d in detalles)
      ResumenVenta(
        id: d.id,
        folio: d.folio,
        fecha: d.fecha,
        total: d.total,
        metodo: d.metodo,
        origen: d.origen,
        cancelada: d.cancelada,
      ),
  ];

  @override
  Future<DetalleVenta> obtenerVenta(String id) async => _detalle(id);

  @override
  Future<void> cancelarVenta(String id) async {
    final d = _detalle(id);
    if (d.cancelada) {
      throw const FalloApi(
        'datos_invalidos',
        'Revisa los campos marcados',
        campos: {'cancelada': 'La venta ya fue cancelada'},
        estado: 400,
      );
    }
    for (final l in d.lineas) {
      final i = productos.indexWhere((p) => p.id == l.productoId);
      if (i < 0) continue;
      final p = productos[i];
      productos[i] = Producto.fromJson({
        ...p.toJson(),
        'existenciaPiezas': p.existenciaPiezas + l.piezas,
      });
    }
    detalles[detalles.indexOf(d)] = DetalleVenta.fromJson({
      ...d.toJson(),
      'cancelada': true,
    });
  }

  DetalleVenta _detalle(String id) =>
      detalles.where((d) => d.id == id).firstOrNull ??
      (throw const FalloApi(
        'no_encontrado',
        'No existe la venta',
        estado: 404,
      ));

  @override
  Future<Map<String, BalanceEnvase>> obtenerBalanceEnvases() async =>
      Map.of(envases);

  @override
  Future<List<PrestamoEnvase>> listarPrestamos() async => List.of(prestamos);

  @override
  Future<PrestamoEnvase> prestarEnvases({
    required String cliente,
    required String formato,
    required int cantidad,
  }) async {
    final p = PrestamoEnvase(
      id: 'pre_${prestamos.length + 1}',
      cliente: cliente.trim(),
      formato: formato,
      cantidad: cantidad,
      fecha: '2026-10-02T18:30:00Z',
    );
    prestamos.insert(0, p);
    _moverEnvases(formato, prestados: cantidad);
    return p;
  }

  @override
  Future<void> devolverPrestamo(String id) async {
    final p =
        prestamos.where((p) => p.id == id).firstOrNull ??
        (throw const FalloApi(
          'no_encontrado',
          'No existe el préstamo',
          estado: 404,
        ));
    prestamos.remove(p);
    _moverEnvases(p.formato, bodega: p.cantidad, prestados: -p.cantidad);
  }

  @override
  Future<Map<String, BalanceEnvase>> recibirVacios({
    required String formato,
    required int cantidad,
  }) async {
    _moverEnvases(formato, bodega: cantidad);
    return Map.of(envases);
  }

  void _moverEnvases(String formato, {int bodega = 0, int prestados = 0}) {
    final b = envases[formato]!;
    envases[formato] = BalanceEnvase(
      formato: formato,
      bodega: b.bodega + bodega,
      prestados: b.prestados + prestados,
      precio: b.precio,
    );
  }
}

/// El balance con que arranca la base (migración m002).
Map<String, BalanceEnvase> balanceDePrueba() => {
  'mega': const BalanceEnvase(
    formato: 'mega',
    bodega: 84,
    prestados: 36,
    precio: 800,
  ),
  'media': const BalanceEnvase(
    formato: 'media',
    bodega: 240,
    prestados: 48,
    precio: 300,
  ),
  'cuarto': const BalanceEnvase(
    formato: 'cuarto',
    bodega: 168,
    prestados: 24,
    precio: 300,
  ),
};

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
