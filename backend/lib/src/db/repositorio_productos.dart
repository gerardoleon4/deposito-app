import 'package:sqlite3/sqlite3.dart';

import '../comun/texto.dart';
import '../modelos/producto.dart';

/// Acceso a `productos` y `movimientos`. Sin reglas de negocio: eso va en
/// servicios/. Las escrituras se llaman dentro de una `transaccion`.
class RepositorioProductos {
  RepositorioProductos(this._db);

  final Database _db;

  List<Producto> listar({String? busqueda, String? categoria}) {
    final condiciones = ['eliminado = 0'];
    final parametros = <Object?>[];
    if (busqueda != null && busqueda.isNotEmpty) {
      condiciones.add(
        "(nombre_busqueda LIKE ? ESCAPE '\\' OR codigo LIKE ? ESCAPE '\\')",
      );
      final patron = '%${_escaparLike(normalizarBusqueda(busqueda))}%';
      parametros.addAll([patron, patron]);
    }
    if (categoria != null && categoria.isNotEmpty) {
      condiciones.add('categoria = ?');
      parametros.add(categoria);
    }
    return _db
        .select(
          'SELECT * FROM productos WHERE ${condiciones.join(' AND ')} '
          'ORDER BY nombre_busqueda, id',
          parametros,
        )
        .map(_desdeFila)
        .toList();
  }

  Producto? porId(String id) {
    final filas = _db.select(
      'SELECT * FROM productos WHERE id = ? AND eliminado = 0',
      [id],
    );
    return filas.isEmpty ? null : _desdeFila(filas.first);
  }

  bool existeCodigo(String codigo) => _db.select(
    'SELECT 1 FROM productos WHERE codigo = ? AND eliminado = 0',
    [codigo],
  ).isNotEmpty;

  void insertar(Producto p) {
    _db.execute(
      '''
      INSERT INTO productos (id, codigo, nombre, nombre_busqueda, categoria, presentacion,
        precio, precio_caja, piezas_por_caja, existencia_piezas, minimo, envase, caducidad,
        foto, creado, actualizado)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        p.id,
        p.codigo,
        p.nombre,
        normalizarBusqueda(p.nombre),
        p.categoria,
        p.presentacion,
        p.precio,
        p.precioCaja,
        p.piezasPorCaja,
        p.existenciaPiezas,
        p.minimo,
        p.envase,
        p.caducidad,
        p.foto,
        p.creado,
        p.actualizado,
      ],
    );
  }

  /// Registra un cambio de existencia. [piezas] lleva signo: `-3` en una venta.
  void registrarMovimiento({
    required String productoId,
    required String tipo,
    required int piezas,
    required int existenciaResultante,
    required String origen,
    required String fecha,
    String? referencia,
    String? nota,
  }) {
    _db.execute(
      '''
      INSERT INTO movimientos (producto_id, tipo, piezas, existencia_resultante, referencia,
        origen, nota, fecha)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        productoId,
        tipo,
        piezas,
        existenciaResultante,
        referencia,
        origen,
        nota,
        fecha,
      ],
    );
  }

  int contar() =>
      _db
              .select('SELECT COUNT(*) AS n FROM productos WHERE eliminado = 0')
              .first['n']
          as int;

  static String _escaparLike(String texto) => texto
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');

  static Producto _desdeFila(Row f) => Producto(
    id: f['id'] as String,
    codigo: f['codigo'] as String,
    nombre: f['nombre'] as String,
    categoria: f['categoria'] as String,
    presentacion: f['presentacion'] as String?,
    precio: f['precio'] as int,
    precioCaja: f['precio_caja'] as int?,
    piezasPorCaja: f['piezas_por_caja'] as int?,
    existenciaPiezas: f['existencia_piezas'] as int,
    minimo: f['minimo'] as int,
    envase: f['envase'] as String?,
    caducidad: f['caducidad'] as String?,
    foto: f['foto'] as String?,
    creado: f['creado'] as String,
    actualizado: f['actualizado'] as String,
  );
}
