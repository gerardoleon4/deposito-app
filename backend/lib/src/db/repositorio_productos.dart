import 'package:sqlite3/sqlite3.dart';

import '../comun/texto.dart';
import '../modelos/movimiento.dart';
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
        "(nombre_busqueda LIKE ? ESCAPE '^' OR codigo LIKE ? ESCAPE '^')",
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

  Producto? porCodigo(String codigo) {
    final filas = _db.select(
      'SELECT * FROM productos WHERE codigo = ? AND eliminado = 0',
      [codigo],
    );
    return filas.isEmpty ? null : _desdeFila(filas.first);
  }

  /// [exceptoId] deja fuera al producto que se está editando.
  bool existeCodigo(String codigo, {String? exceptoId}) => _db.select(
    'SELECT 1 FROM productos WHERE codigo = ? AND eliminado = 0 AND id IS NOT ?',
    [codigo, exceptoId],
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

  /// Reemplaza los campos editables. No toca existencia, foto ni `creado`.
  void actualizar(Producto p) {
    _db.execute(
      '''
      UPDATE productos SET codigo = ?, nombre = ?, nombre_busqueda = ?, categoria = ?,
        presentacion = ?, precio = ?, precio_caja = ?, piezas_por_caja = ?, minimo = ?,
        envase = ?, caducidad = ?, actualizado = ?
      WHERE id = ? AND eliminado = 0
      ''',
      [
        p.codigo,
        p.nombre,
        normalizarBusqueda(p.nombre),
        p.categoria,
        p.presentacion,
        p.precio,
        p.precioCaja,
        p.piezasPorCaja,
        p.minimo,
        p.envase,
        p.caducidad,
        p.actualizado,
        p.id,
      ],
    );
  }

  /// Cambia la existencia; siempre va junto con [registrarMovimiento].
  void actualizarExistencia(
    String id,
    int existencia,
    String fecha, {
    String? caducidad,
    bool cambiarCaducidad = false,
  }) {
    _db.execute(
      cambiarCaducidad
          ? 'UPDATE productos SET existencia_piezas = ?, actualizado = ?, caducidad = ? WHERE id = ?'
          : 'UPDATE productos SET existencia_piezas = ?, actualizado = ? WHERE id = ?',
      [existencia, fecha, if (cambiarCaducidad) caducidad, id],
    );
  }

  void actualizarFoto(String id, String? foto, String fecha) {
    _db.execute('UPDATE productos SET foto = ?, actualizado = ? WHERE id = ?', [
      foto,
      fecha,
      id,
    ]);
  }

  /// Borrado lógico: ventas y movimientos lo siguen referenciando.
  bool eliminar(String id, String fecha) {
    _db.execute(
      'UPDATE productos SET eliminado = 1, actualizado = ? WHERE id = ? AND eliminado = 0',
      [fecha, id],
    );
    return _db.updatedRows > 0;
  }

  List<Movimiento> movimientos(String productoId, {int limite = 200}) => _db
      .select(
        'SELECT * FROM movimientos WHERE producto_id = ? '
        'ORDER BY fecha DESC, id DESC LIMIT ?',
        [productoId, limite],
      )
      .map(
        (f) => Movimiento(
          id: f['id'] as int,
          tipo: f['tipo'] as String,
          piezas: f['piezas'] as int,
          existenciaResultante: f['existencia_resultante'] as int,
          referencia: f['referencia'] as String?,
          origen: f['origen'] as String,
          nota: f['nota'] as String?,
          fecha: f['fecha'] as String,
        ),
      )
      .toList();

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

  /// Productos bajo su mínimo o con existencia que caduca a más tardar
  /// [caducaHasta] (`AAAA-MM-DD`). Las reglas finas van en servicios/.
  List<Producto> candidatosAlerta(String caducaHasta) => _db
      .select(
        'SELECT * FROM productos WHERE eliminado = 0 AND ('
        'existencia_piezas < minimo OR (existencia_piezas > 0 '
        'AND caducidad IS NOT NULL AND caducidad <= ?))',
        [caducaHasta],
      )
      .map(_desdeFila)
      .toList();

  List<Producto> bajoMinimo() => _db
      .select(
        'SELECT * FROM productos '
        'WHERE eliminado = 0 AND existencia_piezas < minimo',
      )
      .map(_desdeFila)
      .toList();

  int contar() =>
      _db
              .select('SELECT COUNT(*) AS n FROM productos WHERE eliminado = 0')
              .first['n']
          as int;

  static String _escaparLike(String texto) =>
      texto.replaceAll('^', '^^').replaceAll('%', '^%').replaceAll('_', '^_');

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
