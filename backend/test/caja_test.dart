import 'dart:async';
import 'dart:convert';

import 'package:deposito_backend/deposito_backend.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:web_socket_channel/io.dart';

import 'ayudantes/servidor_prueba.dart';

/// Caja: turnos, movimientos, cortes y su efecto en las ventas.
void main() {
  late ServidorPrueba s;
  var claves = 0;

  setUp(() async => s = await crearServidorDePrueba());
  tearDown(() => s.cerrar());

  Map<String, String> idem([String? clave]) => {
    cabeceraIdempotencia: clave ?? 'clave-caja-${claves++}',
  };

  Future<http.Response> cobrar(
    String productoId, {
    String metodo = 'efectivo',
    int cantidad = 1,
    String envModo = 'na',
  }) => s.post('/api/v1/ventas', {
    'metodo': metodo,
    'envModo': envModo,
    'lineas': [
      {'productoId': productoId, 'unidad': 'pieza', 'cantidad': cantidad},
    ],
  }, cabeceras: idem());

  Future<http.Response> movimiento(
    String tipo,
    int monto, {
    String motivo = 'Prueba',
    String? clave,
  }) => s.post('/api/v1/caja/movimientos', {
    'tipo': tipo,
    'monto': monto,
    'motivo': motivo,
  }, cabeceras: idem(clave));

  Future<http.Response> cerrarCaja(
    int contado, {
    String? nota,
    String? clave,
  }) => s.post('/api/v1/caja/cerrar', {
    'contado': contado,
    'nota': ?nota,
  }, cabeceras: idem(clave));

  Future<String> crearProducto([
    Map<String, Object?> cambios = const {},
  ]) async =>
      json(await s.post('/api/v1/productos', productoValido(cambios)))['id']
          as String;

  Future<Map<String, Object?>> turnoActual() async =>
      json(await s.get('/api/v1/caja/turno'));

  Map<String, Object?> resumenDe(Map<String, Object?> turno) =>
      (turno['resumen'] as Map).cast();

  group('sin turno abierto', () {
    test('el turno actual es null y no se cobra', () async {
      expect(await turnoActual(), {'turno': null, 'movimientos': []});

      final pid = await crearProducto();
      final venta = await cobrar(pid);
      expect(venta.statusCode, 409);
      expect(codigoError(venta), 'caja_cerrada');

      final vacios = await s.post('/api/v1/envases/venta-vacios', {
        'formato': 'mega',
        'cantidad': 1,
        'metodo': 'efectivo',
      }, cabeceras: idem());
      expect(codigoError(vacios), 'caja_cerrada');

      expect(codigoError(await movimiento('ingreso', 100)), 'caja_cerrada');
      expect(codigoError(await cerrarCaja(0)), 'caja_cerrada');
    });

    test('ventas?turno=actual es una lista vacía', () async {
      final r = await s.get('/api/v1/ventas?turno=actual');
      expect(r.statusCode, 200);
      expect(json(r)['ventas'], isEmpty);
    });
  });

  group('abrir', () {
    test('abre con fondo y no deja abrir otro', () async {
      final r = await s.post('/api/v1/caja/abrir', {'fondo': 50000});
      expect(r.statusCode, 201);
      final turno = Turno.fromJson((json(r)['turno'] as Map).cast());
      expect(turno.id, startsWith('tur_'));
      expect(turno.abierto, isTrue);
      expect(turno.fondo, 50000);
      expect(turno.resumen.esperado, 50000);
      expect(turno.contado, isNull);

      final otra = await s.post('/api/v1/caja/abrir', {'fondo': 0});
      expect(otra.statusCode, 409);
      expect(codigoError(otra), 'caja_abierta');
    });

    test('el fondo es un entero de centavos mayor o igual que 0', () async {
      for (final fondo in [-1, 10.5, '500', null]) {
        final r = await s.post('/api/v1/caja/abrir', {'fondo': fondo});
        expect(r.statusCode, 400, reason: '$fondo');
        expect(camposError(r).keys, ['fondo']);
      }
      final cero = await s.post('/api/v1/caja/abrir', {'fondo': 0});
      expect(cero.statusCode, 201);
    });
  });

  group('con turno abierto', () {
    late String turnoId;

    setUp(() async => turnoId = (await s.abrirCaja())['id'] as String);

    test('cada venta queda en el turno', () async {
      final pid = await crearProducto();
      final venta = json(await cobrar(pid));
      expect(venta['turnoId'], turnoId);

      final detalle = json(await s.get('/api/v1/ventas/${venta['id']}'));
      expect(detalle['turnoId'], turnoId);
      final lista = json(await s.get('/api/v1/ventas?turno=actual'));
      expect(
        (lista['ventas'] as List).single,
        containsPair('turnoId', turnoId),
      );
    });

    test('el resumen suma efectivo, tarjeta, envases y movimientos', () async {
      // Victoria Mega: $42 la pieza, envase mega con depósito de $8.
      final pid = await crearProducto({'existenciaPiezas': 20});
      expect((await cobrar(pid, envModo: 'cobrar')).statusCode, 201); // 5000
      expect(
        (await cobrar(pid, metodo: 'tarjeta', cantidad: 2)).statusCode,
        201,
      ); // 8400
      final vacios = await s.post('/api/v1/envases/venta-vacios', {
        'formato': 'mega',
        'cantidad': 2,
        'metodo': 'efectivo',
      }, cabeceras: idem()); // 1600
      expect(vacios.statusCode, 201);
      final cancelada = json(await cobrar(pid)); // 4200, se cancela
      expect(
        (await s.post(
          '/api/v1/ventas/${cancelada['id']}/cancelar',
          null,
        )).statusCode,
        204,
      );
      expect((await movimiento('ingreso', 10000)).statusCode, 201);
      expect((await movimiento('retiro', 3000)).statusCode, 201);

      final actual = await turnoActual();
      expect(resumenDe((actual['turno'] as Map).cast()), {
        'ventas': 3,
        'canceladas': 1,
        'ventasEfectivo': 6600,
        'ventasTarjeta': 8400,
        'envases': 2400,
        'devoluciones': 4200,
        'ingresos': 10000,
        'retiros': 3000,
        'esperado': 50000 + 6600 + 10000 - 3000,
      });
      final movs = actual['movimientos'] as List;
      expect([for (final m in movs) (m as Map)['tipo']], ['ingreso', 'retiro']);
    });

    test(
      'un movimiento repetido con la misma clave no se registra dos veces',
      () async {
        final primero = await movimiento(
          'retiro',
          1500,
          clave: 'retiro-hielo-1',
        );
        final segundo = await movimiento(
          'retiro',
          1500,
          clave: 'retiro-hielo-1',
        );
        expect(primero.statusCode, 201);
        expect(segundo.statusCode, 201);
        expect(json(segundo), json(primero));
        final m = MovimientoCaja.fromJson(
          (json(primero)['movimiento'] as Map).cast(),
        );
        expect(m.id, startsWith('mc_'));
        expect(m.motivo, 'Prueba');

        final actual = await turnoActual();
        expect(actual['movimientos'], hasLength(1));
        expect(resumenDe((actual['turno'] as Map).cast())['retiros'], 1500);
      },
    );

    test('valida el movimiento', () async {
      final r = await s.post('/api/v1/caja/movimientos', {
        'tipo': 'prestamo',
        'monto': 0,
        'motivo': '',
      }, cabeceras: idem());
      expect(r.statusCode, 400);
      expect(camposError(r).keys, containsAll(['tipo', 'monto', 'motivo']));

      final sinClave = await s.post('/api/v1/caja/movimientos', {
        'tipo': 'ingreso',
        'monto': 100,
        'motivo': 'Cambio',
      });
      expect(camposError(sinClave).keys, ['X-Clave-Idempotencia']);
    });

    test('un retiro no puede dejar el esperado en negativo', () async {
      final r = await movimiento('retiro', 50001);
      expect(r.statusCode, 400);
      expect(camposError(r).keys, ['monto']);
      expect((await movimiento('retiro', 50000)).statusCode, 201);
    });

    test('cerrar con diferencia exige nota y guarda el corte', () async {
      await movimiento('ingreso', 1000);
      final sinNota = await cerrarCaja(50000);
      expect(sinNota.statusCode, 400);
      expect(camposError(sinNota).keys, ['nota']);

      final r = await cerrarCaja(
        50000,
        nota: 'Faltó cambio',
        clave: 'corte-turno-1',
      );
      expect(r.statusCode, 200);
      final corte = Turno.fromJson((json(r)['turno'] as Map).cast());
      expect(corte.estado, 'cerrado');
      expect(corte.cierre, isNotNull);
      expect(corte.resumen.esperado, 51000);
      expect(corte.contado, 50000);
      expect(corte.diferencia, -1000);
      expect(corte.nota, 'Faltó cambio');

      // Si la respuesta se perdió, el reintento recibe el mismo corte.
      final reintento = await cerrarCaja(
        50000,
        nota: 'Faltó cambio',
        clave: 'corte-turno-1',
      );
      expect(reintento.statusCode, 200);
      expect(json(reintento), json(r));

      // Ya cerrada: no se cobra ni se vuelve a cerrar.
      expect(codigoError(await cerrarCaja(0)), 'caja_cerrada');
      expect(await turnoActual(), {'turno': null, 'movimientos': []});
    });

    test('cerrar cuadrado no pide nota', () async {
      final r = await cerrarCaja(50000);
      expect(r.statusCode, 200);
      expect((json(r)['turno'] as Map)['diferencia'], 0);
    });

    test('cortes y detalle del corte', () async {
      await movimiento('ingreso', 2000, motivo: 'Más cambio');
      await cerrarCaja(52000);
      await s.abrirCaja(fondo: 10000);

      final lista = json(await s.get('/api/v1/caja/cortes'));
      final cortes = lista['cortes'] as List;
      expect(cortes, hasLength(1), reason: 'el turno abierto no es corte');
      expect((cortes.single as Map)['id'], turnoId);

      final detalle = DetalleTurno.fromJson(
        json(await s.get('/api/v1/caja/cortes/$turnoId')),
      );
      expect(detalle.turno!.estado, 'cerrado');
      expect(detalle.movimientos.single.motivo, 'Más cambio');

      final noExiste = await s.get('/api/v1/caja/cortes/tur_nada');
      expect(codigoError(noExiste), 'no_encontrado');

      final malRango = await s.get(
        '/api/v1/caja/cortes?desde=2026-10-31&hasta=2026-10-01',
      );
      expect(camposError(malRango).keys, ['hasta']);
      final malaFecha = await s.get('/api/v1/caja/cortes?desde=ayer');
      expect(camposError(malaFecha).keys, ['desde']);
    });

    test('no se cancela una venta de un turno con corte', () async {
      final pid = await crearProducto();
      final venta = json(await cobrar(pid));
      await cerrarCaja(50000 + 4200);
      await s.abrirCaja();

      final r = await s.post('/api/v1/ventas/${venta['id']}/cancelar', null);
      expect(r.statusCode, 409);
      expect(codigoError(r), 'turno_cerrado');
    });

    test('ventas por turno, por id y filtros inválidos', () async {
      final pid = await crearProducto();
      await cobrar(pid);
      await cerrarCaja(54200);
      await s.abrirCaja();
      await cobrar(pid);

      final actual = json(await s.get('/api/v1/ventas?turno=actual'));
      expect(actual['ventas'], hasLength(1));
      final anterior = json(await s.get('/api/v1/ventas?turno=$turnoId'));
      expect(anterior['ventas'], hasLength(1));
      final todas = json(await s.get('/api/v1/ventas'));
      expect(todas['ventas'], hasLength(2));

      final ambos = await s.get('/api/v1/ventas?turno=actual&dia=2026-10-02');
      expect(camposError(ambos).keys, ['turno']);
      final malDia = await s.get('/api/v1/ventas?dia=2026-02-30');
      expect(camposError(malDia).keys, ['dia']);
    });

    test('cancelar una venta "trae" no deja la bodega negativa', () async {
      final pid = await crearProducto();
      final antes = json(await s.get('/api/v1/envases'))['balance'] as Map;
      final enBodega = (antes['mega'] as Map)['bodega'] as int;
      final venta = json(await cobrar(pid, envModo: 'trae'));

      // Se venden todos los vacíos de bodega, incluido el que trajo.
      final vacios = await s.post('/api/v1/envases/venta-vacios', {
        'formato': 'mega',
        'cantidad': enBodega + 1,
        'metodo': 'efectivo',
      }, cabeceras: idem());
      expect(vacios.statusCode, 201);

      final r = await s.post('/api/v1/ventas/${venta['id']}/cancelar', null);
      expect(r.statusCode, 409);
      expect(codigoError(r), 'envases_insuficientes');
      final detalle = json(await s.get('/api/v1/ventas/${venta['id']}'));
      expect(detalle['cancelada'], isFalse, reason: 'no cambió nada');
    });
  });

  test('una terminal no usa la caja', () async {
    final clave = await s.registrarTerminal();
    for (final r in [
      await s.get('/api/v1/caja/turno', clave: clave),
      await s.post('/api/v1/caja/abrir', {'fondo': 0}, clave: clave),
      await s.get('/api/v1/caja/cortes', clave: clave),
    ]) {
      expect(r.statusCode, 403);
      expect(codigoError(r), 'solo_caja');
    }
  });

  test('un turno que cruza la medianoche es un solo corte', () async {
    // 23:30 del 24 de octubre en el local (UTC-6).
    var ahora = DateTime.utc(2026, 10, 25, 5, 30);
    final local = await crearServidorDePrueba(reloj: () => ahora);
    addTearDown(local.cerrar);

    final turno = await local.abrirCaja();
    expect(turno['diaNegocio'], '2026-10-24');

    final pid = json(
      await local.post('/api/v1/productos', productoValido()),
    )['id'];
    ahora = DateTime.utc(2026, 10, 25, 7); // 01:00 del 25
    final venta = json(
      await local.post('/api/v1/ventas', {
        'metodo': 'efectivo',
        'lineas': [
          {'productoId': pid, 'unidad': 'pieza', 'cantidad': 1},
        ],
      }, cabeceras: idem()),
    );
    expect(venta['diaNegocio'], '2026-10-25');
    expect(venta['turnoId'], turno['id']);

    await local.post('/api/v1/caja/cerrar', {
      'contado': 54200,
    }, cabeceras: idem());
    final cortes =
        json(
              await local.get(
                '/api/v1/caja/cortes?desde=2026-10-24&hasta=2026-10-24',
              ),
            )['cortes']
            as List;
    expect(cortes, hasLength(1));
    expect((cortes.single as Map)['resumen'], containsPair('ventas', 1));
  });

  test('con datos de ejemplo arranca con un turno abierto', () async {
    final demo = await crearServidorDePrueba(datosEjemplo: true);
    addTearDown(demo.cerrar);
    final turno = json(await demo.get('/api/v1/caja/turno'))['turno'] as Map;
    expect(turno['estado'], 'abierto');
    expect(turno['fondo'], 50000);
  });

  group('devolución de préstamos', () {
    Future<String> prestar(int cantidad) async =>
        json(
              await s.post('/api/v1/envases/prestamos', {
                'cliente': 'Don Pedro',
                'formato': 'mega',
                'cantidad': cantidad,
              }),
            )['id']
            as String;

    Future<Map<String, Object?>> mega() async =>
        ((json(await s.get('/api/v1/envases'))['balance'] as Map)['mega']
                as Map)
            .cast();

    test('parcial y después el resto', () async {
      final id = await prestar(10);
      final antes = await mega();

      final parcial = await s.post('/api/v1/envases/prestamos/$id/devolver', {
        'cantidad': 4,
      });
      expect(parcial.statusCode, 204);
      final despues = await mega();
      expect(despues['bodega'], (antes['bodega'] as int) + 4);
      expect(despues['prestados'], (antes['prestados'] as int) - 4);

      final activos =
          json(await s.get('/api/v1/envases/prestamos'))['prestamos'] as List;
      final prestamo = PrestamoEnvase.fromJson((activos.single as Map).cast());
      expect(prestamo.cantidad, 6);
      expect(prestamo.devueltos, 4);

      final demasiado = await s.post('/api/v1/envases/prestamos/$id/devolver', {
        'cantidad': 7,
      });
      expect(camposError(demasiado).keys, ['cantidad']);

      final resto = await s.post('/api/v1/envases/prestamos/$id/devolver', '');
      expect(resto.statusCode, 204);
      expect(
        json(await s.get('/api/v1/envases/prestamos'))['prestamos'],
        isEmpty,
      );
      expect((await mega())['prestados'], (antes['prestados'] as int) - 10);
    });
  });

  group('WebSocket', () {
    Future<StreamIterator<Map<String, Object?>>> conectar(String clave) async {
      final canal = IOWebSocketChannel.connect(
        s.uri('/api/v1/ws').replace(scheme: 'ws'),
        headers: {cabeceraClave: clave},
      );
      await canal.ready;
      addTearDown(canal.sink.close);
      final eventos = StreamIterator(
        canal.stream.map(
          (m) => jsonDecode(m as String) as Map<String, Object?>,
        ),
      );
      expect(await eventos.moveNext(), isTrue); // conexion.lista
      return eventos;
    }

    Future<String> siguiente(StreamIterator<Map<String, Object?>> e) async {
      expect(await e.moveNext().timeout(const Duration(seconds: 2)), isTrue);
      return e.current['tipo'] as String;
    }

    /// Tipos recibidos hasta [tipo], incluido.
    Future<List<String>> hasta(
      StreamIterator<Map<String, Object?>> e,
      String tipo,
    ) async {
      final tipos = <String>[];
      while (tipos.isEmpty || tipos.last != tipo) {
        tipos.add(await siguiente(e));
      }
      return tipos;
    }

    test('caja.* solo llega a la caja; venta.* llega a todos', () async {
      final pid = await crearProducto();
      final caja = await conectar(s.claveCaja);
      final terminal = await conectar(await s.registrarTerminal());

      await s.abrirCaja();
      expect(await siguiente(caja), 'caja.abierta');

      await cobrar(pid);
      // Sin envModo el balance de envases no cambia: no hay envases.actualizado.
      expect(await hasta(caja, 'venta.registrada'), [
        'producto.actualizado',
        'venta.registrada',
      ]);
      // La terminal no recibió caja.abierta: lo primero es la venta.
      expect(await hasta(terminal, 'venta.registrada'), [
        'producto.actualizado',
        'venta.registrada',
      ]);
      expect(
        ((terminal.current['datos'] as Map)['venta'] as Map)['folio'],
        1001,
      );

      await movimiento('ingreso', 100);
      expect(await siguiente(caja), 'caja.actualizada');
      await cerrarCaja(50100 + 4200);
      expect(await siguiente(caja), 'caja.cerrada');
      expect(
        ((caja.current['datos'] as Map)['turno'] as Map)['estado'],
        'cerrado',
      );
    });

    test('cancelar avisa venta.cancelada', () async {
      final pid = await crearProducto();
      await s.abrirCaja();
      final venta = json(await cobrar(pid));
      final terminal = await conectar(await s.registrarTerminal());

      await s.post('/api/v1/ventas/${venta['id']}/cancelar', null);
      final tipos = [await siguiente(terminal), await siguiente(terminal)];
      expect(tipos, ['producto.actualizado', 'venta.cancelada']);
      expect(terminal.current['datos'], {'id': venta['id']});
    });
  });
}
