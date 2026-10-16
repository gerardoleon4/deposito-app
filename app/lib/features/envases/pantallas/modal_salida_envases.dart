import 'package:flutter/material.dart';
import '../../../../app/tema/colores.dart';
import '../datos/modelos_envases.dart';

enum AccionSalidaEnvases { cobrarDeposito, clienteTrajoVacios, prestarEnvases }

class ResultadoSalidaEnvases {
  final AccionSalidaEnvases accion;
  final double montoDeposito;
  final int cantidadVaciosRecibidos;
  final double creditoVacios;
  final String? clientePrestamo;
  final String? telefonoPrestamo;

  ResultadoSalidaEnvases({
    required this.accion,
    this.montoDeposito = 0.0,
    this.cantidadVaciosRecibidos = 0,
    this.creditoVacios = 0.0,
    this.clientePrestamo,
    this.telefonoPrestamo,
  });
}

/// 5.3 Flujo de Salida (Cliente se lleva producto en envase)
/// Modal de alta prioridad que salta automáticamente al intentar cobrar cuando
/// hay productos retornables en el carrito y no se han registrado vacíos previos.
class ModalSalidaEnvases extends StatelessWidget {
  const ModalSalidaEnvases({
    super.key,
    required this.cantidadRetornables,
    this.formato = TipoFormatoEnvase.media,
    this.montoDepositoUnitario = 5.0,
  });

  final int cantidadRetornables;
  final TipoFormatoEnvase formato;
  final double montoDepositoUnitario;

  double get montoDepositoTotal => cantidadRetornables * montoDepositoUnitario;

  static Future<ResultadoSalidaEnvases?> mostrar({
    required BuildContext context,
    required int cantidadRetornables,
    TipoFormatoEnvase formato = TipoFormatoEnvase.media,
    double montoDepositoUnitario = 5.0,
  }) {
    return showDialog<ResultadoSalidaEnvases>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ModalSalidaEnvases(
        cantidadRetornables: cantidadRetornables,
        formato: formato,
        montoDepositoUnitario: montoDepositoUnitario,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            decoration: BoxDecoration(
              color: c.superficie,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 36,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icono e indicador de alta prioridad
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: c.azul.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.sync_alt_rounded,
                          color: c.azul,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'PRODUCTOS RETORNABLES',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFB45309),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '¿Cómo se manejan los envases de esta compra?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: c.tinta,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Aviso de cantidad
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: c.superficie2,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: c.linea),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 20,
                          color: c.tinta2,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Esta venta incluye $cantidadRetornables ${cantidadRetornables == 1 ? 'producto retornable' : 'productos retornables'} (${formato.etiqueta}).',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: c.tinta,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // OPCIÓN 1: Cobrar depósito del envase
                  _BotonOpcionOneTap(
                    titulo: 'Cobrar depósito del envase',
                    subtitulo:
                        'Suma +\$${montoDepositoTotal.toStringAsFixed(2)} al ticket (\$${montoDepositoUnitario.toStringAsFixed(0)} c/u)',
                    icono: Icons.payments_outlined,
                    colorIcono: c.azul,
                    fondoIcono: c.azul.withValues(alpha: 0.1),
                    etiquetaBadge:
                        '+\$${montoDepositoTotal.toStringAsFixed(2)}',
                    colorBadge: c.azul,
                    alTocar: () {
                      Navigator.pop(
                        context,
                        ResultadoSalidaEnvases(
                          accion: AccionSalidaEnvases.cobrarDeposito,
                          montoDeposito: montoDepositoTotal,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // OPCIÓN 2: El cliente entregó vacíos
                  _BotonOpcionOneTap(
                    titulo: 'El cliente entregó vacíos',
                    subtitulo:
                        'Intercambio 1 a 1 o registrar cantidad recibida',
                    icono: Icons.recycling_rounded,
                    colorIcono: c.verde,
                    fondoIcono: c.verde.withValues(alpha: 0.12),
                    etiquetaBadge: 'Sin costo / Crédito',
                    colorBadge: c.verde,
                    alTocar: () {
                      Navigator.pop(
                        context,
                        ResultadoSalidaEnvases(
                          accion: AccionSalidaEnvases.clienteTrajoVacios,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // OPCIÓN 3: Prestar envases / Fiar
                  _BotonOpcionOneTap(
                    titulo: 'Prestar envases / Fiar',
                    subtitulo:
                        'Registrar a nombre del cliente en préstamos activos',
                    icono: Icons.handshake_outlined,
                    colorIcono: const Color(0xFFD97706),
                    fondoIcono: Colors.amber.withValues(alpha: 0.15),
                    etiquetaBadge: 'Préstamo',
                    colorBadge: const Color(0xFFD97706),
                    alTocar: () {
                      Navigator.pop(
                        context,
                        ResultadoSalidaEnvases(
                          accion: AccionSalidaEnvases.prestarEnvases,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Botón cancelar / saltar
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Revisar Carrito',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: c.tinta2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BotonOpcionOneTap extends StatelessWidget {
  const _BotonOpcionOneTap({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.colorIcono,
    required this.fondoIcono,
    required this.etiquetaBadge,
    required this.colorBadge,
    required this.alTocar,
  });

  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Color colorIcono;
  final Color fondoIcono;
  final String etiquetaBadge;
  final Color colorBadge;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;

    return Material(
      color: c.superficie,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: alTocar,
        borderRadius: BorderRadius.circular(18),
        hoverColor: c.superficie2,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: c.linea, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: fondoIcono,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icono, color: colorIcono, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: c.tinta,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitulo,
                      style: TextStyle(fontSize: 13, color: c.tinta2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorBadge.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  etiquetaBadge,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colorBadge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
