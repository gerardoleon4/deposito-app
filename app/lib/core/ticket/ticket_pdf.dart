import 'dart:typed_data';

import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../api/proveedores.dart';
import '../formato/formato.dart';

/// Datos del negocio para el encabezado del ticket. Si fallan, el ticket
/// sale sin ellos en lugar de no salir.
final ajustesNegocioProvider = FutureProvider.autoDispose<AjustesNegocio>((
  ref,
) async {
  try {
    return await (await ref.watch(apiProvider.future)).obtenerAjustes();
  } catch (_) {
    return const AjustesNegocio();
  }
});

/// Nombre del archivo del ticket: `ticket-1042.pdf`.
String nombreTicket(DetalleVenta v) => 'ticket-${v.folio}.pdf';

/// Ticket de la venta en PDF, del ancho de un rollo de 80 mm.
///
/// Solo usa Helvetica (latin-1): acentos y ñ sí, viñetas y rayas largas no.
Future<Uint8List> ticketPdf(DetalleVenta v, AjustesNegocio negocio) async {
  final doc = pw.Document(title: 'Ticket ${v.folio}', author: 'Anaquel');
  const chica = pw.TextStyle(fontSize: 8);
  final negrita = pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold);

  pw.Widget fila(String izq, String der, {pw.TextStyle? estilo}) => pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Expanded(child: pw.Text(izq, style: estilo ?? chica)),
      pw.Text(der, style: estilo ?? chica),
    ],
  );

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      margin: const pw.EdgeInsets.all(12),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Text(
            negocio.nombreNegocio ?? 'Depósito',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          if (negocio.direccion != null)
            pw.Text(
              negocio.direccion!,
              textAlign: pw.TextAlign.center,
              style: chica,
            ),
          if (negocio.telefono != null)
            pw.Text(
              'Tel. ${negocio.telefono}',
              textAlign: pw.TextAlign.center,
              style: chica,
            ),
          pw.SizedBox(height: 6),
          fila('Folio', '#${v.folio}', estilo: negrita),
          fila('Fecha', fechaHora(v.fecha).replaceAll('•', '-')),
          if (v.usuario != null) fila('Atendió', v.usuario!.nombre),
          if (v.cancelada) fila('Estado', 'CANCELADA', estilo: negrita),
          pw.Divider(thickness: 0.5),
          for (final l in v.lineas) ...[
            pw.Text(l.nombre, style: negrita),
            fila(
              '${l.cantidad} ${l.porCaja ? 'caja(s)' : 'pza(s)'} x '
              '${dinero(l.precioUnit)}'
              '${l.descuento > 0 ? ' (-${l.descuento}%)' : ''}',
              dinero(l.subtotal),
            ),
            if (l.devueltas > 0) fila('  Devueltas: ${l.devueltas}', ''),
          ],
          if (v.lineas.isEmpty) fila('Envases vacíos (${v.envN})', ''),
          pw.Divider(thickness: 0.5),
          fila('Subtotal productos', dinero(v.subtotalProductos)),
          if (v.envMonto > 0)
            fila('Depósito de envases', '+${dinero(v.envMonto)}'),
          if (v.envCredito > 0)
            fila('Crédito por vacíos', '-${dinero(v.envCredito)}'),
          fila('TOTAL', dinero(v.total), estilo: negrita),
          fila(
            v.metodo == 'tarjeta' ? 'Tarjeta' : 'Efectivo',
            dinero(v.recibido),
          ),
          if (v.cambio > 0) fila('Cambio', dinero(v.cambio)),
          if (v.devuelto > 0) ...[
            pw.SizedBox(height: 4),
            fila('Devuelto', '-${dinero(v.devuelto)}', estilo: negrita),
          ],
          pw.SizedBox(height: 8),
          pw.Text(
            negocio.mensajeTicket ?? 'Gracias por su compra',
            textAlign: pw.TextAlign.center,
            style: chica,
          ),
          pw.Text(
            'Conserve este comprobante para devoluciones',
            textAlign: pw.TextAlign.center,
            style: chica,
          ),
        ],
      ),
    ),
  );
  return doc.save();
}

/// Manda el ticket a imprimir (impresora del sistema o AirPrint).
Future<void> imprimirTicket(DetalleVenta v, AjustesNegocio negocio) =>
    Printing.layoutPdf(
      name: nombreTicket(v),
      onLayout: (_) => ticketPdf(v, negocio),
    );

/// Abre la hoja de compartir del sistema con el PDF (WhatsApp, AirDrop...).
Future<void> compartirTicket(DetalleVenta v, AjustesNegocio negocio) async =>
    Printing.sharePdf(
      bytes: await ticketPdf(v, negocio),
      filename: nombreTicket(v),
    );
