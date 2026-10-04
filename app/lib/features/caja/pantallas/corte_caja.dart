import 'package:flutter/material.dart';
import '../../../../app/tema/colores.dart';
import 'arqueo_caja.dart';

class CorteCaja extends StatelessWidget {
  const CorteCaja({super.key});

  void _irAArqueo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ArqueoCaja()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;

    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
          label: const Text('Volver', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          style: TextButton.styleFrom(
            foregroundColor: c.azul,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
        leadingWidth: 100,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Corte de Caja',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: c.tinta),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Turno: 08:00 AM - 04:30 PM',
                    style: TextStyle(fontSize: 16, color: c.tinta2),
                  ),
                  const SizedBox(height: 48),
                  
                  // Contenedor tipo recibo
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: c.superficie,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: c.linea),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _FilaMonto(titulo: 'Ventas Efectivo', monto: 12500.50, c: c),
                        const SizedBox(height: 16),
                        _FilaMonto(titulo: 'Ventas Tarjeta', monto: 3200.00, c: c),
                        const SizedBox(height: 16),
                        _FilaMonto(titulo: 'Envases / Extra', monto: -150.00, c: c),
                        const SizedBox(height: 32),
                        const Divider(),
                        const SizedBox(height: 32),
                        
                        Text(
                          'Efectivo Esperado en Caja',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: c.tinta2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$12,350.50',
                          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: c.azul, letterSpacing: -1),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _irAArqueo(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.azul,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('Proceder a Conteo Físico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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

class _FilaMonto extends StatelessWidget {
  const _FilaMonto({required this.titulo, required this.monto, required this.c});
  final String titulo;
  final double monto;
  final ColoresAnaquel c;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titulo, style: TextStyle(fontSize: 16, color: c.tinta)),
        Text(
          '\$${monto.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: c.tinta),
        ),
      ],
    );
  }
}
