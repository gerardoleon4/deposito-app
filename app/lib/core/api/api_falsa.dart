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
    bool cajaAbierta = true,
  }) : productos = productos ?? productosDePrueba(),
       terminales = terminales ?? [],
       envases = envases ?? balanceDePrueba(prestamos: prestamos ?? []),
       prestamos = prestamos ?? [] {
    // Como el servidor con datos de ejemplo: se puede cobrar desde el inicio.
    if (cajaAbierta) _abrir(fondoDePrueba);
  }

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
    final turnoId = _turnoAbiertoId();

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
    return _cobrar(
      claveIdempotencia: claveIdempotencia,
      turnoId: turnoId,
      total: total,
      metodo: metodo,
      recibido: recibido,
      envModo: 'na',
      envN: 0,
      envMonto: 0,
      lineas: lineasTicket,
    );
  }

  VentaRegistrada _cobrar({
    required String claveIdempotencia,
    required String turnoId,
    required int total,
    required String metodo,
    required int? recibido,
    required String envModo,
    required int envN,
    required int envMonto,
    required List<LineaTicket> lineas,
  }) {
    final pagado = metodo == 'tarjeta' ? total : (recibido ?? total);
    if (pagado < total) {
      throw FalloApi(
        'datos_invalidos',
        'Revisa los campos marcados',
        campos: {
          'recibido': 'Recibido ($pagado) es menor que el total ($total)',
        },
        estado: 400,
      );
    }
    final venta = VentaRegistrada(
      id: 'v_${ventas.length + 1}',
      folio: 1001 + ventas.length,
      fecha: '2026-10-02T18:30:00Z',
      diaNegocio: '2026-10-02',
      total: total,
      metodo: metodo,
      recibido: pagado,
      cambio: pagado - total,
      turnoId: turnoId,
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
        envModo: envModo,
        envN: envN,
        envMonto: envMonto,
        origen: 'Caja',
        cancelada: false,
        turnoId: turnoId,
        lineas: lineas,
      ),
    );
    return venta;
  }

  /// Tickets cobrados, del más nuevo al más viejo.
  final detalles = <DetalleVenta>[];

  @override
  Future<List<ResumenVenta>> listarVentas({String? turno}) async {
    final turnoId = turno == 'actual' ? _abierto?.id : turno;
    if (turno != null && turnoId == null) return [];
    return [
      for (final d in detalles)
        if (turnoId == null || d.turnoId == turnoId)
          ResumenVenta(
            id: d.id,
            folio: d.folio,
            fecha: d.fecha,
            total: d.total,
            metodo: d.metodo,
            origen: d.origen,
            cancelada: d.cancelada,
            turnoId: d.turnoId,
          ),
    ];
  }

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
    if (d.turnoId == null || d.turnoId != _abierto?.id) {
      throw const FalloApi(
        'turno_cerrado',
        'La venta es de un turno que ya tiene corte: no se puede cancelar',
        estado: 409,
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
  Future<void> devolverPrestamo(String id, {int? cantidad}) async {
    final p =
        prestamos.where((p) => p.id == id).firstOrNull ??
        (throw const FalloApi(
          'no_encontrado',
          'No existe el préstamo',
          estado: 404,
        ));
    final n = cantidad ?? p.cantidad;
    if (n < 1 || n > p.cantidad) {
      throw FalloApi(
        'datos_invalidos',
        'Revisa los campos marcados',
        campos: {'cantidad': 'Solo faltan ${p.cantidad} envases por devolver'},
        estado: 400,
      );
    }
    final i = prestamos.indexOf(p);
    if (n == p.cantidad) {
      prestamos.removeAt(i);
    } else {
      prestamos[i] = PrestamoEnvase(
        id: p.id,
        cliente: p.cliente,
        formato: p.formato,
        cantidad: p.cantidad - n,
        devueltos: p.devueltos + n,
        fecha: p.fecha,
      );
    }
    _moverEnvases(p.formato, bodega: n, prestados: -n);
  }

  @override
  Future<VentaRegistrada> venderVacios({
    required String formato,
    required int cantidad,
    required String metodo,
    int? recibido,
    required String claveIdempotencia,
  }) async {
    final repetida = ventas[claveIdempotencia];
    if (repetida != null) return repetida;
    final turnoId = _turnoAbiertoId();
    final b = envases[formato]!;
    if (b.bodega < cantidad) {
      throw FalloApi(
        'envases_insuficientes',
        'No hay suficientes envases $formato vacíos: quedan ${b.bodega} en '
            'bodega',
        estado: 409,
      );
    }
    final total = cantidad * b.precio;
    final venta = _cobrar(
      claveIdempotencia: claveIdempotencia,
      turnoId: turnoId,
      total: total,
      metodo: metodo,
      recibido: recibido,
      envModo: 'cobrar',
      envN: cantidad,
      envMonto: total,
      lineas: const [],
    );
    _moverEnvases(formato, bodega: -cantidad);
    return venta;
  }

  @override
  Future<Map<String, BalanceEnvase>> recibirVacios({
    required String formato,
    required int cantidad,
  }) async {
    _moverEnvases(formato, bodega: cantidad);
    return Map.of(envases);
  }

  // --- Caja ---

  _TurnoFalso? _abierto;
  final _cortes = <_TurnoFalso>[];
  var _turnos = 0;
  var _movimientos = 0;

  /// Respuestas de movimientos y cierres, por clave de idempotencia.
  final _respuestasCaja = <String, Object>{};

  String _turnoAbiertoId() =>
      _abierto?.id ??
      (throw const FalloApi(
        'caja_cerrada',
        'La caja está cerrada: abre un turno para continuar',
        estado: 409,
      ));

  _TurnoFalso _abrir(int fondo) =>
      _abierto = _TurnoFalso('tur_${++_turnos}', fondo);

  Turno _turno(_TurnoFalso t) {
    final propias = [
      for (final d in detalles)
        if (d.turnoId == t.id) d,
    ];
    final validas = propias.where((d) => !d.cancelada);
    int suma(Iterable<int> xs) => xs.fold(0, (a, b) => a + b);
    final efectivo = suma([
      for (final d in validas)
        if (d.metodo == 'efectivo') d.total,
    ]);
    final ingresos = suma([
      for (final m in t.movimientos)
        if (m.tipo == 'ingreso') m.monto,
    ]);
    final retiros = suma([
      for (final m in t.movimientos)
        if (m.tipo == 'retiro') m.monto,
    ]);
    return Turno(
      id: t.id,
      estado: t.contado == null ? 'abierto' : 'cerrado',
      apertura: '2026-10-02T14:00:00Z',
      cierre: t.contado == null ? null : '2026-10-02T23:00:00Z',
      diaNegocio: '2026-10-02',
      fondo: t.fondo,
      resumen: ResumenTurno(
        ventas: validas.length,
        canceladas: propias.length - validas.length,
        ventasEfectivo: efectivo,
        ventasTarjeta: suma([
          for (final d in validas)
            if (d.metodo == 'tarjeta') d.total,
        ]),
        envases: suma([for (final d in validas) d.envMonto]),
        ingresos: ingresos,
        retiros: retiros,
        esperado: t.fondo + efectivo + ingresos - retiros,
      ),
      contado: t.contado,
      diferencia: t.contado == null
          ? null
          : t.contado! - (t.fondo + efectivo + ingresos - retiros),
      nota: t.nota,
    );
  }

  @override
  Future<DetalleTurno> turnoActual() async {
    final t = _abierto;
    if (t == null) return const DetalleTurno(turno: null, movimientos: []);
    return DetalleTurno(turno: _turno(t), movimientos: List.of(t.movimientos));
  }

  @override
  Future<Turno> abrirCaja({required int fondo}) async {
    if (_abierto != null) {
      throw const FalloApi(
        'caja_abierta',
        'Ya hay un turno de caja abierto',
        estado: 409,
      );
    }
    return _turno(_abrir(fondo));
  }

  @override
  Future<({MovimientoCaja movimiento, Turno turno})> registrarMovimientoCaja({
    required String tipo,
    required int monto,
    required String motivo,
    required String claveIdempotencia,
  }) async {
    final repetida = _respuestasCaja[claveIdempotencia];
    if (repetida != null) {
      return repetida as ({MovimientoCaja movimiento, Turno turno});
    }
    _turnoAbiertoId();
    final t = _abierto!;
    if (tipo == 'retiro' && monto > _turno(t).resumen.esperado) {
      throw FalloApi(
        'datos_invalidos',
        'Revisa los campos marcados',
        campos: {
          'monto':
              'El retiro ($monto) es mayor que el efectivo esperado en '
              'caja (${_turno(t).resumen.esperado})',
        },
        estado: 400,
      );
    }
    final m = MovimientoCaja(
      id: 'mc_${++_movimientos}',
      tipo: tipo,
      monto: monto,
      motivo: motivo.trim(),
      fecha: '2026-10-02T18:30:00Z',
    );
    t.movimientos.add(m);
    final r = (movimiento: m, turno: _turno(t));
    _respuestasCaja[claveIdempotencia] = r;
    return r;
  }

  @override
  Future<Turno> cerrarCaja({
    required int contado,
    String? nota,
    required String claveIdempotencia,
  }) async {
    final repetida = _respuestasCaja[claveIdempotencia];
    if (repetida != null) return repetida as Turno;
    _turnoAbiertoId();
    final t = _abierto!;
    final esperado = _turno(t).resumen.esperado;
    final textoNota = nota?.trim();
    if (contado != esperado && (textoNota == null || textoNota.isEmpty)) {
      final diferencia = contado - esperado;
      throw FalloApi(
        'datos_invalidos',
        'Revisa los campos marcados',
        campos: {
          'nota':
              'Explica la diferencia: hay '
              '${diferencia < 0 ? 'un faltante' : 'un sobrante'} de '
              '${diferencia.abs()} centavos',
        },
        estado: 400,
      );
    }
    t
      ..contado = contado
      ..nota = textoNota;
    _abierto = null;
    _cortes.insert(0, t);
    final corte = _turno(t);
    _respuestasCaja[claveIdempotencia] = corte;
    return corte;
  }

  @override
  Future<List<Turno>> listarCortes({String? desde, String? hasta}) async => [
    for (final t in _cortes) _turno(t),
  ];

  @override
  Future<DetalleTurno> obtenerCorte(String id) async {
    final t =
        [?_abierto, ..._cortes].where((t) => t.id == id).firstOrNull ??
        (throw const FalloApi(
          'no_encontrado',
          'No existe el turno',
          estado: 404,
        ));
    return DetalleTurno(turno: _turno(t), movimientos: List.of(t.movimientos));
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

/// Fondo del turno con que arranca la caja falsa, como el servidor con datos
/// de ejemplo: $500.00.
const fondoDePrueba = 50000;

/// Turno en memoria de [ApiFalsa]; cerrado cuando tiene [contado].
class _TurnoFalso {
  _TurnoFalso(this.id, this.fondo);

  final String id;
  final int fondo;
  final movimientos = <MovimientoCaja>[];
  int? contado;
  String? nota;
}

/// El balance con que arranca la base (migraciones m002 y m005). Como en el
/// servidor, los prestados son la suma de lo pendiente de [prestamos].
Map<String, BalanceEnvase> balanceDePrueba({
  List<PrestamoEnvase> prestamos = const [],
}) {
  int prestados(String formato) => prestamos
      .where((p) => p.formato == formato)
      .fold(0, (t, p) => t + p.cantidad);
  return {
    'mega': BalanceEnvase(
      formato: 'mega',
      bodega: 84,
      prestados: prestados('mega'),
      precio: 800,
    ),
    'media': BalanceEnvase(
      formato: 'media',
      bodega: 240,
      prestados: prestados('media'),
      precio: 300,
    ),
    'cuarto': BalanceEnvase(
      formato: 'cuarto',
      bodega: 168,
      prestados: prestados('cuarto'),
      precio: 300,
    ),
  };
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
