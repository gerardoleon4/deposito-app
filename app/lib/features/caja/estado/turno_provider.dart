import 'dart:async';

import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api.dart';
import '../../../core/api/idempotencia.dart';
import '../../../core/api/proveedores.dart';
import '../../../core/respaldo/respaldos.dart';
import '../../../core/tiempo_real/tiempo_real.dart';

/// El turno abierto con sus movimientos (`turno: null` si la caja está
/// cerrada). Al día con el WebSocket: abrir, movimientos, cerrar y ventas.
final turnoProvider = AsyncNotifierProvider<TurnoNotifier, DetalleTurno>(
  TurnoNotifier.new,
  retry: (_, _) => null,
);

const _eventosQueRecargan = {
  TiposEvento.cajaAbierta,
  TiposEvento.cajaActualizada,
  TiposEvento.cajaCerrada,
  TiposEvento.ventaRegistrada,
  TiposEvento.ventaCancelada,
  TiposEvento.ventaDevuelta,
  eventoReconectado,
};

class TurnoNotifier extends AsyncNotifier<DetalleTurno> {
  @override
  Future<DetalleTurno> build() async {
    final api = await ref.watch(apiProvider.future);
    ref.listen(eventosProvider, (_, siguiente) {
      if (_eventosQueRecargan.contains(siguiente.value?.tipo)) refrescar();
    });
    return api.turnoActual();
  }

  Future<void> refrescar() async {
    final api = await ref.read(apiProvider.future);
    state = await AsyncValue.guard(api.turnoActual);
  }

  /// Los errores llegan como `FalloApi`.
  Future<void> abrir(int fondo, {String? usuarioId}) async {
    final api = await ref.read(apiProvider.future);
    await api.abrirCaja(fondo: fondo, usuarioId: usuarioId);
    await refrescar();
  }

  Future<void> registrarMovimiento({
    required bool esIngreso,
    required int monto,
    required String motivo,
  }) async {
    final api = await ref.read(apiProvider.future);
    await api.registrarMovimientoCaja(
      tipo: esIngreso ? 'ingreso' : 'retiro',
      monto: monto,
      motivo: motivo,
      claveIdempotencia: nuevaClaveIdempotencia(),
    );
    await refrescar();
  }

  /// Hace el corte y regresa el turno cerrado. [claveIdempotencia] se
  /// reutiliza si se reintenta el mismo cierre.
  Future<Turno> cerrar({
    required int contado,
    String? nota,
    String? usuarioId,
    required String claveIdempotencia,
  }) async {
    final api = await ref.read(apiProvider.future);
    final corte = await api.cerrarCaja(
      contado: contado,
      nota: nota,
      usuarioId: usuarioId,
      claveIdempotencia: claveIdempotencia,
    );
    await refrescar();
    // Respaldo automático del cierre, en segundo plano: el corte ya quedó y
    // el recibo no espera.
    if (!kIsWeb) unawaited(_respaldar(api));
    return corte;
  }

  Future<void> _respaldar(Api api) async {
    try {
      await guardarRespaldo(api);
    } catch (_) {
      // Sin carpeta de documentos (pruebas) o sin espacio: se sigue.
    }
  }
}
