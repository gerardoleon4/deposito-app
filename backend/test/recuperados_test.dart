import 'dart:convert';

import 'package:deposito_backend/deposito_backend.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'ayudantes/servidor_prueba.dart';

/// Usuarios y PIN, descuentos, crédito por vacíos, devoluciones parciales,
/// envases, ajustes y respaldo: lo que el diseño de Pablo necesitaba.
void main() {
  late ServidorPrueba s;
  var claves = 0;
  var ahora = DateTime.utc(2026, 10, 24, 18);

  setUp(() async {
    ahora = DateTime.utc(2026, 10, 24, 18);
    s = await crearServidorDePrueba(reloj: () => ahora);
  });
  tearDown(() => s.cerrar());

  Map<String, String> idem() => {cabeceraIdempotencia: 'clave-rec-${claves++}'};

  Future<String> crearProducto([
    Map<String, Object?> cambios = const {},
  ]) async =>
      json(await s.post('/api/v1/productos', productoValido(cambios)))['id']
          as String;

  Future<http.Response> cobrar(
    List<Map<String, Object?>> lineas, {
    String envModo = 'na',
    Map<String, int>? credito,
    String? usuarioId,
    String metodo = 'efectivo',
  }) => s.post('/api/v1/ventas', {
    'metodo': metodo,
    'envModo': envModo,
    'envCredito': ?credito,
    'usuarioId': ?usuarioId,
    'lineas': lineas,
  }, cabeceras: idem());

  Map<String, Object?> pieza(
    String id, [
    int cantidad = 1,
    int descuento = 0,
  ]) => {
    'productoId': id,
    'unidad': 'pieza',
    'cantidad': cantidad,
    'descuento': descuento,
  };

  Future<Map<String, Object?>> detalle(String ventaId) async =>
      json(await s.get('/api/v1/ventas/$ventaId'));

  Future<Map<String, Object?>> balance(String formato) async =>
      ((json(await s.get('/api/v1/envases'))['balance'] as Map)[formato] as Map)
          .cast();

  Future<int> existencia(String id) async =>
      json(await s.get('/api/v1/productos/$id'))['existenciaPiezas'] as int;

  Future<Map<String, Object?>> crearUsuario(
    String nombre,
    String rol,
    String pin, {
    String? pinAutoriza,
  }) async {
    final r = await s.post('/api/v1/usuarios', {
      'nombre': nombre,
      'rol': rol,
      'pin': pin,
      'pinAutoriza': ?pinAutoriza,
    });
    expect(r.statusCode, 201, reason: r.body);
    return (json(r)['usuario'] as Map).cast();
  }

  group('usuarios', () {
    test(
      'el primero es el dueño y los demás necesitan su autorización',
      () async {
        final noDueno = await s.post('/api/v1/usuarios', {
          'nombre': 'Ana',
          'rol': 'cajero',
          'pin': '1111',
        });
        expect(camposError(noDueno).keys, ['rol']);

        final dueno = Usuario.fromJson(
          await crearUsuario('Don Beto', 'dueno', '9999'),
        );
        expect(dueno.id, startsWith('u_'));
        expect(dueno.activo, isTrue);

        final sinPin = await s.post('/api/v1/usuarios', {
          'nombre': 'Ana',
          'rol': 'cajero',
          'pin': '1111',
        });
        expect(codigoError(sinPin), 'pin_invalido');

        await crearUsuario('Ana', 'cajero', '1111', pinAutoriza: '9999');
        final cajeroAutoriza = await s.post('/api/v1/usuarios', {
          'nombre': 'Luis',
          'rol': 'cajero',
          'pin': '2222',
          'pinAutoriza': '1111',
        });
        expect(codigoError(cajeroAutoriza), 'sin_permiso');

        final repetido = await s.post('/api/v1/usuarios', {
          'nombre': 'Luis',
          'rol': 'cajero',
          'pin': '1111',
          'pinAutoriza': '9999',
        });
        expect(camposError(repetido).keys, ['pin']);

        final malPin = await s.post('/api/v1/usuarios', {
          'nombre': 'Luis',
          'rol': 'cajero',
          'pin': '12a4',
          'pinAutoriza': '9999',
        });
        expect(camposError(malPin).keys, ['pin']);

        final lista = json(await s.get('/api/v1/usuarios'))['usuarios'] as List;
        expect(
          [for (final u in lista) (u as Map)['nombre']],
          ['Ana', 'Don Beto'],
        );
        expect(jsonEncode(lista), isNot(contains('9999')), reason: 'sin PIN');
      },
    );

    test('verificar PIN y bloqueo tras cinco intentos', () async {
      final dueno = await crearUsuario('Don Beto', 'dueno', '9999');
      final ok = await s.post('/api/v1/usuarios/verificar', {'pin': '9999'});
      expect((json(ok)['usuario'] as Map)['id'], dueno['id']);

      final otroUsuario = await s.post('/api/v1/usuarios/verificar', {
        'pin': '9999',
        'usuarioId': 'u_otro',
      });
      expect(codigoError(otroUsuario), 'pin_invalido');

      for (var i = 0; i < 4; i++) {
        final mal = await s.post('/api/v1/usuarios/verificar', {'pin': '0000'});
        expect(codigoError(mal), 'pin_invalido');
      }
      final bloqueado = await s.post('/api/v1/usuarios/verificar', {
        'pin': '9999',
      });
      expect(bloqueado.statusCode, 429);
      expect(codigoError(bloqueado), 'demasiados_intentos');

      ahora = ahora.add(const Duration(minutes: 1, seconds: 1));
      final otraVez = await s.post('/api/v1/usuarios/verificar', {
        'pin': '9999',
      });
      expect(otraVez.statusCode, 200);
    });

    test('editar respeta los roles y siempre deja un dueño activo', () async {
      final dueno = await crearUsuario('Don Beto', 'dueno', '9999');
      final gerente = await crearUsuario(
        'Sofía',
        'gerente',
        '5555',
        pinAutoriza: '9999',
      );

      final gerenteEditaDueno = await s.put('/api/v1/usuarios/${dueno['id']}', {
        'nombre': 'Beto',
        'pinAutoriza': '5555',
      });
      expect(codigoError(gerenteEditaDueno), 'sin_permiso');

      final sinDueno = await s.put('/api/v1/usuarios/${dueno['id']}', {
        'activo': false,
        'pinAutoriza': '9999',
      });
      expect(camposError(sinDueno).keys, ['activo']);

      final baja = await s.put('/api/v1/usuarios/${gerente['id']}', {
        'activo': false,
        'pinAutoriza': '9999',
      });
      expect((json(baja)['usuario'] as Map)['activo'], isFalse);
      // De baja ya no autoriza ni su PIN funciona.
      final verificar = await s.post('/api/v1/usuarios/verificar', {
        'pin': '5555',
      });
      expect(codigoError(verificar), 'pin_invalido');

      final cambioPin = await s.put('/api/v1/usuarios/${gerente['id']}', {
        'activo': true,
        'pin': '7777',
        'pinAutoriza': '9999',
      });
      expect(cambioPin.statusCode, 200);
      expect(
        (await s.post('/api/v1/usuarios/verificar', {
          'pin': '7777',
        })).statusCode,
        200,
      );

      final noExiste = await s.put('/api/v1/usuarios/u_nada', {
        'pinAutoriza': '9999',
      });
      expect(codigoError(noExiste), 'no_encontrado');
    });

    test('una terminal no administra usuarios', () async {
      final clave = await s.registrarTerminal();
      final r = await s.get('/api/v1/usuarios', clave: clave);
      expect(codigoError(r), 'solo_caja');
    });
  });

  group('ventas con lo nuevo', () {
    setUp(() async => s.abrirCaja());

    test('el descuento es por unidad y truncado al centavo', () async {
      final pid = await crearProducto({'precio': 4200});
      final r = await cobrar([pieza(pid, 2, 15)]);
      expect(r.statusCode, 201);
      expect(json(r)['total'], 2 * (4200 - 630));

      final linea = LineaTicket.fromJson(
        ((await detalle(json(r)['id'] as String))['lineas'] as List).single
            as Map<String, Object?>,
      );
      expect(
        (linea.precioLista, linea.descuento, linea.precioUnit),
        (4200, 15, 3570),
      );

      // 33 % de $0.10 es 3.3 centavos: se descuentan 3.
      final barato = await crearProducto({
        'codigo': '111',
        'precio': 10,
        'precioCaja': null,
        'piezasPorCaja': null,
        'envase': null,
      });
      expect(json(await cobrar([pieza(barato, 1, 33)]))['total'], 7);

      final mal = await cobrar([pieza(pid, 1, 100)]);
      expect(camposError(mal).keys, ['lineas']);
    });

    test('el crédito por vacíos resta del total y entra a bodega', () async {
      final pid = await crearProducto();
      final antes = await balance('mega');
      final r = await cobrar([pieza(pid)], credito: {'mega': 2, 'media': 0});
      expect(json(r)['total'], 4200 - 2 * 800);
      expect((await balance('mega'))['bodega'], (antes['bodega'] as int) + 2);

      final venta = await detalle(json(r)['id'] as String);
      expect(venta['envCredito'], 1600);

      final deMas = await cobrar([pieza(pid)], credito: {'mega': 6});
      expect(camposError(deMas).keys, ['envCredito']);

      // Cancelar regresa al cliente sus vacíos.
      await s.post('/api/v1/ventas/${json(r)['id']}/cancelar', null);
      expect((await balance('mega'))['bodega'], antes['bodega']);
    });

    test('devolución parcial a merma e inventario, y luego el resto', () async {
      final pid = await crearProducto({'existenciaPiezas': 10});
      // 3 piezas a $42 con depósito de $8: $150.
      final r = await cobrar([pieza(pid, 3)], envModo: 'cobrar');
      final ventaId = json(r)['id'] as String;
      expect(json(r)['total'], 15000);
      final lineaId =
          (((await detalle(ventaId))['lineas'] as List).single
              as Map)['lineaId'];

      final merma = await s.post('/api/v1/ventas/$ventaId/devolver', {
        'lineas': [
          {'lineaId': lineaId, 'cantidad': 1},
        ],
        'destino': 'merma',
        'motivo': 'Botella rota',
      });
      expect(merma.statusCode, 201, reason: merma.body);
      final dev = Devolucion.fromJson(
        (json(merma)['devolucion'] as Map).cast(),
      );
      expect(
        (dev.monto, dev.destino, dev.motivo),
        (5000, 'merma', 'Botella rota'),
      );
      expect(await existencia(pid), 7, reason: 'la merma no regresa');

      await s.post('/api/v1/ventas/$ventaId/devolver', {
        'lineas': [
          {'lineaId': lineaId, 'cantidad': 1},
        ],
      });
      expect(await existencia(pid), 8);

      final venta = DetalleVenta.fromJson(await detalle(ventaId));
      expect(venta.devuelto, 10000);
      expect(venta.lineas.single.devueltas, 2);
      expect(venta.devoluciones, hasLength(2));
      expect(venta.cancelada, isFalse);

      final turno =
          (json(await s.get('/api/v1/caja/turno'))['turno'] as Map)['resumen']
              as Map;
      expect(turno['ventasEfectivo'], 5000);
      expect(turno['devoluciones'], 10000);

      final deMas = await s.post('/api/v1/ventas/$ventaId/devolver', {
        'lineas': [
          {'lineaId': lineaId, 'cantidad': 2},
        ],
      });
      expect(camposError(deMas).keys, ['lineas']);
      final ajena = await s.post('/api/v1/ventas/$ventaId/devolver', {
        'lineas': [
          {'lineaId': 99999, 'cantidad': 1},
        ],
      });
      expect(camposError(ajena).keys, ['lineas']);

      // Devolver lo último cancela la venta.
      await s.post('/api/v1/ventas/$ventaId/devolver', {
        'lineas': [
          {'lineaId': lineaId, 'cantidad': 1},
        ],
      });
      final final_ = DetalleVenta.fromJson(await detalle(ventaId));
      expect(final_.cancelada, isTrue);
      expect(final_.devuelto, 15000);
      final resumen =
          (json(await s.get('/api/v1/caja/turno'))['turno'] as Map)['resumen']
              as Map;
      expect(resumen['ventasEfectivo'], 0);
      expect(resumen['canceladas'], 1);
    });

    test(
      'cancelar después de una devolución regresa solo lo que falta',
      () async {
        final pid = await crearProducto();
        final ventaId = json(await cobrar([pieza(pid, 2)]))['id'] as String;
        final lineaId =
            (((await detalle(ventaId))['lineas'] as List).single
                as Map)['lineaId'];
        await s.post('/api/v1/ventas/$ventaId/devolver', {
          'lineas': [
            {'lineaId': lineaId, 'cantidad': 1},
          ],
        });
        await s.post('/api/v1/ventas/$ventaId/cancelar', {
          'motivo': 'Se arrepintió',
        });
        final venta = DetalleVenta.fromJson(await detalle(ventaId));
        expect([for (final d in venta.devoluciones) d.monto], [4200, 4200]);
        expect(venta.devoluciones.last.motivo, 'Se arrepintió');
        expect(await existencia(pid), 66);
      },
    );

    test(
      'devolver de una venta con préstamo o "trae" mueve los envases',
      () async {
        final pid = await crearProducto();
        final antes = await balance('mega');

        final prestamo =
            json(await cobrar([pieza(pid, 3)], envModo: 'prestamo'))['id']
                as String;
        final l1 =
            (((await detalle(prestamo))['lineas'] as List).single
                as Map)['lineaId'];
        await s.post('/api/v1/ventas/$prestamo/devolver', {
          'lineas': [
            {'lineaId': l1, 'cantidad': 1},
          ],
        });
        final prestamos =
            json(await s.get('/api/v1/envases/prestamos'))['prestamos'] as List;
        expect((prestamos.single as Map)['cantidad'], 2);
        expect(
          (await balance('mega'))['prestados'],
          (antes['prestados'] as int) + 2,
        );

        final trae =
            json(await cobrar([pieza(pid, 2)], envModo: 'trae'))['id']
                as String;
        final l2 =
            (((await detalle(trae))['lineas'] as List).single
                as Map)['lineaId'];
        await s.post('/api/v1/ventas/$trae/devolver', {
          'lineas': [
            {'lineaId': l2, 'cantidad': 1},
          ],
        });
        expect((await balance('mega'))['bodega'], (antes['bodega'] as int) + 1);
      },
    );

    test('con un gerente o dueño, cancelar y devolver piden su PIN', () async {
      await crearUsuario('Don Beto', 'dueno', '9999');
      await crearUsuario('Ana', 'cajero', '1111', pinAutoriza: '9999');
      final gerente = await crearUsuario(
        'Sofía',
        'gerente',
        '5555',
        pinAutoriza: '9999',
      );
      final pid = await crearProducto();
      final ventaId = json(await cobrar([pieza(pid)]))['id'] as String;
      final url = '/api/v1/ventas/$ventaId/cancelar';

      expect(codigoError(await s.post(url, null)), 'pin_invalido');
      expect(codigoError(await s.post(url, {'pin': '1111'})), 'sin_permiso');
      expect(codigoError(await s.post(url, {'pin': '0000'})), 'pin_invalido');
      expect((await s.post(url, {'pin': '5555'})).statusCode, 204);

      final venta = DetalleVenta.fromJson(await detalle(ventaId));
      expect(venta.devoluciones.single.autorizo?.nombre, gerente['nombre']);
    });

    test('quién cobra y quién abre queda en la venta y el turno', () async {
      final dueno = await crearUsuario('Don Beto', 'dueno', '9999');
      final pid = await crearProducto();
      final r = await cobrar([pieza(pid)], usuarioId: dueno['id'] as String);
      await cobrar([pieza(pid)]);
      final ventaId = json(r)['id'] as String;
      expect((await detalle(ventaId))['usuario'], {
        'id': dueno['id'],
        'nombre': 'Don Beto',
      });

      final suyas =
          json(await s.get('/api/v1/ventas?usuario=${dueno['id']}'))['ventas']
              as List;
      expect(suyas.single, containsPair('id', ventaId));

      final inexistente = await cobrar([pieza(pid)], usuarioId: 'u_nada');
      expect(camposError(inexistente).keys, ['usuarioId']);

      await s.post('/api/v1/caja/cerrar', {
        'contado': 50000 + 2 * 4200,
        'usuarioId': dueno['id'],
      }, cabeceras: idem());
      final abierto = await s.post('/api/v1/caja/abrir', {
        'fondo': 0,
        'usuarioId': dueno['id'],
      });
      final turno = Turno.fromJson((json(abierto)['turno'] as Map).cast());
      expect(turno.usuarioApertura?.nombre, 'Don Beto');
      final corte = Turno.fromJson(
        ((json(await s.get('/api/v1/caja/cortes'))['cortes'] as List).single
                as Map)
            .cast(),
      );
      expect(corte.usuarioCierre?.nombre, 'Don Beto');
    });
  });

  group('envases', () {
    test('prestar saca de bodega y guarda el teléfono', () async {
      final antes = await balance('mega');
      final r = await s.post('/api/v1/envases/prestamos', {
        'cliente': 'Don Pedro',
        'telefono': '55 1234 5678',
        'formato': 'mega',
        'cantidad': 10,
      });
      expect(r.statusCode, 201);
      final despues = await balance('mega');
      expect(despues['bodega'], (antes['bodega'] as int) - 10);
      expect(despues['prestados'], (antes['prestados'] as int) + 10);
      final prestamo = PrestamoEnvase.fromJson(
        ((json(await s.get('/api/v1/envases/prestamos'))['prestamos'] as List)
                    .single
                as Map)
            .cast(),
      );
      expect(prestamo.telefono, '55 1234 5678');

      final deMas = await s.post('/api/v1/envases/prestamos', {
        'cliente': 'Don Pedro',
        'formato': 'mega',
        'cantidad': 1000,
      });
      expect(codigoError(deMas), 'envases_insuficientes');
    });

    test('sacar vacíos de bodega', () async {
      final antes = await balance('cuarto');
      final r = await s.post('/api/v1/envases/salida', {
        'formato': 'cuarto',
        'cantidad': 24,
        'motivo': 'Cambio con el proveedor',
      });
      expect(r.statusCode, 200);
      expect(
        (await balance('cuarto'))['bodega'],
        (antes['bodega'] as int) - 24,
      );
      final sinMotivo = await s.post('/api/v1/envases/salida', {
        'formato': 'cuarto',
        'cantidad': 1,
      });
      expect(camposError(sinMotivo).keys, ['motivo']);
    });

    test('devolver depósito mete vacíos y saca el dinero de caja', () async {
      final sinCaja = await s.post('/api/v1/envases/devolucion-deposito', {
        'formato': 'media',
        'cantidad': 12,
      }, cabeceras: idem());
      expect(codigoError(sinCaja), 'caja_cerrada');

      await s.abrirCaja();
      final antes = await balance('media');
      const clave = {cabeceraIdempotencia: 'deposito-don-jose'};
      final r = await s.post('/api/v1/envases/devolucion-deposito', {
        'formato': 'media',
        'cantidad': 12,
        'cliente': 'Don José',
      }, cabeceras: clave);
      expect(r.statusCode, 201, reason: r.body);
      final reintento = await s.post('/api/v1/envases/devolucion-deposito', {
        'formato': 'media',
        'cantidad': 12,
        'cliente': 'Don José',
      }, cabeceras: clave);
      expect(json(reintento), json(r));

      expect((await balance('media'))['bodega'], (antes['bodega'] as int) + 12);
      final mov = MovimientoCaja.fromJson(
        (json(r)['movimiento'] as Map).cast(),
      );
      expect((mov.tipo, mov.monto), ('retiro', 12 * 300));
      expect(mov.motivo, contains('Don José'));
      final turno = Turno.fromJson((json(r)['turno'] as Map).cast());
      expect(turno.resumen.retiros, 3600);

      final demasiado = await s.post('/api/v1/envases/devolucion-deposito', {
        'formato': 'mega',
        'cantidad': 80,
      }, cabeceras: idem());
      expect(camposError(demasiado).keys, [
        'monto',
      ], reason: 'no alcanza el efectivo');
    });

    test('la bitácora de envases registra cada cambio', () async {
      await s.post('/api/v1/envases/entrada', {
        'formato': 'mega',
        'cantidad': 5,
      });
      final pre = json(
        await s.post('/api/v1/envases/prestamos', {
          'cliente': 'Don Pedro',
          'formato': 'mega',
          'cantidad': 3,
        }),
      )['id'];
      await s.post('/api/v1/envases/prestamos/$pre/devolver', {'cantidad': 1});
      await s.post('/api/v1/envases/salida', {
        'formato': 'media',
        'cantidad': 2,
        'motivo': 'Rotos',
      });

      final movs = [
        for (final m
            in json(await s.get('/api/v1/envases/movimientos'))['movimientos']
                as List)
          MovimientoEnvase.fromJson((m as Map).cast()),
      ];
      expect(
        [for (final m in movs) m.tipo],
        ['salida', 'devolucion_prestamo', 'prestamo', 'entrada'],
      );
      expect(
        (movs[2].bodega, movs[2].prestados, movs[2].cliente),
        (-3, 3, 'Don Pedro'),
      );
      expect(movs.first.referencia, 'Rotos');

      final uno =
          json(
                await s.get('/api/v1/envases/movimientos?limite=1'),
              )['movimientos']
              as List;
      expect(uno, hasLength(1));
      final mal = await s.get('/api/v1/envases/movimientos?limite=0');
      expect(camposError(mal).keys, ['limite']);
    });
  });

  group('ajustes y respaldo', () {
    test('se leen, se guardan y null borra', () async {
      expect(json(await s.get('/api/v1/ajustes')), {
        'nombreNegocio': null,
        'direccion': null,
        'telefono': null,
        'mensajeTicket': null,
      });
      final r = await s.put('/api/v1/ajustes', {
        'nombreNegocio': 'Depósito Don Beto',
        'telefono': '961 123 4567',
      });
      expect(
        AjustesNegocio.fromJson(json(r)).nombreNegocio,
        'Depósito Don Beto',
      );
      await s.put('/api/v1/ajustes', {'telefono': null});
      final leidos = AjustesNegocio.fromJson(
        json(await s.get('/api/v1/ajustes')),
      );
      expect(
        (leidos.nombreNegocio, leidos.telefono),
        ('Depósito Don Beto', null),
      );

      final largo = await s.put('/api/v1/ajustes', {'telefono': '1' * 21});
      expect(camposError(largo).keys, ['telefono']);

      final clave = await s.registrarTerminal();
      expect((await s.get('/api/v1/ajustes', clave: clave)).statusCode, 200);
      expect(
        codigoError(await s.put('/api/v1/ajustes', {}, clave: clave)),
        'solo_caja',
      );
    });

    test('el respaldo es la base SQLite completa', () async {
      await crearProducto();
      final r = await s.get('/api/v1/respaldo');
      expect(r.statusCode, 200);
      expect(utf8.decode(r.bodyBytes.sublist(0, 15)), 'SQLite format 3');
      expect(
        r.headers['content-disposition'],
        'attachment; filename="anaquel-20261024-180000.db"',
      );
      final clave = await s.registrarTerminal();
      expect(
        codigoError(await s.get('/api/v1/respaldo', clave: clave)),
        'solo_caja',
      );
    });
  });
}
