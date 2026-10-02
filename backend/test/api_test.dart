import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:web_socket_channel/io.dart';

import 'ayudantes/servidor_prueba.dart';

/// Pruebas e2e: servidor real en un puerto libre, como lo usará la app.
void main() {
  late ServidorPrueba s;

  setUp(() async => s = await crearServidorDePrueba());
  tearDown(() => s.cerrar());

  group('salud y errores generales', () {
    test('GET /salud responde ok sin clave', () async {
      final r = await s.get('/salud', clave: '');
      expect(r.statusCode, 200);
      expect(r.body, 'ok');
    });

    test('sin clave responde 401 con el formato del contrato', () async {
      final r = await s.get('/api/v1/productos', clave: '');
      expect(r.statusCode, 401);
      expect(codigoError(r), 'no_autorizado');
      expect(r.headers['content-type'], contains('application/json'));
    });

    test('una clave inventada es 401', () async {
      final r = await s.get('/api/v1/productos', clave: 'inventada');
      expect(r.statusCode, 401);
    });

    test('una ruta que no existe es 404 no_encontrado', () async {
      final r = await s.get('/api/v1/nada');
      expect(r.statusCode, 404);
      expect(codigoError(r), 'no_encontrado');
    });

    test('un cuerpo que no es JSON es 400 json_invalido', () async {
      final r = await s.post('/api/v1/productos', '{no es json');
      expect(r.statusCode, 400);
      expect(codigoError(r), 'json_invalido');
    });
  });

  group('productos', () {
    test('la caja crea, consulta y lista', () async {
      final creado = await s.post('/api/v1/productos', productoValido());
      expect(creado.statusCode, 201);
      final id = json(creado)['id'];

      final detalle = await s.get('/api/v1/productos/$id');
      expect(detalle.statusCode, 200);
      expect(json(detalle)['precio'], 4200);

      final lista = json(await s.get('/api/v1/productos?q=victoria'));
      expect((lista['productos'] as List).single['id'], id);
    });

    test('datos_invalidos dice qué campo falló', () async {
      final r = await s.post(
        '/api/v1/productos',
        productoValido({'precio': 42.5}),
      );
      expect(r.statusCode, 400);
      expect(codigoError(r), 'datos_invalidos');
      expect((json(r)['error'] as Map)['campos'], contains('precio'));
    });

    test('código repetido es 409 codigo_duplicado', () async {
      await s.post('/api/v1/productos', productoValido());
      final r = await s.post('/api/v1/productos', productoValido());
      expect(r.statusCode, 409);
      expect(codigoError(r), 'codigo_duplicado');
    });

    test('una terminal consulta pero no crea', () async {
      final clave = await s.registrarTerminal();
      expect((await s.get('/api/v1/productos', clave: clave)).statusCode, 200);
      final r = await s.post(
        '/api/v1/productos',
        productoValido(),
        clave: clave,
      );
      expect(r.statusCode, 403);
      expect(codigoError(r), 'solo_caja');
    });
  });

  group('terminales', () {
    test('se empareja con el código del QR y su clave funciona', () async {
      final clave = await s.registrarTerminal('Terminal S24');
      expect(clave, hasLength(43));
      final lista = json(await s.get('/api/v1/terminales'));
      expect((lista['terminales'] as List).single['nombre'], 'Terminal S24');
      expect((await s.get('/api/v1/productos', clave: clave)).statusCode, 200);
    });

    test('un código sirve para una sola terminal', () async {
      final codigo = json(
        await s.post('/api/v1/terminales/codigo', null),
      )['codigo'];
      final cuerpo = {'nombre': 'A', 'codigo': codigo};
      expect(
        (await s.post(
          '/api/v1/terminales/registro',
          cuerpo,
          clave: '',
        )).statusCode,
        201,
      );
      final r = await s.post('/api/v1/terminales/registro', cuerpo, clave: '');
      expect(r.statusCode, 401);
      expect(codigoError(r), 'codigo_invalido');
    });

    test('cinco intentos fallidos invalidan el código', () async {
      final codigo =
          json(await s.post('/api/v1/terminales/codigo', null))['codigo']
              as String;
      final incorrecto = codigo == '000000' ? '111111' : '000000';
      for (var i = 0; i < 5; i++) {
        await s.post('/api/v1/terminales/registro', {
          'nombre': 'X',
          'codigo': incorrecto,
        }, clave: '');
      }
      final r = await s.post('/api/v1/terminales/registro', {
        'nombre': 'X',
        'codigo': codigo,
      }, clave: '');
      expect(r.statusCode, 401);
    });

    test(
      'una terminal no puede generar códigos ni listar terminales',
      () async {
        final clave = await s.registrarTerminal();
        expect(
          (await s.post(
            '/api/v1/terminales/codigo',
            null,
            clave: clave,
          )).statusCode,
          403,
        );
        expect(
          (await s.get('/api/v1/terminales', clave: clave)).statusCode,
          403,
        );
      },
    );

    test('revocar deja la clave sin efecto', () async {
      final clave = await s.registrarTerminal();
      final id =
          ((json(await s.get('/api/v1/terminales'))['terminales'] as List)
                  .single
              as Map)['id'];
      expect((await s.delete('/api/v1/terminales/$id')).statusCode, 204);
      expect((await s.get('/api/v1/productos', clave: clave)).statusCode, 401);
      expect((await s.delete('/api/v1/terminales/$id')).statusCode, 404);
    });
  });

  group('WebSocket', () {
    Future<StreamIterator<Map<String, Object?>>> conectar(String clave) async {
      final canal = IOWebSocketChannel.connect(
        s.uri('/api/v1/ws').replace(scheme: 'ws'),
        headers: {'x-clave-terminal': clave},
      );
      await canal.ready;
      addTearDown(canal.sink.close);
      return StreamIterator(
        canal.stream.map(
          (m) => jsonDecode(m as String) as Map<String, Object?>,
        ),
      );
    }

    test(
      'saluda con conexion.lista y avisa cuando se crea un producto',
      () async {
        final clave = await s.registrarTerminal();
        final eventos = await conectar(clave);

        expect(await eventos.moveNext(), isTrue);
        expect(eventos.current['tipo'], 'conexion.lista');

        final terminales =
            json(await s.get('/api/v1/terminales'))['terminales'] as List;
        expect((terminales.single as Map)['conectada'], isTrue);

        await s.post('/api/v1/productos', productoValido());
        expect(await eventos.moveNext(), isTrue);
        expect(eventos.current['tipo'], 'producto.actualizado');
        expect(
          ((eventos.current['datos'] as Map)['producto'] as Map)['codigo'],
          '7501064191015',
        );
      },
    );

    test('sin clave no conecta', () async {
      final canal = IOWebSocketChannel.connect(
        s.uri('/api/v1/ws').replace(scheme: 'ws'),
      );
      await expectLater(canal.ready, throwsA(anything));
    });
  });

  test(
    'con datos de ejemplo arranca con los productos del prototipo',
    () async {
      final conEjemplos = await crearServidorDePrueba(datosEjemplo: true);
      addTearDown(conEjemplos.cerrar);
      final lista =
          json(await conEjemplos.get('/api/v1/productos'))['productos'] as List;
      expect(lista, hasLength(11));
    },
  );
}
