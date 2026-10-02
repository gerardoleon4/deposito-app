# deposito_app

App Flutter de Anaquel. El mismo código corre en dos modos:

- **Caja** (iPad): arranca el servidor dentro de la app y usa la API en `localhost`.
- **Terminal** (S24, iPhone): se vincula con la caja por QR y usa la API por la Wi-Fi.

## Correr

```bash
flutter pub get
flutter run
```

La primera pantalla pregunta el modo. Se puede cambiar después en Ajustes.

**Probar una terminal contra el servidor de la laptop:**

1. En `backend/`, corre `CLAVE_CAJA=dev dart run bin/server.dart`.
2. Pide un código: `curl -X POST -H "X-Clave-Terminal: dev" localhost:8080/api/v1/terminales/codigo`.
3. En el teléfono elige **Terminal → Escribir los datos a mano**, con la IP de la laptop (`hostname -I`) y el código.

En el emulador de Android, la laptop se ve como `10.0.2.2`.

## Estructura

```
lib/
├── main.dart
├── app/            tema (colores del prototipo, Barlow), router y arranque
├── core/
│   ├── api/        Api (interfaz), ApiHttp (real), ApiFalsa (pruebas), FalloApi
│   ├── config/     modo del dispositivo y conexión con la caja
│   ├── servidor/   servidor embebido (solo Caja) e IP local
│   ├── tiempo_real/ WebSocket con reconexión e indicador de conexión
│   ├── formato/    el único formateador de dinero y existencias
│   └── widgets/    estados (vacío, error, cargando), confirmar, tarjeta de producto...
└── features/
    ├── inicio/     elegir modo
    ├── caja/       menú lateral, tablero, conectar terminal (QR)
    ├── catalogo/   estado del catálogo, vista, detalle y alta de producto
    ├── terminal/   vincular, escáner, escanear, pestañas
    ├── ajustes/
    └── proximamente/  secciones que llegan en sprints siguientes
```

Las pantallas solo conocen `Api`. En pruebas se usa `ApiFalsa`; para programar una pantalla antes de que exista su endpoint, se agrega el método a `Api` y a `ApiFalsa` con los ejemplos del contrato.

## Pruebas

```bash
flutter test
```

- `flujos_test.dart`: flujos de pantalla con `ApiFalsa`.
- `integracion_backend_test.dart`: la capa de datos contra un servidor real (emparejamiento, tiempo real, reconexión).
- `formato_test.dart`: dinero y existencias.

Capturas de todas las pantallas para revisar el diseño:

```bash
CAPTURAS=/tmp/capturas flutter test test/capturas_test.dart
```
