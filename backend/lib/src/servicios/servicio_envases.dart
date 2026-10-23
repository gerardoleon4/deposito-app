import 'dart:convert';

import 'package:sqlite3/sqlite3.dart';

import '../comun/errores.dart';
import '../comun/fechas.dart';
import '../comun/json.dart';
import '../comun/seguridad.dart';
import '../db/base_datos.dart';
import '../db/repositorio_envases.dart';
import '../db/repositorio_idempotencia.dart';
import '../modelos/evento.dart';
import '../modelos/producto.dart';
import '../ws/hub.dart';
import 'servicio_caja.dart';

class ServicioEnvases {
  ServicioEnvases({
    required this._db,
    required RepositorioEnvases repositorio,
    required this._idempotencia,
    required this._caja,
    required this._hub,
    this._reloj = relojSistema,
  }) : _repo = repositorio;

  final Database _db;
  final RepositorioEnvases _repo;
  final RepositorioIdempotencia _idempotencia;
  final ServicioCaja _caja;
  final Hub _hub;
  final Reloj _reloj;

  Map<String, Map<String, int>> balance() => _repo.obtenerBalance();

  List<Map<String, Object?>> prestamos() => _repo.listarPrestamosActivos();

  List<Map<String, Object?>> movimientos(Map<String, Object?> filtros) {
    final crudo = filtros['limite'];
    final limite = crudo == null ? 50 : int.tryParse('$crudo');
    if (limite == null || limite < 1 || limite > 200) {
      throw ErrorApi.datosInvalidos({
        'limite': 'Debe ser un entero de 1 a 200',
      });
    }
    return _repo.movimientos(limite);
  }

  /// Presta vacíos de bodega a un cliente.
  Map<String, Object?> registrarPrestamo(
    Map<String, Object?> datos, {
    required String origen,
  }) {
    final v = Validador(datos);
    final cliente = v.texto('cliente', max: 80);
    final telefono = v.texto('telefono', requerido: false, max: 20);
    final formato = v.opcion('formato', formatosEnvase);
    final cantidad = v.entero('cantidad', min: 1);
    v.comprobar();

    final id = generarId('pre');
    final fecha = instanteIso(_reloj());

    transaccion(_db, () {
      _sacarDeBodega(formato!, cantidad!);
      _repo.actualizarPrestados(formato, cantidad);
      _repo.registrarPrestamo(
        id: id,
        cliente: cliente!,
        telefono: telefono,
        formato: formato,
        cantidad: cantidad,
        fecha: fecha,
      );
      _repo.registrarMovimiento(
        fecha: fecha,
        formato: formato,
        tipo: 'prestamo',
        bodega: -cantidad,
        prestados: cantidad,
        cliente: cliente,
        origen: origen,
      );
    });

    _emitirBalance();
    return {
      'id': id,
      'cliente': cliente,
      'telefono': telefono,
      'formato': formato,
      'cantidad': cantidad,
      'devueltos': 0,
      'fecha': fecha,
    };
  }

  /// Devolución total o, con `cantidad`, parcial. Los envases van a bodega.
  void devolver(
    String prestamoId,
    Map<String, Object?> datos, {
    required String origen,
  }) {
    final v = Validador(datos);
    final pedida = v.entero('cantidad', requerido: false, min: 1);
    v.comprobar();

    transaccion(_db, () {
      final p = _repo.obtenerPrestamo(prestamoId);
      if (p == null || p['devuelto'] == 1) {
        throw ErrorApi.noEncontrado('el préstamo');
      }
      final formato = p['formato'] as String;
      final pendiente = p['cantidad'] as int;
      final cantidad = pedida ?? pendiente;
      if (cantidad > pendiente) {
        throw ErrorApi.datosInvalidos({
          'cantidad': 'Solo faltan $pendiente envases por devolver',
        });
      }

      _repo.devolverPrestamo(
        prestamoId,
        cantidad,
        completo: cantidad == pendiente,
      );
      _repo.actualizarPrestados(formato, -cantidad);
      _repo.actualizarBodega(formato, cantidad);
      _repo.registrarMovimiento(
        fecha: instanteIso(_reloj()),
        formato: formato,
        tipo: 'devolucion_prestamo',
        bodega: cantidad,
        prestados: -cantidad,
        cliente: p['cliente'] as String,
        origen: origen,
      );
    });

    _emitirBalance();
  }

  /// Vacíos que entran a bodega sin una venta (los deja el proveedor).
  Map<String, Map<String, int>> registrarEntrada(
    Map<String, Object?> datos, {
    required String origen,
  }) {
    final v = Validador(datos);
    final formato = v.opcion('formato', formatosEnvase);
    final cantidad = v.entero('cantidad', min: 1);
    v.comprobar();

    transaccion(_db, () {
      _repo.actualizarBodega(formato!, cantidad!);
      _repo.registrarMovimiento(
        fecha: instanteIso(_reloj()),
        formato: formato,
        tipo: 'entrada',
        bodega: cantidad,
        origen: origen,
      );
    });

    _emitirBalance();
    return balance();
  }

  /// Vacíos que salen de bodega sin cobro (al proveedor, rotos...).
  Map<String, Map<String, int>> registrarSalida(
    Map<String, Object?> datos, {
    required String origen,
  }) {
    final v = Validador(datos);
    final formato = v.opcion('formato', formatosEnvase);
    final cantidad = v.entero('cantidad', min: 1);
    final motivo = v.texto('motivo', max: 120);
    v.comprobar();

    transaccion(_db, () {
      _sacarDeBodega(formato!, cantidad!);
      _repo.registrarMovimiento(
        fecha: instanteIso(_reloj()),
        formato: formato,
        tipo: 'salida',
        bodega: -cantidad,
        referencia: motivo,
        origen: origen,
      );
    });

    _emitirBalance();
    return balance();
  }

  /// El cliente regresa vacíos y se le devuelve su depósito en efectivo:
  /// entran a bodega y sale un retiro de caja. Regresa
  /// `{ balance, movimiento, turno }`.
  Map<String, Object?> devolverDeposito(
    Map<String, Object?> datos, {
    required String origen,
    required String? claveIdempotencia,
  }) {
    final v = Validador(datos);
    final formato = v.opcion('formato', formatosEnvase);
    final cantidad = v.entero('cantidad', min: 1);
    final cliente = v.texto('cliente', requerido: false, max: 80);
    final clave = v.claveIdempotencia(claveIdempotencia);
    v.comprobar();

    final fecha = instanteIso(_reloj());
    var repetida = false;
    Map<String, Object?>? turno;

    final respuesta = transaccion(_db, () {
      final guardada = _idempotencia.respuestaGuardada(clave);
      if (guardada != null) {
        repetida = true;
        return (jsonDecode(guardada) as Map).cast<String, Object?>();
      }
      final monto = cantidad! * _repo.obtenerBalance()[formato!]!['precio']!;
      final caja = _caja.movimientoDentro(
        tipo: 'retiro',
        monto: monto,
        motivo:
            'Devolución de depósito: $cantidad $formato'
            '${cliente == null ? '' : ' - $cliente'}',
        fecha: fecha,
        origen: origen,
      );
      _repo.actualizarBodega(formato, cantidad);
      _repo.registrarMovimiento(
        fecha: fecha,
        formato: formato,
        tipo: 'devolucion_deposito',
        bodega: cantidad,
        cliente: cliente,
        monto: -monto,
        origen: origen,
      );
      turno = caja['turno'] as Map<String, Object?>;
      final r = {'balance': _repo.obtenerBalance(), ...caja};
      _idempotencia.guardarRespuesta(clave, jsonEncode(r), fecha);
      return r;
    });

    if (!repetida) {
      _emitirBalance();
      _caja.emitirActualizada(turno!);
    }
    return respuesta;
  }

  void _sacarDeBodega(String formato, int cantidad) {
    final enBodega = _repo.obtenerBalance()[formato]!['bodega']!;
    if (enBodega < cantidad) {
      throw ErrorApi.envasesInsuficientes(formato, enBodega);
    }
    _repo.actualizarBodega(formato, -cantidad);
  }

  void _emitirBalance() {
    _hub.emitir(TiposEvento.balanceEnvasesActualizado, {'balance': balance()});
  }
}
