import '../migraciones.dart';

const m003IdempotenciaPrestamosVenta = Migracion(
  3,
  'idempotencia_prestamos_venta',
  '''
-- Respuesta de cada cobro por su X-Clave-Idempotencia: un reintento de la
-- app recibe la misma venta en lugar de cobrar otra vez.
CREATE TABLE idempotencia (
  clave     TEXT PRIMARY KEY,
  respuesta TEXT NOT NULL,
  creado    TEXT NOT NULL
);

-- Venta que originó el préstamo, para revertirlo si la venta se cancela.
ALTER TABLE prestamos_envases ADD COLUMN venta_id TEXT REFERENCES ventas (id);
''',
);
