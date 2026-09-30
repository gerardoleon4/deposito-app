# Anaquel

![CI](https://github.com/gerardoleon4/deposito-app/actions/workflows/ci.yml/badge.svg)

Sistema de **punto de venta e inventario** para comercios pequeños que venden por pieza y por caja. Funciona **sin internet**, sobre la red Wi-Fi del local: un iPad hace de caja y de servidor, y los teléfonos (Samsung S24 e iPhone) se conectan como terminales para escanear productos, armar pedidos y consultar existencias en tiempo real.

## Qué hace

| Módulo | Descripción |
| --- | --- |
| Catálogo (RF-01) | Productos con foto, código de barras, precio por pieza y por caja, existencia mínima y caducidad. El stock se guarda siempre en piezas. |
| Escaneo (RF-02) | Búsqueda de productos por código de barras con la cámara del teléfono. |
| Envases (RF-03) | Envases retornables por formato: cobro de garantía, intercambio, préstamos a clientes y devoluciones. |
| Ventas (RF-04) | Venta por pieza o caja, efectivo con cálculo de cambio o tarjeta, cancelaciones e historial. |
| Tickets y corte (RF-05) | Ticket en PDF para compartir por WhatsApp o correo. Apertura y cierre de caja con arqueo. |
| Tiempo real (RF-06) | Cada venta actualiza las existencias en todos los dispositivos al instante. |
| Alertas (RF-07) | Aviso de poco stock y de productos próximos a caducar. |
| Resurtido (RF-08) | Sugerencia de cuánto comprar según las ventas de los últimos 30 días. |

## Cómo funciona

```
              Wi-Fi del negocio (red local)

   iPad (modo CAJA)
   ┌────────────────────────────────┐
   │ App Flutter (pantallas)        │
   │        │ localhost:8080        │
   │        ▼                       │        S24 (modo TERMINAL)
   │ backend embebido               │◄─ HTTP ─ iPhone (modo TERMINAL)
   │  • API REST                    │◄─ WebSocket
   │  • WebSocket                   │
   │  • SQLite                      │
   └────────────────────────────────┘
```

- La **caja** ejecuta el backend dentro de la propia app y guarda todo en SQLite.
- Las **terminales** usan la misma app en modo Terminal y se conectan a la IP de la caja (por código QR).
- Todo pasa por una API REST y un WebSocket para los cambios en vivo.

> **Importante:** iOS no permite servidores en segundo plano, así que el iPad debe tener la app abierta y en primer plano (Acceso guiado y sin bloqueo automático).

## Estructura del repositorio

```
deposito-app/
├── backend/    Paquete Dart: API, WebSocket, SQLite y reglas de negocio
├── app/        App Flutter: pantallas de caja y terminal
├── docs/       Contrato de la API, plan de trabajo y prototipo HTML
└── .github/    CI y CODEOWNERS
```

## Tecnologías

| Parte | Herramientas |
| --- | --- |
| Backend | Dart, `shelf`, `shelf_router`, `shelf_web_socket`, `sqlite3` |
| App | Flutter, `flutter_riverpod`, `go_router`, `dio`, `web_socket_channel`, `mobile_scanner`, `pdf`, `printing`, `share_plus`, `qr_flutter` |
| Calidad | GitHub Actions, `dart analyze`, `flutter analyze`, pruebas unitarias |

## Requisitos

- **Flutter 3.47.5** (incluye Dart 3.13.4). Verifica con `flutter --version` y `flutter doctor`.
- Git.
- Para probar en Android: Android Studio (SDK y emulador) o un teléfono con depuración USB.
- Para compilar en iPad o iPhone: **macOS con Xcode**. En Linux y Windows se puede programar y probar todo en Android.

## Primeros pasos

```bash
git clone https://github.com/gerardoleon4/deposito-app.git
cd deposito-app
git checkout develop
```

### Backend

```bash
cd backend
dart pub get
dart run bin/server.dart
```

Abre <http://localhost:8080/salud>: debe responder `ok`.

### App

```bash
cd app
flutter pub get
flutter run
```

La primera vez, la app pregunta si el dispositivo será **Caja** o **Terminal**. Mientras el iPad no esté listo, el backend se corre en una laptop y las terminales se conectan a su IP.

### Pruebas

```bash
cd backend && dart test
cd app && flutter test
```

## Documentación

| Documento | Contenido |
| --- | --- |
| [`docs/API.md`](docs/API.md) | Contrato de la API: endpoints, ejemplos y eventos del WebSocket |
| [`docs/PLAN_DE_TRABAJO.md`](docs/PLAN_DE_TRABAJO.md) | Cómo trabaja el equipo, sprints y reglas de Git |
| [`docs/SETUP.md`](docs/SETUP.md) | Instalación paso a paso en Linux, Windows y macOS |
| [`docs/prototipo/`](docs/prototipo/) | Prototipo HTML navegable con todas las pantallas |
| [`CHANGELOG.md`](CHANGELOG.md) | Cambios por versión |

## Cómo contribuir

1. Actualiza `develop` y crea tu rama: `feature/back-...` para `backend/` o `feature/front-...` para `app/`.
2. Haz commits con prefijo: `feat(back):`, `fix(app):`, `docs:`, `test(back):`.
3. Abre un pull request hacia `develop`. Debe pasar el CI y tener una revisión.
4. Los cambios a la API se documentan primero en `docs/API.md` con la etiqueta `contrato`.

No se hace push directo a `develop` ni a `main`. Los detalles están en el [plan de trabajo](docs/PLAN_DE_TRABAJO.md).

## Equipo

| Persona | Rol | Áreas |
| --- | --- | --- |
| Gerardo | Backend | Servidor, base de datos, productos, WebSocket, alertas, respaldos, contrato de la API |
| Ever | Backend | Ventas, caja y cortes, envases, reportes, resurtido |
| Pablo | Frontend | Base de la app, conexión, tiempo real, catálogo, ajustes |
| Daniel | Frontend | Vender, cobro, tickets, historial, corte, tablero de inicio |
| Luis | Frontend | Terminal, envases, alertas, resurtido |

## Avance

| Sprint | Fechas | Meta | Estado |
| --- | --- | --- | --- |
| 1 | 25 sep – 9 oct | Cimientos: el iPad corre el servidor y una terminal se conecta | En curso |
| 2 | 10 – 23 oct | Catálogo, escaneo y envases | Pendiente |
| 3 | 24 oct – 6 nov | Ventas, caja y tiempo real | Pendiente |
| 4 | 7 – 20 nov | Alertas, resurtido y tablero | Pendiente |
| 5 | 21 – 27 nov | Corrección de errores, manual e instalación | Pendiente |

## Licencia

Por definir con el equipo y el cliente.
