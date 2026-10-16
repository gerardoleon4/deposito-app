import 'dart:typed_data';

import 'package:deposito_backend/deposito_backend.dart';
import 'package:dio/dio.dart';

import 'fallo_api.dart';

/// Lo que la app le puede pedir al servidor (docs/API.md).
///
/// Las pantallas solo conocen esta interfaz. [ApiHttp] habla con el servidor
/// real; `ApiFalsa` regresa datos de prueba para pruebas de widgets y para
/// avanzar antes de que exista un endpoint.
abstract interface class Api {
  /// `http://host:puerto`, para armar la URL del WebSocket.
  Uri get base;

  String get clave;

  Future<List<Producto>> listarProductos();

  Future<Producto> crearProducto(Map<String, Object?> datos);

  /// Para el escáner: `null` si no hay un producto con ese código.
  Future<Producto?> buscarPorCodigo(String codigo);

  /// Reemplaza los campos editables; la existencia no cambia por aquí.
  Future<Producto> editarProducto(String id, Map<String, Object?> datos);

  Future<void> eliminarProducto(String id);

  /// Recibe mercancía: `cajas × piezasPorCaja + piezas`.
  Future<Producto> registrarEntrada(
    String id, {
    int cajas = 0,
    int piezas = 0,
    String? caducidad,
    String? nota,
  });

  /// Fija la existencia a lo que se contó físicamente.
  Future<Producto> registrarConteo(
    String id, {
    required int existenciaPiezas,
    String? nota,
  });

  /// Saca piezas rotas, caducadas o regaladas.
  Future<Producto> registrarMerma(
    String id, {
    required int piezas,
    String? nota,
  });

  Future<List<Movimiento>> listarMovimientos(String id);

  /// [tipo]: `image/jpeg`, `image/png` o `image/webp`, de hasta 5 MB.
  Future<Producto> subirFoto(String id, Uint8List bytes, String tipo);

  Future<Producto> borrarFoto(String id);

  /// Las últimas 100 ventas, del folio más nuevo al más viejo.
  Future<List<ResumenVenta>> listarVentas();

  Future<DetalleVenta> obtenerVenta(String id);

  /// Regresa existencias y envases. Ya cancelada es `datos_invalidos`.
  Future<void> cancelarVenta(String id);

  /// Existencias por formato: `mega`, `media`, `cuarto`.
  Future<Map<String, BalanceEnvase>> obtenerBalanceEnvases();

  /// Préstamos sin devolver, del más nuevo al más viejo.
  Future<List<PrestamoEnvase>> listarPrestamos();

  Future<PrestamoEnvase> prestarEnvases({
    required String cliente,
    required String formato,
    required int cantidad,
  });

  /// Todos los envases del préstamo regresan a bodega.
  Future<void> devolverPrestamo(String id);

  /// Vacíos que entran a bodega sin una venta.
  Future<Map<String, BalanceEnvase>> recibirVacios({
    required String formato,
    required int cantidad,
  });

  Future<CodigoEmparejamiento> crearCodigoEmparejamiento();

  Future<List<Terminal>> listarTerminales();

  Future<void> revocarTerminal(String id);

  /// Cobra en la caja. Reintentar con la misma [claveIdempotencia] regresa
  /// la misma venta en lugar de cobrar otra vez.
  Future<VentaRegistrada> registrarVenta({
    required List<LineaVenta> lineas,
    required String metodo,
    int? recibido,
    required String claveIdempotencia,
  });
}

class ApiHttp implements Api {
  ApiHttp({required this.base, required this.clave, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: base.toString(),
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 10),
              headers: {cabeceraClave: clave},
            ),
          );

  @override
  final Uri base;
  @override
  final String clave;
  final Dio _dio;

  /// Registro de una terminal: es público, todavía no hay clave.
  static Future<({Terminal terminal, String clave})> registrarTerminal({
    required Uri base,
    required String nombre,
    required String codigo,
  }) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: base.toString(),
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    try {
      final r = await dio.post<Map<String, Object?>>(
        '/api/v1/terminales/registro',
        data: {'nombre': nombre, 'codigo': codigo},
      );
      return (
        terminal: Terminal.fromJson((r.data!['terminal'] as Map).cast()),
        clave: r.data!['clave'] as String,
      );
    } on DioException catch (e) {
      throw FalloApi.desdeDio(e);
    } finally {
      dio.close();
    }
  }

  @override
  Future<List<Producto>> listarProductos() => _pedir(() async {
    final r = await _dio.get<Map<String, Object?>>('/api/v1/productos');
    return [
      for (final p in r.data!['productos'] as List)
        Producto.fromJson((p as Map).cast()),
    ];
  });

  @override
  Future<Producto> crearProducto(Map<String, Object?> datos) =>
      _pedir(() async {
        final r = await _dio.post<Map<String, Object?>>(
          '/api/v1/productos',
          data: datos,
        );
        return Producto.fromJson(r.data!);
      });

  @override
  Future<Producto?> buscarPorCodigo(String codigo) async {
    try {
      return await _producto(
        _dio.get('/api/v1/productos/codigo/${Uri.encodeComponent(codigo)}'),
      );
    } on FalloApi catch (e) {
      if (e.estado == 404) return null;
      rethrow;
    }
  }

  @override
  Future<Producto> editarProducto(String id, Map<String, Object?> datos) =>
      _producto(_dio.put('/api/v1/productos/$id', data: datos));

  @override
  Future<void> eliminarProducto(String id) =>
      _pedir(() => _dio.delete<void>('/api/v1/productos/$id'));

  @override
  Future<Producto> registrarEntrada(
    String id, {
    int cajas = 0,
    int piezas = 0,
    String? caducidad,
    String? nota,
  }) => _producto(
    _dio.post(
      '/api/v1/productos/$id/entradas',
      data: {
        'cajas': cajas,
        'piezas': piezas,
        'caducidad': ?caducidad,
        'nota': ?nota,
      },
    ),
  );

  @override
  Future<Producto> registrarConteo(
    String id, {
    required int existenciaPiezas,
    String? nota,
  }) => _producto(
    _dio.post(
      '/api/v1/productos/$id/ajustes',
      data: {
        'motivo': 'conteo',
        'existenciaPiezas': existenciaPiezas,
        'nota': ?nota,
      },
    ),
  );

  @override
  Future<Producto> registrarMerma(
    String id, {
    required int piezas,
    String? nota,
  }) => _producto(
    _dio.post(
      '/api/v1/productos/$id/ajustes',
      data: {'motivo': 'merma', 'piezas': piezas, 'nota': ?nota},
    ),
  );

  @override
  Future<List<Movimiento>> listarMovimientos(String id) => _pedir(() async {
    final r = await _dio.get<Map<String, Object?>>(
      '/api/v1/productos/$id/movimientos',
    );
    return [
      for (final m in r.data!['movimientos'] as List)
        Movimiento.fromJson((m as Map).cast()),
    ];
  });

  @override
  Future<Producto> subirFoto(String id, Uint8List bytes, String tipo) =>
      _producto(
        _dio.put(
          '/api/v1/productos/$id/foto',
          data: Stream.value(bytes),
          options: Options(
            contentType: tipo,
            headers: {Headers.contentLengthHeader: bytes.length},
          ),
        ),
      );

  @override
  Future<Producto> borrarFoto(String id) =>
      _producto(_dio.delete('/api/v1/productos/$id/foto'));

  @override
  Future<List<ResumenVenta>> listarVentas() => _pedir(() async {
    final r = await _dio.get<Map<String, Object?>>('/api/v1/ventas');
    return [
      for (final v in r.data!['ventas'] as List)
        ResumenVenta.fromJson((v as Map).cast()),
    ];
  });

  @override
  Future<DetalleVenta> obtenerVenta(String id) => _pedir(() async {
    final r = await _dio.get<Map<String, Object?>>('/api/v1/ventas/$id');
    return DetalleVenta.fromJson(r.data!);
  });

  @override
  Future<void> cancelarVenta(String id) =>
      _pedir(() => _dio.post<void>('/api/v1/ventas/$id/cancelar'));

  @override
  Future<Map<String, BalanceEnvase>> obtenerBalanceEnvases() =>
      _pedir(() async {
        final r = await _dio.get<Map<String, Object?>>('/api/v1/envases');
        return BalanceEnvase.deJson((r.data!['balance'] as Map).cast());
      });

  @override
  Future<List<PrestamoEnvase>> listarPrestamos() => _pedir(() async {
    final r = await _dio.get<Map<String, Object?>>('/api/v1/envases/prestamos');
    return [
      for (final p in r.data!['prestamos'] as List)
        PrestamoEnvase.fromJson((p as Map).cast()),
    ];
  });

  @override
  Future<PrestamoEnvase> prestarEnvases({
    required String cliente,
    required String formato,
    required int cantidad,
  }) => _pedir(() async {
    final r = await _dio.post<Map<String, Object?>>(
      '/api/v1/envases/prestamos',
      data: {'cliente': cliente, 'formato': formato, 'cantidad': cantidad},
    );
    return PrestamoEnvase.fromJson(r.data!);
  });

  @override
  Future<void> devolverPrestamo(String id) =>
      _pedir(() => _dio.post<void>('/api/v1/envases/prestamos/$id/devolver'));

  @override
  Future<Map<String, BalanceEnvase>> recibirVacios({
    required String formato,
    required int cantidad,
  }) => _pedir(() async {
    final r = await _dio.post<Map<String, Object?>>(
      '/api/v1/envases/entrada',
      data: {'formato': formato, 'cantidad': cantidad},
    );
    return BalanceEnvase.deJson((r.data!['balance'] as Map).cast());
  });

  @override
  Future<CodigoEmparejamiento> crearCodigoEmparejamiento() => _pedir(() async {
    final r = await _dio.post<Map<String, Object?>>(
      '/api/v1/terminales/codigo',
    );
    return CodigoEmparejamiento.fromJson(r.data!);
  });

  @override
  Future<List<Terminal>> listarTerminales() => _pedir(() async {
    final r = await _dio.get<Map<String, Object?>>('/api/v1/terminales');
    return [
      for (final t in r.data!['terminales'] as List)
        Terminal.fromJson((t as Map).cast()),
    ];
  });

  @override
  Future<void> revocarTerminal(String id) =>
      _pedir(() => _dio.delete<void>('/api/v1/terminales/$id'));

  @override
  Future<VentaRegistrada> registrarVenta({
    required List<LineaVenta> lineas,
    required String metodo,
    int? recibido,
    required String claveIdempotencia,
  }) => _pedir(() async {
    final r = await _dio.post<Map<String, Object?>>(
      '/api/v1/ventas',
      data: {
        'metodo': metodo,
        'recibido': ?recibido,
        'lineas': [for (final l in lineas) l.toJson()],
      },
      options: Options(headers: {cabeceraIdempotencia: claveIdempotencia}),
    );
    return VentaRegistrada.fromJson(r.data!);
  });

  /// Peticiones que responden un producto.
  Future<Producto> _producto(Future<Response<Map<String, Object?>>> peticion) =>
      _pedir(() async => Producto.fromJson((await peticion).data!));

  Future<T> _pedir<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on DioException catch (e) {
      throw FalloApi.desdeDio(e);
    }
  }
}
