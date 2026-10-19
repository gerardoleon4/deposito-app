import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/fallo_api.dart';
import '../../../core/api/idempotencia.dart';
import '../../../core/widgets/estados.dart';
import '../estado/turno_provider.dart';
import 'apertura_caja.dart';
import 'arqueo_caja.dart';
import 'corte_caja.dart';
import 'movimientos_caja.dart';
import 'recibo_cierre.dart';

/// Sección "Corte de caja": con la caja cerrada, la apertura con fondo; con
/// un turno abierto, sus movimientos, y de ahí el corte, el conteo físico y
/// el recibo de cierre (pantallas de Pablo).
class SeccionCorte extends ConsumerWidget {
  const SeccionCorte({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(turnoProvider)) {
      AsyncData(value: DetalleTurno(turno: null)) => AperturaCaja(
        nombreCajero: 'Caja principal',
        inicialesCajero: 'CP',
        alAbrir: (fondo) => _ejecutar(
          context,
          () => ref.read(turnoProvider.notifier).abrir(fondo),
        ),
      ),
      AsyncData(:final value) => _TurnoAbierto(detalle: value),
      AsyncError(:final error) => EstadoError(
        error: error,
        alReintentar: () => ref.read(turnoProvider.notifier).refrescar(),
      ),
      _ => const Cargando(mensaje: 'Cargando la caja'),
    };
  }
}

class _TurnoAbierto extends ConsumerWidget {
  const _TurnoAbierto({required this.detalle});

  final DetalleTurno detalle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turno = detalle.turno!;
    final filas = [
      for (final m in detalle.movimientos.reversed)
        FilaMovimiento(
          hora: DateTime.parse(m.fecha).toLocal(),
          esIngreso: m.tipo == 'ingreso',
          motivo: m.motivo,
          monto: m.monto,
        ),
      FilaMovimiento(
        hora: DateTime.parse(turno.apertura).toLocal(),
        esIngreso: true,
        motivo: 'Apertura de caja (fondo)',
        monto: turno.fondo,
      ),
    ];
    return MovimientosCaja(
      saldoEstimado: turno.resumen.esperado,
      movimientos: filas,
      alRegistrar: (esIngreso, monto, motivo) async {
        try {
          await ref
              .read(turnoProvider.notifier)
              .registrarMovimiento(
                esIngreso: esIngreso,
                monto: monto,
                motivo: motivo,
              );
          return null;
        } on FalloApi catch (e) {
          return e.campos.values.firstOrNull ?? mensajeDeError(e);
        }
      },
      alCorte: () => _abrirCorte(context, ref),
    );
  }

  void _abrirCorte(BuildContext context, WidgetRef ref) {
    final navegador = Navigator.of(context, rootNavigator: true);
    navegador.push(
      MaterialPageRoute(
        builder: (_) => Consumer(
          builder: (context, ref, _) {
            final turno = ref.watch(turnoProvider).value?.turno;
            if (turno == null) return const Cargando();
            return CorteCaja(
              turno: turno,
              alArqueo: () => navegador.push(
                MaterialPageRoute(
                  builder: (_) => _Arqueo(esperado: turno.resumen.esperado),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// El conteo físico. Una clave de cierre por pantalla: si se reintenta, el
/// servidor regresa el mismo corte.
class _Arqueo extends ConsumerStatefulWidget {
  const _Arqueo({required this.esperado});

  final int esperado;

  @override
  ConsumerState<_Arqueo> createState() => _ArqueoState();
}

class _ArqueoState extends ConsumerState<_Arqueo> {
  final _clave = nuevaClaveIdempotencia();

  @override
  Widget build(BuildContext context) {
    final navegador = Navigator.of(context, rootNavigator: true);
    return ArqueoCaja(
      esperado: widget.esperado,
      alCerrar: (contado, nota) async {
        try {
          final corte = await ref
              .read(turnoProvider.notifier)
              .cerrar(contado: contado, nota: nota, claveIdempotencia: _clave);
          navegador.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => ReciboCierre(
                corte: corte,
                alFinalizar: () => navegador.popUntil((r) => r.isFirst),
              ),
            ),
            (r) => r.isFirst,
          );
        } on FalloApi catch (e) {
          if (context.mounted) {
            avisar(context, e.campos.values.firstOrNull ?? mensajeDeError(e));
          }
        }
      },
    );
  }
}

Future<void> _ejecutar(
  BuildContext context,
  Future<void> Function() accion,
) async {
  try {
    await accion();
  } on FalloApi catch (e) {
    if (context.mounted) avisar(context, mensajeDeError(e));
  }
}
