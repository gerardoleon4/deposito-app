import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../comun/json.dart';
import '../comun/sesion.dart';
import '../servicios/servicio_pedidos.dart';

void montarRutasPedidos(Router r, ServicioPedidos pedidos) {
  r.get('/api/v1/pedidos', (Request _) {
    return respuestaJson({'pedidos': pedidos.listarPendientes()});
  });

  r.post('/api/v1/pedidos', (Request p) async {
    final sesion = sesionDe(p);
    final res = pedidos.crear(await leerObjetoJson(p), origen: sesion.nombre);
    return respuestaJson(res, estado: 201);
  });

  r.delete('/api/v1/pedidos/<id>', (Request p, String id) {
    exigirCaja(p);
    pedidos.descartar(id);
    return Response(204);
  });
}
