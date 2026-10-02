import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../api/api.dart';
import '../api/proveedores.dart';

enum EstadoConexion { conectando, enLinea, sinConexion }

/// Evento que la app genera al reconectarse: quien lo escuche debe volver a
/// pedir sus datos completos (regla del contrato).
const eventoReconectado = 'app.reconectado';

/// WebSocket con la caja. Se reconecta solo, con espera creciente de 1 a 10 s.
class TiempoReal {
  TiempoReal(this._api) {
    _conectar();
  }

  final Api _api;
  final _eventos = StreamController<Evento>.broadcast();
  final _estado = StreamController<EstadoConexion>.broadcast();
  WebSocketChannel? _canal;
  Timer? _reintento;
  var _intentos = 0;
  var _yaConecto = false;
  var _cerrado = false;
  EstadoConexion _actual = EstadoConexion.conectando;

  Stream<Evento> get eventos => _eventos.stream;

  Stream<EstadoConexion> get estados => _estado.stream;

  EstadoConexion get estado => _actual;

  Future<void> _conectar() async {
    if (_cerrado) return;
    _cambiar(EstadoConexion.conectando);
    final uri = _api.base.replace(
      scheme: _api.base.scheme == 'https' ? 'wss' : 'ws',
      path: '/api/v1/ws',
    );
    try {
      final canal = IOWebSocketChannel.connect(
        uri,
        headers: {cabeceraClave: _api.clave},
        pingInterval: const Duration(seconds: 20),
        connectTimeout: const Duration(seconds: 5),
      );
      _canal = canal;
      await canal.ready;
      if (_cerrado) return;
      _intentos = 0;
      _cambiar(EstadoConexion.enLinea);
      if (_yaConecto) {
        _eventos.add(
          Evento(
            tipo: eventoReconectado,
            datos: const {},
            fecha: instanteIso(DateTime.now()),
          ),
        );
      }
      _yaConecto = true;
      canal.stream.listen(
        (mensaje) {
          try {
            _eventos.add(
              Evento.fromJson((jsonDecode(mensaje as String) as Map).cast()),
            );
          } on Object {
            // Un mensaje que no entendemos no debe tumbar la conexión.
          }
        },
        onDone: _programarReintento,
        onError: (_) => _programarReintento(),
        cancelOnError: true,
      );
    } on Object {
      _programarReintento();
    }
  }

  void _programarReintento() {
    if (_cerrado) return;
    _canal = null;
    _cambiar(EstadoConexion.sinConexion);
    _reintento?.cancel();
    final segundos = min(10, pow(2, _intentos++).toInt());
    _reintento = Timer(Duration(seconds: segundos), _conectar);
  }

  /// Reintenta ya, sin esperar (botón "Reintentar").
  void reconectar() {
    if (_actual == EstadoConexion.enLinea) return;
    _reintento?.cancel();
    _intentos = 0;
    _conectar();
  }

  void _cambiar(EstadoConexion e) {
    if (_actual == e) return;
    _actual = e;
    _estado.add(e);
  }

  Future<void> cerrar() async {
    _cerrado = true;
    _reintento?.cancel();
    await _canal?.sink.close();
    await _eventos.close();
    await _estado.close();
  }
}

final tiempoRealProvider = FutureProvider<TiempoReal>((ref) async {
  final api = await ref.watch(apiProvider.future);
  final tr = TiempoReal(api);
  ref.onDispose(tr.cerrar);
  return tr;
});

final estadoConexionProvider = StreamProvider<EstadoConexion>((ref) async* {
  final tr = await ref.watch(tiempoRealProvider.future);
  yield tr.estado;
  yield* tr.estados;
});

final eventosProvider = StreamProvider<Evento>((ref) async* {
  final tr = await ref.watch(tiempoRealProvider.future);
  yield* tr.eventos;
});
