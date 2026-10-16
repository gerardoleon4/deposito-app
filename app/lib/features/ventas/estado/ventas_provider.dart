import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/proveedores.dart';
import '../../../core/tiempo_real/tiempo_real.dart';

/// Las últimas 100 ventas. Se vuelven a pedir cada vez que se abre la
/// pantalla y al reconectarse: el WebSocket no avisa de ventas nuevas.
final ventasProvider =
    AsyncNotifierProvider.autoDispose<VentasNotifier, List<ResumenVenta>>(
      VentasNotifier.new,
      retry: (_, _) => null,
    );

class VentasNotifier extends AsyncNotifier<List<ResumenVenta>> {
  @override
  Future<List<ResumenVenta>> build() async {
    final api = await ref.watch(apiProvider.future);
    ref.listen(eventosProvider, (_, siguiente) {
      if (siguiente.value?.tipo == eventoReconectado) refrescar();
    });
    return api.listarVentas();
  }

  Future<void> refrescar() async {
    final api = await ref.read(apiProvider.future);
    state = await AsyncValue.guard(api.listarVentas);
  }

  /// Cancela la venta completa: el servidor regresa existencias y envases.
  /// Los errores llegan como `FalloApi`.
  Future<void> cancelar(String id) async {
    final api = await ref.read(apiProvider.future);
    await api.cancelarVenta(id);
    ref.invalidate(detalleVentaProvider(id));
    await refrescar();
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
  final q = busqueda.trim().replaceAll(RegExp(r'[#$,\s]'), '');
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
