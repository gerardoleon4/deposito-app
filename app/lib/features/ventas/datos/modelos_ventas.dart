import 'package:flutter/material.dart';

enum MetodoPagoTicket {
  efectivo('Efectivo', Icons.payments_rounded, Color(0xFF16A34A)),
  tarjeta('Tarjeta', Icons.credit_card_rounded, Color(0xFF2563EB)),
  saldoEnvases('Saldo por Envases', Icons.recycling_rounded, Color(0xFFD97706));

  const MetodoPagoTicket(this.etiqueta, this.icono, this.color);
  final String etiqueta;
  final IconData icono;
  final Color color;
}

enum DestinoStock {
  regresarInventario(
    'Regresar al Inventario',
    'El producto está intacto y puede volver a venderse',
    Icons.inventory_2_rounded,
    Color(0xFF2563EB),
  ),
  merma(
    'Registrar como Merma',
    'El producto está roto, abierto o caducado',
    Icons.delete_sweep_rounded,
    Color(0xFFDC2626),
  );

  const DestinoStock(this.titulo, this.subtitulo, this.icono, this.color);
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Color color;
}

enum EstadoTicket { completado, cancelado }

class ItemTicket {
  ItemTicket({
    required this.id,
    required this.nombre,
    required this.precioUnitario,
    required this.cantidad,
    this.esCaja = false,
    this.urlImagen,
  });

  final String id;
  final String nombre;
  final double precioUnitario;
  final int cantidad;
  final bool esCaja;
  final String? urlImagen;

  double get subtotal => precioUnitario * (esCaja ? (cantidad * 24) : cantidad);

  ItemTicket copyWith({int? cantidad}) {
    return ItemTicket(
      id: id,
      nombre: nombre,
      precioUnitario: precioUnitario,
      cantidad: cantidad ?? this.cantidad,
      esCaja: esCaja,
      urlImagen: urlImagen,
    );
  }
}

class TicketTransaccion {
  TicketTransaccion({
    required this.id,
    required this.folio,
    required this.fecha,
    required this.metodoPago,
    required this.total,
    required this.subtotal,
    this.creditosEnvases = 0.0,
    this.cargoEnvases = 0.0,
    required this.cajero,
    required this.items,
    this.estado = EstadoTicket.completado,
    this.fechaCancelacion,
    this.motivoCancelacion,
    this.destinoStock,
    this.montoReembolsado,
  });

  final String id;
  final String folio;
  final DateTime fecha;
  final MetodoPagoTicket metodoPago;
  final double total;
  final double subtotal;
  final double creditosEnvases;
  final double cargoEnvases;
  final String cajero;
  final List<ItemTicket> items;
  final EstadoTicket estado;
  final DateTime? fechaCancelacion;
  final String? motivoCancelacion;
  final DestinoStock? destinoStock;
  final double? montoReembolsado;

  bool get esCancelado => estado == EstadoTicket.cancelado;

  TicketTransaccion cancelar({
    required DestinoStock destino,
    required double montoReembolsado,
    String? motivo,
  }) {
    return TicketTransaccion(
      id: id,
      folio: folio,
      fecha: fecha,
      metodoPago: metodoPago,
      total: total,
      subtotal: subtotal,
      creditosEnvases: creditosEnvases,
      cargoEnvases: cargoEnvases,
      cajero: cajero,
      items: items,
      estado: EstadoTicket.cancelado,
      fechaCancelacion: DateTime.now(),
      motivoCancelacion: motivo ?? 'Devolución de cliente',
      destinoStock: destino,
      montoReembolsado: montoReembolsado,
    );
  }
}
