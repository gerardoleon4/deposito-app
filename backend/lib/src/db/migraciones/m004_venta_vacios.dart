import '../migraciones.dart';

const m004VentaVacios = Migracion(4, 'venta_vacios', '''
-- Formato de los envases vacíos que se vendieron sueltos (sin productos).
-- Al cancelar esa venta, esos envases regresan a bodega. NULL en las demás.
ALTER TABLE ventas ADD COLUMN env_formato TEXT
  CHECK (env_formato IN ('mega', 'media', 'cuarto'));
''');
