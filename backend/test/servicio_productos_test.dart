import 'package:deposito_backend/deposito_backend.dart';
import 'package:deposito_backend/src/comun/errores.dart';
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
  final ahora = DateTime.utc(2026, 10, 2, 18, 30);

  setUp(() {
    db = abrirBaseDatos(enMemoria);
    aplicarMigraciones(db);
    servicio = ServicioProductos(
      db: db,
      repositorio: RepositorioProductos(db),
      hub: Hub(version: 'prueba', bitacora: Bitacora.silenciosa()),
      reloj: () => ahora,
    );
  });
  tearDown(() => db.dispose());

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
}
