import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../comun/json.dart';
import '../comun/sesion.dart';
import '../servicios/servicio_productos.dart';

/// Las rutas solo leen la petición y responden; la lógica está en el servicio.
void montarRutasProductos(Router r, ServicioProductos productos) {
  r.get('/api/v1/productos', (Request p) {
    final q = p.url.queryParameters;
    final lista = productos.listar(busqueda: q['q'], categoria: q['categoria']);
    return respuestaJson({
      'productos': [for (final x in lista) x.toJson()],
    });
  });

  r.get('/api/v1/productos/<id>', (Request p, String id) {
    return respuestaJson(productos.obtener(id).toJson());
  });

  r.post('/api/v1/productos', (Request p) async {
    final sesion = exigirCaja(p);
    final producto = productos.crear(
      await leerObjetoJson(p),
      origen: sesion.nombre,
    );
    return respuestaJson(producto.toJson(), estado: 201);
  });
}
