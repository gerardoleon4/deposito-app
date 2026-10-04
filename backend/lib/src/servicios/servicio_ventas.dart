import 'dart:convert';

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

  /// Registra un cobro de la caja.
  ///
  /// [claveIdempotencia] viene del encabezado `X-Clave-Idempotencia`: si ya
  /// se usó, regresa la misma venta sin cobrar ni descontar otra vez.
  Map<String, Object?> registrar(
    Map<String, Object?> datos, {
    required String origen,
    required String? claveIdempotencia,
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
    final recibidoPedido = v.entero('recibido', requerido: false, min: 0);
    final lineas = _leerLineas(datos['lineas'], v);
    final clave = claveIdempotencia?.trim() ?? '';
    if (clave.length < 8 || clave.length > 100) {
      v.error(
        'X-Clave-Idempotencia',
        'Es obligatorio para cobrar: de 8 a 100 caracteres',
      );
    }
    v.comprobar();

    final ahora = _reloj();
    final fecha = instanteIso(ahora);
    final dia = diaNegocio(ahora, _repoAjustes.zonaHoraria);

    final productosActualizados = <Producto>[];
    final envPorFormato = <String, int>{};
    var repetida = false;

    final resultado = transaccion(_db, () {
      final guardada = _repoVentas.respuestaGuardada(clave);
      if (guardada != null) {
        repetida = true;
        return (jsonDecode(guardada) as Map).cast<String, Object?>();
      }

      final ventaId = generarId('v');
      final folio = _repoVentas.siguienteFolio();

      // PASO 1: Precios y existencias. Un producto puede venir en varias
      // líneas (piezas y cajas), así que las piezas se suman por producto.
      final procesadas = <_LineaVenta>[];
      final piezasPorProducto = <String, int>{};
      var total = 0;
      var envN = 0;
      for (final l in lineas) {
        final p = _repoProductos.porId(l.productoId);
        if (p == null) {
          throw ErrorApi.noEncontrado('el producto ${l.productoId}');
        }
        final porCaja = l.unidad == 'caja';
        if (porCaja && (p.precioCaja == null || p.piezasPorCaja == null)) {
          throw ErrorApi.datosInvalidos({
            'lineas': '${p.nombre} no se vende por caja',
          });
        }
        final piezas = porCaja ? l.cantidad * p.piezasPorCaja! : l.cantidad;
        final precioUnit = porCaja ? p.precioCaja! : p.precio;
        final subtotal = precioUnit * l.cantidad;
        total += subtotal;
        piezasPorProducto[p.id] = (piezasPorProducto[p.id] ?? 0) + piezas;
        if (p.envase != null) {
          envN += piezas;
          envPorFormato[p.envase!] = (envPorFormato[p.envase!] ?? 0) + piezas;
        }
        procesadas.add(_LineaVenta(p, l, piezas, precioUnit, subtotal));
      }
      for (final e in piezasPorProducto.entries) {
        final p = _repoProductos.porId(e.key)!;
        if (p.existenciaPiezas < e.value) {
          throw ErrorApi.stockInsuficiente(p.nombre, p.existenciaPiezas);
        }
      }

      // PASO 2: Envases y pago.
      var envMonto = 0;
      if (envModo == 'cobrar') {
        final balance = _repoEnvases.obtenerBalance();
        for (final e in envPorFormato.entries) {
          envMonto += e.value * (balance[e.key]?['precio'] ?? 0);
        }
        total += envMonto;
      }
      // Con tarjeta se cobra exacto; en efectivo, sin monto se asume exacto.
      final recibido = metodo == 'tarjeta' ? total : (recibidoPedido ?? total);
      if (recibido < total) {
        throw ErrorApi.datosInvalidos({
          'recibido': 'Recibido ($recibido) es menor que el total ($total)',
        });
      }
      final cambio = recibido - total;

      // PASO 3: Venta, líneas, existencias y movimientos.
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
      for (final lp in procesadas) {
        _repoVentas.insertarLinea(
          ventaId: ventaId,
          productoId: lp.producto.id,
          nombre: lp.producto.nombre,
          unidad: lp.linea.unidad,
          cantidad: lp.linea.cantidad,
          piezas: lp.piezas,
          precioUnit: lp.precioUnit,
          subtotal: lp.subtotal,
        );
        // Se relee: otra línea del mismo producto pudo haberlo cambiado.
        final actual = _repoProductos.porId(lp.producto.id)!;
        final nuevaExistencia = actual.existenciaPiezas - lp.piezas;
        _db.execute(
          'UPDATE productos SET existencia_piezas = ?, actualizado = ? WHERE id = ?',
          [nuevaExistencia, fecha, actual.id],
        );
        _repoProductos.registrarMovimiento(
          productoId: actual.id,
          tipo: 'venta',
          piezas: -lp.piezas,
          existenciaResultante: nuevaExistencia,
          referencia: 'Folio $folio',
          origen: origen,
          fecha: fecha,
        );
      }
      for (final id in piezasPorProducto.keys) {
        productosActualizados.add(_repoProductos.porId(id)!);
      }

      // PASO 4: Bodega o préstamos de envases.
      if (envModo == 'trae') {
        for (final e in envPorFormato.entries) {
          _repoEnvases.actualizarBodega(e.key, e.value);
        }
      } else if (envModo == 'prestamo') {
        for (final e in envPorFormato.entries) {
          _repoEnvases.actualizarPrestados(e.key, e.value);
          _repoEnvases.registrarPrestamo(
            id: generarId('pre'),
            cliente: envCliente ?? 'Cliente Mostrador',
            formato: e.key,
            cantidad: e.value,
            fecha: fecha,
            ventaId: ventaId,
          );
        }
      }

      final respuesta = <String, Object?>{
        'id': ventaId,
        'folio': folio,
        'fecha': fecha,
        'diaNegocio': dia,
        'total': total,
        'metodo': metodo,
        'recibido': recibido,
        'cambio': cambio,
      };
      _repoVentas.guardarRespuesta(clave, jsonEncode(respuesta), fecha);
      return respuesta;
    });

    if (repetida) return resultado;

    // Fuera de la transacción: si la base falla no se avisa nada.
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

  /// Valida la forma de cada línea; los errores quedan en [v].
  List<({String productoId, String unidad, int cantidad})> _leerLineas(
    Object? crudo,
    Validador v,
  ) {
    if (crudo is! List || crudo.isEmpty) {
      v.error('lineas', 'Debe incluir al menos un producto');
      return const [];
    }
    final lineas = <({String productoId, String unidad, int cantidad})>[];
    for (var i = 0; i < crudo.length; i++) {
      final l = crudo[i];
      final pid = l is Map ? l['productoId'] : null;
      final unidad = l is Map ? l['unidad'] : null;
      final cantidad = l is Map ? l['cantidad'] : null;
      if (pid is! String ||
          (unidad != 'pieza' && unidad != 'caja') ||
          cantidad is! int ||
          cantidad < 1) {
        v.error(
          'lineas',
          'La línea ${i + 1} necesita productoId, unidad (pieza o caja) '
              'y cantidad entera mayor que 0',
        );
        continue;
      }
      lineas.add((
        productoId: pid,
        unidad: unidad as String,
        cantidad: cantidad,
      ));
    }
    return lineas;
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

      // Regresar existencias
      for (final l in lineas) {
        final p = _repoProductos.porId(l['producto_id'] as String);
        if (p == null) continue;
        final piezas = l['piezas'] as int;
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
      }
      for (final pid in {for (final l in lineas) l['producto_id'] as String}) {
        final p = _repoProductos.porId(pid);
        if (p != null) prods.add(p);
      }

      // Revertir envases
      final modo = v['env_modo'] as String;
      if (modo == 'trae') {
        for (final l in lineas) {
          final p = _repoProductos.porId(l['producto_id'] as String);
          if (p?.envase != null) {
            _repoEnvases.actualizarBodega(p!.envase!, -(l['piezas'] as int));
          }
        }
      } else if (modo == 'prestamo') {
        for (final pre in _repoEnvases.prestamosPendientesDeVenta(id)) {
          _repoEnvases.actualizarPrestados(
            pre['formato'] as String,
            -(pre['cantidad'] as int),
          );
          _repoEnvases.borrarPrestamo(pre['id'] as String);
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

class _LineaVenta {
  _LineaVenta(
    this.producto,
    this.linea,
    this.piezas,
    this.precioUnit,
    this.subtotal,
  );

  final Producto producto;
  final ({String productoId, String unidad, int cantidad}) linea;
  final int piezas;
  final int precioUnit;
  final int subtotal;
}
