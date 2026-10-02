/// Servidor de Anaquel y modelos compartidos con la app.
///
/// La app importa este paquete para:
/// - arrancar [DepositoServer] en modo Caja;
/// - usar los mismos modelos ([Producto], [Terminal], [Evento]) que el
///   servidor, así los campos nunca se desincronizan.
library;

export 'src/comun/bitacora.dart' show Bitacora;
export 'src/comun/fechas.dart'
    show Reloj, diaNegocio, instanteIso, rangoDiaNegocio;
export 'src/comun/middleware.dart' show cabeceraClave;
export 'src/comun/texto.dart' show normalizarBusqueda;
export 'src/db/base_datos.dart' show enMemoria;
export 'src/modelos/evento.dart';
export 'src/modelos/producto.dart';
export 'src/modelos/terminal.dart';
export 'src/servidor.dart' show DepositoServer, versionServidor;
