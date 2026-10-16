import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/tema/colores.dart';
import '../datos/modelos_envases.dart';
import '../estado/envases_provider.dart';

/// 5.6 Modal de Retorno y Liberación de Depósito
/// Permite al cajero ingresar la cantidad de envases devueltos por un cliente,
/// calcular el monto en efectivo a devolver, e impactar invisiblemente la
/// caja registradora registrando un retiro en la Pantalla de Movimientos (2.2).
class ModalRetornoDeposito extends ConsumerStatefulWidget {
  const ModalRetornoDeposito({
    super.key,
    this.clienteInicial,
    this.prestamoId,
    this.cantidadSugerida = 1,
    this.formatoInicial = TipoFormatoEnvase.media,
  });

  final String? clienteInicial;
  final String? prestamoId;
  final int cantidadSugerida;
  final TipoFormatoEnvase formatoInicial;

  static Future<bool?> mostrar({
    required BuildContext context,
    String? clienteInicial,
    String? prestamoId,
    int cantidadSugerida = 1,
    TipoFormatoEnvase formatoInicial = TipoFormatoEnvase.media,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ModalRetornoDeposito(
        clienteInicial: clienteInicial,
        prestamoId: prestamoId,
        cantidadSugerida: cantidadSugerida,
        formatoInicial: formatoInicial,
      ),
    );
  }

  @override
  ConsumerState<ModalRetornoDeposito> createState() =>
      _ModalRetornoDepositoState();
}

class _ModalRetornoDepositoState extends ConsumerState<ModalRetornoDeposito> {
  late int _cantidad;
  late TipoFormatoEnvase _formato;
  late TextEditingController _clienteCtrl;

  @override
  void initState() {
    super.initState();
    _cantidad = widget.cantidadSugerida.clamp(1, 999);
    _formato = widget.formatoInicial;
    _clienteCtrl = TextEditingController(text: widget.clienteInicial ?? '');
  }

  @override
  void dispose() {
    _clienteCtrl.dispose();
    super.dispose();
  }

  double get _montoReembolso => _cantidad * _formato.precioDeposito;

  void _confirmarDevolucion() {
    final cliente = _clienteCtrl.text.trim().isEmpty
        ? null
        : _clienteCtrl.text.trim();

    if (widget.prestamoId != null) {
      // Liquidar desde préstamo existente
      ref
          .read(envasesProvider.notifier)
          .liquidarPrestamo(
            prestamoId: widget.prestamoId!,
            cantidadDevuelta: _cantidad,
            devolverEfectivo: true,
          );
    } else {
      // Retorno libre de envases contra efectivo
      ref
          .read(envasesProvider.notifier)
          .registrarRetornoYReembolso(
            cantidad: _cantidad,
            montoReembolso: _montoReembolso,
            formato: _formato,
            cliente: cliente,
          );
    }

    Navigator.pop(context, true);

    // Alerta visual de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Éxito: Se entregaron \$${_montoReembolso.toStringAsFixed(2)} en efectivo y se registraron $_cantidad envases devueltos en caja.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF15803D),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            decoration: BoxDecoration(
              color: c.superficie,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 36,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cabecera
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: c.verde.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.payments_outlined,
                          color: c.verde,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Retorno de Envases',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: c.tinta,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Devolución de Efectivo al Cliente',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: c.verde,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        color: c.tinta2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Selector de formato
                  Text(
                    'Formato del envase:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c.tinta,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: TipoFormatoEnvase.values.map((f) {
                        final seleccionado = _formato == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            selected: seleccionado,
                            showCheckmark: false,
                            avatar: Icon(
                              f.icono,
                              size: 16,
                              color: seleccionado ? Colors.white : c.azul,
                            ),
                            label: Text(
                              '${f.etiqueta} (\$${f.precioDeposito.toStringAsFixed(0)})',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: seleccionado
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: seleccionado ? Colors.white : c.tinta,
                              ),
                            ),
                            selectedColor: c.azul,
                            backgroundColor: c.superficie2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: seleccionado
                                    ? Colors.transparent
                                    : c.linea,
                              ),
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _formato = f);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Controles de cantidad devuelta [-] [Número] [+]
                  Text(
                    'Cantidad de envases devueltos:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c.tinta,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: c.superficie2,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: c.linea),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Material(
                          color: _cantidad > 1
                              ? c.superficie
                              : c.superficie.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(14),
                          elevation: _cantidad > 1 ? 1 : 0,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: _cantidad > 1
                                ? () => setState(() => _cantidad--)
                                : null,
                            child: SizedBox(
                              width: 52,
                              height: 52,
                              child: Icon(
                                Icons.remove_rounded,
                                size: 32,
                                color: _cantidad > 1 ? c.tinta : c.linea,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '$_cantidad',
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: c.tinta,
                                height: 1,
                              ),
                            ),
                            Text(
                              _cantidad == 1 ? 'pieza' : 'piezas',
                              style: TextStyle(fontSize: 12, color: c.tinta2),
                            ),
                          ],
                        ),
                        Material(
                          color: c.azul,
                          borderRadius: BorderRadius.circular(14),
                          elevation: 1,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => setState(() => _cantidad++),
                            child: const SizedBox(
                              width: 52,
                              height: 52,
                              child: Icon(
                                Icons.add_rounded,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Cliente (opcional o de préstamo)
                  if (widget.clienteInicial == null) ...[
                    TextField(
                      controller: _clienteCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nombre del Cliente (opcional)',
                        hintText: 'Ej. Juan Pérez',
                        filled: true,
                        fillColor: c.superficie2,
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: c.linea),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Indicador de Reembolso: Jerarquía alta en el centro
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: c.verdeSuave,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: c.verde.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Monto a reembolsar:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: c.verde,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${_montoReembolso.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: c.verde,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          'Se registrará un retiro en efectivo de la caja',
                          style: TextStyle(
                            fontSize: 12,
                            color: c.verde.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón Primario: "Confirmar y Entregar Efectivo"
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _confirmarDevolucion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.verde,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.payments_rounded, size: 22),
                      label: Text(
                        'Confirmar y Entregar Efectivo (\$${_montoReembolso.toStringAsFixed(2)})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
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
