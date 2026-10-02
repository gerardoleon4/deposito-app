# deposito_backend

Servidor de Anaquel: API REST, WebSocket y SQLite. La app lo arranca dentro de sí misma en modo Caja; en desarrollo se corre en la laptop.

El contrato de la API está en [`docs/API.md`](../docs/API.md).

## Correr en desarrollo

```bash
dart pub get
dart run bin/server.dart
```

Al arrancar imprime la **clave de caja** y un `curl` de prueba. Por omisión carga los productos del prototipo y guarda la base en `datos/anaquel.db`, que git ignora.

| Variable | Para qué |
| --- | --- |
| `PUERTO` | Puerto (8080 por omisión) |
| `BASE_DATOS` | Ruta del archivo SQLite |
| `CLAVE_CAJA` | Fija la clave de caja para no copiarla en cada arranque |
| `SIN_EJEMPLOS=1` | Arranca con la base vacía |

Para emparejar una terminal desde la laptop:

```bash
curl -X POST -H "X-Clave-Terminal: <clave de caja>" localhost:8080/api/v1/terminales/codigo
```

## Usarlo desde la app

```dart
import 'package:deposito_backend/deposito_backend.dart';

final servidor = DepositoServer(rutaBaseDatos: '${docs.path}/anaquel.db');
await servidor.iniciar();
// Las pantallas de la caja mandan servidor.claveCaja en X-Clave-Terminal.
await servidor.detener();
```

La app también importa de aquí los modelos (`Producto`, `Terminal`, `Evento`), para que los campos sean los mismos en los dos lados.

## Estructura

```
lib/src/
├── servidor.dart   DepositoServer: arranque, rutas y middleware
├── comun/          errores, validación, fechas, log, sesión, seguridad
├── db/             conexión, transacciones, migraciones y repositorios
├── modelos/        Producto, Terminal, Evento (con toJson/fromJson)
├── rutas/          un archivo por módulo; solo leen la petición y responden
├── servicios/      reglas de negocio
├── ws/             hub de WebSocket
└── seed/           datos de ejemplo del prototipo
```

**Regla de capas:** las rutas no tienen lógica, los servicios no escriben SQL y los repositorios no tienen reglas de negocio.

## Reglas que no se rompen

- **Dinero:** enteros en centavos. Un número con decimales es un error, no se redondea.
- **Fechas:** se guardan en UTC. El día del negocio se calcula solo con `diaNegocio()`.
- **Transacciones:** toda operación de dinero o existencias va dentro de `transaccion()`.
- **Existencias:** cada cambio deja un registro en `movimientos`.
- **Migraciones:** se agrega una nueva en `db/migraciones/` y se registra en `migraciones.dart`. Nunca se edita una ya publicada. Antes de aplicarlas se respalda la base en `respaldos/`.
- **Eventos:** se emiten después de confirmar la transacción, nunca dentro.

## Pruebas

```bash
dart test
```

- `test/ayudantes/servidor_prueba.dart`: `crearServidorDePrueba()` levanta un servidor real con SQLite en memoria en un puerto libre.
- `api_test.dart`: pruebas e2e del contrato.
- El resto son pruebas unitarias de servicios, fechas y migraciones.
