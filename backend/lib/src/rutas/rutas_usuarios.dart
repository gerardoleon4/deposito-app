import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../comun/json.dart';
import '../comun/sesion.dart';
import '../servicios/servicio_usuarios.dart';

/// Toda la sección Usuarios del contrato es "Solo caja".
void montarRutasUsuarios(Router r, ServicioUsuarios usuarios) {
  r.get('/api/v1/usuarios', (Request p) {
    exigirCaja(p);
    return respuestaJson({
      'usuarios': [for (final u in usuarios.listar()) u.toJson()],
    });
  });

  r.post('/api/v1/usuarios', (Request p) async {
    exigirCaja(p);
    final u = usuarios.crear(await leerObjetoJson(p));
    return respuestaJson({'usuario': u.toJson()}, estado: 201);
  });

  r.post('/api/v1/usuarios/verificar', (Request p) async {
    exigirCaja(p);
    final u = usuarios.verificar(await leerObjetoJson(p));
    return respuestaJson({'usuario': u.toJson()});
  });

  r.put('/api/v1/usuarios/<id>', (Request p, String id) async {
    exigirCaja(p);
    final u = usuarios.editar(id, await leerObjetoJson(p));
    return respuestaJson({'usuario': u.toJson()});
  });
}
