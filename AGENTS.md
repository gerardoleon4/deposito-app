# AGENTS.md — Guía para el equipo y sus asistentes de IA

Anaquel es un punto de venta e inventario sin internet para un depósito de cerveza. Un iPad en modo **Caja** corre la app y el servidor embebido (API REST, WebSocket y SQLite). Los teléfonos en modo **Terminal** se conectan por la Wi-Fi del local.

Se entrega a un negocio real: el dinero y los datos no pueden fallar.

## Antes de escribir código, leer

1. [`docs/ESTANDARES.md`](docs/ESTANDARES.md): reglas obligatorias (dinero, fechas, transacciones, migraciones, capas).
2. [`docs/API.md`](docs/API.md): el contrato. Ningún endpoint existe si no está ahí.
3. [`docs/PLAN_DE_TRABAJO.md`](docs/PLAN_DE_TRABAJO.md): quién es dueño de qué y qué toca en cada sprint.

## Estructura

```
backend/   Paquete Dart puro. DepositoServer, modelos compartidos, SQLite.
app/       App Flutter. Pantallas de caja y terminal; importa deposito_backend.
docs/      Contrato, estándares, plan, prototipo HTML (docs/prototipo/).
```

La app depende del backend por ruta (`path: ../backend`): los dos viven en este repo.

## Comandos

```bash
# Backend
cd backend
dart pub get
dart run bin/server.dart        # servidor de desarrollo con datos de ejemplo
dart test                       # unitarias y e2e
dart format . && dart analyze

# App
cd app
flutter pub get
flutter run
flutter test
dart format lib test && flutter analyze
```

Versiones fijas: **Flutter 3.47.6, Dart 3.13.5**.

## Cómo agregar...

### Un endpoint

1. Documentarlo en `docs/API.md` (PR con etiqueta `contrato`, aprobado por quien lo consume).
2. Modelo en `backend/lib/src/modelos/` con `toJson`/`fromJson`, exportado en `lib/deposito_backend.dart` si la app lo usa.
3. SQL en un repositorio de `backend/lib/src/db/`.
4. Reglas, validación con `Validador`, transacción y evento en `backend/lib/src/servicios/`.
5. Ruta en `backend/lib/src/rutas/`: solo lee, llama al servicio y responde. Usar `exigirCaja()` si el contrato dice "Solo caja".
6. Pruebas: unitarias del servicio y e2e en `test/api_test.dart` con `crearServidorDePrueba()`.

### Una migración

1. Archivo nuevo `backend/lib/src/db/migraciones/mNNN_descripcion.dart` con el siguiente número.
2. Agregarla al final de la lista en `migraciones.dart`.
3. Nunca editar una migración publicada en un tag.

### Una pantalla

1. Dentro de `app/lib/features/<feature>/` con `datos/`, `estado/` y `pantallas/`.
2. Programar contra la interfaz de la API, con la versión falsa mientras el endpoint no exista.
3. Reutilizar `core/widgets/` (confirmar, error, vacío, cargando, moneda). Si falta un componente, se propone en el PR.
4. Manejar cargando, error, vacío y con datos. Probar en un dispositivo real.

## No hacer

- Usar `double` para dinero o redondear.
- Usar `DateTime.now()` directo en lógica de negocio: recibir un `Reloj`.
- Calcular "hoy" con la zona del dispositivo: usar `diaNegocio()`.
- Cambiar existencias sin registrar el movimiento.
- Escribir SQL fuera de `db/` o lógica dentro de `rutas/`.
- Emitir eventos de WebSocket dentro de una transacción.
- Cambiar la API sin actualizar `docs/API.md`.
- Subir bases de datos, logs, claves o keystores.

## Git

- Ramas desde `develop`: `feature/back-...`, `feature/front-...`, `fix/...`, `chore/...`.
- Commits: `feat(back): ...`, `fix(app): ...`, `docs: ...`, `test(back): ...`, con la tarjeta de Trello `(ANQ-12)`.
- Todo entra por PR con CI verde y una revisión. Nadie hace push directo a `develop` ni a `main`.
