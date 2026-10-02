import 'package:sqlite3/sqlite3.dart';

import '../comun/errores.dart';
import '../comun/fechas.dart';
import '../comun/json.dart';
import '../comun/seguridad.dart';
import '../db/base_datos.dart';
import '../db/repositorio_productos.dart';
import '../modelos/evento.dart';
import '../modelos/producto.dart';
import '../ws/hub.dart';

final _patronCodigo = RegExp(r'^[0-9A-Za-z]+$');

class ServicioProductos {
  ServicioProductos({
    required Database db,
    required RepositorioProductos repositorio,
    required Hub hub,
    Reloj reloj = relojSistema,
  }) : _db = db,
       _repo = repositorio,
       _hub = hub,
       _reloj = reloj;

  final Database _db;
  final RepositorioProductos _repo;
  final Hub _hub;
  final Reloj _reloj;

  List<Producto> listar({String? busqueda, String? categoria}) =>
      _repo.listar(busqueda: busqueda?.trim(), categoria: categoria?.trim());

  Producto obtener(String id) =>
      _repo.porId(id) ?? (throw ErrorApi.noEncontrado('el producto'));

  /// Crea un producto con su existencia inicial. [origen] queda en el
  /// movimiento de inventario: "Caja", el nombre de la terminal o "Datos de ejemplo".
  Producto crear(Map<String, Object?> datos, {required String origen}) {
    final v = Validador(datos);
    final codigo = v.texto(
      'codigo',
      max: 64,
      patron: _patronCodigo,
      mensajePatron: 'Solo letras y dígitos, sin espacios',
    );
    final nombre = v.texto('nombre', max: 80);
    final categoria = v.texto('categoria', max: 40)?.toLowerCase();
    final presentacion = v.texto('presentacion', requerido: false, max: 40);
    final precio = v.centavos('precio');
    final precioCaja = v.centavos('precioCaja', requerido: false);
    final piezasPorCaja = v.entero(
      'piezasPorCaja',
      requerido: false,
      min: 2,
      mensaje: 'Debe ser un entero de 2 o más',
    );
    final existencia =
        v.entero('existenciaPiezas', requerido: false, min: 0) ?? 0;
    final minimo = v.entero('minimo', requerido: false, min: 0) ?? 0;
    final envase = v.opcion('envase', formatosEnvase, requerido: false);
    final caducidad = v.fecha('caducidad', requerido: false);

    if (v.presente('precioCaja') != v.presente('piezasPorCaja')) {
      v.error(
        v.presente('precioCaja') ? 'piezasPorCaja' : 'precioCaja',
        'precioCaja y piezasPorCaja van juntos: los dos o ninguno',
      );
    }
    v.comprobar();

    final ahora = instanteIso(_reloj());
    final producto = Producto(
      id: generarId('p'),
      codigo: codigo!,
      nombre: nombre!,
      categoria: categoria!,
      presentacion: presentacion,
      precio: precio!,
      precioCaja: precioCaja,
      piezasPorCaja: piezasPorCaja,
      existenciaPiezas: existencia,
      minimo: minimo,
      envase: envase,
      caducidad: caducidad,
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

    _hub.emitir(TiposEvento.productoActualizado, {
      'producto': producto.toJson(),
    });
    return producto;
  }
}
