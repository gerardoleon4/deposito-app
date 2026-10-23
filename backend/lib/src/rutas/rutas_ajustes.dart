import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../comun/json.dart';
import '../comun/sesion.dart';
import '../servicios/servicio_ajustes.dart';

void montarRutasAjustes(Router r, ServicioAjustes ajustes) {
  r.get(
    '/api/v1/ajustes',
    (Request _) => respuestaJson(ajustes.leer().toJson()),
  );

  r.put('/api/v1/ajustes', (Request p) async {
    exigirCaja(p);
    return respuestaJson(ajustes.guardar(await leerObjetoJson(p)).toJson());
  });

  r.get('/api/v1/respaldo', (Request p) {
    exigirCaja(p);
    final copia = ajustes.respaldo();
    return Response.ok(
      copia.bytes,
      headers: {
        'content-type': 'application/vnd.sqlite3',
        'content-disposition': 'attachment; filename="${copia.nombre}"',
      },
    );
  });
}
