import 'dart:io';
import 'dart:typed_data';

import 'package:deposito_backend/deposito_backend.dart';
import 'package:deposito_backend/src/comun/errores.dart';
import 'package:deposito_backend/src/db/almacen_fotos.dart';
import 'package:deposito_backend/src/db/base_datos.dart';
import 'package:deposito_backend/src/db/migraciones.dart';
import 'package:deposito_backend/src/db/repositorio_productos.dart';
import 'package:deposito_backend/src/servicios/servicio_productos.dart';
import 'package:deposito_backend/src/ws/hub.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import 'ayudantes/servidor_prueba.dart';

void main() {
  late Database db;
  late ServicioProductos servicio;
  late Directory fotos;
  var ahora = DateTime.utc(2026, 10, 2, 18, 30);

  setUp(() {
    ahora = DateTime.utc(2026, 10, 2, 18, 30);
    db = abrirBaseDatos(enMemoria);
    aplicarMigraciones(db);
    fotos = Directory.systemTemp.createTempSync('anaquel_prueba_');
    servicio = ServicioProductos(
      db: db,
      repositorio: RepositorioProductos(db),
      hub: Hub(version: 'prueba', bitacora: Bitacora.silenciosa()),
      fotos: AlmacenFotos(fotos.path),
      reloj: () => ahora,
    );
  });
  tearDown(() {
    db.close();
    fotos.deleteSync(recursive: true);
  });

  List<Row> movimientosDe(String id) => db.select(
    'SELECT * FROM movimientos WHERE producto_id = ? ORDER BY id',
    [id],
  );

  ErrorApi errorDe(void Function() accion) {
    try {
      accion();
    } on ErrorApi catch (e) {
      return e;
    }
    fail('Se esperaba un ErrorApi');
  }

  Map<String, String> camposConError(void Function() accion) {
    try {
      accion();
    } on ErrorApi catch (e) {
      expect(e.codigo, 'datos_invalidos');
      return e.campos!;
    }
    fail('Se esperaba datos_invalidos');
  }

  group('crear', () {
    test('guarda el producto con fechas UTC e ID con prefijo', () {
      final p = servicio.crear(productoValido(), origen: 'Caja');
      expect(p.id, startsWith('p_'));
      expect(p.creado, '2026-10-02T18:30:00Z');
      expect(servicio.obtener(p.id).toJson(), p.toJson());
    });

    test('registra la existencia inicial como movimiento de inventario', () {
      final p = servicio.crear(
        productoValido({'existenciaPiezas': 66}),
        origen: 'Caja',
      );
      final m = db.select('SELECT * FROM movimientos WHERE producto_id = ?', [
        p.id,
      ]);
      expect(m, hasLength(1));
      expect(m.first['tipo'], 'inicial');
      expect(m.first['piezas'], 66);
      expect(m.first['existencia_resultante'], 66);
      expect(m.first['origen'], 'Caja');
    });

    test('sin existencia inicial no hay movimiento', () {
      final p = servicio.crear(
        productoValido({'existenciaPiezas': null}),
        origen: 'Caja',
      );
      expect(p.existenciaPiezas, 0);
      expect(db.select('SELECT 1 FROM movimientos'), isEmpty);
    });

    test('el dinero con decimales se rechaza, no se redondea', () {
      final campos = camposConError(
        () => servicio.crear(productoValido({'precio': 42.5}), origen: 'Caja'),
      );
      expect(campos.keys, ['precio']);
    });

    test('precioCaja y piezasPorCaja van juntos', () {
      final campos = camposConError(
        () => servicio.crear(
          productoValido({'piezasPorCaja': null}),
          origen: 'Caja',
        ),
      );
      expect(campos.keys, ['piezasPorCaja']);
    });

    test('responde todos los campos con error a la vez', () {
      final campos = camposConError(
        () => servicio.crear({
          'codigo': '750 106',
          'precio': 0,
          'envase': 'litro',
          'caducidad': '2026-02-30',
        }, origen: 'Caja'),
      );
      expect(
        campos.keys,
        unorderedEquals([
          'codigo',
          'nombre',
          'categoria',
          'precio',
          'envase',
          'caducidad',
        ]),
      );
    });

    test('un código repetido es codigo_duplicado y no deja nada a medias', () {
      servicio.crear(productoValido(), origen: 'Caja');
      expect(
        () =>
            servicio.crear(productoValido({'nombre': 'Otro'}), origen: 'Caja'),
        throwsA(
          isA<ErrorApi>().having((e) => e.codigo, 'codigo', 'codigo_duplicado'),
        ),
      );
      expect(db.select('SELECT 1 FROM productos'), hasLength(1));
      expect(db.select('SELECT 1 FROM movimientos'), hasLength(1));
    });

    test('la categoría se guarda en minúsculas', () {
      expect(
        servicio
            .crear(productoValido({'categoria': 'Cerveza'}), origen: 'Caja')
            .categoria,
        'cerveza',
      );
    });
  });

  group('listar', () {
    setUp(() {
      servicio.crear(
        productoValido({'codigo': '1', 'nombre': 'Pacífico'}),
        origen: 'Caja',
      );
      servicio.crear(
        productoValido({
          'codigo': '2',
          'nombre': 'Coca-Cola',
          'categoria': 'refresco',
        }),
        origen: 'Caja',
      );
      servicio.crear(
        productoValido({'codigo': '3', 'nombre': 'Agua 100%'}),
        origen: 'Caja',
      );
    });

    test('ordena por nombre', () {
      expect(servicio.listar().map((p) => p.nombre), [
        'Agua 100%',
        'Coca-Cola',
        'Pacífico',
      ]);
    });

    test('busca sin distinguir mayúsculas ni acentos', () {
      expect(servicio.listar(busqueda: 'PACIF').map((p) => p.nombre), [
        'Pacífico',
      ]);
    });

    test('busca por código', () {
      expect(servicio.listar(busqueda: '2').map((p) => p.nombre), [
        'Coca-Cola',
      ]);
    });

    test('% y _ en la búsqueda son texto, no comodines', () {
      expect(servicio.listar(busqueda: '%').map((p) => p.nombre), [
        'Agua 100%',
      ]);
    });

    test('filtra por categoría', () {
      expect(servicio.listar(categoria: 'refresco').map((p) => p.nombre), [
        'Coca-Cola',
      ]);
    });
  });

  test('obtener un ID inexistente es no_encontrado', () {
    expect(
      () => servicio.obtener('p_no'),
      throwsA(isA<ErrorApi>().having((e) => e.estado, 'estado', 404)),
    );
  });

  group('editar', () {
    test('reemplaza los campos y no toca existencia, foto ni creado', () {
      final p = servicio.crear(productoValido(), origen: 'Caja');
      ahora = ahora.add(const Duration(hours: 1));
      final e = servicio.editar(
        p.id,
        productoValido({
          'nombre': 'Victoria Mega Retornable',
          'precio': 4500,
          'existenciaPiezas': 999,
          'caducidad': null,
        }),
      );
      expect(e.nombre, 'Victoria Mega Retornable');
      expect(e.precio, 4500);
      expect(e.existenciaPiezas, 66);
      expect(e.caducidad, isNull);
      expect(e.creado, p.creado);
      expect(e.actualizado, '2026-10-02T19:30:00Z');
      expect(movimientosDe(p.id), hasLength(1));
      expect(servicio.listar(busqueda: 'retornable').single.id, p.id);
    });

    test('puede conservar su código pero no tomar el de otro', () {
      final a = servicio.crear(productoValido(), origen: 'Caja');
      servicio.crear(productoValido({'codigo': '111'}), origen: 'Caja');
      expect(servicio.editar(a.id, productoValido()).codigo, a.codigo);
      expect(
        errorDe(() => servicio.editar(a.id, productoValido({'codigo': '111'})))
            .codigo,
        'codigo_duplicado',
      );
    });

    test('valida igual que al crear', () {
      final p = servicio.crear(productoValido(), origen: 'Caja');
      final campos = camposConError(
        () => servicio.editar(p.id, productoValido({'precioCaja': null})),
      );
      expect(campos.keys, ['precioCaja']);
    });

    test('un producto que no existe es no_encontrado', () {
      expect(
        errorDe(() => servicio.editar('p_no', productoValido())).estado,
        404,
      );
    });
  });

  group('eliminar', () {
    test('desaparece de las consultas y libera su código', () {
      final p = servicio.crear(productoValido(), origen: 'Caja');
      servicio.eliminar(p.id);
      expect(servicio.listar(), isEmpty);
      expect(errorDe(() => servicio.obtener(p.id)).estado, 404);
      expect(errorDe(() => servicio.porCodigo(p.codigo)).estado, 404);
      // Los movimientos se conservan.
      expect(movimientosDe(p.id), hasLength(1));
      expect(servicio.crear(productoValido(), origen: 'Caja').codigo, p.codigo);
    });

    test('eliminar dos veces es no_encontrado', () {
      final p = servicio.crear(productoValido(), origen: 'Caja');
      servicio.eliminar(p.id);
      expect(errorDe(() => servicio.eliminar(p.id)).estado, 404);
    });
  });

  group('entradas', () {
    test('suma cajas y piezas sueltas y deja el movimiento', () {
      final p = servicio.crear(productoValido(), origen: 'Caja');
      final e = servicio.registrarEntrada(p.id, {
        'cajas': 2,
        'piezas': 3,
        'nota': 'Proveedor Modelo',
      }, origen: 'Caja');
      expect(e.existenciaPiezas, 66 + 2 * 12 + 3);
      final m = movimientosDe(p.id).last;
      expect(m['tipo'], 'entrada');
      expect(m['piezas'], 27);
      expect(m['existencia_resultante'], 93);
      expect(m['nota'], 'Proveedor Modelo');
    });

    test('la caducidad se queda con la más próxima', () {
      final p = servicio.crear(
        productoValido({'caducidad': '2027-01-29'}),
        origen: 'Caja',
      );
      final tarde = servicio.registrarEntrada(p.id, {
        'piezas': 1,
        'caducidad': '2027-06-01',
      }, origen: 'Caja');
      expect(tarde.caducidad, '2027-01-29');
      final pronto = servicio.registrarEntrada(p.id, {
        'piezas': 1,
        'caducidad': '2026-12-01',
      }, origen: 'Caja');
      expect(pronto.caducidad, '2026-12-01');
    });

    test('sin existencias, manda la caducidad del lote nuevo', () {
      final p = servicio.crear(
        productoValido({'existenciaPiezas': 0, 'caducidad': '2026-11-01'}),
        origen: 'Caja',
      );
      final e = servicio.registrarEntrada(p.id, {
        'piezas': 12,
        'caducidad': '2027-05-01',
      }, origen: 'Caja');
      expect(e.caducidad, '2027-05-01');
    });

    test('cajas en un producto sin caja es datos_invalidos', () {
      final p = servicio.crear(
        productoValido({'precioCaja': null, 'piezasPorCaja': null}),
        origen: 'Caja',
      );
      expect(
        camposConError(
          () => servicio.registrarEntrada(p.id, {'cajas': 1}, origen: 'Caja'),
        ).keys,
        ['cajas'],
      );
    });

    test('una entrada vacía o negativa no pasa', () {
      final p = servicio.crear(productoValido(), origen: 'Caja');
      expect(
        camposConError(
          () => servicio.registrarEntrada(p.id, {}, origen: 'Caja'),
        ).keys,
        ['piezas'],
      );
      expect(
        camposConError(
          () => servicio.registrarEntrada(p.id, {'piezas': -5}, origen: 'Caja'),
        ).keys,
        ['piezas'],
      );
    });
  });

  group('ajustes', () {
    test('un conteo fija la existencia y registra la diferencia', () {
      final p = servicio.crear(productoValido(), origen: 'Caja');
      final a = servicio.ajustar(p.id, {
        'motivo': 'conteo',
        'existenciaPiezas': 60,
        'nota': 'Conteo del lunes',
      }, origen: 'Caja');
      expect(a.existenciaPiezas, 60);
      final m = movimientosDe(p.id).last;
      expect(m['tipo'], 'ajuste');
      expect(m['piezas'], -6);
      expect(m['existencia_resultante'], 60);
    });

    test('un conteo igual a la existencia no deja movimiento', () {
      final p = servicio.crear(productoValido(), origen: 'Caja');
      servicio.ajustar(p.id, {
        'motivo': 'conteo',
        'existenciaPiezas': 66,
      }, origen: 'Caja');
      expect(movimientosDe(p.id), hasLength(1));
    });

    test('una merma resta piezas', () {
      final p = servicio.crear(productoValido(), origen: 'Caja');
      final a = servicio.ajustar(p.id, {
        'motivo': 'merma',
        'piezas': 3,
      }, origen: 'Caja');
      expect(a.existenciaPiezas, 63);
      expect(movimientosDe(p.id).last['tipo'], 'merma');
      expect(movimientosDe(p.id).last['piezas'], -3);
    });

    test('una merma mayor que la existencia es stock_insuficiente', () {
      final p = servicio.crear(productoValido(), origen: 'Caja');
      expect(
        errorDe(
          () => servicio.ajustar(p.id, {
            'motivo': 'merma',
            'piezas': 67,
          }, origen: 'Caja'),
        ).codigo,
        'stock_insuficiente',
      );
      expect(servicio.obtener(p.id).existenciaPiezas, 66);
    });

    test('cada motivo pide su campo', () {
      final p = servicio.crear(productoValido(), origen: 'Caja');
      expect(
        camposConError(
          () => servicio.ajustar(p.id, {
            'motivo': 'conteo',
            'piezas': 3,
          }, origen: 'Caja'),
        ).keys,
        ['existenciaPiezas'],
      );
      expect(
        camposConError(
          () => servicio.ajustar(p.id, {
            'motivo': 'merma',
            'existenciaPiezas': 3,
          }, origen: 'Caja'),
        ).keys,
        ['piezas'],
      );
      expect(
        camposConError(
          () => servicio.ajustar(p.id, {'motivo': 'robo'}, origen: 'Caja'),
        ).keys,
        ['motivo'],
      );
    });
  });

  test('movimientos salen del más nuevo al más viejo', () {
    final p = servicio.crear(productoValido(), origen: 'Caja');
    ahora = ahora.add(const Duration(minutes: 5));
    servicio.registrarEntrada(p.id, {'piezas': 4}, origen: 'Caja');
    final m = servicio.movimientos(p.id);
    expect(m.map((x) => x.tipo), ['entrada', 'inicial']);
    expect(m.first.existenciaResultante, 70);
  });

  group('foto', () {
    final png = Uint8List.fromList(pngPrueba);
    final jpg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 1, 2]);

    test('se guarda, se lee y la ruta cambia con cada foto', () {
      final p = servicio.crear(productoValido(), origen: 'Caja');
      final a = servicio.guardarFoto(p.id, 'image/png', png);
      expect(a.foto, '/api/v1/productos/${p.id}/foto?v=1790965800000');
      expect(servicio.leerFoto(p.id).bytes, png);

      ahora = ahora.add(const Duration(seconds: 1));
      final b = servicio.guardarFoto(p.id, 'image/jpeg', jpg);
      expect(b.foto, isNot(a.foto));
      expect(servicio.leerFoto(p.id).tipo, 'image/jpeg');
      // La foto anterior con otra extensión ya no está.
      expect(fotos.listSync(), hasLength(1));
    });

    test('borrarla deja foto en null', () {
      final p = servicio.crear(productoValido(), origen: 'Caja');
      servicio.guardarFoto(p.id, 'image/png', png);
      expect(servicio.borrarFoto(p.id).foto, isNull);
      expect(errorDe(() => servicio.leerFoto(p.id)).estado, 404);
      expect(fotos.listSync(), isEmpty);
    });

    test('rechaza tipos no permitidos y contenido que no coincide', () {
      final p = servicio.crear(productoValido(), origen: 'Caja');
      for (final (tipo, bytes) in [
        ('image/gif', png),
        (null, png),
        ('image/jpeg', png),
        ('image/png', Uint8List(0)),
      ]) {
        expect(
          camposConError(() => servicio.guardarFoto(p.id, tipo, bytes)).keys,
          ['foto'],
          reason: '$tipo',
        );
      }
      expect(servicio.obtener(p.id).foto, isNull);
    });
  });
}
