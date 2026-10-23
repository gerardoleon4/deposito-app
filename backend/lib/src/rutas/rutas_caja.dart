import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../comun/json.dart';
import '../comun/middleware.dart';
import '../comun/sesion.dart';
import '../servicios/servicio_caja.dart';

/// Toda la sección Caja del contrato es "Solo caja".
void montarRutasCaja(Router r, ServicioCaja caja) {
  r.get('/api/v1/caja/turno', (Request p) {
    exigirCaja(p);
    return respuestaJson(caja.actual().toJson());
  });

  r.post('/api/v1/caja/abrir', (Request p) async {
    exigirCaja(p);
    final turno = caja.abrir(await leerObjetoJson(p));
    return respuestaJson({'turno': turno.toJson()}, estado: 201);
  });

  r.post('/api/v1/caja/movimientos', (Request p) async {
    final sesion = exigirCaja(p);
    final res = caja.registrarMovimiento(
      await leerObjetoJson(p),
      origen: sesion.nombre,
      claveIdempotencia: p.headers[cabeceraIdempotencia],
    );
    return respuestaJson(res, estado: 201);
  });

  r.post('/api/v1/caja/cerrar', (Request p) async {
    exigirCaja(p);
    final res = caja.cerrar(
      await leerObjetoJson(p),
      claveIdempotencia: p.headers[cabeceraIdempotencia],
    );
    return respuestaJson(res);
  });

  r.get('/api/v1/caja/cortes', (Request p) {
    exigirCaja(p);
    final cortes = caja.cortes(p.url.queryParameters);
    return respuestaJson({
      'cortes': [for (final t in cortes) t.toJson()],
    });
  });

  r.get('/api/v1/caja/cortes/<id>', (Request p, String id) {
    exigirCaja(p);
    return respuestaJson(caja.detalle(id).toJson());
  });
}
