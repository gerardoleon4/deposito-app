import 'package:flutter/material.dart';
import '../../../../app/tema/colores.dart';
import 'recibo_cierre.dart';

class Denominacion {
  final double valor;
  int cantidad;

  Denominacion(this.valor, {this.cantidad = 0});
  
  double get subtotal => valor * cantidad;
}

class ArqueoCaja extends StatefulWidget {
  const ArqueoCaja({super.key});

  @override
  State<ArqueoCaja> createState() => _ArqueoCajaState();
}

class _ArqueoCajaState extends State<ArqueoCaja> {
  final List<Denominacion> _denominaciones = [
    Denominacion(1000),
    Denominacion(500),
    Denominacion(200),
    Denominacion(100),
    Denominacion(50),
    Denominacion(20),
    Denominacion(10),
    Denominacion(5),
    Denominacion(2),
    Denominacion(1),
    Denominacion(0.5),
  ];

  double get _totalContado {
    return _denominaciones.fold(0, (sum, item) => sum + item.subtotal);
  }
  
  final double _esperado = 12350.50; // Hardcoded para el demo

  void _calcularDiscrepancia() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ModalDiscrepancia(
        esperado: _esperado,
        contado: _totalContado,
        alConfirmar: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ReciboCierre()),
          );
        },
      ),
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
        title: Text('Conteo Físico (Arqueo)', style: TextStyle(color: c.tinta, fontWeight: FontWeight.bold)),
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
          label: const Text('Volver', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          style: TextButton.styleFrom(foregroundColor: c.azul, padding: const EdgeInsets.symmetric(horizontal: 16)),
        ),
        leadingWidth: 100,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: _denominaciones.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, i) {
                  final den = _denominaciones[i];
                  return Row(
                    children: [
                      Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: c.azul.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '\$${den.valor == den.valor.toInt() ? den.valor.toInt() : den.valor.toStringAsFixed(1)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, color: c.azul, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('x', style: TextStyle(fontSize: 18, color: c.tinta2)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '0',
                            filled: true,
                            fillColor: c.superficie,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.linea)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.linea)),
                          ),
                          onChanged: (val) {
                            setState(() {
                              den.cantidad = int.tryParse(val) ?? 0;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 100,
                        child: Text(
                          '\$${den.subtotal.toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c.tinta),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            // Panel Fijo Inferior
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: c.superficie,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Contado', style: TextStyle(fontSize: 16, color: c.tinta2, fontWeight: FontWeight.w600)),
                        Text('\$${_totalContado.toStringAsFixed(2)}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: c.tinta)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _calcularDiscrepancia,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.azul,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Calcular Discrepancia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

// 2.6 Modal de Discrepancia
class ModalDiscrepancia extends StatefulWidget {
  const ModalDiscrepancia({super.key, required this.esperado, required this.contado, required this.alConfirmar});
  
  final double esperado;
  final double contado;
  final VoidCallback alConfirmar;

  @override
  State<ModalDiscrepancia> createState() => _ModalDiscrepanciaState();
}

class _ModalDiscrepanciaState extends State<ModalDiscrepancia> {
  final _justificacionCtrl = TextEditingController();

  double get diferencia => widget.contado - widget.esperado;
  bool get tieneDiscrepancia => diferencia != 0;

  @override
  void dispose() {
    _justificacionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final bool puedeConfirmar = !tieneDiscrepancia || _justificacionCtrl.text.trim().isNotEmpty;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: c.superficie,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (tieneDiscrepancia)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, color: c.alerta, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    diferencia < 0 ? 'Faltante detectado' : 'Sobrante detectado',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c.alerta),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, color: Colors.green[600], size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Caja Cuadrada',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[600]),
                  ),
                ],
              ),
            
            const SizedBox(height: 32),
            
            // Comparativa
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('Esperado', style: TextStyle(fontSize: 14, color: c.tinta2)),
                    const SizedBox(height: 4),
                    Text('\$${widget.esperado.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c.tinta)),
                  ],
                ),
                Container(width: 1, height: 40, color: c.linea),
                Column(
                  children: [
                    Text('Contado', style: TextStyle(fontSize: 14, color: c.tinta2)),
                    const SizedBox(height: 4),
                    Text('\$${widget.contado.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c.tinta)),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: tieneDiscrepancia ? c.alerta.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: tieneDiscrepancia ? c.alerta.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text('Diferencia', style: TextStyle(fontSize: 14, color: tieneDiscrepancia ? c.alerta : Colors.green[700])),
                  const SizedBox(height: 8),
                  Text(
                    '\$${diferencia.abs().toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: tieneDiscrepancia ? c.alerta : Colors.green[700]),
                  ),
                ],
              ),
            ),
            
            if (tieneDiscrepancia) ...[
              const SizedBox(height: 32),
              TextField(
                controller: _justificacionCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Justificación / Comentarios',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: c.fondo,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.linea)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.linea)),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
            
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: puedeConfirmar ? () {
                Navigator.pop(context);
                widget.alConfirmar();
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: c.azul,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Confirmar y Cerrar Turno', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
