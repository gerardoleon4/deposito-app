import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../comun/json.dart';
import '../comun/sesion.dart';
import '../servicios/servicio_terminales.dart';

void montarRutasTerminales(Router r, ServicioTerminales terminales) {
  r.post('/api/v1/terminales/codigo', (Request p) {
    exigirCaja(p);
    return respuestaJson(terminales.crearCodigo().toJson(), estado: 201);
  });

  r.post('/api/v1/terminales/registro', (Request p) async {
    final registro = terminales.registrar(await leerObjetoJson(p));
    return respuestaJson({
      'terminal': registro.terminal.toJson(),
      'clave': registro.clave,
    }, estado: 201);
  });

  r.get('/api/v1/terminales', (Request p) {
    exigirCaja(p);
    return respuestaJson({
      'terminales': [for (final t in terminales.listar()) t.toJson()],
    });
  });

  r.delete('/api/v1/terminales/<id>', (Request p, String id) async {
    exigirCaja(p);
    await terminales.revocar(id);
    return Response(204);
  });
}
