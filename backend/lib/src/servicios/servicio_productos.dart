import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../comun/errores.dart';
import '../comun/fechas.dart';
import '../comun/json.dart';
import '../comun/seguridad.dart';
import '../db/almacen_fotos.dart';
import '../db/base_datos.dart';
import '../db/repositorio_productos.dart';
import '../modelos/evento.dart';
import '../modelos/movimiento.dart';
import '../modelos/producto.dart';
import '../ws/hub.dart';

final _patronCodigo = RegExp(r'^[0-9A-Za-z]+$');

/// Tamaño máximo de una foto: la app la reduce antes de subirla.
const maxBytesFoto = 5 * 1024 * 1024;

class ServicioProductos {
  ServicioProductos({
    required this._db,
    required RepositorioProductos repositorio,
    required this._hub,
    this._fotos,
    this._reloj = relojSistema,
  }) : _repo = repositorio;

  final Database _db;
  final RepositorioProductos _repo;
  final Hub _hub;
  final AlmacenFotos? _fotos;
  final Reloj _reloj;

  List<Producto> listar({String? busqueda, String? categoria}) =>
      _repo.listar(busqueda: busqueda?.trim(), categoria: categoria?.trim());

  Producto obtener(String id) =>
      _repo.porId(id) ?? (throw ErrorApi.noEncontrado('el producto'));

  /// Búsqueda exacta para el escáner.
  Producto porCodigo(String codigo) =>
      _repo.porCodigo(codigo.trim()) ??
      (throw ErrorApi.noEncontrado('un producto con el código $codigo'));

  /// Crea un producto con su existencia inicial. [origen] queda en el
  /// movimiento de inventario: "Caja", el nombre de la terminal o "Datos de ejemplo".
  Producto crear(Map<String, Object?> datos, {required String origen}) {
    final v = Validador(datos);
    final campos = _leerCampos(v);
    final existencia =
        v.entero('existenciaPiezas', requerido: false, min: 0) ?? 0;
    v.comprobar();

    final ahora = instanteIso(_reloj());
    final producto = Producto(
      id: generarId('p'),
      codigo: campos.codigo!,
      nombre: campos.nombre!,
      categoria: campos.categoria!,
      presentacion: campos.presentacion,
      precio: campos.precio!,
      precioCaja: campos.precioCaja,
      piezasPorCaja: campos.piezasPorCaja,
      existenciaPiezas: existencia,
      minimo: campos.minimo,
      envase: campos.envase,
      caducidad: campos.caducidad,
      creado: ahora,
      actualizado: ahora,
    );

    transaccion(_db, () {
      if (_repo.existeCodigo(producto.codigo)) {
        throw ErrorApi.codigoDuplicado(producto.codigo);
      }
      _repo.insertar(producto);
      if (existencia > 0) {
        _repo.registrarMovimiento(
          productoId: producto.id,
          tipo: 'inicial',
          piezas: existencia,
          existenciaResultante: existencia,
          origen: origen,
          fecha: ahora,
        );
      }
    });

    _emitir(producto);
    return producto;
  }

  /// Reemplaza los campos editables. `existenciaPiezas` se ignora: un
  /// formulario abierto no debe pisar una venta hecha mientras tanto.
  Producto editar(String id, Map<String, Object?> datos) {
    final v = Validador(datos);
    final campos = _leerCampos(v);
    v.comprobar();

    final ahora = instanteIso(_reloj());
    final producto = transaccion(_db, () {
      final actual = obtener(id);
      if (_repo.existeCodigo(campos.codigo!, exceptoId: id)) {
        throw ErrorApi.codigoDuplicado(campos.codigo!);
      }
      _repo.actualizar(
        Producto(
          id: id,
          codigo: campos.codigo!,
          nombre: campos.nombre!,
          categoria: campos.categoria!,
          presentacion: campos.presentacion,
          precio: campos.precio!,
          precioCaja: campos.precioCaja,
          piezasPorCaja: campos.piezasPorCaja,
          existenciaPiezas: actual.existenciaPiezas,
          minimo: campos.minimo,
          envase: campos.envase,
          caducidad: campos.caducidad,
          foto: actual.foto,
          creado: actual.creado,
          actualizado: ahora,
        ),
      );
      return _repo.porId(id)!;
    });

    _emitir(producto);
    return producto;
  }

  void eliminar(String id) {
    final ahora = instanteIso(_reloj());
    final eliminado = transaccion(_db, () => _repo.eliminar(id, ahora));
    if (!eliminado) throw ErrorApi.noEncontrado('el producto');
    _hub.emitir(TiposEvento.productoEliminado, {'id': id});
  }

  /// Entrada de mercancía: `cajas × piezasPorCaja + piezas`.
  Producto registrarEntrada(
    String id,
    Map<String, Object?> datos, {
    required String origen,
  }) {
    final v = Validador(datos);
    final cajas = v.entero('cajas', requerido: false, min: 0) ?? 0;
    final sueltas = v.entero('piezas', requerido: false, min: 0) ?? 0;
    final caducidad = v.fecha('caducidad', requerido: false);
    final nota = v.texto('nota', requerido: false, max: 120);
    v.comprobar();

    final ahora = instanteIso(_reloj());
    final producto = transaccion(_db, () {
      final actual = obtener(id);
      if (cajas > 0 && actual.piezasPorCaja == null) {
        throw ErrorApi.datosInvalidos({
          'cajas': '${actual.nombre} no se maneja por caja',
        });
      }
      final piezas = cajas * (actual.piezasPorCaja ?? 0) + sueltas;
      if (piezas == 0) {
        throw ErrorApi.datosInvalidos({
          'piezas': 'La entrada debe tener al menos una pieza',
        });
      }
      final nueva = actual.existenciaPiezas + piezas;

      // La caducidad del producto es la más próxima de lo que hay en bodega.
      // Si estaba en cero, lo viejo ya no existe y manda el lote nuevo.
      final cambiarCaducidad =
          caducidad != null &&
          (actual.existenciaPiezas == 0 ||
              actual.caducidad == null ||
              caducidad.compareTo(actual.caducidad!) < 0);

      _repo.actualizarExistencia(
        id,
        nueva,
        ahora,
        caducidad: caducidad,
        cambiarCaducidad: cambiarCaducidad,
      );
      _repo.registrarMovimiento(
        productoId: id,
        tipo: 'entrada',
        piezas: piezas,
        existenciaResultante: nueva,
        origen: origen,
        nota: nota,
        fecha: ahora,
      );
      return _repo.porId(id)!;
    });

    _emitir(producto);
    return producto;
  }

  /// `conteo` fija la existencia a lo contado; `merma` resta piezas.
  Producto ajustar(
    String id,
    Map<String, Object?> datos, {
    required String origen,
  }) {
    final v = Validador(datos);
    final motivo = v.opcion('motivo', {'conteo', 'merma'});
    final contado = motivo == 'conteo'
        ? v.entero('existenciaPiezas', min: 0)
        : null;
    final merma = motivo == 'merma'
        ? v.entero('piezas', min: 1, mensaje: 'Debe ser un entero mayor que 0')
        : null;
    final nota = v.texto('nota', requerido: false, max: 120);
    v.comprobar();

    final ahora = instanteIso(_reloj());
    final producto = transaccion(_db, () {
      final actual = obtener(id);
      final nueva = contado ?? actual.existenciaPiezas - merma!;
      if (nueva < 0) {
        throw ErrorApi.stockInsuficiente(
          actual.nombre,
          actual.existenciaPiezas,
        );
      }
      final diferencia = nueva - actual.existenciaPiezas;
      if (diferencia == 0) return actual;

      _repo.actualizarExistencia(id, nueva, ahora);
      _repo.registrarMovimiento(
        productoId: id,
        tipo: motivo == 'conteo' ? 'ajuste' : 'merma',
        piezas: diferencia,
        existenciaResultante: nueva,
        origen: origen,
        nota: nota,
        fecha: ahora,
      );
      return _repo.porId(id)!;
    });

    _emitir(producto);
    return producto;
  }

  List<Movimiento> movimientos(String id) {
    obtener(id);
    return _repo.movimientos(id);
  }

  /// Guarda la foto y regresa el producto con `foto` en su versión nueva.
  Producto guardarFoto(String id, String? tipoContenido, Uint8List bytes) {
    final tipo = tipoContenido?.split(';').first.trim().toLowerCase();
    final error = switch (tipo) {
      _ when !tiposFoto.containsKey(tipo) =>
        'Debe ser image/jpeg, image/png o image/webp',
      _ when bytes.isEmpty => 'La imagen está vacía',
      _ when bytes.length > maxBytesFoto => 'La imagen pasa de 5 MB',
      _ when !firmaCoincide(tipo!, bytes) => 'El contenido no es una $tipo',
      _ => null,
    };
    if (error != null) throw ErrorApi.datosInvalidos({'foto': error});

    obtener(id);
    final ahora = _reloj();
    _almacen.guardar(id, tipo!, bytes);
    final ruta = '/api/v1/productos/$id/foto?v=${ahora.millisecondsSinceEpoch}';
    final producto = transaccion(_db, () {
      _repo.actualizarFoto(id, ruta, instanteIso(ahora));
      return obtener(id);
    });

    _emitir(producto);
    return producto;
  }

  ({Uint8List bytes, String tipo}) leerFoto(String id) {
    final producto = obtener(id);
    final foto = producto.foto == null ? null : _almacen.leer(id);
    return foto ?? (throw ErrorApi.noEncontrado('la foto del producto'));
  }

  Producto borrarFoto(String id) {
    obtener(id);
    final producto = transaccion(_db, () {
      _repo.actualizarFoto(id, null, instanteIso(_reloj()));
      return obtener(id);
    });
    _almacen.borrar(id);

    _emitir(producto);
    return producto;
  }

  AlmacenFotos get _almacen =>
      _fotos ?? (throw StateError('El servidor no tiene carpeta de fotos'));

  void _emitir(Producto producto) => _hub.emitir(
    TiposEvento.productoActualizado,
    {'producto': producto.toJson()},
  );

  /// Campos editables, con las mismas reglas al crear y al editar.
  _Campos _leerCampos(Validador v) {
    final campos = _Campos(
      codigo: v.texto(
        'codigo',
        max: 64,
        patron: _patronCodigo,
        mensajePatron: 'Solo letras y dígitos, sin espacios',
      ),
      nombre: v.texto('nombre', max: 80),
      categoria: v.texto('categoria', max: 40)?.toLowerCase(),
      presentacion: v.texto('presentacion', requerido: false, max: 40),
      precio: v.centavos('precio'),
      precioCaja: v.centavos('precioCaja', requerido: false),
      piezasPorCaja: v.entero(
        'piezasPorCaja',
        requerido: false,
        min: 2,
        mensaje: 'Debe ser un entero de 2 o más',
      ),
      minimo: v.entero('minimo', requerido: false, min: 0) ?? 0,
      envase: v.opcion('envase', formatosEnvase, requerido: false),
      caducidad: v.fecha('caducidad', requerido: false),
    );
    if (v.presente('precioCaja') != v.presente('piezasPorCaja')) {
      v.error(
        v.presente('precioCaja') ? 'piezasPorCaja' : 'precioCaja',
        'precioCaja y piezasPorCaja van juntos: los dos o ninguno',
      );
    }
    return campos;
  }
}

class _Campos {
  const _Campos({
    required this.codigo,
    required this.nombre,
    required this.categoria,
    required this.presentacion,
    required this.precio,
    required this.precioCaja,
    required this.piezasPorCaja,
    required this.minimo,
    required this.envase,
    required this.caducidad,
  });

  final String? codigo;
  final String? nombre;
  final String? categoria;
  final String? presentacion;
  final int? precio;
  final int? precioCaja;
  final int? piezasPorCaja;
  final int minimo;
  final String? envase;
  final String? caducidad;
}
