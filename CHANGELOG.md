# Cambios

Formato: una sección por versión del backend (tag), con lo que se agregó y lo que cambió en el contrato de la API.

## Sin publicar (rumbo a v0.1.0)

### Contrato
- Convenciones de autenticación (`X-Clave-Terminal`), catálogo de errores y fechas de calendario.
- Terminales: código de emparejamiento, registro, listado y revocación.
- Productos: listar y buscar, detalle y crear.
- WebSocket: `conexion.lista` y `producto.actualizado`.

### Backend
- `DepositoServer` embebible con `iniciar()` y `detener()`.
- Estructura por capas, middleware de errores, log y autenticación.
- SQLite en modo WAL, transacciones `BEGIN IMMEDIATE`, migraciones numeradas con respaldo previo.
- Tabla `movimientos` para el historial de existencias.
- Datos de ejemplo del prototipo.
- Pruebas unitarias y e2e con `crearServidorDePrueba()`.
