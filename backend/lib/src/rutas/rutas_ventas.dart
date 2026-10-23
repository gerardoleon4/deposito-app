import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../comun/json.dart';
import '../comun/middleware.dart';
import '../comun/sesion.dart';
import '../servicios/servicio_ventas.dart';

void montarRutasVentas(Router r, ServicioVentas ventas) {
  r.get('/api/v1/ventas', (Request p) {
    return respuestaJson({'ventas': ventas.listar(p.url.queryParameters)});
  });

  r.get('/api/v1/ventas/<id>', (Request _, String id) {
    return respuestaJson(ventas.detalle(id));
  });

  r.post('/api/v1/ventas', (Request p) async {
    final sesion = exigirCaja(p);
    final venta = ventas.registrar(
      await leerObjetoJson(p),
      origen: sesion.nombre,
      claveIdempotencia: p.headers[cabeceraIdempotencia],
    );
    return respuestaJson(venta, estado: 201);
  });

  r.post('/api/v1/ventas/<id>/cancelar', (Request p, String id) async {
    final sesion = exigirCaja(p);
    ventas.cancelar(id, await leerObjetoJsonOpcional(p), origen: sesion.nombre);
    return Response(204);
  });

  r.post('/api/v1/ventas/<id>/devolver', (Request p, String id) async {
    final sesion = exigirCaja(p);
    final res = ventas.devolverParte(
      id,
      await leerObjetoJson(p),
      origen: sesion.nombre,
    );
    return respuestaJson(res, estado: 201);
  });
}
