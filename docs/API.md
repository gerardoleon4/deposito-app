# Contrato de la API

Este documento es el acuerdo entre `backend/` y `app/`. Ningún endpoint se programa sin estar primero aquí.

Los cambios a este archivo se hacen por pull request con la etiqueta `contrato`.

## Convenciones

| Tema | Regla |
| --- | --- |
| Prefijo | Las rutas empiezan con `/api/v1`, salvo `/salud` |
| Formato | JSON en UTF-8 |
| Nombres | En español, sin acentos, en `camelCase`: `precioCaja`, `piezasPorCaja` |
| Dinero | Entero en centavos: $42.50 se manda como `4250`. Un número con decimales es `datos_invalidos` |
| Instantes | ISO 8601 en UTC, sin milisegundos: `2026-10-02T18:30:00Z` |
| Fechas de calendario | `AAAA-MM-DD` en la hora local del negocio: `2027-03-15` (caducidad, día de un reporte) |
| Existencias | Siempre en piezas. Las cajas son solo visuales |
| IDs | Texto generado por el servidor, con prefijo por tipo: `p_` producto, `t_` terminal |
| Autenticación | Encabezado `X-Clave-Terminal` en toda petición, salvo las marcadas como públicas |
| Reintentos | Las operaciones de cobro llevan el encabezado `X-Clave-Idempotencia` (se detalla con ventas) |
| Errores | `{ "error": { "codigo": "stock_insuficiente", "mensaje": "..." } }` |

### Quién llama

| Rol | Cómo se identifica | Puede |
| --- | --- | --- |
| Caja | La clave de caja que el servidor embebido le da a la app al arrancar | Todo |
| Terminal | La clave que recibió al registrarse con el código del QR | Consultar, y lo que cada endpoint indique |

Un endpoint marcado **Solo caja** responde `403 solo_caja` a una terminal.

### Errores

| HTTP | `codigo` | Cuándo |
| --- | --- | --- |
| `400` | `datos_invalidos` | Falta un campo o tiene un formato o valor no permitido. Incluye `campos` (abajo) |
| `400` | `json_invalido` | El cuerpo no es JSON válido |
| `401` | `no_autorizado` | Falta `X-Clave-Terminal`, no existe o fue revocada |
| `401` | `codigo_invalido` | Código de emparejamiento incorrecto o vencido |
| `403` | `solo_caja` | Una terminal intenta algo que solo hace la caja |
| `404` | `no_encontrado` | El recurso o la ruta no existe |
| `409` | `codigo_duplicado` | Ya existe un producto activo con ese código de barras |
| `409` | `stock_insuficiente` | No hay piezas suficientes (ventas, Sprint 3) |
| `409` | `caja_cerrada` | Se intenta cobrar sin turno abierto (caja, Sprint 3) |
| `500` | `error_interno` | Error no previsto. El detalle queda en el log del servidor |

Los errores de validación dicen qué campo falló, para que la app lo muestre junto al campo:

```json
{
  "error": {
    "codigo": "datos_invalidos",
    "mensaje": "Revisa los campos marcados",
    "campos": { "precio": "Debe ser un entero mayor que 0 (centavos)" }
  }
}
```

## Endpoints

### Salud

`GET /salud` · Pública

Comprueba que el servidor responde.

- Respuesta `200`: el texto `ok`.

### Terminales

Una terminal se vincula así:

1. La caja pide un código de emparejamiento y lo muestra en un QR.
2. La terminal escanea el QR y se registra con ese código.
3. El servidor le entrega una clave propia, que la terminal guarda y manda en cada petición.

El QR contiene este JSON:

```json
{ "v": 1, "host": "192.168.1.20", "puerto": 8080, "codigo": "482913" }
```

#### Crear código de emparejamiento

`POST /api/v1/terminales/codigo` · Solo caja

Genera un código de 6 dígitos que vence en 10 minutos. Pedir uno nuevo invalida el anterior. Cinco intentos fallidos también lo invalidan, y sirve para registrar una sola terminal.

- Respuesta `201`:

```json
{ "codigo": "482913", "expira": "2026-10-02T18:40:00Z" }
```

#### Registrar terminal

`POST /api/v1/terminales/registro` · Pública

```json
{ "nombre": "Terminal S24", "codigo": "482913" }
```

- `nombre`: de 1 a 40 caracteres.
- Respuesta `201`. La `clave` se entrega **solo esta vez**; el servidor guarda únicamente su hash:

```json
{
  "terminal": {
    "id": "t_8f2a4c9d1e",
    "nombre": "Terminal S24",
    "registrada": "2026-10-02T18:31:00Z",
    "ultimaConexion": "2026-10-02T18:31:00Z",
    "conectada": false
  },
  "clave": "Zq0vX3...43 caracteres..."
}
```

- `400 datos_invalidos`, `401 codigo_invalido`.

#### Listar terminales

`GET /api/v1/terminales` · Solo caja

- Respuesta `200`: `{ "terminales": [ <terminal>, ... ] }`, sin las revocadas. `conectada` es `true` si tiene un WebSocket abierto.

#### Revocar terminal

`DELETE /api/v1/terminales/{id}` · Solo caja

La clave deja de servir de inmediato y se cierra su WebSocket.

- Respuesta `204` sin cuerpo. `404 no_encontrado`.

### Productos

#### El objeto producto

```json
{
  "id": "p_3k9x2m7q1z",
  "codigo": "7501064191015",
  "nombre": "Victoria Mega",
  "categoria": "cerveza",
  "presentacion": "Mega 1.2 L",
  "precio": 4200,
  "precioCaja": 48000,
  "piezasPorCaja": 12,
  "existenciaPiezas": 66,
  "minimo": 36,
  "envase": "mega",
  "caducidad": "2027-01-29",
  "foto": null,
  "creado": "2026-10-02T18:30:00Z",
  "actualizado": "2026-10-02T18:30:00Z"
}
```

| Campo | Tipo | Regla |
| --- | --- | --- |
| `codigo` | texto | Código de barras, de 1 a 64 letras o dígitos. Único entre productos activos |
| `nombre` | texto | De 1 a 80 caracteres |
| `categoria` | texto | De 1 a 40 caracteres, en minúsculas: `cerveza`, `refresco`, `botana`, `hielo`... |
| `presentacion` | texto o `null` | Hasta 40 caracteres |
| `precio` | entero | Centavos por pieza, mayor que 0 |
| `precioCaja` | entero o `null` | Centavos por caja, mayor que 0. Va junto con `piezasPorCaja`: los dos o ninguno |
| `piezasPorCaja` | entero o `null` | 2 o más |
| `existenciaPiezas` | entero | 0 o más. Solo lectura después de crear: cambia por entradas, ventas o ajustes |
| `minimo` | entero | 0 o más. Bajo este número se genera alerta. Por omisión `0` |
| `envase` | texto o `null` | `mega`, `media` o `cuarto` si usa envase retornable |
| `caducidad` | fecha o `null` | `AAAA-MM-DD`, la más próxima |
| `foto` | texto o `null` | Ruta de la foto (Sprint 2). Solo lectura |

#### Listar y buscar

`GET /api/v1/productos?q=victoria&categoria=cerveza`

- `q` (opcional): busca en nombre y código, sin distinguir mayúsculas ni acentos.
- `categoria` (opcional): filtro exacto.
- Respuesta `200`: `{ "productos": [ <producto>, ... ] }`, ordenados por nombre. Sin paginación: el catálogo de un depósito cabe en una respuesta.

#### Detalle

`GET /api/v1/productos/{id}`

- Respuesta `200`: el producto. `404 no_encontrado`.

#### Crear

`POST /api/v1/productos` · Solo caja

El cuerpo es el producto sin `id`, `foto`, `creado` ni `actualizado`. `existenciaPiezas` es la existencia inicial (por omisión `0`) y queda registrada como movimiento de inventario.

```json
{
  "codigo": "7501064191015",
  "nombre": "Victoria Mega",
  "categoria": "cerveza",
  "presentacion": "Mega 1.2 L",
  "precio": 4200,
  "precioCaja": 48000,
  "piezasPorCaja": 12,
  "existenciaPiezas": 66,
  "minimo": 36,
  "envase": "mega",
  "caducidad": "2027-01-29"
}
```

- Respuesta `201`: el producto creado. Emite `producto.actualizado`.
- `400 datos_invalidos`, `409 codigo_duplicado`.

## WebSocket

`GET /api/v1/ws`

Lleva la misma autenticación que el resto: el encabezado `X-Clave-Terminal`, o `?clave=` en la URL si el cliente no puede mandar encabezados.

Todos los mensajes del servidor tienen esta forma:

```json
{ "tipo": "producto.actualizado", "datos": { "producto": { } }, "fecha": "2026-10-02T18:30:00Z" }
```

| Tipo | Cuándo | `datos` |
| --- | --- | --- |
| `conexion.lista` | Al conectarse | `{ "version": "0.1.0" }` |
| `producto.actualizado` | Se crea o cambia un producto | `{ "producto": <producto> }` |

- El servidor manda ping cada 20 segundos. Si no hay respuesta, cierra la conexión.
- Al reconectarse, la app vuelve a pedir los datos completos con `GET` en lugar de confiar en los eventos que se perdió.
- El cliente no manda mensajes por ahora.

## Pendientes

Se documentarán aquí, en este orden:

- **Sprint 2:** productos por código, editar, eliminar, entradas de mercancía, foto, ajuste de existencia con motivo, movimientos de un producto; envases y préstamos.
- **Sprint 3:** pedidos, ventas (con `X-Clave-Idempotencia`), cancelaciones, caja y cortes, resto de eventos del WebSocket.
- **Sprint 4:** alertas, reportes, resurtido, ajustes, PIN del dueño, respaldo y diagnóstico.
