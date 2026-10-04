import 'package:sqlite3/sqlite3.dart';

import '../comun/errores.dart';
import '../comun/fechas.dart';
import '../comun/json.dart';
import '../comun/seguridad.dart';
import '../db/base_datos.dart';
import '../db/repositorio_ajustes.dart';
import '../db/repositorio_envases.dart';
import '../db/repositorio_productos.dart';
import '../db/repositorio_ventas.dart';
import '../modelos/evento.dart';
import '../modelos/producto.dart';
import '../ws/hub.dart';

class ServicioVentas {
  ServicioVentas({
    required this._db,
    required this._repoVentas,
    required this._repoProductos,
    required this._repoEnvases,
    required this._repoAjustes,
    required this._hub,
    this._reloj = relojSistema,
  });

  final Database _db;
  final RepositorioVentas _repoVentas;
  final RepositorioProductos _repoProductos;
  final RepositorioEnvases _repoEnvases;
  final RepositorioAjustes _repoAjustes;
  final Hub _hub;
  final Reloj _reloj;

  // backend/lib/src/servicios/servicio_ventas.dart

  Map<String, Object?> registrar(
    Map<String, Object?> datos, {
    required String origen,
  }) {
    final v = Validador(datos);
    final metodo = v.opcion('metodo', {'efectivo', 'tarjeta'});
    final tarjeta = v.texto('tarjeta', requerido: false, max: 20);
    final envModo =
        v.opcion('envModo', {
          'na',
          'cobrar',
          'trae',
          'prestamo',
        }, requerido: false) ??
        'na';
    final envCliente = v.texto('envCliente', requerido: false, max: 80);
    final lineasRaw = datos['lineas'];
    if (lineasRaw is! List || lineasRaw.isEmpty) {
      v.error('lineas', 'Debe incluir al menos un producto');
    }
    v.comprobar();

    final ahora = _reloj();
    final fecha = instanteIso(ahora);
    final dia = diaNegocio(ahora, _repoAjustes.zonaHoraria);
    final ventaId = generarId('v');

    final productosActualizados = <Producto>[];
    var total = 0;
    var envN = 0;
    var envMonto = 0;
    final envPorFormato = <String, int>{};

    final resultado = transaccion(_db, () {
      final folio = _repoVentas.siguienteFolio();
      final lineasProcesadas = <Map<String, Object?>>[];

      // PASO 1: Validar inventario y calcular totales (sin insertar líneas aún)
      for (final item in (lineasRaw as List)) {
        if (item is! Map) {
          throw ErrorApi.datosInvalidos({'lineas': 'Estructura inválida'});
        }
        final pid = item['productoId'] as String?;
        final unidad = item['unidad'] as String?;
        final cantidad = item['cantidad'] as int?;

        if (pid == null ||
            unidad == null ||
            cantidad == null ||
            cantidad <= 0) {
          throw ErrorApi.datosInvalidos({
            'lineas': 'Faltan datos obligatorios en línea',
          });
        }

        final p = _repoProductos.porId(pid);
        if (p == null) throw ErrorApi.noEncontrado('el producto $pid');

        final piezas = unidad == 'caja'
            ? (cantidad * (p.piezasPorCaja ?? 1))
            : cantidad;
        if (p.existenciaPiezas < piezas) {
          throw ErrorApi.datosInvalidos({
            'existencias':
                'Existencias insuficientes para ${p.nombre}. Disponibles: ${p.existenciaPiezas}',
          });
        }

        final precioUnit = unidad == 'caja'
            ? (p.precioCaja ??
                  (throw ErrorApi.datosInvalidos({
                    'unidad': 'El producto no se vende por caja',
                  })))
            : p.precio;

        final subtotal = precioUnit * cantidad;
        total += subtotal;

        if (p.envase != null) {
          envN += piezas;
          envPorFormato[p.envase!] = (envPorFormato[p.envase!] ?? 0) + piezas;
        }

        lineasProcesadas.add({
          'p': p,
          'unidad': unidad,
          'cantidad': cantidad,
          'piezas': piezas,
          'precioUnit': precioUnit,
          'subtotal': subtotal,
        });
      }

      // PASO 2: Cálculo final de envases y validación de cobro
      final balance = _repoEnvases.obtenerBalance();
      if (envModo == 'cobrar') {
        for (final entry in envPorFormato.entries) {
          final precioEnv = balance[entry.key]?['precio'] ?? 0;
          envMonto += entry.value * precioEnv;
        }
        total += envMonto;
      }

      final recibido = (datos['recibido'] is int)
          ? (datos['recibido'] as int)
          : total;
      if (metodo == 'efectivo' && recibido < total) {
        throw ErrorApi.datosInvalidos({
          'recibido':
              'El monto recibido ($recibido) es menor al total ($total)',
        });
      }
      final cambio = (metodo == 'efectivo') ? (recibido - total) : 0;

      // PASO 3: Insertar el registro maestro (ventas) PRIMERO
      _repoVentas.insertarVenta(
        id: ventaId,
        folio: folio,
        fecha: fecha,
        diaNegocio: dia,
        total: total,
        metodo: metodo!,
        tarjeta: tarjeta,
        recibido: recibido,
        cambio: cambio,
        envModo: envModo,
        envN: envN,
        envMonto: envMonto,
        envCliente: envCliente,
        origen: origen,
      );

      // PASO 4: Insertar líneas, actualizar inventario y registrar movimientos
      for (final lp in lineasProcesadas) {
        final p = lp['p'] as Producto;
        final piezas = lp['piezas'] as int;

        _repoVentas.insertarLinea(
          ventaId: ventaId,
          productoId: p.id,
          nombre: p.nombre,
          unidad: lp['unidad'] as String,
          cantidad: lp['cantidad'] as int,
          piezas: piezas,
          precioUnit: lp['precioUnit'] as int,
          subtotal: lp['subtotal'] as int,
        );

        final nuevaExistencia = p.existenciaPiezas - piezas;
        _db.execute(
          'UPDATE productos SET existencia_piezas = ?, actualizado = ? WHERE id = ?',
          [nuevaExistencia, fecha, p.id],
        );

        _repoProductos.registrarMovimiento(
          productoId: p.id,
          tipo: 'venta',
          piezas: -piezas,
          existenciaResultante: nuevaExistencia,
          referencia: 'Folio $folio',
          origen: origen,
          fecha: fecha,
        );

        final actualizado = _repoProductos.porId(p.id);
        if (actualizado != null) {
          productosActualizados.add(actualizado);
        }
      }

      // PASO 5: Actualizar bodega o préstamos de envases
      if (envModo == 'trae') {
        for (final entry in envPorFormato.entries) {
          _repoEnvases.actualizarBodega(entry.key, entry.value);
        }
      } else if (envModo == 'prestamo') {
        for (final entry in envPorFormato.entries) {
          _repoEnvases.actualizarPrestados(entry.key, entry.value);
          _repoEnvases.registrarPrestamo(
            id: generarId('pre'),
            cliente: envCliente ?? 'Cliente Mostrador',
            formato: entry.key,
            cantidad: entry.value,
            fecha: fecha,
          );
        }
      }

      return {
        'id': ventaId,
        'folio': folio,
        'fecha': fecha,
        'diaNegocio': dia,
        'total': total,
        'metodo': metodo,
        'cambio': cambio,
      };
    });

    // Notificar por WebSocket fuera de la transacción para no enviar eventos si falla la BD
    for (final prod in productosActualizados) {
      _hub.emitir(TiposEvento.productoActualizado, {'producto': prod.toJson()});
    }
    if (envPorFormato.isNotEmpty) {
      _hub.emitir(TiposEvento.balanceEnvasesActualizado, {
        'balance': _repoEnvases.obtenerBalance(),
      });
    }

    return resultado;
  }

  void cancelar(String id, {required String origen}) {
    final prods = <Producto>[];
    transaccion(_db, () {
      final v = _repoVentas.obtenerPorId(id);
      if (v == null) throw ErrorApi.noEncontrado('la venta');
      if ((v['cancelada'] as int) == 1) {
        throw ErrorApi.datosInvalidos({
          'cancelada': 'La venta ya fue cancelada',
        });
      }

      final lineas = _repoVentas.obtenerLineas(id);
      final fecha = instanteIso(_reloj());
      final folio = v['folio'] as int;

      // Reversar existencias
      for (final l in lineas) {
        final pid = l['producto_id'] as String;
        final piezas = l['piezas'] as int;
        final p = _repoProductos.porId(pid);
        if (p != null) {
          final restock = p.existenciaPiezas + piezas;
          _db.execute(
            'UPDATE productos SET existencia_piezas = ?, actualizado = ? WHERE id = ?',
            [restock, fecha, p.id],
          );
          _repoProductos.registrarMovimiento(
            productoId: p.id,
            tipo: 'cancelacion',
            piezas: piezas,
            existenciaResultante: restock,
            referencia: 'Cancelación Folio $folio',
            origen: origen,
            fecha: fecha,
          );
          prods.add(_repoProductos.porId(p.id)!);
        }
      }

      // Reversar envases si se ingresaron a bodega
      final modo = v['env_modo'] as String;
      if (modo == 'trae') {
        // Descontar los que se habían sumado
        for (final l in lineas) {
          final p = _repoProductos.porId(l['producto_id'] as String);
          if (p?.envase != null) {
            _repoEnvases.actualizarBodega(p!.envase!, -(l['piezas'] as int));
          }
        }
      }

      _repoVentas.anularVenta(id);
    });

    for (final prod in prods) {
      _hub.emitir(TiposEvento.productoActualizado, {'producto': prod.toJson()});
    }
    _hub.emitir(TiposEvento.balanceEnvasesActualizado, {
      'balance': _repoEnvases.obtenerBalance(),
    });
  }

  Map<String, Object?> detalle(String id) {
    final v = _repoVentas.obtenerPorId(id);
    if (v == null) throw ErrorApi.noEncontrado('la venta');
    final lineas = _repoVentas.obtenerLineas(id);
    return {
      'id': v['id'],
      'folio': v['folio'],
      'fecha': v['fecha'],
      'diaNegocio': v['dia_negocio'],
      'total': v['total'],
      'metodo': v['metodo'],
      'tarjeta': v['tarjeta'],
      'recibido': v['recibido'],
      'cambio': v['cambio'],
      'envModo': v['env_modo'],
      'envN': v['env_n'],
      'envMonto': v['env_monto'],
      'origen': v['origen'],
      'cancelada': (v['cancelada'] as int) == 1,
      'lineas': [
        for (final l in lineas)
          {
            'productoId': l['producto_id'],
            'nombre': l['nombre'],
            'unidad': l['unidad'],
            'cantidad': l['cantidad'],
            'piezas': l['piezas'],
            'precioUnit': l['precio_unit'],
            'subtotal': l['subtotal'],
          },
      ],
    };
  }

  List<Map<String, Object?>> listar({String? diaNegocio}) {
    return _repoVentas
        .listar(diaNegocio: diaNegocio)
        .map(
          (v) => {
            'id': v['id'],
            'folio': v['folio'],
            'fecha': v['fecha'],
            'total': v['total'],
            'metodo': v['metodo'],
            'origen': v['origen'],
            'cancelada': (v['cancelada'] as int) == 1,
          },
        )
        .toList();
  }
}
