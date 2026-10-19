import 'dart:io';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../comun/fechas.dart';
import '../comun/json.dart';
import '../db/base_datos.dart';
import '../db/repositorio_ajustes.dart';
import '../modelos/ajustes.dart';

/// Máximo de cada campo de los ajustes del negocio.
const _maximos = {
  'nombreNegocio': 80,
  'direccion': 80,
  'telefono': 20,
  'mensajeTicket': 120,
};

/// Datos del negocio y respaldo de la base.
class ServicioAjustes {
  ServicioAjustes({
    required this._db,
    required this._repo,
    this._reloj = relojSistema,
  });

  final Database _db;
  final RepositorioAjustes _repo;
  final Reloj _reloj;

  AjustesNegocio leer() => AjustesNegocio(
    nombreNegocio: _repo.leer('nombreNegocio'),
    direccion: _repo.leer('direccion'),
    telefono: _repo.leer('telefono'),
    mensajeTicket: _repo.leer('mensajeTicket'),
  );

  /// Reemplaza los campos que vienen; `null` los borra.
  AjustesNegocio guardar(Map<String, Object?> datos) {
    final v = Validador(datos);
    final valores = <String, String?>{};
    for (final e in _maximos.entries) {
      if (!datos.containsKey(e.key)) continue;
      valores[e.key] = datos[e.key] == null
          ? null
          : v.texto(e.key, max: e.value);
    }
    v.comprobar();
    transaccion(_db, () {
      for (final e in valores.entries) {
        _repo.escribir(e.key, e.value);
      }
    });
    return leer();
  }

  /// Copia consistente de la base completa (`VACUUM INTO`), con su nombre
  /// de archivo sugerido.
  ({Uint8List bytes, String nombre}) respaldo() {
    final marca = instanteIso(_reloj())
        .replaceAll(RegExp('[-:]'), '')
        .replaceAll('T', '-')
        .replaceAll('Z', '');
    final carpeta = Directory.systemTemp.createTempSync('anaquel_respaldo_');
    try {
      final ruta = '${carpeta.path}/respaldo.db';
      _db.execute('VACUUM INTO ?', [ruta]);
      return (bytes: File(ruta).readAsBytesSync(), nombre: 'anaquel-$marca.db');
    } finally {
      carpeta.deleteSync(recursive: true);
    }
  }
}
