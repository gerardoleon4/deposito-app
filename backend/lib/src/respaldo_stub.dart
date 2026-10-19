/// En web no hay archivos ni SQLite: no se restaura nada.
enum EstadoRespaldo { noEsRespaldo, requierePin, pinIncorrecto, valido }

EstadoRespaldo verificarRespaldo(String ruta, {String? pin}) =>
    EstadoRespaldo.noEsRespaldo;

void restaurarRespaldo(String origen, String destino) =>
    throw UnsupportedError('No se restaura en web');
