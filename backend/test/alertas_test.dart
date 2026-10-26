import 'package:deposito_backend/deposito_backend.dart';
import 'package:deposito_backend/src/comun/errores.dart';
import 'package:deposito_backend/src/db/base_datos.dart';
import 'package:deposito_backend/src/db/migraciones.dart';
import 'package:deposito_backend/src/db/repositorio_ajustes.dart';
import 'package:deposito_backend/src/db/repositorio_productos.dart';
import 'package:deposito_backend/src/servicios/servicio_alertas.dart';
import 'package:deposito_backend/src/servicios/servicio_productos.dart';
import 'package:deposito_backend/src/ws/hub.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import 'ayudantes/servidor_prueba.dart';

/// Guarda lo que se emite en vez de mandarlo por WebSocket.
class _HubEspia extends Hub {
  _HubEspia() : super(version: 'prueba', bitacora: Bitacora.silenciosa());

  final emitidos = <({String tipo, Map<String, Object?> datos})>[];

  List<Map<String, Object?>> get alertas => [
    for (final e in emitidos)
      if (e.tipo == TiposEvento.alertaNueva) (e.datos['alerta'] as Map).cast(),
  ];

  @override
  void emitir(String tipo, Map<String, Object?> datos) =>
      emitidos.add((tipo: tipo, datos: datos));
}

Producto _producto(
  String nombre, {
  int existencia = 10,
  int minimo = 0,
  String? caducidad,
}) => Producto(
  id: 'p_$nombre',
  codigo: nombre,
  nombre: nombre,
  categoria: 'cerveza',
  precio: 4200,
  existenciaPiezas: existencia,
  minimo: minimo,
  caducidad: caducidad,
  creado: '2026-10-02T18:30:00Z',
  actualizado: '2026-10-02T18:30:00Z',
);

void main() {
  group('calcularAlertas', () {
    List<(String, String, int?)> resumen(List<Alerta> alertas) => [
      for (final a in alertas) (a.tipo, a.producto.nombre, a.diasParaCaducar),
    ];

    test('clasifica existencia y caducidad según el contrato', () {
      final alertas = calcularAlertas(
        [
          _producto('agotado', existencia: 0, minimo: 5),
          _producto('poco', existencia: 3, minimo: 5),
          _producto('justo', existencia: 5, minimo: 5),
          _producto('sinMinimo', existencia: 0),
          _producto('vencido', caducidad: '2026-10-01'),
          _producto('hoy', caducidad: '2026-10-02'),
          _producto('enLaVentana', caducidad: '2026-11-01'),
          _producto('fuera', caducidad: '2026-11-02'),
          _producto('sinExistencia', existencia: 0, caducidad: '2026-10-01'),
        ],
        hoy: '2026-10-02',
        dias: 30,
      );

      expect(resumen(alertas), [
        ('agotado', 'agotado', null),
        ('poco_stock', 'poco', null),
        ('caducado', 'vencido', -1),
        ('por_caducar', 'hoy', 0),
        ('por_caducar', 'enLaVentana', 30),
      ]);
    });

    test('un producto puede tener alerta de existencia y de caducidad', () {
      final alertas = calcularAlertas(
        [_producto('doble', existencia: 2, minimo: 6, caducidad: '2026-10-05')],
        hoy: '2026-10-02',
        dias: 30,
      );
      expect(resumen(alertas), [
        ('poco_stock', 'doble', null),
        ('por_caducar', 'doble', 3),
      ]);
    });

    test('ordena por urgencia dentro de cada tipo y luego por nombre', () {
      final alertas = calcularAlertas(
        [
          _producto('b', existencia: 5, minimo: 10), // la mitad
          _producto('a', existencia: 9, minimo: 10), // casi completo
          _producto('c', existencia: 2, minimo: 20), // una décima
          _producto('e', caducidad: '2026-10-20'),
          _producto('d', caducidad: '2026-10-04'),
          _producto('f', caducidad: '2026-10-04'),
          _producto('g', caducidad: '2026-09-01'),
          _producto('h', caducidad: '2026-09-30'),
        ],
        hoy: '2026-10-02',
        dias: 30,
      );
      expect(
        [for (final a in alertas) a.producto.nombre],
        ['c', 'b', 'a', 'g', 'h', 'd', 'f', 'e'],
      );
    });

    test('ida y vuelta por JSON', () {
      final a = calcularAlertas(
        [_producto('x', caducidad: '2026-10-03')],
        hoy: '2026-10-02',
        dias: 30,
      ).single;
      expect(Alerta.fromJson(a.toJson()).toJson(), a.toJson());
    });
  });

  group('ServicioAlertas', () {
    late Database db;
    late _HubEspia hub;
    late ServicioAlertas alertas;
    late ServicioProductos productos;
    var ahora = DateTime.utc(2026, 10, 2, 18, 30);

    void armar() {
      final repo = RepositorioProductos(db);
      alertas = ServicioAlertas(
        repoProductos: repo,
        repoAjustes: RepositorioAjustes(db),
        hub: hub,
        reloj: () => ahora,
      );
      productos = ServicioProductos(
        db: db,
        repositorio: repo,
        hub: hub,
        alertas: alertas,
        reloj: () => ahora,
      );
    }

    setUp(() {
      ahora = DateTime.utc(2026, 10, 2, 18, 30);
      db = abrirBaseDatos(enMemoria);
      aplicarMigraciones(db);
      hub = _HubEspia();
      armar();
    });
    tearDown(() => db.close());

    String crear(Map<String, Object?> cambios) =>
        productos.crear(productoValido(cambios), origen: 'Caja').id;

    void merma(String id, int piezas) => productos.ajustar(id, {
      'motivo': 'merma',
      'piezas': piezas,
    }, origen: 'Caja');

    test('lista con el día del negocio, no el de UTC', () {
      // 23:00 del 2 de octubre en el local = 05:00 del 3 en UTC.
      ahora = DateTime.utc(2026, 10, 3, 5);
      crear({'caducidad': '2026-10-02', 'minimo': 0});

      final r = alertas.listar();
      expect(r['dia'], '2026-10-02');
      expect(r['dias'], 30);
      final a = (r['alertas'] as List).single as Map;
      expect(a['tipo'], 'por_caducar');
      expect(a['diasParaCaducar'], 0);
    });

    test('dias cambia la ventana de caducidad', () {
      crear({'caducidad': '2026-10-12', 'minimo': 0});
      expect(alertas.listar(dias: '9')['alertas'], isEmpty);
      expect(alertas.listar(dias: '10')['alertas'], hasLength(1));
    });

    test('dias fuera de 1 a 365 o no entero es datos_invalidos', () {
      for (final dias in ['0', '366', 'abc', '2.5', '']) {
        expect(
          () => alertas.listar(dias: dias),
          throwsA(
            isA<ErrorApi>()
                .having((e) => e.codigo, 'codigo', 'datos_invalidos')
                .having((e) => e.campos, 'campos', contains('dias')),
          ),
          reason: dias,
        );
      }
    });

    test('avisa al bajar del mínimo y al agotarse, sin repetir', () {
      final id = crear({'existenciaPiezas': 40, 'minimo': 36});
      expect(hub.alertas, isEmpty);

      merma(id, 5); // 35: baja del mínimo
      expect(hub.alertas.map((a) => a['tipo']), ['poco_stock']);
      expect((hub.alertas.single['producto'] as Map)['existenciaPiezas'], 35);

      merma(id, 5); // 30: sigue igual
      expect(hub.alertas, hasLength(1));

      merma(id, 30); // 0: se agota
      expect(hub.alertas.map((a) => a['tipo']), ['poco_stock', 'agotado']);
    });

    test('no avisa cuando mejora, y vuelve a avisar si baja otra vez', () {
      final id = crear({'existenciaPiezas': 0, 'minimo': 10});
      expect(hub.alertas.map((a) => a['tipo']), ['agotado']);

      productos.registrarEntrada(id, {'piezas': 5}, origen: 'Caja');
      expect(hub.alertas, hasLength(1)); // agotado → poco_stock mejora

      productos.registrarEntrada(id, {'piezas': 10}, origen: 'Caja');
      merma(id, 7); // 15 → 8
      expect(hub.alertas.map((a) => a['tipo']), ['agotado', 'poco_stock']);
    });

    test('editar el mínimo por encima de la existencia avisa', () {
      final id = crear({'existenciaPiezas': 20, 'minimo': 10});
      productos.editar(id, productoValido({'minimo': 24}));
      expect(hub.alertas.map((a) => a['tipo']), ['poco_stock']);
    });

    test('al arrancar no avisa de lo que ya estaba bajo su mínimo', () {
      final id = crear({'existenciaPiezas': 20, 'minimo': 30});
      expect(hub.alertas, hasLength(1));

      hub = _HubEspia();
      armar(); // como reiniciar el servidor
      merma(id, 1);
      expect(hub.alertas, isEmpty);
    });

    test('el aviso sale después de producto.actualizado', () {
      crear({'existenciaPiezas': 0, 'minimo': 10});
      expect(
        [for (final e in hub.emitidos) e.tipo],
        [TiposEvento.productoActualizado, TiposEvento.alertaNueva],
      );
    });
  });
}
