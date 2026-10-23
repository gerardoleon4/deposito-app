import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/proveedores.dart';
import '../../../core/tiempo_real/tiempo_real.dart';
import '../datos/modelos_envases.dart';

/// Balance, préstamos y bitácora de envases tal como los tiene la caja.
class EstadoEnvases {
  const EstadoEnvases({
    required this.balance,
    required this.prestamos,
    this.movimientos = const [],
  });

  final Map<String, BalanceEnvase> balance;

  /// Sin devolver, del más nuevo al más viejo.
  final List<PrestamoEnvase> prestamos;

  /// Bitácora, del más nuevo al más viejo.
  final List<MovimientoEnvase> movimientos;

  BalanceEnvase de(FormatoEnvase f) =>
      balance[f.clave] ??
      BalanceEnvase(formato: f.clave, bodega: 0, prestados: 0, precio: 0);

  /// Depósito por envase del formato, en centavos.
  int precio(FormatoEnvase f) => de(f).precio;

  int get totalBodega => balance.values.fold(0, (s, b) => s + b.bodega);

  int get totalPrestados => balance.values.fold(0, (s, b) => s + b.prestados);

  int get total => totalBodega + totalPrestados;
}

/// Al día con el WebSocket: `envases.actualizado` y la reconexión vuelven a
/// pedir balance, préstamos y bitácora (el evento solo trae el balance).
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
    String? telefono,
    required FormatoEnvase formato,
    required int cantidad,
  }) async {
    final api = await ref.read(apiProvider.future);
    await api.prestarEnvases(
      cliente: cliente,
      telefono: telefono,
      formato: formato.clave,
      cantidad: cantidad,
    );
    await refrescar();
  }

  /// Sin [cantidad], todo lo pendiente.
  Future<void> devolver(String prestamoId, {int? cantidad}) async {
    final api = await ref.read(apiProvider.future);
    await api.devolverPrestamo(prestamoId, cantidad: cantidad);
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

  Future<void> sacarVacios({
    required FormatoEnvase formato,
    required int cantidad,
    required String motivo,
  }) async {
    final api = await ref.read(apiProvider.future);
    await api.sacarVacios(
      formato: formato.clave,
      cantidad: cantidad,
      motivo: motivo,
    );
    await refrescar();
  }

  /// Entrega en efectivo el depósito de [cantidad] vacíos (retiro de caja).
  /// [claveIdempotencia] se reutiliza si se reintenta.
  Future<void> devolverDeposito({
    required FormatoEnvase formato,
    required int cantidad,
    String? cliente,
    required String claveIdempotencia,
  }) async {
    final api = await ref.read(apiProvider.future);
    await api.devolverDeposito(
      formato: formato.clave,
      cantidad: cantidad,
      cliente: cliente,
      claveIdempotencia: claveIdempotencia,
    );
    await refrescar();
  }

  Future<EstadoEnvases> _cargar() async {
    final api = await ref.read(apiProvider.future);
    final (balance, prestamos, movimientos) = await (
      api.obtenerBalanceEnvases(),
      api.listarPrestamos(),
      api.listarMovimientosEnvases(limite: 30),
    ).wait;
    return EstadoEnvases(
      balance: balance,
      prestamos: prestamos,
      movimientos: movimientos,
    );
  }
}
