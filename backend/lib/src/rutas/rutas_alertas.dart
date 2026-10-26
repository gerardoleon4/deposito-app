import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../comun/json.dart';
import '../servicios/servicio_alertas.dart';

void montarRutasAlertas(Router r, ServicioAlertas alertas) {
  r.get('/api/v1/alertas', (Request p) {
    return respuestaJson(alertas.listar(dias: p.url.queryParameters['dias']));
  });
}
