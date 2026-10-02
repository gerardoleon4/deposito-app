import 'dart:io';

import 'package:deposito_app/core/api/api.dart';
import 'package:deposito_app/core/api/fallo_api.dart';
import 'package:deposito_app/core/tiempo_real/tiempo_real.dart';
import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter_test/flutter_test.dart';

/// La capa de datos de la app contra el servidor real (sin pantallas):
/// lo mismo que pasa entre la caja y una terminal en el depósito.
void main() {
  late DepositoServer servidor;
  late Uri base;
  late ApiHttp caja;

  setUp(() async {
    servidor = DepositoServer(
      rutaBaseDatos: enMemoria,
      puerto: 0,
      direccion: InternetAddress.loopbackIPv4,
      datosEjemplo: true,
      bitacora: Bitacora.silenciosa(),
    );
    await servidor.iniciar();
    base = Uri.parse('http://127.0.0.1:${servidor.puertoActual}');
    caja = ApiHttp(base: base, clave: servidor.claveCaja);
  });

  tearDown(() => servidor.detener());

  test('la caja lista los productos de ejemplo', () async {
    final productos = await caja.listarProductos();
    expect(productos, hasLength(11));
    expect(productos.map((p) => p.nombre), contains('Victoria Mega'));
  });

  test(
    'una terminal se vincula con el código y ve en vivo lo que crea la caja',
    () async {
      final codigo = await caja.crearCodigoEmparejamiento();
      final registro = await ApiHttp.registrarTerminal(
        base: base,
        nombre: 'Terminal S24',
        codigo: codigo.codigo,
      );
      final terminal = ApiHttp(base: base, clave: registro.clave);
      expect(await terminal.listarProductos(), hasLength(11));

      final tiempoReal = TiempoReal(terminal);
      addTearDown(tiempoReal.cerrar);
      await tiempoReal.estados
          .firstWhere((e) => e == EstadoConexion.enLinea)
          .timeout(const Duration(seconds: 5));
      final llegada = tiempoReal.eventos.firstWhere(
        (e) => e.tipo == TiposEvento.productoActualizado,
      );

      await caja.crearProducto({
        'codigo': '750999',
        'nombre': 'Tecate Light',
        'categoria': 'cerveza',
        'precio': 2350,
      });

      final evento = await llegada.timeout(const Duration(seconds: 5));
      expect((evento.datos['producto'] as Map)['nombre'], 'Tecate Light');

      final terminales = await caja.listarTerminales();
      expect(terminales.single.conectada, isTrue);
    },
  );

  test(
    'los errores del servidor llegan como FalloApi con sus campos',
    () async {
      await expectLater(
        caja.crearProducto({
          'codigo': '1',
          'nombre': 'X',
          'categoria': 'c',
          'precio': 42.5,
        }),
        throwsA(
          isA<FalloApi>()
              .having((f) => f.codigo, 'codigo', 'datos_invalidos')
              .having((f) => f.campos.keys, 'campos', contains('precio')),
        ),
      );
    },
  );

  test('una terminal revocada recibe no autorizado', () async {
    final codigo = await caja.crearCodigoEmparejamiento();
    final registro = await ApiHttp.registrarTerminal(
      base: base,
      nombre: 'iPhone',
      codigo: codigo.codigo,
    );
    await caja.revocarTerminal(registro.terminal.id);
    await expectLater(
      ApiHttp(base: base, clave: registro.clave).listarProductos(),
      throwsA(
        isA<FalloApi>().having((f) => f.noAutorizado, 'noAutorizado', isTrue),
      ),
    );
  });

  test('sin servidor el error es sin_conexion', () async {
    await servidor.detener();
    await expectLater(
      caja.listarProductos(),
      throwsA(
        isA<FalloApi>().having((f) => f.sinConexion, 'sinConexion', isTrue),
      ),
    );
  });

  test('el tiempo real se reconecta solo y avisa para recargar', () async {
    final tiempoReal = TiempoReal(caja);
    addTearDown(tiempoReal.cerrar);
    final estados = <EstadoConexion>[];
    final sub = tiempoReal.estados.listen(estados.add);
    addTearDown(sub.cancel);
    await tiempoReal.estados.firstWhere((e) => e == EstadoConexion.enLinea);
    final reconectado = tiempoReal.eventos.firstWhere(
      (e) => e.tipo == eventoReconectado,
    );

    // Se cae el servidor (Wi-Fi, iPad bloqueado...) y vuelve en el mismo puerto.
    final puerto = servidor.puertoActual;
    await servidor.detener();
    servidor = DepositoServer(
      rutaBaseDatos: enMemoria,
      puerto: puerto,
      direccion: InternetAddress.loopbackIPv4,
      claveCaja: servidor.claveCaja,
      bitacora: Bitacora.silenciosa(),
    );
    await servidor.iniciar();

    await reconectado.timeout(const Duration(seconds: 10));
    expect(
      estados,
      containsAllInOrder([EstadoConexion.sinConexion, EstadoConexion.enLinea]),
    );
  });
}
