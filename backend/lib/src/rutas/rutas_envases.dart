import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../comun/json.dart';
import '../comun/sesion.dart';
import '../servicios/servicio_envases.dart';

void montarRutasEnvases(Router r, ServicioEnvases envases) {
  r.get('/api/v1/envases', (Request _) {
    return respuestaJson({'balance': envases.balance()});
  });

  r.get('/api/v1/envases/prestamos', (Request _) {
    return respuestaJson({'prestamos': envases.prestamos()});
  });

  r.post('/api/v1/envases/prestamos', (Request p) async {
    exigirCaja(p);
    final res = envases.registrarPrestamo(await leerObjetoJson(p));
    return respuestaJson(res, estado: 201);
  });

  r.post('/api/v1/envases/prestamos/<id>/devolver', (Request p, String id) {
    exigirCaja(p);
    envases.devolver(id);
    return Response(204);
  });
}
