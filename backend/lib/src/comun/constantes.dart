/// Constantes que la app usa también en web, donde no existen `dart:io` ni
/// SQLite: por eso viven aparte del middleware y de la base.
library;

/// Encabezado con la clave de la caja o de la terminal.
const cabeceraClave = 'x-clave-terminal';

/// Clave que la app genera por cobro para que un reintento no cobre dos veces.
const cabeceraIdempotencia = 'x-clave-idempotencia';

/// Ruta especial para una base en memoria (pruebas y demos).
const enMemoria = ':memory:';
