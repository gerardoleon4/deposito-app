import '../migraciones.dart';

const m005CajaTurnos = Migracion(5, 'caja_turnos', '''
-- Turnos de caja: de la apertura con fondo al corte con efectivo contado.
-- El resumen se calcula de las ventas y movimientos del turno; al cerrar se
-- guarda el esperado para que la diferencia nunca cambie.
CREATE TABLE turnos (
  id          TEXT PRIMARY KEY,
  apertura    TEXT NOT NULL,
  cierre      TEXT,
  dia_negocio TEXT NOT NULL,
  fondo       INTEGER NOT NULL CHECK (fondo >= 0),
  abierto     INTEGER NOT NULL DEFAULT 1 CHECK (abierto IN (0, 1)),
  esperado    INTEGER,
  contado     INTEGER CHECK (contado >= 0),
  diferencia  INTEGER,
  nota        TEXT,
  CHECK (abierto = 1 OR (cierre IS NOT NULL AND esperado IS NOT NULL
    AND contado IS NOT NULL AND diferencia IS NOT NULL))
);
-- Solo un turno abierto a la vez, impedido en la base.
CREATE UNIQUE INDEX turnos_un_abierto ON turnos (abierto) WHERE abierto = 1;
CREATE INDEX turnos_dia ON turnos (dia_negocio);

-- Efectivo que entra o sale del cajón sin ser venta. Nunca se edita ni borra.
CREATE TABLE caja_movimientos (
  id       TEXT PRIMARY KEY,
  turno_id TEXT NOT NULL REFERENCES turnos (id),
  tipo     TEXT NOT NULL CHECK (tipo IN ('ingreso', 'retiro')),
  monto    INTEGER NOT NULL CHECK (monto > 0),
  motivo   TEXT NOT NULL,
  fecha    TEXT NOT NULL,
  origen   TEXT NOT NULL
);
CREATE INDEX caja_movimientos_turno ON caja_movimientos (turno_id);

-- Turno en que se cobró cada venta. NULL en las anteriores a la caja.
ALTER TABLE ventas ADD COLUMN turno_id TEXT REFERENCES turnos (id);
CREATE INDEX idx_ventas_turno ON ventas (turno_id, cancelada);

-- Envases ya devueltos de un préstamo con devolución parcial. `cantidad`
-- queda como lo que falta por devolver.
ALTER TABLE prestamos_envases ADD COLUMN devueltos INTEGER NOT NULL DEFAULT 0
  CHECK (devueltos >= 0);

-- m002 sembró "prestados" sin préstamos que los respalden. Los prestados son
-- siempre la suma de lo pendiente de los préstamos activos.
UPDATE balance_envases SET prestados = (
  SELECT COALESCE(SUM(p.cantidad), 0) FROM prestamos_envases p
  WHERE p.formato = balance_envases.formato AND p.devuelto = 0
);
''');
