import 'dart:convert';
import 'dart:io';

import 'package:deposito_backend/deposito_backend.dart';
import 'package:http/http.dart' as http;

/// Servidor real con SQLite en memoria en un puerto libre, para pruebas e2e.
///
/// ```dart
/// late ServidorPrueba s;
/// setUp(() async => s = await crearServidorDePrueba());
/// tearDown(() => s.cerrar());
/// ```
Future<ServidorPrueba> crearServidorDePrueba({
  bool datosEjemplo = false,
  Reloj? reloj,
}) async {
  final servidor = DepositoServer(
    rutaBaseDatos: enMemoria,
    puerto: 0,
    direccion: InternetAddress.loopbackIPv4,
    datosEjemplo: datosEjemplo,
    bitacora: Bitacora.silenciosa(),
    reloj: reloj ?? () => DateTime.now().toUtc(),
  );
  await servidor.iniciar();
  return ServidorPrueba._(servidor);
}

class ServidorPrueba {
  ServidorPrueba._(this.servidor)
    : base = Uri.parse('http://127.0.0.1:${servidor.puertoActual}');

  final DepositoServer servidor;
  final Uri base;
  final _cliente = http.Client();

  String get claveCaja => servidor.claveCaja;

  Uri uri(String ruta) => base.resolve(ruta);

  /// [clave] `null` usa la de caja; `''` no manda clave.
  Future<http.Response> get(String ruta, {String? clave}) =>
      _cliente.get(uri(ruta), headers: _cabeceras(clave));

  Future<http.Response> post(
    String ruta,
    Object? cuerpo, {
    String? clave,
    Map<String, String> cabeceras = const {},
  }) => _cliente.post(
    uri(ruta),
    headers: {..._cabeceras(clave), ...cabeceras},
    body: cuerpo is String ? cuerpo : jsonEncode(cuerpo),
  );

  Future<http.Response> put(String ruta, Object? cuerpo, {String? clave}) =>
      _cliente.put(
        uri(ruta),
        headers: _cabeceras(clave),
        body: cuerpo is String ? cuerpo : jsonEncode(cuerpo),
      );

  /// Sube bytes sin envolver, como la foto de un producto.
  Future<http.Response> putBytes(
    String ruta,
    List<int> bytes, {
    required String tipo,
    String? clave,
  }) => _cliente.put(
    uri(ruta),
    headers: {..._cabeceras(clave), 'content-type': tipo},
    body: bytes,
  );

  Future<http.Response> delete(String ruta, {String? clave}) =>
      _cliente.delete(uri(ruta), headers: _cabeceras(clave));

  /// Empareja una terminal como lo haría la app y regresa su clave.
  Future<String> registrarTerminal([String nombre = 'Terminal S24']) async {
    final codigo = json(
      await post('/api/v1/terminales/codigo', null),
    )['codigo'];
    final r = await post('/api/v1/terminales/registro', {
      'nombre': nombre,
      'codigo': codigo,
    }, clave: '');
    return json(r)['clave'] as String;
  }

  /// Abre un turno de caja: sin él no se cobra (`409 caja_cerrada`).
  Future<Map<String, Object?>> abrirCaja({int fondo = 50000}) async {
    final r = await post('/api/v1/caja/abrir', {'fondo': fondo});
    if (r.statusCode != 201) throw StateError('No abrió la caja: ${r.body}');
    return (json(r)['turno'] as Map).cast();
  }

  Future<void> cerrar() async {
    _cliente.close();
    await servidor.detener();
  }

  Map<String, String> _cabeceras(String? clave) => {
    'content-type': 'application/json',
    if (clave != '') cabeceraClave: clave ?? claveCaja,
  };
}

/// Encabezado mínimo de un PNG: basta para pasar la revisión de firma.
final pngPrueba = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 1, 2, 3, 4];

Map<String, Object?> json(http.Response r) =>
    jsonDecode(r.body) as Map<String, Object?>;

/// `codigo` del error del contrato.
String? codigoError(http.Response r) =>
    (json(r)['error'] as Map<String, Object?>?)?['codigo'] as String?;

/// Campos con error de un `datos_invalidos`.
Map<String, Object?> camposError(http.Response r) =>
    ((json(r)['error'] as Map)['campos'] as Map).cast();

/// Producto válido mínimo para pruebas; [cambios] reemplaza campos.
Map<String, Object?> productoValido([
  Map<String, Object?> cambios = const {},
]) => {
  'codigo': '7501064191015',
  'nombre': 'Victoria Mega',
  'categoria': 'cerveza',
  'presentacion': 'Mega 1.2 L',
  'precio': 4200,
  'precioCaja': 48000,
  'piezasPorCaja': 12,
  'existenciaPiezas': 66,
  'minimo': 36,
  'envase': 'mega',
  'caducidad': '2027-01-29',
  ...cambios,
};
