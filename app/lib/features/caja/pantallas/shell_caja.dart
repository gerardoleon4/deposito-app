import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/tema/colores.dart';
import '../../../core/config/configuracion.dart';
import '../../../core/formato/formato.dart';
import '../../../core/servidor/servidor_embebido.dart';
import '../../../core/widgets/estados.dart';
import '../../../core/widgets/indicador_conexion.dart';
import '../../../core/widgets/marca.dart';
import '../../catalogo/estado/productos.dart';
import 'conectar_terminal.dart';
import 'secciones_caja.dart';

/// Marco de la caja: menú lateral café, barra superior y la sección activa.
///
/// - 1000 px o más (iPad horizontal): menú completo.
/// - 640 a 1000 px (iPad vertical): menú de íconos.
/// - Menos: menú en cajón (para probar en teléfono).
class ShellCaja extends ConsumerWidget {
  const ShellCaja({super.key, required this.seccion, required this.child});

  final String seccion;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servidor = ref.watch(servidorEmbebidoProvider);
    return switch (servidor) {
      AsyncData() => _Marco(seccion: seccion, child: child),
      AsyncError(:final error) => Scaffold(
        body: EstadoVacio(
          icono: Icons.dns_outlined,
          titulo: 'No se pudo iniciar la caja',
          mensaje:
              '$error\n\nCierra otras apps que usen el puerto $puertoServidor y reintenta.',
          accion: FilledButton.icon(
            onPressed: () => ref.invalidate(servidorEmbebidoProvider),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ),
      ),
      _ => const _Arrancando(),
    };
  }
}

class _Arrancando extends StatelessWidget {
  const _Arrancando();

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Scaffold(
      backgroundColor: c.vidrio,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LogoAnaquel(tamano: 72),
            const SizedBox(height: 20),
            Text(
              'Abriendo la caja…',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: c.vidrioTinta),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 160,
              child: LinearProgressIndicator(
                color: c.lager,
                backgroundColor: c.vidrio2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Marco extends StatelessWidget {
  const _Marco({required this.seccion, required this.child});

  final String seccion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, medidas) {
        final ancho = medidas.maxWidth;
        final actual = seccionCaja(seccion);
        if (ancho < 640) {
          return Scaffold(
            appBar: AppBar(
              title: Text(actual.titulo),
              actions: const [
                _BotonConectar(compacto: true),
                SizedBox(width: 8),
              ],
            ),
            drawer: Drawer(
              backgroundColor: context.colores.vidrio,
              child: _MenuLateral(
                seccion: seccion,
                compacto: false,
                alNavegar: () => Navigator.pop(context),
              ),
            ),
            body: child,
          );
        }
        final compacto = ancho < 1000;
        return Scaffold(
          body: Row(
            children: [
              _MenuLateral(seccion: seccion, compacto: compacto),
              Expanded(
                child: Column(
                  children: [
                    _BarraSuperior(
                      titulo: actual.titulo,
                      compacta: ancho < 820,
                    ),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuLateral extends ConsumerWidget {
  const _MenuLateral({
    required this.seccion,
    required this.compacto,
    this.alNavegar,
  });

  final String seccion;
  final bool compacto;
  final VoidCallback? alNavegar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colores;
    final textos = Theme.of(context).textTheme;
    final ip = ref.watch(direccionLocalProvider).value;
    final productos = ref.watch(productosProvider).value ?? const <Producto>[];
    final hoy = DateTime.now();
    final alertas = productos
        .where(
          (p) =>
              p.bajoMinimo ||
              (p.caducidad != null && diasHasta(p.caducidad!, hoy) <= 15),
        )
        .length;

    return Container(
      width: compacto ? 92 : 240,
      color: c.vidrio,
      child: SafeArea(
        right: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compacto ? 12 : 14,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: compacto
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(compacto ? 0 : 8, 0, 0, 22),
                child: Row(
                  mainAxisAlignment: compacto
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    const LogoAnaquel(),
                    if (!compacto) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Anaquel',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textos.headlineSmall?.copyWith(
                                color: c.vidrioTinta,
                                height: 1,
                              ),
                            ),
                            Text(
                              'Caja principal',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: c.vidrioTinta2,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    for (final s in seccionesCaja)
                      _ElementoMenu(
                        seccion: s,
                        activo: s.ruta == seccion,
                        compacto: compacto,
                        insignia: s.ruta == 'alertas' && alertas > 0
                            ? alertas
                            : null,
                        alTocar: () {
                          alNavegar?.call();
                          context.go('/caja/${s.ruta}');
                        },
                      ),
                  ],
                ),
              ),
              if (!compacto)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      IndicadorConexion(
                        colorTexto: c.vidrioTinta,
                        etiquetaEnLinea: 'Servidor activo',
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.wifi_rounded,
                            size: 16,
                            color: c.vidrioTinta2,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              ip == null ? 'Sin Wi-Fi' : '$ip:$puertoServidor',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: c.vidrioTinta2,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ElementoMenu extends StatelessWidget {
  const _ElementoMenu({
    required this.seccion,
    required this.activo,
    required this.compacto,
    required this.alTocar,
    this.insignia,
  });

  final SeccionCaja seccion;
  final bool activo;
  final bool compacto;
  final VoidCallback alTocar;
  final int? insignia;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final color = activo ? c.lagerTinta : c.vidrioTinta;
    final icono = Icon(
      activo ? seccion.iconoActivo : seccion.icono,
      color: color,
      size: 23,
    );
    final contenido = compacto
        ? Badge(
            isLabelVisible: insignia != null,
            label: Text('${insignia ?? ''}'),
            backgroundColor: c.alerta,
            child: icono,
          )
        : Row(
            children: [
              icono,
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  seccion.titulo,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: activo ? FontWeight.w600 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
              if (insignia != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: activo ? c.vidrio : c.alerta,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$insignia',
                    style: TextStyle(
                      color: activo ? c.vidrioTinta : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Tooltip(
        message: compacto ? seccion.titulo : '',
        child: Material(
          color: activo ? c.lager : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            hoverColor: c.vidrio2,
            onTap: alTocar,
            child: Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: compacto ? 0 : 12),
              alignment: compacto ? Alignment.center : Alignment.centerLeft,
              child: contenido,
            ),
          ),
        ),
      ),
    );
  }
}

class _BarraSuperior extends ConsumerWidget {
  const _BarraSuperior({required this.titulo, required this.compacta});

  final String titulo;
  final bool compacta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colores;
    final tema = ref.watch(configuracionProvider).tema;
    final oscuro =
        tema == ThemeMode.dark ||
        (tema == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 20, 12),
      decoration: BoxDecoration(
        color: c.superficie,
        border: Border(bottom: BorderSide(color: c.linea)),
      ),
      child: SafeArea(
        bottom: false,
        left: false,
        child: Row(
          spacing: 10,
          children: [
            Expanded(
              child: Text(
                titulo,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            if (!compacta)
              Pildora(
                texto: fechaLarga(DateTime.now()),
                icono: Icons.calendar_today_rounded,
              ),
            IconButton.outlined(
              tooltip: oscuro ? 'Tema claro' : 'Tema oscuro',
              style: IconButton.styleFrom(side: BorderSide(color: c.linea)),
              onPressed: () => ref
                  .read(configuracionProvider.notifier)
                  .cambiarTema(oscuro ? ThemeMode.light : ThemeMode.dark),
              icon: Icon(
                oscuro ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
            ),
            _BotonConectar(compacto: compacta),
          ],
        ),
      ),
    );
  }
}

class _BotonConectar extends StatelessWidget {
  const _BotonConectar({required this.compacto});

  final bool compacto;

  @override
  Widget build(BuildContext context) => compacto
      ? IconButton.outlined(
          tooltip: 'Conectar terminal',
          onPressed: () => mostrarConectarTerminal(context),
          icon: const Icon(Icons.qr_code_2_rounded),
        )
      : OutlinedButton.icon(
          onPressed: () => mostrarConectarTerminal(context),
          icon: const Icon(Icons.qr_code_2_rounded),
          label: const Text('Conectar terminal'),
        );
}
