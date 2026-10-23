import 'dart:convert';

import 'package:sqlite3/sqlite3.dart';

import '../comun/errores.dart';
import '../comun/fechas.dart';
import '../comun/json.dart';
import '../comun/seguridad.dart';
import '../db/base_datos.dart';
import '../db/repositorio_ajustes.dart';
import '../db/repositorio_caja.dart';
import '../db/repositorio_envases.dart';
import '../db/repositorio_idempotencia.dart';
import '../db/repositorio_productos.dart';
import '../db/repositorio_ventas.dart';
import '../modelos/evento.dart';
import '../modelos/producto.dart';
import '../ws/hub.dart';
import 'servicio_usuarios.dart';

typedef _LineaPedida = ({
  String productoId,
  String unidad,
  int cantidad,
  int descuento,
});

class ServicioVentas {
  ServicioVentas({
    required this._db,
    required this._repoVentas,
    required this._repoProductos,
    required this._repoEnvases,
    required this._repoAjustes,
    required this._repoCaja,
    required this._idempotencia,
    required this._usuarios,
    required this._hub,
    this._reloj = relojSistema,
  });

  final Database _db;
  final RepositorioVentas _repoVentas;
  final RepositorioProductos _repoProductos;
  final RepositorioEnvases _repoEnvases;
  final RepositorioAjustes _repoAjustes;
  final RepositorioCaja _repoCaja;
  final RepositorioIdempotencia _idempotencia;
  final ServicioUsuarios _usuarios;
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
    final usuarioId = v.texto('usuarioId', requerido: false, max: 40);
    final credito = _leerCredito(datos['envCredito'], v);
    final lineas = _leerLineas(datos['lineas'], v);
    final clave = v.claveIdempotencia(claveIdempotencia);
    v.comprobar();

    final ahora = _reloj();
    final fecha = instanteIso(ahora);
    final dia = diaNegocio(ahora, _repoAjustes.zonaHoraria);

    final productosActualizados = <Producto>[];
    var cambioEnvases = false;
    var repetida = false;

    final resultado = transaccion(_db, () {
      final guardada = _idempotencia.respuestaGuardada(clave);
      if (guardada != null) {
        repetida = true;
        return (jsonDecode(guardada) as Map).cast<String, Object?>();
      }
      final turnoId = _turnoAbiertoId();
      _usuarios.activo(usuarioId);

      final ventaId = generarId('v');
      final folio = _repoVentas.siguienteFolio();
      final balance = _repoEnvases.obtenerBalance();

      // PASO 1: Precios y existencias. Un producto puede venir en varias
      // líneas (piezas y cajas), así que las piezas se suman por producto.
      final procesadas = <_LineaVenta>[];
      final piezasPorProducto = <String, int>{};
      final envPorFormato = <String, int>{};
      var total = 0;
      var envN = 0;
      var envMonto = 0;
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
        final precioLista = porCaja ? p.precioCaja! : p.precio;
        // Descuento por unidad, truncado al centavo (contrato).
        final precioUnit = precioLista - precioLista * l.descuento ~/ 100;
        final subtotal = precioUnit * l.cantidad;
        total += subtotal;
        piezasPorProducto[p.id] = (piezasPorProducto[p.id] ?? 0) + piezas;
        var deposito = 0;
        if (p.envase != null) {
          envN += piezas;
          envPorFormato[p.envase!] = (envPorFormato[p.envase!] ?? 0) + piezas;
          if (envModo == 'cobrar') {
            deposito = balance[p.envase!]!['precio']!;
            envMonto += deposito * piezas;
          }
        }
        procesadas.add(
          _LineaVenta(
            p,
            l,
            piezas,
            precioLista,
            precioUnit,
            subtotal,
            deposito,
          ),
        );
      }
      for (final e in piezasPorProducto.entries) {
        final p = _repoProductos.porId(e.key)!;
        if (p.existenciaPiezas < e.value) {
          throw ErrorApi.stockInsuficiente(p.nombre, p.existenciaPiezas);
        }
      }

      // PASO 2: Envases y pago.
      total += envMonto;
      var envCredito = 0;
      for (final e in credito.entries) {
        envCredito += e.value * balance[e.key]!['precio']!;
      }
      if (envCredito > total) {
        throw ErrorApi.datosInvalidos({
          'envCredito':
              'El crédito ($envCredito) pasa del total ($total): usa '
              'Devolver depósito',
        });
      }
      total -= envCredito;
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
        turnoId: turnoId,
        usuarioId: usuarioId,
        envCredito: envCredito,
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
          precioLista: lp.precioLista,
          descuento: lp.linea.descuento,
          deposito: lp.deposito,
        );
        // Se relee: otra línea del mismo producto pudo haberlo cambiado.
        final actual = _repoProductos.porId(lp.producto.id)!;
        final nuevaExistencia = actual.existenciaPiezas - lp.piezas;
        _repoProductos.actualizarExistencia(actual.id, nuevaExistencia, fecha);
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

      // PASO 4: Bodega o préstamos de envases, y crédito por vacíos.
      final referencia = 'Folio $folio';
      if (envModo == 'trae') {
        for (final e in envPorFormato.entries) {
          _repoEnvases.actualizarBodega(e.key, e.value);
          _repoEnvases.registrarMovimiento(
            fecha: fecha,
            formato: e.key,
            tipo: 'venta_trae',
            bodega: e.value,
            referencia: referencia,
            origen: origen,
          );
          cambioEnvases = true;
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
          _repoEnvases.registrarMovimiento(
            fecha: fecha,
            formato: e.key,
            tipo: 'venta_prestamo',
            prestados: e.value,
            cliente: envCliente ?? 'Cliente Mostrador',
            referencia: referencia,
            origen: origen,
          );
          cambioEnvases = true;
        }
      }
      for (final e in credito.entries) {
        _repoVentas.insertarCredito(ventaId, e.key, e.value);
        _repoEnvases.actualizarBodega(e.key, e.value);
        _repoEnvases.registrarMovimiento(
          fecha: fecha,
          formato: e.key,
          tipo: 'credito',
          bodega: e.value,
          monto: -e.value * balance[e.key]!['precio']!,
          referencia: referencia,
          origen: origen,
        );
        cambioEnvases = true;
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
        'turnoId': turnoId,
      };
      _idempotencia.guardarRespuesta(clave, jsonEncode(respuesta), fecha);
      return respuesta;
    });

    if (repetida) return resultado;

    // Fuera de la transacción: si la base falla no se avisa nada.
    for (final prod in productosActualizados) {
      _hub.emitir(TiposEvento.productoActualizado, {'producto': prod.toJson()});
    }
    if (cambioEnvases) _emitirBalance();
    _hub.emitir(TiposEvento.ventaRegistrada, {'venta': resultado});
    return resultado;
  }

  /// Cobra envases vacíos de bodega al precio de depósito. Queda como venta
  /// sin líneas, con `env_formato`, para que aparezca en el historial y el
  /// corte, y para que cancelarla los regrese a bodega.
  Map<String, Object?> venderVacios(
    Map<String, Object?> datos, {
    required String origen,
    required String? claveIdempotencia,
  }) {
    final v = Validador(datos);
    final formato = v.opcion('formato', formatosEnvase);
    final cantidad = v.entero('cantidad', min: 1);
    final metodo = v.opcion('metodo', {'efectivo', 'tarjeta'});
    final tarjeta = v.texto('tarjeta', requerido: false, max: 20);
    final recibidoPedido = v.entero('recibido', requerido: false, min: 0);
    final usuarioId = v.texto('usuarioId', requerido: false, max: 40);
    final clave = v.claveIdempotencia(claveIdempotencia);
    v.comprobar();

    final ahora = _reloj();
    final fecha = instanteIso(ahora);
    final dia = diaNegocio(ahora, _repoAjustes.zonaHoraria);
    var repetida = false;

    final resultado = transaccion(_db, () {
      final guardada = _idempotencia.respuestaGuardada(clave);
      if (guardada != null) {
        repetida = true;
        return (jsonDecode(guardada) as Map).cast<String, Object?>();
      }
      final turnoId = _turnoAbiertoId();
      _usuarios.activo(usuarioId);

      final balance = _repoEnvases.obtenerBalance()[formato!]!;
      final enBodega = balance['bodega']!;
      if (enBodega < cantidad!) {
        throw ErrorApi.envasesInsuficientes(formato, enBodega);
      }
      final total = cantidad * balance['precio']!;
      final recibido = metodo == 'tarjeta' ? total : (recibidoPedido ?? total);
      if (recibido < total) {
        throw ErrorApi.datosInvalidos({
          'recibido': 'Recibido ($recibido) es menor que el total ($total)',
        });
      }

      final ventaId = generarId('v');
      final folio = _repoVentas.siguienteFolio();
      _repoVentas.insertarVenta(
        id: ventaId,
        folio: folio,
        fecha: fecha,
        diaNegocio: dia,
        total: total,
        metodo: metodo!,
        tarjeta: tarjeta,
        recibido: recibido,
        cambio: recibido - total,
        envModo: 'cobrar',
        envN: cantidad,
        envMonto: total,
        envFormato: formato,
        origen: origen,
        turnoId: turnoId,
        usuarioId: usuarioId,
      );
      _repoEnvases.actualizarBodega(formato, -cantidad);
      _repoEnvases.registrarMovimiento(
        fecha: fecha,
        formato: formato,
        tipo: 'venta_vacios',
        bodega: -cantidad,
        monto: total,
        referencia: 'Folio $folio',
        origen: origen,
      );

      final respuesta = <String, Object?>{
        'id': ventaId,
        'folio': folio,
        'fecha': fecha,
        'diaNegocio': dia,
        'total': total,
        'metodo': metodo,
        'recibido': recibido,
        'cambio': recibido - total,
        'turnoId': turnoId,
      };
      _idempotencia.guardarRespuesta(clave, jsonEncode(respuesta), fecha);
      return respuesta;
    });

    if (!repetida) {
      _emitirBalance();
      _hub.emitir(TiposEvento.ventaRegistrada, {'venta': resultado});
    }
    return resultado;
  }

  /// Sin turno abierto no se cobra (`409 caja_cerrada`).
  String _turnoAbiertoId() {
    final turno = _repoCaja.abierto();
    if (turno == null) throw ErrorApi.cajaCerrada();
    return turno['id'] as String;
  }

  /// `envCredito`: `{ formato: cantidad }`; los ceros se ignoran.
  Map<String, int> _leerCredito(Object? crudo, Validador v) {
    if (crudo == null) return const {};
    final credito = <String, int>{};
    if (crudo is! Map) {
      v.error('envCredito', 'Debe ser un objeto { formato: cantidad }');
      return credito;
    }
    for (final e in crudo.entries) {
      final n = e.value;
      if (!formatosEnvase.contains(e.key) || n is! int || n < 0) {
        v.error(
          'envCredito',
          'Cada formato (mega, media, cuarto) lleva un entero mayor o igual a 0',
        );
        return const {};
      }
      if (n > 0) credito[e.key as String] = n;
    }
    return credito;
  }

  /// Valida la forma de cada línea; los errores quedan en [v].
  List<_LineaPedida> _leerLineas(Object? crudo, Validador v) {
    if (crudo is! List || crudo.isEmpty) {
      v.error('lineas', 'Debe incluir al menos un producto');
      return const [];
    }
    final lineas = <_LineaPedida>[];
    for (var i = 0; i < crudo.length; i++) {
      final l = crudo[i];
      final pid = l is Map ? l['productoId'] : null;
      final unidad = l is Map ? l['unidad'] : null;
      final cantidad = l is Map ? l['cantidad'] : null;
      final descuento = l is Map ? (l['descuento'] ?? 0) : null;
      if (pid is! String ||
          (unidad != 'pieza' && unidad != 'caja') ||
          cantidad is! int ||
          cantidad < 1 ||
          descuento is! int ||
          descuento < 0 ||
          descuento > 99) {
        v.error(
          'lineas',
          'La línea ${i + 1} necesita productoId, unidad (pieza o caja), '
              'cantidad entera mayor que 0 y descuento de 0 a 99',
        );
        continue;
      }
      lineas.add((
        productoId: pid,
        unidad: unidad as String,
        cantidad: cantidad,
        descuento: descuento,
      ));
    }
    return lineas;
  }

  /// Cancela lo que falta por devolver de la venta.
  void cancelar(
    String id,
    Map<String, Object?> datos, {
    required String origen,
  }) {
    final v = Validador(datos);
    final destino = _leerDestino(v);
    final motivo = v.texto('motivo', requerido: false, max: 120);
    final pin = v.texto('pin', requerido: false, max: 6);
    v.comprobar();

    final efectos = _Efectos();
    transaccion(_db, () {
      final venta = _ventaDevolvible(id);
      final autorizo = _usuarios.autorizar(pin);
      _devolver(
        venta,
        null,
        destino: destino,
        motivo: motivo,
        autorizoId: autorizo?.id,
        origen: origen,
        efectos: efectos,
      );
    });
    _emitir(efectos, id);
  }

  /// Devolución parcial: `{ lineas: [{ lineaId, cantidad }], destino, ... }`.
  /// Regresa `{ devolucion, venta }`.
  Map<String, Object?> devolverParte(
    String id,
    Map<String, Object?> datos, {
    required String origen,
  }) {
    final v = Validador(datos);
    final destino = _leerDestino(v);
    final motivo = v.texto('motivo', requerido: false, max: 120);
    final pin = v.texto('pin', requerido: false, max: 6);
    final pedidas = <int, int>{};
    final crudo = datos['lineas'];
    if (crudo is! List || crudo.isEmpty) {
      v.error('lineas', 'Indica qué líneas y cuántas unidades se devuelven');
    } else {
      for (final l in crudo) {
        final lineaId = l is Map ? l['lineaId'] : null;
        final cantidad = l is Map ? l['cantidad'] : null;
        if (lineaId is! int || cantidad is! int || cantidad < 1) {
          v.error('lineas', 'Cada línea lleva lineaId y cantidad mayor que 0');
          break;
        }
        pedidas[lineaId] = (pedidas[lineaId] ?? 0) + cantidad;
      }
    }
    v.comprobar();

    final efectos = _Efectos();
    final devolucion = transaccion(_db, () {
      final venta = _ventaDevolvible(id);
      final autorizo = _usuarios.autorizar(pin);
      return _devolver(
        venta,
        pedidas,
        destino: destino,
        motivo: motivo,
        autorizoId: autorizo?.id,
        origen: origen,
        efectos: efectos,
      );
    });
    _emitir(efectos, id);
    return {'devolucion': devolucion, 'venta': detalle(id)};
  }

  String _leerDestino(Validador v) =>
      v.opcion('destino', {'inventario', 'merma'}, requerido: false) ??
      'inventario';

  /// Venta del turno abierto y sin cancelar.
  Row _ventaDevolvible(String id) {
    final venta = _repoVentas.obtenerPorId(id);
    if (venta == null) throw ErrorApi.noEncontrado('la venta');
    if ((venta['cancelada'] as int) == 1) {
      throw ErrorApi.datosInvalidos({'cancelada': 'La venta ya fue cancelada'});
    }
    // Solo ventas del turno abierto: el corte de un turno cerrado no cambia.
    final turno = _repoCaja.abierto();
    if (turno == null || venta['turno_id'] != turno['id']) {
      throw ErrorApi.turnoCerrado();
    }
    return venta;
  }

  /// Devuelve [pedidas] (`lineaId → unidades`) o, con `null`, todo lo que
  /// falta. Si al final no queda nada por devolver, la venta se cancela.
  /// Dentro de una transacción. Regresa la devolución como JSON.
  Map<String, Object?> _devolver(
    Row venta,
    Map<int, int>? pedidas, {
    required String destino,
    required String? motivo,
    required String? autorizoId,
    required String origen,
    required _Efectos efectos,
  }) {
    final ventaId = venta['id'] as String;
    final folio = venta['folio'] as int;
    final fecha = instanteIso(_reloj());
    final modo = venta['env_modo'] as String;
    final lineas = _repoVentas.obtenerLineas(ventaId);

    // Cuántas unidades de cada línea se devuelven ahora.
    final aDevolver = <int, int>{};
    if (pedidas == null) {
      for (final l in lineas) {
        final falta = (l['cantidad'] as int) - (l['devueltas'] as int);
        if (falta > 0) aDevolver[l['id'] as int] = falta;
      }
    } else {
      final porId = {for (final l in lineas) l['id'] as int: l};
      for (final e in pedidas.entries) {
        final l = porId[e.key];
        if (l == null) {
          throw ErrorApi.datosInvalidos({
            'lineas': 'La línea ${e.key} no es de esta venta',
          });
        }
        final falta = (l['cantidad'] as int) - (l['devueltas'] as int);
        if (e.value > falta) {
          throw ErrorApi.datosInvalidos({
            'lineas': 'De ${l['nombre']} solo faltan $falta por devolver',
          });
        }
        aDevolver[e.key] = e.value;
      }
    }
    final completa =
        pedidas == null ||
        lineas.every(
          (l) =>
              (l['cantidad'] as int) - (l['devueltas'] as int) ==
              (aDevolver[l['id'] as int] ?? 0),
        );

    final referencia = completa
        ? 'Cancelación Folio $folio'
        : 'Devolución Folio $folio';
    var monto = 0;
    final envPorFormato = <String, int>{};
    for (final l in lineas) {
      final unidades = aDevolver[l['id'] as int];
      if (unidades == null) continue;
      final piezas = (l['piezas'] as int) ~/ (l['cantidad'] as int) * unidades;
      monto +=
          (l['precio_unit'] as int) * unidades +
          (l['deposito'] as int) * piezas;
      _repoVentas.marcarDevueltas(l['id'] as int, unidades);

      final p = _repoProductos.porId(l['producto_id'] as String);
      if (p == null) continue;
      if (destino == 'inventario') {
        final existencia = p.existenciaPiezas + piezas;
        _repoProductos.actualizarExistencia(p.id, existencia, fecha);
        _repoProductos.registrarMovimiento(
          productoId: p.id,
          tipo: 'cancelacion',
          piezas: piezas,
          existenciaResultante: existencia,
          referencia: referencia,
          origen: origen,
          fecha: fecha,
        );
        efectos.productos.add(p.id);
      }
      if (p.envase != null) {
        envPorFormato[p.envase!] = (envPorFormato[p.envase!] ?? 0) + piezas;
      }
    }

    // Envases de las piezas devueltas, según cómo salieron.
    final balance = _repoEnvases.obtenerBalance();
    void sacarDeBodega(String formato, int n, String tipo) {
      final enBodega = balance[formato]!['bodega']!;
      if (enBodega < n) throw ErrorApi.envasesInsuficientes(formato, enBodega);
      balance[formato]!['bodega'] = enBodega - n;
      _repoEnvases.actualizarBodega(formato, -n);
      _repoEnvases.registrarMovimiento(
        fecha: fecha,
        formato: formato,
        tipo: tipo,
        bodega: -n,
        referencia: referencia,
        origen: origen,
      );
      efectos.envases = true;
    }

    if (modo == 'trae') {
      // Se le regresan los vacíos que dejó.
      envPorFormato.forEach((f, n) => sacarDeBodega(f, n, 'cancelacion'));
    } else if (modo == 'prestamo') {
      // El préstamo de esa venta baja en esas piezas (lo ya devuelto se
      // queda en bodega).
      final pendientes = {
        for (final pre in _repoEnvases.prestamosPendientesDeVenta(ventaId))
          pre['formato'] as String: pre,
      };
      for (final e in envPorFormato.entries) {
        final pre = pendientes[e.key];
        if (pre == null) continue;
        final n = e.value < (pre['cantidad'] as int)
            ? e.value
            : pre['cantidad'] as int;
        _repoEnvases.actualizarPrestados(e.key, -n);
        if (n == pre['cantidad'] && (pre['devueltos'] as int) == 0) {
          _repoEnvases.borrarPrestamo(pre['id'] as String);
        } else {
          _repoEnvases.reducirPrestamo(pre['id'] as String, n);
        }
        _repoEnvases.registrarMovimiento(
          fecha: fecha,
          formato: e.key,
          tipo: 'cancelacion',
          prestados: -n,
          cliente: pre['cliente'] as String,
          referencia: referencia,
          origen: origen,
        );
        efectos.envases = true;
      }
    }

    if (completa) {
      // Lo que falta del total, exacto: incluye el depósito de líneas ya
      // anteriores a m006 y descuenta el crédito por vacíos.
      monto = (venta['total'] as int) - (venta['devuelto'] as int);
      for (final c in _repoVentas.creditos(ventaId)) {
        sacarDeBodega(
          c['formato'] as String,
          c['cantidad'] as int,
          'cancelacion',
        );
      }
      final formatoVacios = venta['env_formato'] as String?;
      if (formatoVacios != null) {
        // Venta de vacíos: los envases regresan a bodega.
        final n = venta['env_n'] as int;
        _repoEnvases.actualizarBodega(formatoVacios, n);
        _repoEnvases.registrarMovimiento(
          fecha: fecha,
          formato: formatoVacios,
          tipo: 'cancelacion',
          bodega: n,
          monto: -monto,
          referencia: referencia,
          origen: origen,
        );
        efectos.envases = true;
      }
      _repoVentas.anularVenta(ventaId);
      efectos.cancelada = true;
    }

    final devolucion = <String, Object?>{
      'id': generarId('dev'),
      'fecha': fecha,
      'monto': monto,
      'destino': destino,
      'motivo': motivo,
      'autorizo': autorizoId == null
          ? null
          : {'id': autorizoId, 'nombre': _repoVentas.nombreUsuario(autorizoId)},
    };
    _repoVentas.insertarDevolucion(
      id: devolucion['id'] as String,
      ventaId: ventaId,
      turnoId: venta['turno_id'] as String?,
      fecha: fecha,
      monto: monto,
      metodo: venta['metodo'] as String,
      destino: destino,
      motivo: motivo,
      autorizoId: autorizoId,
      origen: origen,
    );
    _repoVentas.sumarDevuelto(ventaId, monto);
    efectos.monto = monto;
    return devolucion;
  }

  void _emitir(_Efectos efectos, String ventaId) {
    for (final id in efectos.productos) {
      final p = _repoProductos.porId(id);
      if (p != null) {
        _hub.emitir(TiposEvento.productoActualizado, {'producto': p.toJson()});
      }
    }
    if (efectos.envases) _emitirBalance();
    if (efectos.cancelada) {
      _hub.emitir(TiposEvento.ventaCancelada, {'id': ventaId});
    } else {
      _hub.emitir(TiposEvento.ventaDevuelta, {
        'id': ventaId,
        'monto': efectos.monto,
      });
    }
  }

  void _emitirBalance() {
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
      'envCredito': v['env_credito'],
      'origen': v['origen'],
      'cancelada': (v['cancelada'] as int) == 1,
      'turnoId': v['turno_id'],
      'devuelto': v['devuelto'],
      'usuario': _usuario(v),
      'lineas': [
        for (final l in lineas)
          {
            'lineaId': l['id'],
            'productoId': l['producto_id'],
            'nombre': l['nombre'],
            'unidad': l['unidad'],
            'cantidad': l['cantidad'],
            'piezas': l['piezas'],
            'precioLista': l['precio_lista'] ?? l['precio_unit'],
            'descuento': l['descuento'],
            'precioUnit': l['precio_unit'],
            'subtotal': l['subtotal'],
            'devueltas': l['devueltas'],
            'deposito': l['deposito'],
          },
      ],
      'devoluciones': [
        for (final d in _repoVentas.devoluciones(id))
          {
            'id': d['id'],
            'fecha': d['fecha'],
            'monto': d['monto'],
            'destino': d['destino'],
            'motivo': d['motivo'],
            'autorizo': d['autorizo_id'] == null
                ? null
                : {'id': d['autorizo_id'], 'nombre': d['autorizo_nombre']},
          },
      ],
    };
  }

  /// `GET /ventas` con `dia` o `turno` (`actual` o un id), nunca los dos, y
  /// opcionalmente `usuario`.
  List<Map<String, Object?>> listar(Map<String, Object?> filtros) {
    final v = Validador(filtros);
    final dia = v.fecha('dia', requerido: false);
    final turno = v.texto('turno', requerido: false, max: 40);
    final usuario = v.texto('usuario', requerido: false, max: 40);
    if (dia != null && turno != null) {
      v.error('turno', 'Usa dia o turno, no los dos');
    }
    v.comprobar();

    String? turnoId = turno;
    if (turno == 'actual') {
      turnoId = _repoCaja.abierto()?['id'] as String?;
      if (turnoId == null) return const [];
    }
    return _repoVentas
        .listar(diaNegocio: dia, turnoId: turnoId, usuarioId: usuario)
        .map(
          (v) => {
            'id': v['id'],
            'folio': v['folio'],
            'fecha': v['fecha'],
            'total': v['total'],
            'metodo': v['metodo'],
            'origen': v['origen'],
            'cancelada': (v['cancelada'] as int) == 1,
            'turnoId': v['turno_id'],
            'devuelto': v['devuelto'],
            'usuario': _usuario(v),
          },
        )
        .toList();
  }

  Map<String, Object?>? _usuario(Row v) => v['usuario_id'] == null
      ? null
      : {'id': v['usuario_id'], 'nombre': v['usuario_nombre']};
}

/// Lo que cambió en una devolución, para avisar después de la transacción.
class _Efectos {
  final productos = <String>{};
  var envases = false;
  var cancelada = false;
  var monto = 0;
}

class _LineaVenta {
  _LineaVenta(
    this.producto,
    this.linea,
    this.piezas,
    this.precioLista,
    this.precioUnit,
    this.subtotal,
    this.deposito,
  );

  final Producto producto;
  final _LineaPedida linea;
  final int piezas;
  final int precioLista;
  final int precioUnit;
  final int subtotal;

  /// Depósito cobrado por pieza (0 si no se cobró).
  final int deposito;
}
