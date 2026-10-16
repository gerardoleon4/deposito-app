import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

/// Tipos de imagen permitidos → extensión del archivo.
const tiposFoto = {
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
};

/// Fotos de productos como archivos `{productoId}.{ext}` en una carpeta junto
/// a la base. La ruta pública vive en `productos.foto`; aquí solo los bytes.
class AlmacenFotos {
  AlmacenFotos(this.carpeta);

  final String carpeta;

  /// Guarda la foto y borra la anterior si tenía otra extensión. Escribe en
  /// un temporal y renombra, así una foto a medias nunca queda visible.
  void guardar(String productoId, String tipo, Uint8List bytes) {
    final ext = tiposFoto[tipo]!;
    Directory(carpeta).createSync(recursive: true);
    final destino = File(p.join(carpeta, '$productoId.$ext'));
    final temporal = File('${destino.path}.tmp');
    temporal.writeAsBytesSync(bytes, flush: true);
    temporal.renameSync(destino.path);
    for (final otra in tiposFoto.values.where((e) => e != ext)) {
      _borrar(productoId, otra);
    }
  }

  ({Uint8List bytes, String tipo})? leer(String productoId) {
    for (final e in tiposFoto.entries) {
      final f = File(p.join(carpeta, '$productoId.${e.value}'));
      if (f.existsSync()) return (bytes: f.readAsBytesSync(), tipo: e.key);
    }
    return null;
  }

  void borrar(String productoId) {
    for (final ext in tiposFoto.values) {
      _borrar(productoId, ext);
    }
  }

  void _borrar(String productoId, String ext) {
    final f = File(p.join(carpeta, '$productoId.$ext'));
    if (f.existsSync()) f.deleteSync();
  }
}

/// Comprueba por los primeros bytes que el contenido sea del [tipo] que dice
/// el encabezado, para no guardar cualquier archivo con nombre de imagen.
bool firmaCoincide(String tipo, Uint8List b) => switch (tipo) {
  'image/jpeg' => b.length > 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF,
  'image/png' =>
    b.length > 8 &&
        b[0] == 0x89 &&
        b[1] == 0x50 &&
        b[2] == 0x4E &&
        b[3] == 0x47,
  'image/webp' =>
    b.length > 12 &&
        String.fromCharCodes(b.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(b.sublist(8, 12)) == 'WEBP',
  _ => false,
};
