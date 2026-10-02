import '../migraciones.dart';

/// Productos, movimientos de inventario, terminales y ajustes.
///
/// Dinero en centavos (INTEGER), instantes en texto ISO UTC, fechas de
/// calendario en texto AAAA-MM-DD.
const m001Inicial = Migracion(1, 'inicial', '''
CREATE TABLE productos (
  id                TEXT PRIMARY KEY,
  codigo            TEXT NOT NULL,
  nombre            TEXT NOT NULL,
  nombre_busqueda   TEXT NOT NULL,
  categoria         TEXT NOT NULL,
  presentacion      TEXT,
  precio            INTEGER NOT NULL CHECK (precio > 0),
  precio_caja       INTEGER CHECK (precio_caja > 0),
  piezas_por_caja   INTEGER CHECK (piezas_por_caja >= 2),
  existencia_piezas INTEGER NOT NULL DEFAULT 0 CHECK (existencia_piezas >= 0),
  minimo            INTEGER NOT NULL DEFAULT 0 CHECK (minimo >= 0),
  envase            TEXT CHECK (envase IN ('mega', 'media', 'cuarto')),
  caducidad         TEXT,
  foto              TEXT,
  eliminado         INTEGER NOT NULL DEFAULT 0,
  creado            TEXT NOT NULL,
  actualizado       TEXT NOT NULL,
  CHECK ((precio_caja IS NULL) = (piezas_por_caja IS NULL))
);

-- Único solo entre activos: un producto eliminado no bloquea su código.
CREATE UNIQUE INDEX productos_codigo_activo ON productos (codigo) WHERE eliminado = 0;
CREATE INDEX productos_categoria ON productos (categoria) WHERE eliminado = 0;

-- Bitácora de todo cambio de existencia. Nunca se edita ni se borra.
CREATE TABLE movimientos (
  id                    INTEGER PRIMARY KEY AUTOINCREMENT,
  producto_id           TEXT NOT NULL REFERENCES productos (id),
  tipo                  TEXT NOT NULL CHECK (tipo IN
                          ('inicial', 'entrada', 'venta', 'cancelacion', 'ajuste', 'merma')),
  piezas                INTEGER NOT NULL,
  existencia_resultante INTEGER NOT NULL CHECK (existencia_resultante >= 0),
  referencia            TEXT,
  origen                TEXT NOT NULL,
  nota                  TEXT,
  fecha                 TEXT NOT NULL
);
CREATE INDEX movimientos_producto ON movimientos (producto_id, fecha);

CREATE TABLE terminales (
  id              TEXT PRIMARY KEY,
  nombre          TEXT NOT NULL,
  clave_hash      TEXT NOT NULL UNIQUE,
  registrada      TEXT NOT NULL,
  ultima_conexion TEXT NOT NULL,
  revocada        INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE ajustes (
  clave TEXT PRIMARY KEY,
  valor TEXT NOT NULL
);

-- México centro, sin horario de verano desde 2022.
INSERT INTO ajustes (clave, valor) VALUES ('zonaHoraria', '-06:00');
''');
