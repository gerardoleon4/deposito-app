import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datos/modelos_ventas.dart';

class EstadoVentas {
  const EstadoVentas({
    required this.tickets,
    this.filtroMetodoPago,
    this.busqueda = '',
    this.ticketSeleccionadoId,
  });

  final List<TicketTransaccion> tickets;
  final MetodoPagoTicket? filtroMetodoPago;
  final String busqueda;
  final String? ticketSeleccionadoId;

  List<TicketTransaccion> get ticketsFiltrados {
    return tickets.where((t) {
      if (filtroMetodoPago != null && t.metodoPago != filtroMetodoPago) {
        return false;
      }
      if (busqueda.trim().isNotEmpty) {
        final q = busqueda.trim().toLowerCase();
        final coincideFolio = t.folio.toLowerCase().contains(q);
        final coincideMonto =
            t.total.toStringAsFixed(2).contains(q) ||
            t.total.toStringAsFixed(0).contains(q);
        if (!coincideFolio && !coincideMonto) return false;
      }
      return true;
    }).toList();
  }

  TicketTransaccion? get ticketSeleccionado {
    if (ticketSeleccionadoId == null) {
      return ticketsFiltrados.isNotEmpty ? ticketsFiltrados.first : null;
    }
    try {
      return tickets.firstWhere((t) => t.id == ticketSeleccionadoId);
    } catch (_) {
      return ticketsFiltrados.isNotEmpty ? ticketsFiltrados.first : null;
    }
  }

  EstadoVentas copyWith({
    List<TicketTransaccion>? tickets,
    MetodoPagoTicket? Function()? filtroMetodoPago,
    String? busqueda,
    String? Function()? ticketSeleccionadoId,
  }) {
    return EstadoVentas(
      tickets: tickets ?? this.tickets,
      filtroMetodoPago: filtroMetodoPago != null
          ? filtroMetodoPago()
          : this.filtroMetodoPago,
      busqueda: busqueda ?? this.busqueda,
      ticketSeleccionadoId: ticketSeleccionadoId != null
          ? ticketSeleccionadoId()
          : this.ticketSeleccionadoId,
    );
  }
}

class VentasNotifier extends Notifier<EstadoVentas> {
  @override
  EstadoVentas build() {
    return EstadoVentas(
      tickets: _generarTicketsEjemplo(),
      ticketSeleccionadoId: 't-1042',
    );
  }

  void seleccionarTicket(String id) {
    state = state.copyWith(ticketSeleccionadoId: () => id);
  }

  void filtrarPorMetodo(MetodoPagoTicket? metodo) {
    state = state.copyWith(filtroMetodoPago: () => metodo);
  }

  void buscar(String query) {
    state = state.copyWith(busqueda: query);
  }

  void cancelarTicket({
    required String ticketId,
    required DestinoStock destino,
    required double montoReembolso,
    String? motivo,
  }) {
    final nuevos = state.tickets.map((t) {
      if (t.id == ticketId) {
        return t.cancelar(
          destino: destino,
          montoReembolsado: montoReembolso,
          motivo: motivo,
        );
      }
      return t;
    }).toList();

    state = state.copyWith(tickets: nuevos);
  }

  void registrarNuevaVenta({
    required String folio,
    required MetodoPagoTicket metodo,
    required double total,
    required double subtotal,
    double creditosEnvases = 0.0,
    double cargoEnvases = 0.0,
    required String cajero,
    required List<ItemTicket> items,
  }) {
    final nuevoTicket = TicketTransaccion(
      id: 't-${DateTime.now().millisecondsSinceEpoch}',
      folio: folio,
      fecha: DateTime.now(),
      metodoPago: metodo,
      total: total,
      subtotal: subtotal,
      creditosEnvases: creditosEnvases,
      cargoEnvases: cargoEnvases,
      cajero: cajero,
      items: items,
    );

    state = state.copyWith(
      tickets: [nuevoTicket, ...state.tickets],
      ticketSeleccionadoId: () => nuevoTicket.id,
    );
  }

  static List<TicketTransaccion> _generarTicketsEjemplo() {
    final ahora = DateTime.now();

    return [
      TicketTransaccion(
        id: 't-1042',
        folio: '#T-1042',
        fecha: ahora.subtract(const Duration(minutes: 6)),
        metodoPago: MetodoPagoTicket.tarjeta,
        subtotal: 58.0,
        total: 58.0,
        cajero: 'Daniel Mendoza',
        items: [
          ItemTicket(
            id: 'i-1',
            nombre: 'Corona Extra',
            precioUnitario: 20.0,
            cantidad: 2,
            urlImagen: 'assets/productos/corona_extra.webp',
          ),
          ItemTicket(
            id: 'i-2',
            nombre: 'Doritos Nacho',
            precioUnitario: 18.0,
            cantidad: 1,
            urlImagen: 'assets/productos/doritos_nacho.webp',
          ),
        ],
      ),
      TicketTransaccion(
        id: 't-1041',
        folio: '#T-1041',
        fecha: ahora.subtract(const Duration(minutes: 24)),
        metodoPago: MetodoPagoTicket.efectivo,
        subtotal: 88.0,
        total: 88.0,
        cajero: 'Daniel Mendoza',
        items: [
          ItemTicket(
            id: 'i-3',
            nombre: 'Modelo Especial',
            precioUnitario: 22.0,
            cantidad: 4,
            urlImagen: 'assets/productos/modelo_especial.webp',
          ),
        ],
      ),
      TicketTransaccion(
        id: 't-1040',
        folio: '#T-1040',
        fecha: ahora.subtract(const Duration(minutes: 48)),
        metodoPago: MetodoPagoTicket.efectivo,
        subtotal: 50.0,
        cargoEnvases: 10.0,
        total: 60.0,
        cajero: 'Daniel Mendoza',
        items: [
          ItemTicket(
            id: 'i-4',
            nombre: 'Victoria',
            precioUnitario: 21.0,
            cantidad: 1,
            urlImagen: 'assets/productos/victoria.webp',
          ),
          ItemTicket(
            id: 'i-5',
            nombre: 'Bolsa Hielo 5kg',
            precioUnitario: 35.0,
            cantidad: 1,
            urlImagen: 'assets/productos/hielo_5kg.webp',
          ),
        ],
      ),
      TicketTransaccion(
        id: 't-1039',
        folio: '#T-1039',
        fecha: ahora.subtract(const Duration(hours: 1, minutes: 15)),
        metodoPago: MetodoPagoTicket.tarjeta,
        subtotal: 510.0,
        creditosEnvases: 15.0,
        total: 495.0,
        cajero: 'Daniel Mendoza',
        estado: EstadoTicket.cancelado,
        fechaCancelacion: ahora.subtract(const Duration(hours: 1)),
        motivoCancelacion: 'Error de cobro / Devolución solicitada',
        destinoStock: DestinoStock.regresarInventario,
        montoReembolsado: 495.0,
        items: [
          ItemTicket(
            id: 'i-6',
            nombre: 'Corona Extra (Cartón 24pz)',
            precioUnitario: 20.0,
            cantidad: 1,
            esCaja: true,
            urlImagen: 'assets/productos/corona_extra.webp',
          ),
          ItemTicket(
            id: 'i-7',
            nombre: 'Cacahuates Japoneses',
            precioUnitario: 15.0,
            cantidad: 2,
            urlImagen: 'assets/productos/cacahuates_japoneses.webp',
          ),
        ],
      ),
      TicketTransaccion(
        id: 't-1038',
        folio: '#T-1038',
        fecha: ahora.subtract(const Duration(hours: 2, minutes: 5)),
        metodoPago: MetodoPagoTicket.efectivo,
        subtotal: 105.0,
        total: 105.0,
        cajero: 'Daniel Mendoza',
        items: [
          ItemTicket(
            id: 'i-8',
            nombre: 'Victoria',
            precioUnitario: 21.0,
            cantidad: 3,
            urlImagen: 'assets/productos/victoria.webp',
          ),
          ItemTicket(
            id: 'i-9',
            nombre: 'Doritos Nacho',
            precioUnitario: 18.0,
            cantidad: 1,
            urlImagen: 'assets/productos/doritos_nacho.webp',
          ),
          ItemTicket(
            id: 'i-10',
            nombre: 'Cacahuates Japoneses',
            precioUnitario: 15.0,
            cantidad: 1,
            urlImagen: 'assets/productos/cacahuates_japoneses.webp',
          ),
        ],
      ),
      TicketTransaccion(
        id: 't-1037',
        folio: '#T-1037',
        fecha: ahora.subtract(const Duration(hours: 3)),
        metodoPago: MetodoPagoTicket.saldoEnvases,
        subtotal: 44.0,
        creditosEnvases: 44.0,
        total: 0.0,
        cajero: 'Daniel Mendoza',
        items: [
          ItemTicket(
            id: 'i-11',
            nombre: 'Modelo Especial',
            precioUnitario: 22.0,
            cantidad: 2,
            urlImagen: 'assets/productos/modelo_especial.webp',
          ),
        ],
      ),
    ];
  }
}

final ventasProvider = NotifierProvider<VentasNotifier, EstadoVentas>(
  VentasNotifier.new,
);
