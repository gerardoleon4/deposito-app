import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../comun/json.dart';
import '../comun/sesion.dart';
import '../servicios/servicio_resurtido.dart';

void montarRutasReportes(Router r, ServicioResurtido resurtido) {
  r.get('/api/v1/reportes/resurtido', (Request p) {
    exigirCaja(p);
    final reporte = resurtido.calcular(
      dias: p.url.queryParameters['dias'],
      cobertura: p.url.queryParameters['cobertura'],
    );
    return respuestaJson(reporte.toJson());
  });
}
