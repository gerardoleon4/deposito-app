import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/fallo_api.dart';
import '../../../core/widgets/estados.dart';
import '../datos/modelos_envases.dart';
import '../estado/envases_provider.dart';
import 'modal_recepcion_envases.dart';
import 'modal_registro_prestamo.dart';

/// Acciones de envases que comparten el tablero y el historial. Cada una
/// pide los datos, llama al servidor y avisa el resultado o el error.

Future<void> prestarEnvases(BuildContext context, WidgetRef ref) async {
  final nuevo = await ModalRegistroPrestamo.mostrar(context);
  if (nuevo == null || !context.mounted) return;
  await _ejecutar(
    context,
    () => ref
        .read(envasesProvider.notifier)
        .prestar(
          cliente: nuevo.cliente,
          formato: nuevo.formato,
          cantidad: nuevo.cantidad,
        ),
    'Préstamo de ${nuevo.cantidad} ${nuevo.formato.etiqueta} a ${nuevo.cliente}',
  );
}

Future<void> recibirVacios(BuildContext context, WidgetRef ref) async {
  final r = await ModalRecepcionEnvases.mostrar(context);
  if (r == null || !context.mounted) return;
  await _ejecutar(
    context,
    () => ref
        .read(envasesProvider.notifier)
        .recibirVacios(formato: r.formato, cantidad: r.cantidad),
    '${r.cantidad} ${r.formato.etiqueta} entraron a bodega',
  );
}

Future<void> recibirPrestamo(
  BuildContext context,
  WidgetRef ref,
  PrestamoEnvase p,
) async {
  final formato = FormatoEnvase.de(p.formato);
  final ok = await confirmar(
    context,
    titulo: 'Recibir envases',
    mensaje:
        '${p.cliente} regresa ${p.cantidad} ${formato.etiqueta} vacíos. '
        'Entran a bodega y el préstamo queda saldado.',
    accion: 'Recibir ${p.cantidad}',
  );
  if (!ok || !context.mounted) return;
  await _ejecutar(
    context,
    () => ref.read(envasesProvider.notifier).devolver(p.id),
    'Préstamo de ${p.cliente} saldado',
  );
}

Future<void> _ejecutar(
  BuildContext context,
  Future<void> Function() accion,
  String exito,
) async {
  try {
    await accion();
    if (context.mounted) avisar(context, exito);
  } on FalloApi catch (e) {
    // En datos_invalidos, el campo dice qué falló mejor que el mensaje general.
    final detalle = e.campos.values.firstOrNull ?? mensajeDeError(e);
    if (context.mounted) avisar(context, detalle);
  }
}
