import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:deposito_backend/deposito_backend.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/formato/formato.dart';

/// Encabezado de la plantilla (`docs/plantilla_inventario.csv`). El archivo
/// que exporta la app se puede volver a importar sin cambios.
const columnasInventario = [
  'codigo',
  'nombre',
  'categoria',
  'presentacion',
  'precio',
  'precioCaja',
  'piezasPorCaja',
  'existencia',
  'minimo',
  'envase',
  'caducidad',
];

/// Inventario en CSV, con los precios en pesos como los lee el servidor.
String csvInventario(List<Producto> productos) {
  final renglones = <String>[
    columnasInventario.join(','),
    for (final p in productos)
      [
        _celda(p.codigo),
        _celda(p.nombre),
        _celda(p.categoria),
        _celda(p.presentacion),
        _celda(pesosEditables(p.precio)),
        _celda(p.precioCaja == null ? null : pesosEditables(p.precioCaja!)),
        _celda(p.piezasPorCaja),
        _celda(p.existenciaPiezas),
        _celda(p.minimo),
        _celda(p.envase),
        _celda(p.caducidad),
      ].join(','),
  ];
  // El BOM hace que Excel abra los acentos bien; el servidor lo ignora.
  return '\uFEFF${renglones.join('\n')}\n';
}

String _celda(Object? valor) {
  final texto = valor == null ? '' : '$valor';
  return '"${texto.replaceAll('"', '""')}"';
}

/// Pide dónde guardar el CSV del inventario. En móvil/iPad, si el selector
/// de archivos falla, abre la hoja nativa de compartir.
Future<bool> exportarInventario(
  List<Producto> productos, {
  Rect? origen,
}) async {
  final hoy = DateTime.now();
  final fecha =
      '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}'
      '-${hoy.day.toString().padLeft(2, '0')}';
  final nombre = 'inventario-$fecha.csv';
  final contenido = csvInventario(productos);
  final bytes = Uint8List.fromList(utf8.encode(contenido));
  try {
    final destino = await FilePicker.saveFile(
      fileName: nombre,
      bytes: bytes,
      mimeType: 'text/csv',
    );
    return destino != null;
  } catch (_) {
    final dir = await getTemporaryDirectory();
    final archivo = File('${dir.path}/$nombre')
      ..writeAsBytesSync(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(archivo.path, mimeType: 'text/csv')],
        subject: 'Inventario de Anaquel ($fecha)',
        sharePositionOrigin: origen,
      ),
    );
    return true;
  }
}
