import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/fallo_api.dart';
import '../../../core/api/idempotencia.dart';
import '../../../core/formato/formato.dart';
import '../../../core/widgets/estados.dart';
import '../estado/envases_provider.dart';
import 'modal_recepcion_envases.dart';
import 'modal_registro_prestamo.dart';
import 'modal_retorno_deposito.dart';

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
          telefono: nuevo.telefono,
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

Future<void> sacarVacios(BuildContext context, WidgetRef ref) async {
  final r = await ModalRecepcionEnvases.mostrar(
    context,
    modo: ModoVacios.salida,
  );
  if (r == null || !context.mounted) return;
  await _ejecutar(
    context,
    () => ref
        .read(envasesProvider.notifier)
        .sacarVacios(
          formato: r.formato,
          cantidad: r.cantidad,
          motivo: r.motivo!,
        ),
    '${r.cantidad} ${r.formato.etiqueta} salieron de bodega',
  );
}

/// Recibe un préstamo, total o parcialmente (sin dinero).
Future<void> recibirPrestamo(
  BuildContext context,
  WidgetRef ref,
  PrestamoEnvase p,
) async {
  final r = await ModalRetornoDeposito.mostrar(context, prestamo: p);
  if (r == null || !context.mounted) return;
  final completo = r.cantidad == p.cantidad;
  await _ejecutar(
    context,
    () => ref
        .read(envasesProvider.notifier)
        .devolver(p.id, cantidad: completo ? null : r.cantidad),
    completo
        ? 'Préstamo de ${p.cliente} saldado'
        : '${p.cliente} regresó ${r.cantidad}; le faltan ${p.cantidad - r.cantidad}',
  );
}

/// El cliente regresa vacíos y se le entrega su depósito en efectivo.
Future<void> devolverDeposito(BuildContext context, WidgetRef ref) async {
  final r = await ModalRetornoDeposito.mostrar(context);
  if (r == null || !context.mounted) return;
  final precio = ref.read(envasesProvider).value?.precio(r.formato) ?? 0;
  final clave = nuevaClaveIdempotencia();
  await _ejecutar(
    context,
    () => ref
        .read(envasesProvider.notifier)
        .devolverDeposito(
          formato: r.formato,
          cantidad: r.cantidad,
          cliente: r.cliente,
          claveIdempotencia: clave,
        ),
    'Se entregaron ${dinero(r.cantidad * precio)} en efectivo y '
    '${r.cantidad} envases entraron a bodega',
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
