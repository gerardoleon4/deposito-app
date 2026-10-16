import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/proveedores.dart';
import '../../../core/tiempo_real/tiempo_real.dart';
import '../datos/modelos_envases.dart';

/// Balance y préstamos de envases tal como los tiene la caja.
class EstadoEnvases {
  const EstadoEnvases({required this.balance, required this.prestamos});

  final Map<String, BalanceEnvase> balance;

  /// Sin devolver, del más nuevo al más viejo.
  final List<PrestamoEnvase> prestamos;

  BalanceEnvase de(FormatoEnvase f) =>
      balance[f.clave] ??
      BalanceEnvase(formato: f.clave, bodega: 0, prestados: 0, precio: 0);

  int get totalBodega => balance.values.fold(0, (s, b) => s + b.bodega);

  int get totalPrestados => balance.values.fold(0, (s, b) => s + b.prestados);

  int get total => totalBodega + totalPrestados;
}

/// Al día con el WebSocket: `envases.actualizado` y la reconexión vuelven a
/// pedir balance y préstamos (el evento no trae los préstamos).
final envasesProvider = AsyncNotifierProvider<EnvasesNotifier, EstadoEnvases>(
  EnvasesNotifier.new,
  retry: (_, _) => null,
);

class EnvasesNotifier extends AsyncNotifier<EstadoEnvases> {
  @override
  Future<EstadoEnvases> build() async {
    // Si cambia la conexión (otra caja, otra clave), se vuelve a construir.
    await ref.watch(apiProvider.future);
    ref.listen(eventosProvider, (_, siguiente) {
      final tipo = siguiente.value?.tipo;
      if (tipo == TiposEvento.balanceEnvasesActualizado ||
          tipo == eventoReconectado) {
        refrescar();
      }
    });
    return _cargar();
  }

  Future<void> refrescar() async {
    state = await AsyncValue.guard(_cargar);
  }

  /// Los errores llegan como `FalloApi` para mostrarlos en la pantalla.
  Future<void> prestar({
    required String cliente,
    required FormatoEnvase formato,
    required int cantidad,
  }) async {
    final api = await ref.read(apiProvider.future);
    await api.prestarEnvases(
      cliente: cliente,
      formato: formato.clave,
      cantidad: cantidad,
    );
    await refrescar();
  }

  Future<void> devolver(String prestamoId) async {
    final api = await ref.read(apiProvider.future);
    await api.devolverPrestamo(prestamoId);
    await refrescar();
  }

  Future<void> recibirVacios({
    required FormatoEnvase formato,
    required int cantidad,
  }) async {
    final api = await ref.read(apiProvider.future);
    await api.recibirVacios(formato: formato.clave, cantidad: cantidad);
    await refrescar();
  }

  Future<EstadoEnvases> _cargar() async {
    final api = await ref.read(apiProvider.future);
    final (balance, prestamos) = await (
      api.obtenerBalanceEnvases(),
      api.listarPrestamos(),
    ).wait;
    return EstadoEnvases(balance: balance, prestamos: prestamos);
  }
}
