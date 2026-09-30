# Plan de trabajo: POS e inventario del depósito

Documento para el equipo de desarrollo: **Gerardo y Ever** en backend, **Pablo, Daniel y Luis** en frontend. Explica cómo funciona el sistema, quién hace qué, cómo nos coordinamos y qué se entrega en cada sprint.

> Guarden este archivo en el repo de backend como `docs/PLAN_DE_TRABAJO.md` para que todos lo tengan a la mano.

---

## 1. Cómo funciona el sistema

### 1.1 La idea general

El sistema no usa internet ni un servidor en la nube. Todo vive en la red Wi-Fi del depósito:

```
                 Wi-Fi del depósito (red local)
   ┌──────────────────────────────────────────────────────┐
   │                                                      │
   │   iPad (modo CAJA)                                   │
   │   ┌────────────────────────────────┐                 │
   │   │ App Flutter (pantallas de caja)│                 │
   │   │        │ http://localhost:8080 │                 │
   │   │        ▼                       │                 │
   │   │ deposito_backend (embebido)    │◄──── HTTP ──────┼── S24 (modo TERMINAL)
   │   │  • API REST                    │◄── WebSocket ───┼── iPhone (modo TERMINAL)
   │   │  • WebSocket (tiempo real)     │                 │
   │   │  • SQLite (la base de datos)   │                 │
   │   └────────────────────────────────┘                 │
   └──────────────────────────────────────────────────────┘
```

- **El iPad es la caja y también el servidor.** La app Flutter, en modo Caja, arranca el backend dentro de sí misma. El backend guarda todo en una base de datos SQLite en el iPad.
- **El S24 y el iPhone son terminales.** Tienen la misma app, en modo Terminal. Se conectan a la IP del iPad para escanear, consultar existencias y mandar pedidos.
- **La caja también usa la API.** Aunque el servidor esté en el mismo iPad, sus pantallas le hablan por `http://localhost:8080`. Así hay un solo camino para los datos y el front se programa igual para caja y terminal.
- **Tiempo real con WebSocket.** Cuando cambia algo (una venta descuenta stock, llega un pedido), el servidor avisa a todos los dispositivos conectados y estos actualizan su pantalla.

### 1.2 Restricciones que hay que respetar

| Restricción | Qué significa para nosotros |
| --- | --- |
| iOS no permite servidores en segundo plano | El iPad debe tener la app abierta y en primer plano. Usar "Acceso guiado" y desactivar el bloqueo automático. |
| Para compilar en iPad/iPhone se necesita macOS | Una persona con Mac (o Codemagic) se encarga de las builds de iOS. El día a día se prueba en Android. |
| Permisos de red local en iOS | Hay que declarar `NSLocalNetworkUsageDescription` en `Info.plist` desde el Sprint 1. |
| Toda la información vive en un solo iPad | El backend debe ofrecer respaldo y restauración de la base de datos (Sprint 4). |
| La red puede fallar | Las terminales deben reconectarse solas y mostrar si están desconectadas. |

---

## 2. Repositorios

| Repo | Contenido | Quién trabaja |
| --- | --- | --- |
| `deposito-backend` | Paquete Dart puro: API, WebSocket, base de datos, reglas de negocio y **modelos compartidos**. Incluye `docs/API.md` (el contrato). | Gerardo y Ever |
| `deposito-app` | App Flutter: pantallas de caja y terminal, escáner, PDFs, arranque del servidor embebido. Incluye `docs/prototipo/` con el prototipo HTML. | Pablo, Daniel y Luis |

**Cómo se conectan:** la app declara el backend como dependencia en `pubspec.yaml`, fijada a una versión (tag):

```yaml
dependencies:
  deposito_backend:
    git:
      url: https://github.com/gerardoleon4/deposito-backend.git
      ref: v0.1.0
```

Gracias a esto:
- La app en modo Caja puede ejecutar `DepositoServer(...).start()`.
- El front importa los **mismos modelos** que usa el backend (`Producto`, `Venta`, etc.), así que nunca se desincronizan los campos.

**Versión de herramientas para todos:** Flutter 3.47.5 y Dart 3.13.4. Si alguien actualiza, se acuerda en equipo y se cambia aquí.

---

## 3. Equipo y responsabilidades

| Rol | Persona | Responsable de |
| --- | --- | --- |
| **Back 1** | **Gerardo** | Núcleo del servidor: arranque, base de datos y migraciones, productos e inventario, WebSocket, pedidos de terminales, alertas, ajustes y respaldos. Mantiene `API.md` y crea los tags. |
| **Back 2** | **Ever** | Negocio de ventas: modelos compartidos, ventas y cancelaciones, caja y cortes, envases y préstamos, reportes y algoritmo de resurtido. |
| **Front 1** | **Pablo** | Base de la app: arquitectura, navegación, tema, cliente de API, conexión (IP y QR), arranque del servidor embebido, WebSocket en la app. Pantallas de Catálogo y Ajustes. |
| **Front 2** | **Daniel** | Flujo de venta en la caja: pantalla Vender, cobro, tickets PDF y compartir, historial de ventas, corte de caja, tablero de Inicio. |
| **Front 3** | **Luis** | Todo lo de la terminal (escáner, productos, pedido) y en la caja: Envases, Alertas y Resurtido. |

**Reglas de responsabilidad:**
- Cada módulo tiene un dueño, pero cualquiera puede ayudar. Si tomas algo de otro, avísale primero.
- **Gerardo y Pablo son los "integradores"**: si algo no conecta entre front y back, ellos lo resuelven juntos primero.
- **Parejas de revisión:** Gerardo ↔ Ever revisan los PRs de backend; Pablo, Daniel y Luis se revisan entre ellos en rotación.
- Si el equipo tiene Scrum Master o QA, el Scrum Master maneja Trello y las ceremonias, y QA prueba en dispositivos reales y revisa los PRs antes de pasar tareas a "Hecho".

---

## 4. El contrato entre back y front (API)

El contrato es el documento `docs/API.md` del repo de backend. **Ningún endpoint se programa sin estar primero en el contrato.** Así el front puede avanzar con datos falsos mientras el back lo construye.

### 4.1 Convenciones

| Tema | Regla |
| --- | --- |
| Prefijo | Todas las rutas empiezan con `/api/v1`. |
| Formato | JSON, UTF-8. |
| Nombres | En español y sin acentos, en `camelCase`: `precioCaja`, `piezasPorCaja`. |
| Dinero | **Entero en centavos**: `$42.50` se manda como `4250`. Evita errores de redondeo. El front lo formatea al mostrar. |
| Fechas | Texto ISO 8601 en UTC: `"2026-10-02T18:30:00Z"`. |
| Existencias | Siempre en **piezas**. La conversión a cajas es solo visual. |
| IDs | Los genera el servidor. El folio de venta es un número consecutivo. |
| Errores | Código HTTP adecuado y cuerpo con este formato: |

```json
{ "error": { "codigo": "stock_insuficiente", "mensaje": "Solo hay 8 piezas de Corona Mega" } }
```

Códigos HTTP que usaremos: `200` OK, `201` creado, `400` datos inválidos, `401` terminal no autorizada, `404` no existe, `409` conflicto (stock insuficiente, caja cerrada, código de barras repetido), `500` error del servidor.

**Seguridad mínima:** el QR que muestra la caja incluye la IP y una clave. La terminal la manda en cada petición con el encabezado `X-Clave-Terminal`. Así un celular cualquiera en la misma Wi-Fi no puede modificar datos.

### 4.2 Endpoints

| Módulo | Método y ruta | Para qué | Dueño back | Sprint |
| --- | --- | --- | --- | --- |
| Salud | `GET /salud` | Comprobar que el servidor responde | Gerardo | 1 |
| Terminales | `POST /terminales/registro` | Registrar una terminal con su nombre y la clave del QR | Ever | 1 |
| Productos | `GET /productos?cat=&q=` | Listar y buscar | Gerardo | 1 |
| | `GET /productos/{id}` | Detalle | Gerardo | 1 |
| | `POST /productos` | Crear | Gerardo | 1 |
| | `GET /productos/codigo/{codigo}` | Buscar por código de barras (escáner) | Gerardo | 2 |
| | `PUT /productos/{id}` | Editar (incluye ajuste de existencia) | Gerardo | 2 |
| | `DELETE /productos/{id}` | Eliminar | Gerardo | 2 |
| | `POST /productos/{id}/entradas` | Recibir mercancía (cajas, piezas, caducidad) | Gerardo | 2 |
| | `PUT /productos/{id}/foto` | Subir foto del producto | Gerardo | 2 |
| Envases | `GET /envases` | Existencias por formato (mega, media, cuarto) | Ever | 2 |
| | `GET /prestamos` | Préstamos activos | Ever | 2 |
| | `POST /prestamos` | Registrar préstamo | Ever | 2 |
| | `POST /prestamos/{id}/devolucion` | Devolución total o parcial | Ever | 2 |
| | `POST /envases/venta-vacios` | Vender envases vacíos | Ever | 2 |
| | `POST /envases/entrada` | Recibir vacíos sin venta | Ever | 2 |
| Pedidos | `GET /pedidos` | Pedidos pendientes enviados por terminales | Gerardo | 3 |
| | `POST /pedidos` | La terminal manda un pedido a la caja | Gerardo | 3 |
| | `DELETE /pedidos/{id}` | Descartar o marcar como cobrado | Gerardo | 3 |
| Ventas | `POST /ventas` | Registrar venta (descuenta stock en una transacción) | Gerardo | 3 |
| | `GET /ventas?desde=&hasta=&turno=actual` | Historial | Ever | 3 |
| | `GET /ventas/{id}` | Detalle para ticket | Ever | 3 |
| | `POST /ventas/{id}/cancelar` | Cancelar y regresar stock y envases | Gerardo | 3 |
| Caja | `GET /caja/turno` | Estado del turno actual y resumen | Ever | 3 |
| | `POST /caja/abrir` | Abrir con fondo inicial | Ever | 3 |
| | `POST /caja/cerrar` | Cerrar con efectivo contado; genera el corte | Ever | 3 |
| | `GET /caja/cortes` y `GET /caja/cortes/{id}` | Historial de cortes | Ever | 3 |
| Alertas | `GET /alertas` | Poco stock y caducidades próximas | Gerardo | 4 |
| Reportes | `GET /reportes/dia` | Totales del día para el tablero | Ever | 4 |
| | `GET /reportes/ventas-por-hora?fecha=` | Gráfica por hora | Ever | 4 |
| | `GET /reportes/semana` | Gráfica de 7 días | Ever | 4 |
| | `GET /reportes/resurtido?dias=7` | Sugerencias de compra | Ever | 4 |
| Ajustes | `GET /ajustes` y `PUT /ajustes` | Nombre del negocio, depósitos, días de alerta | Gerardo | 4 |
| Respaldo | `GET /respaldo` y `POST /respaldo` | Exportar e importar la base de datos (solo caja) | Gerardo | 4 |
| Tiempo real | `GET /ws` (WebSocket) | Eventos en vivo | Gerardo | 1 a 3 |

### 4.3 Eventos del WebSocket

El servidor manda mensajes JSON con esta forma: `{ "tipo": "...", "datos": { ... } }`.

| Tipo | Cuándo se manda | Qué hace el front |
| --- | --- | --- |
| `producto.actualizado` | Se crea, edita o recibe mercancía de un producto | Refresca ese producto en listas y tarjetas |
| `producto.eliminado` | Se borra un producto | Lo quita de listas y carritos |
| `stock.actualizado` | Una venta o cancelación cambia existencias | Actualiza el número de existencias |
| `pedido.nuevo` | Una terminal manda pedido | La caja muestra el aviso "Pedido de Terminal S24" |
| `pedido.eliminado` | La caja cobra o descarta un pedido | Lo quita de la lista |
| `venta.registrada` | Se cobra una venta | Actualiza tablero e historial |
| `caja.abierta` y `caja.cerrada` | Cambia el turno | Habilita o bloquea el cobro |
| `alerta.nueva` | Un producto baja de su mínimo | Muestra notificación |

**Regla para el front:** al reconectarse, la app vuelve a pedir los datos completos (`GET`) en lugar de confiar en los eventos que se perdió mientras estaba desconectada.

### 4.4 Ejemplo: registrar una venta

Petición `POST /api/v1/ventas`:

```json
{
  "lineas": [
    { "productoId": "p1", "unidad": "caja", "cantidad": 1 },
    { "productoId": "p10", "unidad": "pieza", "cantidad": 2 }
  ],
  "envases": { "modo": "cobrar", "cliente": null },
  "pago": { "metodo": "efectivo", "recibido": 100000 },
  "origen": "Caja"
}
```

Respuesta `201`:

```json
{
  "id": "v_8f2a",
  "folio": 1046,
  "fecha": "2026-10-02T18:30:00Z",
  "total": 60000,
  "cambio": 40000,
  "lineas": [ { "productoId": "p1", "nombre": "Victoria Mega", "unidad": "caja", "cantidad": 1, "precioUnitario": 48000, "piezas": 12 } ],
  "envases": { "modo": "cobrar", "cantidad": 12, "monto": 9600 }
}
```

Si no hay existencias suficientes: `409` con `"codigo": "stock_insuficiente"` y **no se descuenta nada** (la venta completa se hace en una sola transacción).

---

## 5. Base de datos (SQLite en el iPad)

| Tabla | Campos principales |
| --- | --- |
| `productos` | id, codigo (único), nombre, categoria, presentacion, precio, precio_caja, piezas_por_caja, stock_piezas, minimo, envase, caducidad, foto, creado, actualizado |
| `entradas` | id, producto_id, piezas, caducidad, fecha |
| `ventas` | id, folio (único), fecha, total, metodo, tipo_tarjeta, recibido, cambio, envases_modo, envases_cantidad, envases_monto, cliente_prestamo, origen, cancelada, corte_id |
| `venta_lineas` | id, venta_id, producto_id, nombre, unidad, cantidad, precio_unitario, piezas |
| `envases` | formato (mega, media, cuarto), bodega, prestados, precio_deposito |
| `prestamos` | id, cliente, formato, cantidad, fecha, devueltos |
| `pedidos` | id, origen, nota, fecha, lineas_json |
| `turnos` | id, apertura, cierre, fondo, efectivo_contado, diferencia |
| `ajustes` | clave, valor |
| `terminales` | id, nombre, clave, ultima_conexion |

Reglas:
- **Las migraciones son numeradas** (`001_inicial.sql`, `002_fotos.sql`...) y se aplican solas al arrancar. Nunca se modifica una migración ya publicada; se agrega una nueva.
- Las ventas guardan el nombre y precio del producto al momento de vender, para que el historial no cambie si después se edita el producto.
- Las fotos se guardan como archivos en la carpeta de documentos del iPad, y en la tabla solo la ruta.

---

## 6. Estructura de cada repo

### 6.1 Backend

```
deposito_backend/
├── bin/server.dart              ← correr el servidor en la laptop para desarrollo
├── lib/
│   ├── deposito_backend.dart    ← exporta DepositoServer y los modelos
│   └── src/
│       ├── servidor.dart        ← arranque, rutas, middleware (clave, logs, errores)
│       ├── db/                  ← conexión, migraciones, repositorios por tabla
│       ├── modelos/             ← Producto, Venta, Linea, Prestamo, Turno... (con toJson/fromJson)
│       ├── rutas/               ← un archivo por módulo: productos.dart, ventas.dart...
│       ├── servicios/           ← reglas de negocio: ventas, caja, envases, resurtido
│       └── ws/                  ← hub de WebSocket y eventos
├── test/                        ← pruebas de servicios y de rutas
└── docs/API.md                  ← el contrato
```

**Regla de capas:** las rutas solo reciben y responden; la lógica va en `servicios/`; el acceso a SQLite va en `db/`. Así la lógica se puede probar sin levantar el servidor.

### 6.2 App

```
deposito_app/
├── lib/
│   ├── main.dart
│   ├── app/                     ← router, tema, arranque según modo (Caja o Terminal)
│   ├── core/
│   │   ├── api/                 ← ApiCliente (real) y ApiFalsa (datos de prueba)
│   │   ├── tiempo_real/         ← conexión WebSocket y reconexión
│   │   ├── servidor/            ← arranque del backend embebido (solo Caja)
│   │   └── widgets/             ← componentes compartidos: tarjeta de producto, teclado, etc.
│   └── features/
│       ├── inicio/  vender/  ventas/  catalogo/  envases/
│       ├── corte/  alertas/  resurtido/  ajustes/
│       └── terminal/            ← escanear, productos, pedido
├── test/
└── docs/prototipo/              ← prototipo HTML de referencia
```

Cada `feature` tiene tres partes: `datos` (llamadas a la API), `estado` (providers de Riverpod) y `pantallas` (widgets).

**Dueños de carpetas en la app:**
- Pablo: `app/`, `core/` completo, `features/catalogo`, `features/ajustes`.
- Daniel: `features/vender`, `features/ventas`, `features/corte`, `features/inicio`.
- Luis: `features/terminal`, `features/envases`, `features/alertas`, `features/resurtido`.

Si alguien necesita un widget nuevo en `core/widgets/`, lo propone a Pablo en el PR para evitar componentes duplicados.

---

## 7. Cómo trabajamos en paralelo

### 7.1 Primero el contrato, luego el código

1. Antes de empezar un módulo, Gerardo o Ever escriben en `API.md` los endpoints con ejemplos de petición y respuesta.
2. Lo suben en un PR con la etiqueta **`contrato`**. Ese PR necesita la aprobación de **la persona de front que usará esos endpoints**.
3. Ya aprobado, back programa el endpoint y front programa la pantalla **al mismo tiempo**.

### 7.2 El front no espera al back

El front programa contra una interfaz, no contra el servidor. Mientras el endpoint no existe, usa una versión falsa que regresa los ejemplos del contrato:

```dart
abstract class ApiProductos {
  Future<List<Producto>> listar({String? q});
  Future<Producto?> porCodigo(String codigo);
}

class ApiProductosFalsa implements ApiProductos {
  @override
  Future<List<Producto>> listar({String? q}) async => productosDePrueba;
  @override
  Future<Producto?> porCodigo(String c) async =>
      productosDePrueba.where((p) => p.codigo == c).firstOrNull;
}
```

Cuando el back termina, solo se cambia qué implementación usa el provider. Ninguna pantalla se toca.

### 7.3 Servidor de desarrollo compartido

- Mientras el iPad no esté listo, **Gerardo corre el servidor en su laptop** (`dart run bin/server.dart`) y comparte su IP en el grupo.
- Cada quien también puede correrlo en su propia computadora: el backend es Dart puro y funciona en Linux, Windows y Mac.
- Pablo, Daniel y Luis usan `pubspec_overrides.yaml` apuntando a su copia local del backend para probar cambios antes del tag.

### 7.4 Día de integración

**Cada miércoles** se hace la integración:
1. Gerardo crea un tag con lo que está estable en `develop` (por ejemplo `v0.2.1`).
2. Pablo actualiza el `ref` en `pubspec.yaml` de la app.
3. Se instala en el iPad, el S24 y el iPhone y se prueba el flujo completo.
4. Lo que falle se anota en Trello como tarea para esa misma semana.

---

## 8. Flujo de Git

### 8.1 Ramas

| Rama | Uso |
| --- | --- |
| `main` | Solo versiones estables que se entregan. Se actualiza al cerrar cada sprint. |
| `develop` | Lo que ya se integró. Rama por defecto. |
| `feature/rf01-crud-productos` | Una rama por tarea, desde `develop`. |
| `fix/cambio-negativo` | Corrección de un error. |

Nombre de rama: tipo, número de requerimiento si aplica y descripción corta en minúsculas con guiones.

### 8.2 Commits

Mensajes cortos, en español y en presente, con un prefijo:

- `feat: registrar venta con descuento de stock`
- `fix: el cambio salía negativo con billetes de 1000`
- `docs: agregar endpoints de envases al contrato`
- `test: pruebas del algoritmo de resurtido`
- `refactor: separar repositorio de productos`

### 8.3 Pull requests

- Todo entra a `develop` por PR. Nadie hace push directo a `develop` ni a `main`.
- **Revisores:** en backend, Gerardo y Ever se revisan entre sí. En frontend, rotación: Pablo revisa a Daniel, Daniel a Luis, Luis a Pablo. Los PRs con etiqueta `contrato` también los aprueba alguien del otro equipo.
- El PR debe explicar qué cambia, cómo probarlo y, si es de front, llevar captura de pantalla.
- El CI (GitHub Actions) debe pasar: `analyze`, `format` y pruebas.
- PRs pequeños: idealmente menos de 400 líneas. Es mejor abrir tres PRs chicos que uno enorme.
- Si tu PR lleva más de un día sin revisión, avisa en el grupo.

### 8.4 Versiones del backend

| Tag | Cuándo |
| --- | --- |
| `v0.1.0`, `v0.2.0`... | Al cerrar cada sprint |
| `v0.2.1`, `v0.2.2`... | En cada día de integración o corrección urgente |
| `v1.0.0` | Entrega final |

Cada tag lleva una nota en `CHANGELOG.md` con lo que se agregó y lo que cambió en el contrato.

---

## 9. Plan por sprint

### Sprint 1: Cimientos (25 sep – 9 oct)

**Meta:** el iPad corre el servidor dentro de la app y el S24 se conecta y lista productos.

| Persona | Tareas |
| --- | --- |
| Gerardo | Estructura del repo por capas. Conexión a SQLite y sistema de migraciones. Tabla `productos`. `GET /salud`, `GET` y `POST /productos`. WebSocket básico (`/ws` con un evento de prueba). Primera versión de `API.md`. Tag `v0.1.0`. |
| Ever | Modelos compartidos con `toJson`/`fromJson` y sus pruebas. Formato de errores y middleware (logs, clave de terminal). `POST /terminales/registro`. CI de GitHub Actions del backend. |
| Pablo | Estructura del repo, tema claro y oscuro, navegación. Pantalla de elegir modo. Conexión por IP y QR. `ApiCliente` y `ApiFalsa`. **Arranque del servidor embebido en modo Caja** (junto con Gerardo). Permisos de red local en iOS. CI de la app. |
| Daniel | Componentes compartidos: tarjeta de producto, botones, teclado numérico, tarjeta de total. Pantalla Vender con datos falsos (sin cobro). |
| Luis | Estructura de la terminal (pestañas). `mobile_scanner` funcionando en el S24 y el iPhone. Pantalla de producto escaneado con datos falsos. |

**Prueba de aceptación:** con el iPad en modo Caja y el S24 en modo Terminal en la misma Wi-Fi, el S24 escanea el QR, se conecta y ve la lista de productos creados desde el iPad.

### Sprint 2: Catálogo, escaneo y envases (10 – 23 oct) · RF-01, RF-02, RF-03

| Persona | Tareas |
| --- | --- |
| Gerardo | CRUD completo de productos. Búsqueda por código. Entradas de mercancía con caducidad. Subida de fotos. Eventos `producto.*`. |
| Ever | Módulo de envases: existencias, préstamos, devoluciones parciales, venta de vacíos, entradas. Reglas de envases que usará la venta (cobrar, trae vacíos, préstamo). Pruebas. |
| Pablo | Pantalla Catálogo: lista con búsqueda y filtros, formulario de producto con foto, recibir mercancía, detalle de producto. |
| Daniel | Vender conectado a la API real: carrito, pieza o caja, validación de existencias, bloque de envases en el ticket. |
| Luis | Terminal conectada: escanear y mostrar el producto real, pestaña Productos con fotos, armar pedido local. En la caja: pantalla Envases. |

Tag `v0.2.0`.

### Sprint 3: Ventas, cobro, caja y tiempo real (24 oct – 6 nov) · RF-04, RF-05, RF-06

| Persona | Tareas |
| --- | --- |
| Gerardo | Hub de WebSocket con todos los eventos. Pedidos de terminales. `POST /ventas` con transacción y validación de stock. Cancelación de ventas. |
| Ever | Caja: abrir, cerrar, corte y resumen del turno. Historial de ventas con filtros. Pruebas de ventas y cortes (cambio, cancelaciones, envases). |
| Pablo | Servicio de tiempo real en la app: conexión, reconexión automática, indicador "en línea / sin conexión", recarga al reconectar. |
| Daniel | Cobro en efectivo y tarjeta. Ticket en PDF con el paquete `pdf` y compartir por WhatsApp o correo. Historial de ventas. Pantalla de corte de caja. |
| Luis | Enviar pedido desde la terminal. Aviso de pedidos en la caja y "Pasar al ticket". Existencias en vivo en la terminal. |

**Prueba de rendimiento:** con los 3 dispositivos conectados, una venta en la caja debe verse reflejada en las terminales en menos de 500 ms.

Tag `v0.3.0`.

### Sprint 4: Alertas, resurtido y tablero (7 – 20 nov) · RF-07, RF-08

| Persona | Tareas |
| --- | --- |
| Gerardo | Alertas de stock mínimo y caducidad, evento `alerta.nueva`. Ajustes. Respaldo y restauración de la base de datos. |
| Ever | Reportes: día, ventas por hora, semana, más vendidos. Algoritmo de resurtido con pruebas. |
| Pablo | Pantalla Ajustes, respaldo e importación, modo oscuro, revisión general de diseño y accesibilidad. |
| Daniel | Tablero de Inicio con gráficas (`fl_chart`). |
| Luis | Pantallas de Alertas y Resurtido, con pedido al proveedor en PDF y WhatsApp. |

QA integral en el depósito con productos reales. Tag `v0.4.0`.

### Sprint 5: Cierre (21 – 27 nov)

| Persona | Tareas |
| --- | --- |
| Gerardo y Ever | Corrección de errores. Script para cargar el inventario inicial desde un CSV. Revisión de rendimiento con datos reales. |
| Pablo, Daniel y Luis | Corrección de errores y detalles visuales. Builds finales para iPad, iPhone y S24. |
| Todos | Manual de usuario, capacitación al dueño del depósito, instalación final. Tag `v1.0.0` y merge a `main`. |

### Resumen de parejas back ↔ front por sprint

Quién debe hablar con quién para que cada pantalla conecte con su endpoint:

| Sprint | Gerardo trabaja con | Ever trabaja con |
| --- | --- | --- |
| 1 | Pablo (servidor embebido, conexión) y Luis (listar productos en la terminal) | Pablo (registro de terminales, errores) |
| 2 | Pablo (catálogo) y Luis (búsqueda por código) | Luis (envases) y Daniel (envases en la venta) |
| 3 | Daniel (registrar venta), Luis (pedidos) y Pablo (WebSocket) | Daniel (caja, corte, historial) |
| 4 | Pablo (ajustes, respaldo) y Luis (alertas) | Daniel (tablero) y Luis (resurtido) |

---

## 10. Cuándo una tarea está "Hecha"

Una tarjeta pasa a **Hecho** solo si cumple todo esto:

- [ ] El código está en `develop` mediante un PR aprobado.
- [ ] El CI pasó (análisis, formato y pruebas).
- [ ] Si toca la API, `API.md` está actualizado.
- [ ] Back: tiene pruebas de la lógica en `servicios/`.
- [ ] Front: se probó en un dispositivo real (mínimo el S24) y maneja los estados de carga, error y lista vacía.
- [ ] Alguien distinto a quien lo programó lo probó.

---

## 11. Ceremonias y comunicación

| Qué | Cuándo | Duración | Para qué |
| --- | --- | --- | --- |
| Planning | Primer día del sprint | 1 hora | Elegir tarjetas y repartirlas |
| Daily | Todos los días | 15 min | Qué hice, qué haré, qué me bloquea. Si no coinciden horarios, por escrito en el grupo antes de las 10 a.m. |
| Integración | Miércoles | 1 a 2 horas | Tag del backend, actualizar la app, probar en los 3 dispositivos |
| Review | Último día del sprint | 45 min | Demo en dispositivos reales, de preferencia con el dueño del depósito |
| Retrospectiva | Después de la review | 30 min | Qué funcionó y qué cambiar |

**Canales:**
- **Trello:** todas las tareas. Columnas: Backlog, Sprint, En progreso, En revisión, QA, Hecho. Cada tarjeta lleva el nombre de su dueño.
- **GitHub:** código, PRs y discusión técnica en los comentarios del PR.
- **Grupo de WhatsApp:** avisos rápidos, IP del servidor de desarrollo, bloqueos.
- **Si estás bloqueado más de 2 horas, pide ayuda.** No esperes al daily.

---

## 12. Pruebas

| Tipo | Quién | Qué |
| --- | --- | --- |
| Unitarias de backend | Gerardo y Ever | Servicios: ventas, cambio, envases, cortes, resurtido, alertas |
| De rutas | Gerardo y Ever | Cada endpoint responde con el código y formato del contrato |
| De widgets | Pablo, Daniel y Luis | Componentes clave: carrito, teclado, cálculo de cambio en pantalla |
| Manuales en dispositivo | Todos, al integrar | Lista de verificación por módulo en `docs/pruebas.md` |
| Rendimiento | Gerardo y Pablo | Menos de 500 ms entre la venta y la actualización en terminales |
| En el depósito | Todos, Sprint 4 | Un turno real de prueba con productos y personal del depósito |

---

## 13. Convenciones de código

- Formato automático con `dart format` antes de cada commit.
- Sin advertencias de `dart analyze` / `flutter analyze`.
- Nombres de clases, variables y endpoints **en español sin acentos**, igual que en el contrato (`Producto`, `precioCaja`, `registrarVenta`).
- Textos de la interfaz en español, con acentos, en un archivo de textos compartido para no repetirlos.
- Nada de datos sensibles en el repo (contraseñas, claves de Apple, etc.).
- Comentarios solo donde la lógica no sea obvia, sobre todo en cálculos de dinero, envases y resurtido.

---

## 14. Riesgos y cómo los atendemos

| Riesgo | Impacto | Plan | Responsable |
| --- | --- | --- | --- |
| Nadie tiene Mac o no hay cuenta de Apple Developer | No se puede instalar en iPad/iPhone | Resolverlo en la semana 1: Mac prestada o Codemagic, y confirmar la cuenta de Apple | Pablo |
| El servidor embebido falla en iOS | Todo el diseño depende de eso | Probarlo en el Sprint 1 con un "hola mundo" antes de avanzar | Gerardo y Pablo |
| El iPad se bloquea y se cae el servidor | Terminales sin servicio | Acceso guiado, sin bloqueo automático, cargador conectado | Pablo |
| Se pierde o daña el iPad | Se pierde la información | Respaldo diario exportado al cerrar caja (Sprint 4) | Gerardo |
| Cambios al contrato sin avisar | Front y back dejan de conectar | Todo cambio de API pasa por PR con etiqueta `contrato` | Gerardo y Ever |
| Conflictos de Git | Tiempo perdido | Ramas cortas, PRs pequeños, `git pull` de `develop` diario | Todos |
| Wi-Fi inestable | Terminales desconectadas | Reconexión automática e indicador visible de conexión | Pablo |

---

## 15. Lista de arranque (esta semana)

- [ ] Todos instalan Flutter 3.47.5 y ejecutan `flutter doctor`.
- [ ] Gerardo invita a Ever a `deposito-backend` y a Pablo, Daniel y Luis a `deposito-app` (Settings → Collaborators).
- [ ] Pablo crea la estructura inicial de `deposito-app` y la sube.
- [ ] Gerardo protege `main` y `develop` en ambos repos.
- [ ] Gerardo publica la primera versión de `API.md` con salud, terminales y productos.
- [ ] Confirmar quién tiene Mac y el tema de la cuenta de Apple.
- [ ] Llenar Trello con las tareas del Sprint 1 de este documento, cada una con su dueño.
- [ ] Fijar el horario del daily y del día de integración.

---

## 16. Glosario

| Término | Significado |
| --- | --- |
| Caja | El iPad donde se cobra; también es el servidor |
| Terminal | S24 o iPhone con la app en modo Terminal |
| Servidor embebido | El backend corriendo dentro de la app del iPad |
| Contrato | El archivo `API.md` con todos los endpoints |
| Tag | Versión marcada del backend que usa el front |
| Envase retornable | Botella que el cliente regresa; se cobra depósito si no la trae |
| Préstamo | Envases que el cliente se lleva sin dejar depósito y regresará después |
| Corte de caja | Cierre del turno comparando el efectivo esperado con el contado |
| Resurtido | Sugerencia de cuánto comprar según lo que se vende |
