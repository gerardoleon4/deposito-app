import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../comun/bitacora.dart';
import '../comun/fechas.dart';
import '../comun/sesion.dart';
import '../modelos/evento.dart';

/// Conexiones WebSocket abiertas y envío de eventos a todas.
///
/// Los servicios llaman a [emitir] DESPUÉS de confirmar la transacción, para
/// no avisar de un cambio que terminó en rollback.
class Hub {
  Hub({
    required this.version,
    required this._bitacora,
    this._reloj = relojSistema,
  });

  final String version;
  final Bitacora _bitacora;
  final Reloj _reloj;
  final _conexiones = <WebSocketChannel, Sesion>{};

  int get totalConexiones => _conexiones.length;

  Set<String> get terminalesConectadas => {
    for (final s in _conexiones.values)
      if (s.terminalId != null) s.terminalId!,
  };

  void conectar(WebSocketChannel canal, Sesion sesion) {
    _conexiones[canal] = sesion;
    _bitacora.info(
      'WS conectado: ${sesion.nombre} (${_conexiones.length} abiertos)',
    );
    _enviar(canal, _evento(TiposEvento.conexionLista, {'version': version}));
    canal.stream.listen(
      (_) {}, // El cliente no manda mensajes por ahora (contrato).
      onDone: () => _quitar(canal),
      onError: (Object e) => _quitar(canal),
      cancelOnError: true,
    );
  }

  void emitir(String tipo, Map<String, Object?> datos) {
    final texto = jsonEncode(_evento(tipo, datos).toJson());
    for (final canal in _conexiones.keys.toList()) {
      _enviarTexto(canal, texto);
    }
  }

  /// Cierra los WebSocket de una terminal revocada.
  Future<void> desconectarTerminal(String terminalId) async {
    final canales = [
      for (final e in _conexiones.entries)
        if (e.value.terminalId == terminalId) e.key,
    ];
    for (final c in canales) {
      _conexiones.remove(c);
      await c.sink.close();
    }
  }

  Future<void> cerrar() async {
    final canales = _conexiones.keys.toList();
    _conexiones.clear();
    await Future.wait(canales.map((c) => c.sink.close()));
  }

  Evento _evento(String tipo, Map<String, Object?> datos) =>
      Evento(tipo: tipo, datos: datos, fecha: instanteIso(_reloj()));

  void _enviar(WebSocketChannel canal, Evento evento) =>
      _enviarTexto(canal, jsonEncode(evento.toJson()));

  void _enviarTexto(WebSocketChannel canal, String texto) {
    try {
      canal.sink.add(texto);
    } on StateError {
      _quitar(canal);
    }
  }

  void _quitar(WebSocketChannel canal) {
    final sesion = _conexiones.remove(canal);
    if (sesion != null) {
      _bitacora.info(
        'WS desconectado: ${sesion.nombre} (${_conexiones.length} abiertos)',
      );
    }
  }
}
