const String versionServidor = '0.1.0';

class DepositoServer {
  DepositoServer({
    required this.rutaBaseDatos,
    this.puerto = 8080,
    dynamic direccion,
    String? claveCaja,
    this.datosEjemplo = false,
    dynamic bitacora,
    dynamic reloj,
  }) : claveCaja = claveCaja ?? 'clave_stub';

  final String rutaBaseDatos;
  final int puerto;
  final bool datosEjemplo;
  final String claveCaja;

  Future<void> iniciar() async {}
  Future<void> detener() async {}

  int get puertoActual => puerto;
}
