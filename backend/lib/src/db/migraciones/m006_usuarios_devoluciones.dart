import '../migraciones.dart';

const m006UsuariosDevoluciones = Migracion(6, 'usuarios_devoluciones', '''
-- Personal con PIN. El PIN se guarda como sha256(sal + pin); la sal es
-- aleatoria por base. Un PIN no se repite entre usuarios activos.
CREATE TABLE usuarios (
  id       TEXT PRIMARY KEY,
  nombre   TEXT NOT NULL,
  rol      TEXT NOT NULL CHECK (rol IN ('dueno', 'gerente', 'cajero')),
  pin_hash TEXT NOT NULL,
  activo   INTEGER NOT NULL DEFAULT 1 CHECK (activo IN (0, 1)),
  creado   TEXT NOT NULL
);
CREATE UNIQUE INDEX usuarios_pin_activo ON usuarios (pin_hash) WHERE activo = 1;
INSERT INTO ajustes (clave, valor) VALUES ('salPin', lower(hex(randomblob(16))));

-- Quién cobró, crédito por vacíos extra y lo ya devuelto de cada venta.
ALTER TABLE ventas ADD COLUMN usuario_id TEXT REFERENCES usuarios (id);
ALTER TABLE ventas ADD COLUMN env_credito INTEGER NOT NULL DEFAULT 0
  CHECK (env_credito >= 0);
ALTER TABLE ventas ADD COLUMN devuelto INTEGER NOT NULL DEFAULT 0
  CHECK (devuelto >= 0);
CREATE INDEX idx_ventas_usuario ON ventas (usuario_id);

-- Vacíos extra que entregó el cliente en una venta, por formato.
CREATE TABLE venta_creditos (
  venta_id TEXT NOT NULL REFERENCES ventas (id),
  formato  TEXT NOT NULL CHECK (formato IN ('mega', 'media', 'cuarto')),
  cantidad INTEGER NOT NULL CHECK (cantidad > 0),
  PRIMARY KEY (venta_id, formato)
);

-- Descuento por línea (porcentaje) y unidades ya devueltas. precio_unit
-- queda como el precio neto por unidad; precio_lista, el de antes del
-- descuento (NULL en ventas anteriores: es igual a precio_unit).
ALTER TABLE venta_lineas ADD COLUMN precio_lista INTEGER CHECK (precio_lista > 0);
ALTER TABLE venta_lineas ADD COLUMN descuento INTEGER NOT NULL DEFAULT 0
  CHECK (descuento BETWEEN 0 AND 100);
ALTER TABLE venta_lineas ADD COLUMN devueltas INTEGER NOT NULL DEFAULT 0
  CHECK (devueltas >= 0);
-- Depósito cobrado por pieza en la línea (envModo cobrar), para regresarlo
-- exacto en una devolución parcial. 0 si no se cobró.
ALTER TABLE venta_lineas ADD COLUMN deposito INTEGER NOT NULL DEFAULT 0
  CHECK (deposito >= 0);

-- Dinero regresado por cancelaciones y devoluciones parciales. Nunca se
-- edita ni se borra.
CREATE TABLE devoluciones (
  id          TEXT PRIMARY KEY,
  venta_id    TEXT NOT NULL REFERENCES ventas (id),
  turno_id    TEXT REFERENCES turnos (id),
  fecha       TEXT NOT NULL,
  monto       INTEGER NOT NULL CHECK (monto >= 0),
  metodo      TEXT NOT NULL CHECK (metodo IN ('efectivo', 'tarjeta')),
  destino     TEXT NOT NULL CHECK (destino IN ('inventario', 'merma')),
  motivo      TEXT,
  autorizo_id TEXT REFERENCES usuarios (id),
  origen      TEXT NOT NULL
);
CREATE INDEX devoluciones_turno ON devoluciones (turno_id);
CREATE INDEX devoluciones_venta ON devoluciones (venta_id);

-- Las ventas ya canceladas quedan como devueltas por completo.
INSERT INTO devoluciones (id, venta_id, turno_id, fecha, monto, metodo, destino, origen)
  SELECT 'dev_m006_' || id, id, turno_id, fecha, total, metodo, 'inventario', origen
  FROM ventas WHERE cancelada = 1;
UPDATE ventas SET devuelto = total WHERE cancelada = 1;
UPDATE venta_lineas SET devueltas = cantidad
  WHERE venta_id IN (SELECT id FROM ventas WHERE cancelada = 1);

ALTER TABLE turnos ADD COLUMN usuario_apertura TEXT REFERENCES usuarios (id);
ALTER TABLE turnos ADD COLUMN usuario_cierre TEXT REFERENCES usuarios (id);

ALTER TABLE prestamos_envases ADD COLUMN telefono TEXT;

-- Bitácora de todo cambio del balance de envases. Nunca se edita ni se borra.
CREATE TABLE envase_movimientos (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  fecha      TEXT NOT NULL,
  formato    TEXT NOT NULL CHECK (formato IN ('mega', 'media', 'cuarto')),
  tipo       TEXT NOT NULL CHECK (tipo IN ('entrada', 'salida', 'prestamo',
               'devolucion_prestamo', 'venta_trae', 'venta_prestamo', 'credito',
               'venta_vacios', 'devolucion_deposito', 'cancelacion')),
  bodega     INTEGER NOT NULL,
  prestados  INTEGER NOT NULL,
  cliente    TEXT,
  monto      INTEGER,
  referencia TEXT,
  origen     TEXT NOT NULL
);
CREATE INDEX envase_movimientos_fecha ON envase_movimientos (fecha);
''');
