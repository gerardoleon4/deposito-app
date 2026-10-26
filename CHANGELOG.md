# Cambios

Formato: una sección por versión del backend (tag), con lo que se agregó y lo que cambió en el contrato de la API.

## Sin publicar (rumbo a v0.1.0)

### Alertas de existencia y caducidad

#### Contrato
- `GET /api/v1/alertas?dias=30`: productos agotados, con poco stock, caducados y por caducar, ordenados por urgencia.
- Evento `alerta.nueva` cuando un producto baja de su mínimo o se agota.

#### Backend
- Servicio de alertas: calcula con el día del negocio y avisa solo cuando la alerta de existencia empeora, sin repetir ni avisar de nuevo al reiniciar.
- Modelo `Alerta` y `calcularAlertas` exportados para que la app use la misma regla.

#### App
- `Api.listarAlertas` en `ApiHttp` y `ApiFalsa`, para que la pantalla de Alertas se haga contra la interfaz.

### Caja, personal, devoluciones y envases completos

#### Contrato
- Caja: turno (`GET/POST /caja/turno`, cerrar con corte), movimientos de efectivo y cortes con arqueo. Ventas y cobros exigen turno abierto (`caja_cerrada`).
- Usuarios con PIN (dueño, gerente, cajero), verificación de PIN con bloqueo tras 5 intentos y autorización de gerente o dueño para acciones sensibles.
- Ajustes del negocio para el ticket y respaldo de la base (crear, verificar y restaurar).
- Ventas: descuento por renglón, crédito por vacíos extra (`envCredito`), quién cobró (`usuarioId`), devolución parcial por `lineaId` y cancelación como devolución del resto.
- Envases: salida sin cobro, devolución de depósito y movimientos.
- Eventos `venta.devuelta` y `caja.*` (solo a la caja).

#### Backend
- Migración 005: turnos, movimientos de caja, cortes y conciliación de envases prestados.
- Migración 006: usuarios, devoluciones, descuentos, crédito por vacíos y movimientos de envases.
- Fotos de los productos de ejemplo (diseño de Pablo).

#### App
- API de caja, personal, devoluciones, descuentos y envases, también en `ApiFalsa`.
- Pantallas del diseño de Pablo conectadas al servidor: envases (tablero, historial, recepción, préstamo, devolución de depósito y salida al cobrar), ventas del turno (detalle, cancelación y devolución parcial, merma o inventario, autorización con PIN, reimpresión), Vender y Cobro completos (descuento, vacíos, saldo por envases, efectivo, tarjeta, recibo con vista previa del ticket), escáner continuo, caja (apertura, movimientos, corte, arqueo y recibo), personal, inicio de turno, cuenta maestra y respaldo.
- Ticket y corte en PDF para imprimir o compartir.
- Las fotos de los productos de ejemplo se ven también en web y mientras carga la del servidor.
Migración 002: tablas para ventas, venta_lineas, pedidos y balance_envases.   
Endpoints POST/GET /api/v1/ventas, POST/GET/DELETE /api/v1/pedidos y GET/POST /api/v1/envases.   
Eventos de tiempo real para actualización de envases y creación de pedidos.  
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

### App
- Tema del prototipo (claro y oscuro) con Barlow incluida en la app.
- Elegir modo Caja o Terminal.
- Caja: servidor embebido, menú lateral adaptable, tablero, catálogo con búsqueda y filtros, alta de producto, QR para conectar terminales y ajustes.
- Terminal: vinculación por QR o a mano, escanear producto, catálogo y ajustes.
- Tiempo real con reconexión automática e indicador de conexión.
- Permisos de red y cámara en Android e iOS; nombre "Anaquel".
