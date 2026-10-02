import '../migraciones.dart';

const m002VentasPedidosEnvases = Migracion(2, 'ventas_pedidos_envases', '''
-- Balance y seguimiento de envases retornables
CREATE TABLE balance_envases (
  formato       TEXT PRIMARY KEY CHECK (formato IN ('mega', 'media', 'cuarto')),
  bodega        INTEGER NOT NULL DEFAULT 0 CHECK (bodega >= 0),
  prestados     INTEGER NOT NULL DEFAULT 0 CHECK (prestados >= 0),
  precio        INTEGER NOT NULL CHECK (precio > 0)
);

INSERT INTO balance_envases (formato, bodega, prestados, precio) VALUES
  ('mega', 84, 36, 800),
  ('media', 240, 48, 300),
  ('cuarto', 168, 24, 300);

CREATE TABLE prestamos_envases (
  id        TEXT PRIMARY KEY,
  cliente   TEXT NOT NULL,
  formato   TEXT NOT NULL CHECK (formato IN ('mega', 'media', 'cuarto')),
  cantidad  INTEGER NOT NULL CHECK (cantidad > 0),
  fecha     TEXT NOT NULL,
  devuelto  INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX idx_prestamos_cliente ON prestamos_envases (cliente, devuelto);

-- Ventas y Tickets
CREATE TABLE ventas (
  id          TEXT PRIMARY KEY,
  folio       INTEGER NOT NULL UNIQUE,
  fecha       TEXT NOT NULL,
  dia_negocio TEXT NOT NULL,
  total       INTEGER NOT NULL CHECK (total >= 0),
  metodo      TEXT NOT NULL CHECK (metodo IN ('efectivo', 'tarjeta')),
  tarjeta     TEXT,
  recibido    INTEGER NOT NULL DEFAULT 0 CHECK (recibido >= 0),
  cambio      INTEGER NOT NULL DEFAULT 0 CHECK (cambio >= 0),
  env_modo    TEXT NOT NULL DEFAULT 'na' CHECK (env_modo IN ('na', 'cobrar', 'trae', 'prestamo')),
  env_n       INTEGER NOT NULL DEFAULT 0 CHECK (env_n >= 0),
  env_monto   INTEGER NOT NULL DEFAULT 0 CHECK (env_monto >= 0),
  env_cliente TEXT,
  origen      TEXT NOT NULL,
  cancelada   INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX idx_ventas_dia ON ventas (dia_negocio, cancelada);

CREATE TABLE venta_lineas (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  venta_id    TEXT NOT NULL REFERENCES ventas (id),
  producto_id TEXT NOT NULL REFERENCES productos (id),
  nombre      TEXT NOT NULL,
  unidad      TEXT NOT NULL CHECK (unidad IN ('pieza', 'caja')),
  cantidad    INTEGER NOT NULL CHECK (cantidad > 0),
  piezas      INTEGER NOT NULL CHECK (piezas > 0),
  precio_unit INTEGER NOT NULL CHECK (precio_unit > 0),
  subtotal    INTEGER NOT NULL CHECK (subtotal > 0)
);
CREATE INDEX idx_lineas_venta ON venta_lineas (venta_id);

-- Pedidos levantados por Terminales
CREATE TABLE pedidos (
  id        TEXT PRIMARY KEY,
  origen    TEXT NOT NULL,
  fecha     TEXT NOT NULL,
  nota      TEXT,
  atendido  INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE pedido_lineas (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  pedido_id   TEXT NOT NULL REFERENCES pedidos (id),
  producto_id TEXT NOT NULL REFERENCES productos (id),
  unidad      TEXT NOT NULL CHECK (unidad IN ('pieza', 'caja')),
  cantidad    INTEGER NOT NULL CHECK (cantidad > 0)
);
''');
