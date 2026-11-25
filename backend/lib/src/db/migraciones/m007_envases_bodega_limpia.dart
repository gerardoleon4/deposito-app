import '../migraciones.dart';

/// Limpia la bodega inicial ficticia sembrada en m002 (84, 240, 168) cuando la
/// base aún no tiene operaciones reales (sin movimientos de envases ni ventas),
/// para que el depósito arranque en 0 y capture su conteo físico real.
const m007EnvasesBodegaLimpia = Migracion(7, 'envases_bodega_limpia', '''
UPDATE balance_envases
SET bodega = 0
WHERE NOT EXISTS (SELECT 1 FROM envase_movimientos)
  AND NOT EXISTS (SELECT 1 FROM ventas);
''');
