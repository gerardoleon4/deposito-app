import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/tema/colores.dart';
import '../../core/config/configuracion.dart';
import '../../core/widgets/marca.dart';

/// Primera pantalla: ¿este dispositivo es la caja o una terminal?
class ElegirModo extends ConsumerWidget {
  const ElegirModo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colores;
    final textos = Theme.of(context).textTheme;
    final notificador = ref.read(configuracionProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, medidas) {
            final ancho = medidas.maxWidth >= 760;
            final opciones = [
              _Opcion(
                icono: Icons.point_of_sale_rounded,
                titulo: 'Caja',
                texto: 'Guarda la base de datos, cobra y recibe a las terminales. Debe quedarse encendida con la app abierta.',
                alElegir: () => notificador.elegirModo(ModoDispositivo.caja),
              ),
              _Opcion(
                icono: Icons.smartphone_rounded,
                titulo: 'Terminal',
                texto: 'Escanea productos, arma pedidos y consulta existencias en los pasillos. Se conecta a la caja por Wi-Fi.',
                alElegir: () =>
                    notificador.elegirModo(ModoDispositivo.terminal),
              ),
            ];
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: ancho ? 48 : 22,
                vertical: 40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 880),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const LogoAnaquel(tamano: 52),
                          const SizedBox(width: 14),
                          Text('Anaquel', style: textos.headlineLarge),
                        ],
                      ),
                      const SizedBox(height: 36),
                      Flex(
                        direction: ancho ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: ancho
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Punto de venta\ndel depósito',
                                  style: ancho
                                      ? textos.displayLarge
                                      : textos.displayMedium,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Ventas, inventario y envases en tiempo real entre la caja y los teléfonos del equipo. '
                                  'Para empezar, dinos cómo se usará este dispositivo; puedes cambiarlo después en Ajustes.',
                                  style: textos.bodyLarge?.copyWith(
                                    color: c.tinta2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (ancho) ...[
                            const SizedBox(width: 40),
                            const _Escena(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 36),
                      if (ancho)
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: opciones[0]),
                              const SizedBox(width: 18),
                              Expanded(child: opciones[1]),
                            ],
                          ),
                        )
                      else
                        Column(spacing: 14, children: opciones),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.icono,
    required this.titulo,
    required this.texto,
    required this.alElegir,
  });

  final IconData icono;
  final String titulo;
  final String texto;
  final VoidCallback alElegir;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final textos = Theme.of(context).textTheme;
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          color: c.superficie,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.linea),
          boxShadow: c.sombra,
        ),
        child: InkWell(
          onTap: alElegir,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: c.lager,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icono, color: c.lagerTinta, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(titulo, style: textos.headlineMedium),
                          ),
                          Icon(Icons.arrow_forward_rounded, color: c.tinta2),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        texto,
                        style: textos.bodyMedium?.copyWith(color: c.tinta2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dibujo de un iPad y un teléfono conectados por Wi-Fi.
class _Escena extends StatelessWidget {
  const _Escena();

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    Widget celda() => Container(
      decoration: BoxDecoration(
        color: c.superficie2,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 16,
          decoration: BoxDecoration(
            color: c.lager,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
    return SizedBox(
      width: 300,
      height: 200,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 24,
            child: Container(
              width: 210,
              height: 150,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: c.tinta,
                borderRadius: BorderRadius.circular(16),
                boxShadow: c.sombra,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      color: c.vidrio,
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        spacing: 6,
                        children: [
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: c.lager,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          for (var i = 0; i < 4; i++)
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: c.vidrioTinta2,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: c.fondo,
                        padding: const EdgeInsets.all(7),
                        child: GridView.count(
                          crossAxisCount: 3,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          physics: const NeverScrollableScrollPhysics(),
                          children: List.generate(6, (_) => celda()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 60,
            child: Container(
              width: 72,
              height: 132,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: c.tinta,
                borderRadius: BorderRadius.circular(14),
                boxShadow: c.sombra,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  children: [
                    Container(height: 20, color: c.vidrio),
                    Expanded(
                      child: Container(
                        color: c.fondo,
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          spacing: 6,
                          children: [
                            Expanded(child: celda()),
                            Container(
                              height: 7,
                              decoration: BoxDecoration(
                                color: c.lager,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: c.superficie3,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 26,
            top: 14,
            child: Icon(Icons.wifi_rounded, size: 40, color: c.verde),
          ),
        ],
      ),
    );
  }
}
