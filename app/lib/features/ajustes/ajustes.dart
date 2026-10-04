import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/tema/colores.dart';
import '../../core/config/configuracion.dart';
import '../../core/servidor/servidor_embebido.dart';
import '../../core/widgets/estados.dart';

/// Ajustes de este dispositivo. Los del negocio (nombre, días de alerta,
/// respaldo, PIN) llegan en el Sprint 4.
class PantallaAjustes extends ConsumerWidget {
  const PantallaAjustes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configuracionProvider);
    final notificador = ref.read(configuracionProvider.notifier);
    final c = context.colores;
    final esCaja = config.modo == ModoDispositivo.caja;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 18,
              children: [
                _Grupo(
                  titulo: 'Apariencia',
                  children: [
                    SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.brightness_auto_outlined),
                          label: Text('Automático'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode_outlined),
                          label: Text('Claro'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode_outlined),
                          label: Text('Oscuro'),
                        ),
                      ],
                      selected: {config.tema},
                      onSelectionChanged: (s) =>
                          notificador.cambiarTema(s.first),
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: c.seleccion,
                        selectedForegroundColor: c.seleccionTinta,
                        side: BorderSide(color: c.linea),
                      ),
                    ),
                  ],
                ),
                _Grupo(
                  titulo: 'Este dispositivo',
                  children: [
                    _Dato('Modo', esCaja ? 'Caja (servidor)' : 'Terminal'),
                    if (esCaja) ...[
                      _Dato(
                        'Dirección en la Wi-Fi',
                        '${ref.watch(direccionLocalProvider).value ?? 'sin Wi-Fi'}:$puertoServidor',
                      ),
                      _Dato('Versión del servidor', versionServidor),
                    ] else if (config.conexion case final cx?) ...[
                      _Dato('Nombre', cx.nombre),
                      _Dato('Caja', '${cx.host}:${cx.puerto}'),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        if (!esCaja)
                          OutlinedButton.icon(
                            onPressed: () async {
                              final ok = await confirmar(
                                context,
                                titulo: '¿Desvincular de la caja?',
                                mensaje: 'Para volver a usar esta terminal hay que escanear un código nuevo en la caja.',
                                accion: 'Desvincular',
                                peligrosa: true,
                              );
                              if (ok) await notificador.olvidarConexion();
                            },
                            icon: const Icon(Icons.link_off_rounded),
                            label: const Text('Desvincular de la caja'),
                          ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final ok = await confirmar(
                              context,
                              titulo: 'Cambiar el modo',
                              mensaje: esCaja
                                  ? 'La caja dejará de atender a las terminales. Los datos se conservan en este iPad.'
                                  : 'Esta terminal se desvinculará de la caja.',
                              accion: 'Cambiar modo',
                              peligrosa: esCaja,
                            );
                            if (!ok) return;
                            if (!esCaja) await notificador.olvidarConexion();
                            await notificador.elegirModo(null);
                          },
                          icon: const Icon(Icons.swap_horiz_rounded),
                          label: const Text('Cambiar modo'),
                        ),
                      ],
                    ),
                  ],
                ),
                _Grupo(
                  titulo: 'Próximamente',
                  children: [
                    Text(
                      'Nombre del negocio, días de alerta de caducidad, PIN del dueño, respaldo y restauración (Sprint 4).',
                      style: TextStyle(color: c.tinta2),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Grupo extends StatelessWidget {
  const _Grupo({required this.titulo, required this.children});

  final String titulo;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.linea),
        boxShadow: c.sombra,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Text(titulo, style: Theme.of(context).textTheme.titleLarge),
          ...children,
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato(this.etiqueta, this.valor);

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(etiqueta, style: TextStyle(color: context.colores.tinta2)),
      ),
      Flexible(
        child: Text(
          valor,
          style: const TextStyle(fontWeight: FontWeight.w600),
          textAlign: TextAlign.right,
        ),
      ),
    ],
  );
}
