import 'package:flutter/material.dart';

import '../../../../app/tema/colores.dart';
import '../../../../core/formato/formato.dart';
import '../../../../core/widgets/teclado_numerico.dart';
import 'corte_caja.dart';

class MovimientoCaja {
  final String id;
  final DateTime hora;
  final bool esIngreso;
  final String motivo;

  /// Centavos.
  final int monto;

  MovimientoCaja(this.id, this.hora, this.esIngreso, this.motivo, this.monto);
}

class MovimientosCaja extends StatefulWidget {
  const MovimientosCaja({super.key});

  @override
  State<MovimientosCaja> createState() => _MovimientosCajaState();
}

class _MovimientosCajaState extends State<MovimientosCaja> {
  int _saldoEstimado = 150000;
  final List<MovimientoCaja> _movimientos = [
    MovimientoCaja(
      '1',
      DateTime.now().subtract(const Duration(hours: 2)),
      true,
      'Apertura de caja',
      100000,
    ),
    MovimientoCaja(
      '2',
      DateTime.now().subtract(const Duration(minutes: 45)),
      false,
      'Pago proveedor hielo',
      25000,
    ),
    MovimientoCaja(
      '3',
      DateTime.now().subtract(const Duration(minutes: 10)),
      true,
      'Venta efectivo',
      75000,
    ),
  ];

  void _abrirRegistroMovimiento() {
    showDialog(
      context: context,
      builder: (_) => ModalRegistroMovimiento(
        alGuardar: (esIngreso, monto, motivo) {
          setState(() {
            _movimientos.insert(
              0,
              MovimientoCaja(
                DateTime.now().toString(),
                DateTime.now(),
                esIngreso,
                motivo,
                monto,
              ),
            );
            if (esIngreso) {
              _saldoEstimado += monto;
            } else {
              _saldoEstimado -= monto;
            }
          });
        },
      ),
    );
  }

  void _irAlCorte() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CorteCaja()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;

    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        backgroundColor: c.fondo,
        elevation: 0,
        title: Text(
          'Historial de Movimientos',
          style: TextStyle(color: c.tinta, fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: _abrirRegistroMovimiento,
              style: TextButton.styleFrom(
                backgroundColor: c.azul.withValues(alpha: 0.1),
                foregroundColor: c.azul,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text(
                'Registrar Movimiento',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Saldo estimado
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: c.azul,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saldo actual estimado',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dinero(_saldoEstimado),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _irAlCorte,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: c.azul,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Corte de Caja',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Tabla
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: c.superficie,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  border: Border.all(color: c.linea),
                ),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'HORA',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: c.tinta2,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'TIPO',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: c.tinta2,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              'MOTIVO',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: c.tinta2,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'MONTO',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: c.tinta2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _movimientos.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final mov = _movimientos[i];
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${mov.hora.hour}:${mov.hora.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(color: c.tinta),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Icon(
                                        mov.esIngreso
                                            ? Icons.arrow_upward_rounded
                                            : Icons.arrow_downward_rounded,
                                        size: 16,
                                        color: mov.esIngreso
                                            ? Colors.green[600]
                                            : c.tinta2,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        mov.esIngreso ? 'Ingreso' : 'Retiro',
                                        style: TextStyle(
                                          color: mov.esIngreso
                                              ? Colors.green[600]
                                              : c.tinta2,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    mov.motivo,
                                    style: TextStyle(color: c.tinta),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    dinero(mov.monto),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: c.tinta,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 2.3 Modal de Registro de Movimiento
class ModalRegistroMovimiento extends StatefulWidget {
  const ModalRegistroMovimiento({super.key, required this.alGuardar});

  /// [centavos] del movimiento.
  final void Function(bool esIngreso, int centavos, String motivo) alGuardar;

  @override
  State<ModalRegistroMovimiento> createState() =>
      _ModalRegistroMovimientoState();
}

class _ModalRegistroMovimientoState extends State<ModalRegistroMovimiento> {
  bool _esIngreso = false;
  final _motivoCtrl = TextEditingController();
  String _montoText = '';

  @override
  void dispose() {
    _motivoCtrl.dispose();
    super.dispose();
  }

  void _teclear(String tecla) {
    setState(() {
      if (_montoText.length < 6) _montoText += tecla;
    });
  }

  void _borrar() {
    setState(() {
      if (_montoText.isNotEmpty) {
        _montoText = _montoText.substring(0, _montoText.length - 1);
      }
    });
  }

  /// Se teclean pesos enteros.
  int get _monto => _montoText.isEmpty ? 0 : int.parse(_montoText) * 100;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final puedeGuardar = _monto > 0 && _motivoCtrl.text.trim().isNotEmpty;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: c.superficie,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Registrar Movimiento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: c.tinta,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Toggle
            Container(
              decoration: BoxDecoration(
                color: c.fondo,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.linea),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _esIngreso = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_esIngreso
                              ? c.superficie
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: !_esIngreso
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          'Retiro',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: !_esIngreso ? c.tinta : c.tinta2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _esIngreso = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _esIngreso ? c.superficie : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: _esIngreso
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          'Ingreso',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _esIngreso ? c.tinta : c.tinta2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Monto display
            Center(
              child: Text(
                '\$${_montoText.isEmpty ? '0' : _montoText}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: c.tinta,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Input motivo
            TextField(
              controller: _motivoCtrl,
              decoration: InputDecoration(
                hintText: 'Motivo del movimiento...',
                filled: true,
                fillColor: c.fondo,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.linea),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.linea),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),

            // Teclado miniatura (simplificado)
            SizedBox(
              width: 250,
              child: TecladoNumerico(
                alPresionarTecla: _teclear,
                alBorrar: _borrar,
              ),
            ),
            const SizedBox(height: 24),

            // Guardar
            ElevatedButton(
              onPressed: puedeGuardar
                  ? () {
                      Navigator.pop(context);
                      widget.alGuardar(
                        _esIngreso,
                        _monto,
                        _motivoCtrl.text.trim(),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: c.azul,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Guardar Movimiento',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
