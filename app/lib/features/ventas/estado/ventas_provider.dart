import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/proveedores.dart';
import '../../../core/tiempo_real/tiempo_real.dart';

/// Las ventas que muestra la lista.
class EstadoVentas {
  const EstadoVentas({required this.ventas, required this.delTurno});

  /// Del folio más nuevo al más viejo.
  final List<ResumenVenta> ventas;

  /// `true`: las del turno abierto. `false`: la caja está cerrada y son las
  /// últimas 100.
  final bool delTurno;
}

/// Ventas del turno abierto (o las últimas si la caja está cerrada). Al día
/// con el WebSocket: cobros, cancelaciones, devoluciones y cambios de turno.
final ventasProvider =
    AsyncNotifierProvider.autoDispose<VentasNotifier, EstadoVentas>(
      VentasNotifier.new,
      retry: (_, _) => null,
    );

const _eventosQueRecargan = {
  TiposEvento.ventaRegistrada,
  TiposEvento.ventaCancelada,
  TiposEvento.ventaDevuelta,
  TiposEvento.cajaAbierta,
  TiposEvento.cajaCerrada,
  eventoReconectado,
};

class VentasNotifier extends AsyncNotifier<EstadoVentas> {
  @override
  Future<EstadoVentas> build() async {
    await ref.watch(apiProvider.future);
    ref.listen(eventosProvider, (_, siguiente) {
      if (_eventosQueRecargan.contains(siguiente.value?.tipo)) refrescar();
    });
    return _cargar();
  }

  Future<void> refrescar() async {
    state = await AsyncValue.guard(_cargar);
  }

  Future<EstadoVentas> _cargar() async {
    final api = await ref.read(apiProvider.future);
    final turno = (await api.turnoActual()).turno;
    return turno == null
        ? EstadoVentas(ventas: await api.listarVentas(), delTurno: false)
        : EstadoVentas(
            ventas: await api.listarVentas(turno: 'actual'),
            delTurno: true,
          );
  }

  /// Regresa lo que falta de la venta. [pin] si se pidió autorización.
  /// Los errores llegan como `FalloApi`.
  Future<void> cancelar(
    String id, {
    String? pin,
    String destino = 'inventario',
    String? motivo,
  }) async {
    final api = await ref.read(apiProvider.future);
    await api.cancelarVenta(id, pin: pin, destino: destino, motivo: motivo);
    ref.invalidate(detalleVentaProvider(id));
    await refrescar();
  }

  /// Devolución parcial: [lineas] es `lineaId → unidades`.
  Future<Devolucion> devolver(
    String id, {
    required Map<int, int> lineas,
    String? pin,
    String destino = 'inventario',
    String? motivo,
  }) async {
    final api = await ref.read(apiProvider.future);
    final r = await api.devolverVenta(
      id,
      lineas: lineas,
      pin: pin,
      destino: destino,
      motivo: motivo,
    );
    ref.invalidate(detalleVentaProvider(id));
    await refrescar();
    return r.devolucion;
  }
}

/// El ticket completo de una venta.
final detalleVentaProvider = FutureProvider.autoDispose
    .family<DetalleVenta, String>(
      (ref, id) async => (await ref.watch(apiProvider.future)).obtenerVenta(id),
      retry: (_, _) => null,
    );

/// Filtro local de la lista: por folio o por total (`1042`, `58`, `58.50`).
List<ResumenVenta> filtrarVentas(
  List<ResumenVenta> ventas, {
  String busqueda = '',
  String? metodo,
}) {
  final q = busqueda.trim().replaceAll(
    RegExp(r'[#$,\s]|^T-', caseSensitive: false),
    '',
  );
  return [
    for (final v in ventas)
      if ((metodo == null || v.metodo == metodo) &&
          (q.isEmpty ||
              '${v.folio}'.contains(q) ||
              _pesos(v.total).contains(q)))
        v,
  ];
}

/// `5850` → `58.50`; `5800` → `58`.
String _pesos(int centavos) {
  final resto = centavos % 100;
  return resto == 0
      ? '${centavos ~/ 100}'
      : '${centavos ~/ 100}.${resto.toString().padLeft(2, '0')}';
}
