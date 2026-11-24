import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/proveedores.dart';
import '../../../core/tiempo_real/tiempo_real.dart';

/// Días de cobertura deseados para calcular cuánto pedir al proveedor.
final coberturaResurtidoProvider =
    NotifierProvider<CoberturaResurtidoNotifier, int>(
      CoberturaResurtidoNotifier.new,
    );

class CoberturaResurtidoNotifier extends Notifier<int> {
  @override
  int build() => 7;

  void cambiar(int dias) => state = dias;
}

/// Sugerencias de compra calculadas por el servidor, al día con WebSocket.
final resurtidoProvider =
    AsyncNotifierProvider<ResurtidoNotifier, ReporteResurtido>(
      ResurtidoNotifier.new,
      retry: (_, _) => null,
    );

class ResurtidoNotifier extends AsyncNotifier<ReporteResurtido> {
  @override
  Future<ReporteResurtido> build() async {
    final api = await ref.watch(apiProvider.future);
    final cobertura = ref.watch(coberturaResurtidoProvider);
    ref.listen(eventosProvider, (_, siguiente) {
      final evento = siguiente.value;
      if (evento == null) return;
      switch (evento.tipo) {
        case TiposEvento.ventaRegistrada:
        case TiposEvento.ventaCancelada:
        case TiposEvento.ventaDevuelta:
        case TiposEvento.productoActualizado:
        case TiposEvento.productoEliminado:
        case eventoReconectado:
          _refrescarSinParpadeo();
      }
    });
    return api.obtenerResurtido(dias: 30, cobertura: cobertura);
  }

  Future<void> refrescar() async {
    final api = await ref.read(apiProvider.future);
    final cobertura = ref.read(coberturaResurtidoProvider);
    state = await AsyncValue.guard(
      () => api.obtenerResurtido(dias: 30, cobertura: cobertura),
    );
  }

  Future<void> _refrescarSinParpadeo() async {
    final api = await ref.read(apiProvider.future);
    final cobertura = ref.read(coberturaResurtidoProvider);
    state = await AsyncValue.guard(
      () => api.obtenerResurtido(dias: 30, cobertura: cobertura),
    );
  }
}
