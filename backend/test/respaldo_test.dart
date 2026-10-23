import 'dart:io';

import 'package:deposito_backend/deposito_backend.dart';
import 'package:test/test.dart';

import 'ayudantes/servidor_prueba.dart';

void main() {
  test('verifica el PIN del dueño del respaldo y lo restaura', () async {
    final carpeta = Directory.systemTemp.createTempSync('anaquel_prueba_');
    addTearDown(() => carpeta.deleteSync(recursive: true));

    final s = await crearServidorDePrueba();
    await s.post('/api/v1/usuarios', {
      'nombre': 'Don Beto',
      'rol': 'dueno',
      'pin': '123456',
    });
    await s.post('/api/v1/productos', productoValido());
    final respaldo = File('${carpeta.path}/respaldo.db')
      ..writeAsBytesSync((await s.get('/api/v1/respaldo')).bodyBytes);
    await s.cerrar();

    expect(verificarRespaldo(respaldo.path), EstadoRespaldo.requierePin);
    expect(
      verificarRespaldo(respaldo.path, pin: '000000'),
      EstadoRespaldo.pinIncorrecto,
    );
    expect(
      verificarRespaldo(respaldo.path, pin: '123456'),
      EstadoRespaldo.valido,
    );
    final basura = File('${carpeta.path}/basura.db')..writeAsStringSync('hola');
    expect(verificarRespaldo(basura.path), EstadoRespaldo.noEsRespaldo);

    // Restaurar sobre una base nueva: el servidor arranca con lo respaldado.
    final destino = '${carpeta.path}/anaquel.db';
    File(destino).writeAsStringSync('base anterior');
    restaurarRespaldo(respaldo.path, destino);
    expect(File('$destino.antes').readAsStringSync(), 'base anterior');
    final restaurado = DepositoServer(
      rutaBaseDatos: destino,
      puerto: 0,
      direccion: InternetAddress.loopbackIPv4,
      bitacora: Bitacora.silenciosa(),
    );
    await restaurado.iniciar();
    addTearDown(restaurado.detener);
    final api = Uri.parse('http://127.0.0.1:${restaurado.puertoActual}');
    final cliente = HttpClient();
    final r =
        await (await cliente.getUrl(api.resolve('/api/v1/productos'))
              ..headers.set(cabeceraClave, restaurado.claveCaja))
            .close();
    final cuerpo = await r.transform(const SystemEncoding().decoder).join();
    cliente.close();
    expect(cuerpo, contains('Victoria Mega'));
  });
}
