import 'dart:typed_data';
import 'dart:ui';

import 'package:deposito_backend/deposito_backend.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

/// Renglón editado para incluir en el pedido al proveedor.
typedef RenglonResurtido = ({
  SugerenciaResurtido sugerencia,
  int cantidad,
  bool porCaja,
});

/// Texto formateado para enviar por WhatsApp o mensaje al proveedor.
String textoPedidoProveedor(
  List<RenglonResurtido> renglones, {
  required String dia,
  required AjustesNegocio negocio,
}) {
  final lineas = <String>[
    '*Pedido de resurtido — ${negocio.nombreNegocio ?? 'Anaquel'}*',
    'Fecha: $dia',
    '',
    for (final r in renglones)
      if (r.cantidad > 0)
        '• ${r.sugerencia.producto.nombre}: '
            '${r.cantidad} ${r.porCaja ? (r.cantidad == 1 ? 'caja' : 'cajas') : (r.cantidad == 1 ? 'pieza' : 'piezas')}',
  ];
  return lineas.join('\n');
}

Future<void> compartirPedidoWhatsApp(
  List<RenglonResurtido> renglones, {
  required String dia,
  required AjustesNegocio negocio,
  Rect? origen,
}) => SharePlus.instance.share(
  ShareParams(
    text: textoPedidoProveedor(renglones, dia: dia, negocio: negocio),
    subject: 'Pedido de resurtido $dia',
    sharePositionOrigin: origen,
  ),
);

/// PDF tamaño carta para entregar o enviar al proveedor.
Future<Uint8List> pedidoProveedorPdf(
  List<RenglonResurtido> renglones, {
  required String dia,
  required AjustesNegocio negocio,
}) async {
  final doc = pw.Document(title: 'Pedido de resurtido $dia', author: 'Anaquel');
  final activos = [
    for (final r in renglones)
      if (r.cantidad > 0) r,
  ];
  final totalCajas = activos
      .where((r) => r.porCaja)
      .fold<int>(0, (s, r) => s + r.cantidad);
  final totalPiezas = activos
      .where((r) => !r.porCaja)
      .fold<int>(0, (s, r) => s + r.cantidad);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.all(36),
      build: (_) => [
        pw.Text(
          negocio.nombreNegocio ?? 'Anaquel',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Pedido de resurtido · Fecha: $dia',
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 16),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
          cellAlignment: pw.Alignment.centerLeft,
          headers: const ['Producto', 'Presentación', 'Existencia', 'Pedir'],
          data: [
            for (final r in activos)
              [
                r.sugerencia.producto.nombre,
                r.sugerencia.producto.presentacion ?? '-',
                '${r.sugerencia.producto.existenciaPiezas} pz',
                '${r.cantidad} ${r.porCaja ? (r.cantidad == 1 ? 'caja' : 'cajas') : (r.cantidad == 1 ? 'pieza' : 'piezas')}',
              ],
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Text(
          'Total: ${activos.length} productos · '
          '$totalCajas cajas${totalPiezas > 0 ? ' y $totalPiezas piezas' : ''}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
        ),
      ],
    ),
  );
  return doc.save();
}

Future<void> imprimirPedidoProveedor(
  List<RenglonResurtido> renglones, {
  required String dia,
  required AjustesNegocio negocio,
}) => Printing.layoutPdf(
  name: 'pedido-resurtido-$dia.pdf',
  onLayout: (_) => pedidoProveedorPdf(renglones, dia: dia, negocio: negocio),
);

Future<void> compartirPedidoProveedorPdf(
  List<RenglonResurtido> renglones, {
  required String dia,
  required AjustesNegocio negocio,
  Rect? origen,
}) async => Printing.sharePdf(
  bytes: await pedidoProveedorPdf(renglones, dia: dia, negocio: negocio),
  filename: 'pedido-resurtido-$dia.pdf',
  bounds: origen,
);
