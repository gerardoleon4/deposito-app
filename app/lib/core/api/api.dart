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

  Future<T> _pedir<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on DioException catch (e) {
      throw FalloApi.desdeDio(e);
    }
  }
}
