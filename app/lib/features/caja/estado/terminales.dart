import 'dart:async';

import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/proveedores.dart';

/// Terminales vinculadas. El servidor no avisa por WebSocket cuando una se
/// conecta, así que se vuelve a pedir cada 10 s mientras alguien la vea.
final terminalesProvider = FutureProvider.autoDispose<List<Terminal>>((
  ref,
) async {
  final api = await ref.watch(apiProvider.future);
  final reintento = Timer(const Duration(seconds: 10), ref.invalidateSelf);
  ref.onDispose(reintento.cancel);
  return api.listarTerminales();
}, retry: (_, _) => null);
