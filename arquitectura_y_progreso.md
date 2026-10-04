# Arquitectura y Progreso del Sistema de Punto de Venta e Inventarios

Este documento servirá como mapa de la arquitectura del proyecto y para hacer seguimiento continuo de los hitos logrados a lo largo del desarrollo. Como regla general, se actualizará al finalizar cada sesión de trabajo o hito importante.

## 1. Arquitectura de Estado Recomendada (Flutter)

El sistema utilizará **Riverpod** como manejador de estado principal. Esta decisión se basa en las siguientes ventajas para un sistema reactivo y con dependencias complejas (como WebSocket y bases de datos locales):

- **Inyección de Dependencias Segura:** Riverpod permite proveer la instancia del repositorio, la base de datos (SQLite) y el cliente WebSocket de forma segura sin depender del árbol de widgets (`BuildContext`).
- **Reactividad Real (Streams & StateNotifiers):** Las actualizaciones que lleguen por WebSocket (como un descuento de inventario desde una terminal) podrán alimentar un `StreamProvider` o `NotifierProvider`, causando que toda la UI (caja y terminales) se refresque automáticamente con una latencia mínima.
- **División por Features:** Cada funcionalidad (Catálogo, Ventas, Envases, Terminal) tendrá sus providers separados.
- **Caché y Reconexión Automática:** Permitirá manejar escenarios de desconexión. Al volver a conectarse el WebSocket, Riverpod facilitará invalidar (`ref.invalidate`) los providers necesarios para hacer un `GET` completo de la información de la API, manteniendo la coherencia.

### Patrón de Arquitectura en App (Caja y Terminal)
Se respetará el patrón definido en el plan de trabajo donde cada feature tiene 3 capas:
1. **`datos/`:** Llamadas a la API vía HTTP o escucha del WebSocket.
2. **`estado/`:** `Providers` (Riverpod) que almacenan la lista de productos, el carrito de compras, o el estado de conexión.
3. **`pantallas/`:** Widgets de UI consumiendo estado usando `ConsumerWidget` o `ConsumerStatefulWidget`.

## 2. Esquema Inicial de la Base de Datos (SQLite)

La base de datos vivirá únicamente en el iPad (Host). A continuación se describe el esquema relacional inicial con sus tablas principales:

### `productos`
Almacena el catálogo de productos disponibles.
- `id`: TEXT PRIMARY KEY
- `codigo`: TEXT UNIQUE (Código de barras)
- `nombre`: TEXT
- `categoria`: TEXT (Ej. cerveza, botana)
- `presentacion`: TEXT
- `precio`: INTEGER (Precio en centavos por pieza)
- `precio_caja`: INTEGER (Precio en centavos por caja)
- `piezas_por_caja`: INTEGER
- `stock_piezas`: INTEGER (Existencia física actual)
- `minimo`: INTEGER (Límite para alertas)
- `envase`: TEXT (mega, media, cuarto o NULL)
- `caducidad`: TEXT (Formato AAAA-MM-DD)
- `foto`: TEXT
- `creado`: TEXT
- `actualizado`: TEXT
- `eliminado`: INTEGER (Borrado lógico: 0 o 1)

### `ventas` y `venta_lineas`
Registra las transacciones completadas (Cobros).
- **`ventas`**: `id`, `folio` (UNIQUE), `fecha`, `total`, `metodo` (efectivo/tarjeta), `tipo_tarjeta`, `recibido`, `cambio`, `envases_modo`, `envases_cantidad`, `envases_monto`, `cliente_prestamo`, `origen`, `cancelada`, `corte_id`
- **`venta_lineas`**: `id`, `venta_id` (FK), `producto_id` (FK), `nombre`, `unidad` (caja/pieza), `cantidad`, `precio_unitario`, `piezas`

### `entradas` y `pedidos`
- **`entradas`**: Registro de abastecimiento. `id`, `producto_id`, `piezas`, `caducidad`, `fecha`.
- **`pedidos`**: Pedidos enviados por terminales a la caja. `id`, `origen`, `nota`, `fecha`, `lineas_json`.

### `envases` y `prestamos`
Gestión de vidrio retornable.
- **`envases`**: `formato` (PK), `bodega` (vacíos disponibles), `prestados`, `precio_deposito`.
- **`prestamos`**: `id`, `cliente`, `formato`, `cantidad`, `fecha`, `devueltos`.

### `turnos` y `caja`
Cortes de caja y gestión de dinero.
- **`turnos`**: `id`, `apertura`, `cierre`, `fondo`, `efectivo_contado`, `diferencia`.

### `terminales` y `ajustes`
- **`terminales`**: Dispositivos autorizados. `id`, `nombre`, `clave` (Hash), `ultima_conexion`, `eliminado`.
- **`ajustes`**: Configuraciones generales. `clave` (PK), `valor`.

---

## 3. Progreso del Proyecto (Límite: 4 semanas)

| Sprint / Hito | Estado | Tareas Completadas | Siguientes Pasos |
|--------------|--------|---------------------|------------------|
| **Preparación** | 🟡 En progreso | - Análisis del repositorio clonado<br>- Definición de la arquitectura de estado y base de datos.<br>- Instalación de dependencias. | - Iniciar diseño y esqueleto UI con Flutter.<br>- Levantar API y WebSocket local. |
| **Sprint 1: Cimientos** | 🔴 Pendiente | | - Server embebido.<br>- Registro terminales.<br>- API Salud y Productos. |
| **Sprint 2: Catálogo y Envases**| 🔴 Pendiente | | - CRUD Productos.<br>- Escáner barras.<br>- Módulo envases. |
| **Sprint 3: Ventas y Tiempo Real**| 🔴 Pendiente | | - Flujo de venta.<br>- Cobro tarjeta/efectivo.<br>- Tickets PDF.<br>- WebSockets final. |
| **Sprint 4: Alertas y Cierre**| 🔴 Pendiente | | - Resurtido automático.<br>- Alertas caducidad.<br>- Ajustes y respaldos. |
