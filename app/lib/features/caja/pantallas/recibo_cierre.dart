import 'package:flutter/material.dart';
import '../../../../app/tema/colores.dart';
import '../../auth/pantallas/login_diario.dart';

class ReciboCierre extends StatelessWidget {
  const ReciboCierre({super.key});

  void _finalizar(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginDiario()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;

    return Scaffold(
      backgroundColor: c.fondo,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8), // Borde ligero para simular ticket
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'DEPÓSITO DE CERVEZA',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800], letterSpacing: 1),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ticket de Cierre de Turno',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 24),
                          
                          _FilaTicket(etiqueta: 'Fecha:', valor: '03-Oct-2026'),
                          _FilaTicket(etiqueta: 'Turno:', valor: '08:00 AM - 04:30 PM'),
                          _FilaTicket(etiqueta: 'Cajero:', valor: 'Sofía Vega'),
                          
                          const SizedBox(height: 16),
                          const Divider(color: Colors.black54), // No hay estilo dash nativo simple, uso solid
                          const SizedBox(height: 16),
                          
                          const Text('DESGLOSE DE VENTAS', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          _FilaTicket(etiqueta: 'Efectivo', valor: '\$12,500.50'),
                          _FilaTicket(etiqueta: 'Tarjeta', valor: '\$3,200.00'),
                          _FilaTicket(etiqueta: 'Envases / Extra', valor: '-\$150.00'),
                          
                          const SizedBox(height: 16),
                          const Divider(color: Colors.black54),
                          const SizedBox(height: 16),
                          
                          const Text('ARQUEO', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          _FilaTicket(etiqueta: 'Fondo Inicial', valor: '\$1,000.00'),
                          _FilaTicket(etiqueta: 'Ventas en Efectivo', valor: '\$12,500.50'),
                          _FilaTicket(etiqueta: 'Retiros', valor: '-\$1,150.00'),
                          const SizedBox(height: 8),
                          _FilaTicket(etiqueta: 'Total Esperado', valor: '\$12,350.50', bold: true),
                          _FilaTicket(etiqueta: 'Total Contado', valor: '\$12,300.50', bold: true),
                          
                          const SizedBox(height: 16),
                          const Divider(color: Colors.black54),
                          const SizedBox(height: 16),
                          
                          _FilaTicket(etiqueta: 'DIFERENCIA', valor: '-\$50.00', bold: true),
                          const SizedBox(height: 8),
                          const Text('Justificación:', style: TextStyle(fontSize: 12)),
                          Text(
                            'Faltó cambio al cliente de la mañana',
                            style: TextStyle(fontSize: 12, color: Colors.grey[800], fontStyle: FontStyle.italic),
                          ),
                          
                          const SizedBox(height: 48),
                          Text(
                            '------------------------',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            'Firma del Cajero',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Botones
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.print_rounded, size: 20),
                              label: const Text('Imprimir'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                foregroundColor: c.tinta,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
                              label: const Text('PDF'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                foregroundColor: c.tinta,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _finalizar(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: c.azul,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Finalizar y Salir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
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

class _FilaTicket extends StatelessWidget {
  const _FilaTicket({required this.etiqueta, required this.valor, this.bold = false});
  final String etiqueta;
  final String valor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            etiqueta,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
