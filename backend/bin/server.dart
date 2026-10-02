import 'dart:io';

import 'package:deposito_backend/deposito_backend.dart';
import 'package:path/path.dart' as p;

/// Servidor de desarrollo: corre en la laptop mientras el iPad no está listo.
///
///   dart run bin/server.dart
///
/// Variables opcionales:
///   PUERTO          8080 por omisión.
///   BASE_DATOS      datos/anaquel.db por omisión (ignorado por git).
///   CLAVE_CAJA      fija la clave de caja; si no, se genera una por arranque.
///   SIN_EJEMPLOS=1  no carga los productos del prototipo.
Future<void> main() async {
  final entorno = Platform.environment;
  final rutaBase = entorno['BASE_DATOS'] ?? p.join('datos', 'anaquel.db');
  Directory(p.dirname(rutaBase)).createSync(recursive: true);

  final servidor = DepositoServer(
    rutaBaseDatos: rutaBase,
    puerto: int.tryParse(entorno['PUERTO'] ?? '') ?? 8080,
    claveCaja: entorno['CLAVE_CAJA'],
    datosEjemplo: entorno['SIN_EJEMPLOS'] != '1',
    bitacora: Bitacora(rutaArchivo: p.join(p.dirname(rutaBase), 'anaquel.log')),
  );
  await servidor.iniciar();

  stdout.writeln('''

  Anaquel $versionServidor escuchando en el puerto ${servidor.puertoActual}
  Base de datos: $rutaBase

  Clave de caja (solo desarrollo, no la compartas fuera del equipo):
    ${servidor.claveCaja}

  Prueba:
    curl -H "X-Clave-Terminal: ${servidor.claveCaja}" localhost:${servidor.puertoActual}/api/v1/productos

  Ctrl + C para detener.
''');

  ProcessSignal.sigint.watch().first.then((_) async {
    await servidor.detener();
    exit(0);
  });
}
