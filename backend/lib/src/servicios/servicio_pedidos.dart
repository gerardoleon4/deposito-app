import 'package:sqlite3/sqlite3.dart';

import '../comun/fechas.dart';
import '../comun/json.dart';
import '../comun/seguridad.dart';
import '../db/base_datos.dart';
import '../modelos/evento.dart';
import '../ws/hub.dart';

class ServicioPedidos {
  ServicioPedidos({
    required this._db,
    required this._hub,
    this._reloj = relojSistema,
  });

  final Database _db;
  final Hub _hub;
  final Reloj _reloj;

  Map<String, Object?> crear(
    Map<String, Object?> datos, {
    required String origen,
  }) {
    final v = Validador(datos);
    final nota = v.texto('nota', requerido: false, max: 120);
    final lineas = datos['lineas'];
    if (lineas is! List || lineas.isEmpty) {
      v.error('lineas', 'Debe contener productos');
    }
    v.comprobar();

    final pedidoId = generarId('ped');
    final fecha = instanteIso(_reloj());

    transaccion(_db, () {
      _db.execute(
        'INSERT INTO pedidos (id, origen, fecha, nota) VALUES (?, ?, ?, ?)',
        [pedidoId, origen, fecha, nota],
      );

      for (final l in (lineas as List)) {
        if (l is! Map) continue;
        _db.execute(
          'INSERT INTO pedido_lineas (pedido_id, producto_id, unidad, cantidad) VALUES (?, ?, ?, ?)',
          [pedidoId, l['productoId'], l['unidad'], l['cantidad']],
        );
      }
    });

    final payload = {
      'id': pedidoId,
      'origen': origen,
      'fecha': fecha,
      'nota': nota,
      'lineas': lineas,
    };

    _hub.emitir(TiposEvento.pedidoCreado, {'pedido': payload});
    return payload;
  }

  List<Map<String, Object?>> listarPendientes() {
    final filas = _db.select(
      'SELECT * FROM pedidos WHERE atendido = 0 ORDER BY fecha ASC',
    );
    return [
      for (final f in filas)
        {
          'id': f['id'],
          'origen': f['origen'],
          'fecha': f['fecha'],
          'nota': f['nota'],
          'lineas': _db
              .select(
                'SELECT producto_id, unidad, cantidad FROM pedido_lineas WHERE pedido_id = ?',
                [f['id']],
              )
              .map(
                (l) => {
                  'productoId': l['producto_id'],
                  'unidad': l['unidad'],
                  'cantidad': l['cantidad'],
                },
              )
              .toList(),
        },
    ];
  }

  void descartar(String id) {
    _db.execute('UPDATE pedidos SET atendido = 1 WHERE id = ?', [id]);
    _hub.emitir(TiposEvento.pedidoAtendido, {'id': id});
  }
}
