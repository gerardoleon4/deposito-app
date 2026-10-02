import 'package:shelf/shelf.dart';
import 'package:sqlite3/sqlite3.dart';

import '../servicios/servicio_terminales.dart';
import 'bitacora.dart';
import 'errores.dart';
import 'json.dart';
import 'seguridad.dart';
import 'sesion.dart';

const cabeceraClave = 'x-clave-terminal';

/// Rutas que no piden clave (relativas, sin `/` inicial).
const _rutasPublicas = {'salud', 'api/v1/terminales/registro'};

/// Escribe en la bitácora cada petición con su estado y duración.
Middleware registrarPeticiones(Bitacora bitacora) =>
    (siguiente) => (peticion) async {
      final cronometro = Stopwatch()..start();
      final respuesta = await siguiente(peticion);
      bitacora.info(
        '${peticion.method} /${peticion.url.path} ${respuesta.statusCode} '
        '${cronometro.elapsedMilliseconds}ms',
      );
      return respuesta;
    };

/// Convierte cualquier error en una respuesta con el formato del contrato.
Middleware manejarErrores(Bitacora bitacora) =>
    (siguiente) => (peticion) async {
      try {
        return await siguiente(peticion);
      } on HijackException {
        rethrow; // El WebSocket toma la conexión; shelf lo maneja.
      } on ErrorApi catch (e) {
        return respuestaJson(e.toJson(), estado: e.estado);
      } on SqliteException catch (e, pila) {
        final error = _traducirSqlite(e);
        if (error != null) {
          return respuestaJson(error.toJson(), estado: error.estado);
        }
        bitacora.error(
          'SQLite en ${peticion.method} /${peticion.url.path}',
          e,
          pila,
        );
        return respuestaJson(ErrorApi.interno().toJson(), estado: 500);
      } catch (e, pila) {
        bitacora.error(
          'Error no previsto en ${peticion.method} /${peticion.url.path}',
          e,
          pila,
        );
        return respuestaJson(ErrorApi.interno().toJson(), estado: 500);
      }
    };

/// Respaldo por si dos peticiones pasan la validación al mismo tiempo: el
/// índice UNIQUE de la base es quien de verdad impide el duplicado.
ErrorApi? _traducirSqlite(SqliteException e) {
  const sqliteConstraintUnique = 2067;
  if (e.extendedResultCode == sqliteConstraintUnique &&
      e.message.contains('productos.codigo')) {
    return ErrorApi(
      409,
      'codigo_duplicado',
      'Ya existe un producto con ese código',
    );
  }
  return null;
}

/// Identifica a la caja o a la terminal por `X-Clave-Terminal` (o `?clave=`
/// en el WebSocket) y pone la [Sesion] en la petición. Es el único punto de
/// autenticación para HTTP y WebSocket.
Middleware autenticar({
  required String claveCaja,
  required ServicioTerminales terminales,
}) =>
    (siguiente) => (peticion) {
      if (_rutasPublicas.contains(peticion.url.path)) {
        return siguiente(peticion);
      }

      final clave =
          peticion.headers[cabeceraClave] ??
          peticion.url.queryParameters['clave'];
      if (clave == null || clave.isEmpty) throw ErrorApi.noAutorizado();

      if (igualesSeguro(clave, claveCaja)) {
        return siguiente(conSesion(peticion, const Sesion.caja()));
      }
      final terminal = terminales.autenticar(clave);
      if (terminal == null) throw ErrorApi.noAutorizado();
      return siguiente(
        conSesion(
          peticion,
          Sesion.terminal(id: terminal.id, nombre: terminal.nombre),
        ),
      );
    };
