import 'dart:convert';

import 'package:sqlite3/sqlite3.dart';

import '../comun/errores.dart';
import '../comun/fechas.dart';
import '../comun/json.dart';
import '../comun/seguridad.dart';
import '../db/base_datos.dart';
import '../db/repositorio_ajustes.dart';
import '../db/repositorio_caja.dart';
import '../db/repositorio_idempotencia.dart';
import '../modelos/caja.dart';
import '../modelos/evento.dart';
import '../modelos/usuario.dart';
import '../ws/hub.dart';
import 'servicio_usuarios.dart';

/// Turnos de caja: apertura con fondo, movimientos de efectivo y corte.
class ServicioCaja {
  ServicioCaja({
    required this._db,
    required this._repo,
    required this._idempotencia,
    required this._ajustes,
    required this._usuarios,
    required this._hub,
    this._reloj = relojSistema,
  });

  final Database _db;
  final RepositorioCaja _repo;
  final RepositorioIdempotencia _idempotencia;
  final RepositorioAjustes _ajustes;
  final ServicioUsuarios _usuarios;
  final Hub _hub;
  final Reloj _reloj;

  /// Id del turno abierto, o `null`. Para las ventas, dentro de su transacción.
  String? turnoAbiertoId() => _repo.abierto()?['id'] as String?;

  /// `GET /caja/turno`: el turno abierto con sus movimientos, o `turno: null`.
  DetalleTurno actual() {
    final fila = _repo.abierto();
    if (fila == null) return const DetalleTurno(turno: null, movimientos: []);
    return DetalleTurno(
      turno: _turnoDe(fila),
      movimientos: _repo.movimientos(fila['id'] as String),
    );
  }

  /// `GET /caja/cortes/{id}`: cualquier turno, abierto o cerrado.
  DetalleTurno detalle(String id) {
    final fila = _repo.porId(id);
    if (fila == null) throw ErrorApi.noEncontrado('el turno');
    return DetalleTurno(
      turno: _turnoDe(fila),
      movimientos: _repo.movimientos(id),
    );
  }

  List<Turno> cortes(Map<String, Object?> filtros) {
    final v = Validador(filtros);
    final desde = v.fecha('desde', requerido: false);
    final hasta = v.fecha('hasta', requerido: false);
    if (desde != null && hasta != null && desde.compareTo(hasta) > 0) {
      v.error('hasta', 'No puede ser antes de desde');
    }
    v.comprobar();
    return [
      for (final f in _repo.cortes(desde: desde, hasta: hasta)) _turnoDe(f),
    ];
  }

  Turno abrir(Map<String, Object?> datos) {
    final v = Validador(datos);
    final fondo = v.entero(
      'fondo',
      min: 0,
      max: 1000000000,
      mensaje: 'Debe ser un entero de 0 a 1,000,000,000 (centavos)',
    );
    final usuarioId = v.texto('usuarioId', requerido: false, max: 40);
    v.comprobar();

    final ahora = _reloj();
    final id = generarId('tur');
    final turno = transaccion(_db, () {
      if (_repo.abierto() != null) throw ErrorApi.cajaAbierta();
      _usuarios.activo(usuarioId);
      _repo.abrir(
        id: id,
        apertura: instanteIso(ahora),
        diaNegocio: diaNegocio(ahora, _ajustes.zonaHoraria),
        fondo: fondo!,
        usuarioId: usuarioId,
      );
      return _turnoDe(_repo.porId(id)!);
    });

    _hub.emitirACaja(TiposEvento.cajaAbierta, {'turno': turno.toJson()});
    return turno;
  }

  /// Ingreso o retiro de efectivo. Regresa `{ movimiento, turno }`.
  Map<String, Object?> registrarMovimiento(
    Map<String, Object?> datos, {
    required String origen,
    required String? claveIdempotencia,
  }) {
    final v = Validador(datos);
    final tipo = v.opcion('tipo', {'ingreso', 'retiro'});
    final monto = v.centavos('monto');
    final motivo = v.texto('motivo', max: 120);
    final clave = v.claveIdempotencia(claveIdempotencia);
    v.comprobar();

    final fecha = instanteIso(_reloj());
    var repetida = false;
    Map<String, Object?>? turnoJson;

    final respuesta = transaccion(_db, () {
      final guardada = _idempotencia.respuestaGuardada(clave);
      if (guardada != null) {
        repetida = true;
        return (jsonDecode(guardada) as Map).cast<String, Object?>();
      }

      final r = movimientoDentro(
        tipo: tipo!,
        monto: monto!,
        motivo: motivo!,
        fecha: fecha,
        origen: origen,
      );
      turnoJson = r['turno'] as Map<String, Object?>;
      _idempotencia.guardarRespuesta(clave, jsonEncode(r), fecha);
      return r;
    });

    if (!repetida) emitirActualizada(turnoJson!);
    return respuesta;
  }

  /// Registra un movimiento en el turno abierto, dentro de la transacción
  /// de quien llama (por ejemplo, la devolución de depósito de envases).
  /// Regresa `{ movimiento, turno }`; el aviso lo da [emitirActualizada]
  /// después de confirmar.
  Map<String, Object?> movimientoDentro({
    required String tipo,
    required int monto,
    required String motivo,
    required String fecha,
    required String origen,
  }) {
    final fila = _repo.abierto();
    if (fila == null) throw ErrorApi.cajaCerrada();
    final turnoId = fila['id'] as String;
    if (tipo == 'retiro') {
      final esperado = _repo.resumen(turnoId, fila['fondo'] as int).esperado;
      if (monto > esperado) {
        throw ErrorApi.datosInvalidos({
          'monto':
              'El retiro ($monto) es mayor que el efectivo esperado en '
              'caja ($esperado)',
        });
      }
    }
    final movimiento = MovimientoCaja(
      id: generarId('mc'),
      tipo: tipo,
      monto: monto,
      motivo: motivo,
      fecha: fecha,
    );
    _repo.registrarMovimiento(
      id: movimiento.id,
      turnoId: turnoId,
      tipo: tipo,
      monto: monto,
      motivo: motivo,
      fecha: fecha,
      origen: origen,
    );
    return {
      'movimiento': movimiento.toJson(),
      'turno': _turnoDe(_repo.porId(turnoId)!).toJson(),
    };
  }

  void emitirActualizada(Map<String, Object?> turno) =>
      _hub.emitirACaja(TiposEvento.cajaActualizada, {'turno': turno});

  /// Corte: guarda el esperado, lo contado y la diferencia. Regresa el turno
  /// cerrado como JSON (`{ turno }`).
  Map<String, Object?> cerrar(
    Map<String, Object?> datos, {
    required String? claveIdempotencia,
  }) {
    final v = Validador(datos);
    final contado = v.entero(
      'contado',
      min: 0,
      max: 1000000000,
      mensaje: 'Debe ser un entero de 0 a 1,000,000,000 (centavos)',
    );
    final nota = v.texto('nota', requerido: false, max: 200);
    final usuarioId = v.texto('usuarioId', requerido: false, max: 40);
    final clave = v.claveIdempotencia(claveIdempotencia);
    v.comprobar();

    final cierre = instanteIso(_reloj());
    var repetida = false;

    final respuesta = transaccion(_db, () {
      final guardada = _idempotencia.respuestaGuardada(clave);
      if (guardada != null) {
        repetida = true;
        return (jsonDecode(guardada) as Map).cast<String, Object?>();
      }

      final fila = _repo.abierto();
      if (fila == null) throw ErrorApi.cajaCerrada();
      _usuarios.activo(usuarioId);
      final id = fila['id'] as String;
      final esperado = _repo.resumen(id, fila['fondo'] as int).esperado;
      final diferencia = contado! - esperado;
      if (diferencia != 0 && nota == null) {
        throw ErrorApi.datosInvalidos({
          'nota':
              'Explica la diferencia: hay '
              '${diferencia < 0 ? 'un faltante' : 'un sobrante'} de '
              '${diferencia.abs()} centavos',
        });
      }

      _repo.cerrar(
        id: id,
        cierre: cierre,
        esperado: esperado,
        contado: contado,
        nota: nota,
        usuarioId: usuarioId,
      );
      final r = {'turno': _turnoDe(_repo.porId(id)!).toJson()};
      _idempotencia.guardarRespuesta(clave, jsonEncode(r), cierre);
      return r;
    });

    if (!repetida) {
      _hub.emitirACaja(TiposEvento.cajaCerrada, respuesta);
    }
    return respuesta;
  }

  Turno _turnoDe(Row f) {
    final id = f['id'] as String;
    final fondo = f['fondo'] as int;
    final abierto = (f['abierto'] as int) == 1;
    var resumen = _repo.resumen(id, fondo);
    if (!abierto) {
      // El esperado de un corte es el que se guardó al cerrar.
      resumen = ResumenTurno(
        ventas: resumen.ventas,
        canceladas: resumen.canceladas,
        ventasEfectivo: resumen.ventasEfectivo,
        ventasTarjeta: resumen.ventasTarjeta,
        envases: resumen.envases,
        devoluciones: resumen.devoluciones,
        ingresos: resumen.ingresos,
        retiros: resumen.retiros,
        esperado: f['esperado'] as int,
      );
    }
    return Turno(
      id: id,
      estado: abierto ? 'abierto' : 'cerrado',
      apertura: f['apertura'] as String,
      cierre: f['cierre'] as String?,
      diaNegocio: f['dia_negocio'] as String,
      fondo: fondo,
      resumen: resumen,
      contado: f['contado'] as int?,
      diferencia: f['diferencia'] as int?,
      nota: f['nota'] as String?,
      usuarioApertura: UsuarioBreve.deJson(
        _repo.usuario(f['usuario_apertura']),
      ),
      usuarioCierre: UsuarioBreve.deJson(_repo.usuario(f['usuario_cierre'])),
    );
  }
}
