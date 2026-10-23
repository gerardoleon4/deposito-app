import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../core/api/proveedores.dart';
import '../../../core/formato/formato.dart';
import '../../../core/widgets/estados.dart';
import '../../ventas/datos/modelos_ventas.dart';
import '../../ventas/pantallas/detalle_ticket.dart';

/// Las ventas que cobró una persona (`GET /ventas?usuario=`).
final _ventasDeProvider = FutureProvider.autoDispose
    .family<List<ResumenVenta>, String>(
      (ref, id) async =>
          (await ref.watch(apiProvider.future)).listarVentas(usuario: id),
      retry: (_, _) => null,
    );

class VentasEmpleado extends ConsumerWidget {
  const VentasEmpleado({super.key, required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colores;
    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        backgroundColor: c.superficie,
        title: Text('Ventas de ${usuario.nombre}'),
      ),
      body: switch (ref.watch(_ventasDeProvider(usuario.id))) {
        AsyncData(:final value) when value.isEmpty => EstadoVacio(
          icono: Icons.receipt_long_outlined,
          titulo: 'Sin ventas',
          mensaje: '${usuario.nombre} todavía no ha cobrado ventas.',
        ),
        AsyncData(:final value) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: value.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final v = value[i];
            final metodo = MetodoPago.de(v.metodo);
            return ListTile(
              leading: Icon(
                v.cancelada ? Icons.cancel_outlined : metodo.icono,
                color: v.cancelada ? rojoCancelacion : metodo.color,
              ),
              title: Text('#${v.folio}'),
              subtitle: Text(fechaHora(v.fecha)),
              trailing: Text(
                dinero(v.total),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: v.cancelada ? rojoCancelacion : c.tinta,
                  decoration: v.cancelada ? TextDecoration.lineThrough : null,
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetalleTicket(ventaId: v.id)),
              ),
            );
          },
        ),
        AsyncError(:final error) => EstadoError(
          error: error,
          alReintentar: () => ref.invalidate(_ventasDeProvider(usuario.id)),
        ),
        _ => const Cargando(),
      },
    );
  }
}
