import 'dart:io';
import 'dart:typed_data';

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
    expect(productos, hasLength(12));
    expect(productos.map((p) => p.nombre), contains('Victoria Mega'));
  });

  test(
    'la caja cobra y un reintento con la misma clave no cobra dos veces',
    () async {
      final victoria = (await caja.listarProductos()).firstWhere(
        (p) => p.nombre == 'Victoria Mega',
      );
      final lineas = [
        LineaVenta(productoId: victoria.id, porCaja: true, cantidad: 1),
        LineaVenta(productoId: victoria.id, porCaja: false, cantidad: 2),
      ];

      final primera = await caja.registrarVenta(
        lineas: lineas,
        metodo: 'efectivo',
        recibido: 100000,
        claveIdempotencia: 'cobro-integracion-1',
      );
      final reintento = await caja.registrarVenta(
        lineas: lineas,
        metodo: 'efectivo',
        recibido: 100000,
        claveIdempotencia: 'cobro-integracion-1',
      );

      expect(reintento.folio, primera.folio);
      expect(primera.total, victoria.precioCaja! + 2 * victoria.precio);
      expect(primera.cambio, 100000 - primera.total);
      final despues = (await caja.listarProductos()).firstWhere(
        (p) => p.id == victoria.id,
      );
      expect(
        despues.existenciaPiezas,
        victoria.existenciaPiezas - victoria.piezasPorCaja! - 2,
      );
    },
  );

  test('la caja administra el catálogo completo', () async {
    final victoria = (await caja.buscarPorCodigo('7501064191015'))!;
    expect(victoria.nombre, 'Victoria Mega');
    expect(await caja.buscarPorCodigo('no-existe'), isNull);

    final editado = await caja.editarProducto(victoria.id, {
      ...victoria.toJson(),
      'precio': 4500,
    });
    expect(editado.precio, 4500);
    expect(editado.existenciaPiezas, victoria.existenciaPiezas);

    final conEntrada = await caja.registrarEntrada(
      victoria.id,
      cajas: 1,
      piezas: 2,
      nota: 'Proveedor',
    );
    expect(conEntrada.existenciaPiezas, victoria.existenciaPiezas + 14);
    final contado = await caja.registrarConteo(
      victoria.id,
      existenciaPiezas: 50,
    );
    expect(contado.existenciaPiezas, 50);
    final conMerma = await caja.registrarMerma(victoria.id, piezas: 2);
    expect(conMerma.existenciaPiezas, 48);
    await expectLater(
      caja.registrarMerma(victoria.id, piezas: 1000),
      throwsA(
        isA<FalloApi>().having((e) => e.codigo, 'codigo', 'stock_insuficiente'),
      ),
    );
    final movimientos = await caja.listarMovimientos(victoria.id);
    expect(movimientos.map((m) => m.tipo).take(3), [
      'merma',
      'ajuste',
      'entrada',
    ]);

    final png = Uint8List.fromList([
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      1,
      2,
      3,
    ]);
    final conFoto = await caja.subirFoto(victoria.id, png, 'image/png');
    expect(conFoto.foto, startsWith('/api/v1/productos/${victoria.id}/foto'));
    expect((await caja.borrarFoto(victoria.id)).foto, isNull);

    await caja.eliminarProducto(victoria.id);
    expect(await caja.buscarPorCodigo('7501064191015'), isNull);
  });

  test('la caja consulta y cancela ventas y maneja envases', () async {
    final hielo = (await caja.buscarPorCodigo('7502000000017'))!;
    final venta = await caja.registrarVenta(
      lineas: [LineaVenta(productoId: hielo.id, porCaja: false, cantidad: 2)],
      metodo: 'tarjeta',
      claveIdempotencia: 'cobro-integracion-ventas',
    );

    final lista = await caja.listarVentas();
    expect(lista.single.folio, venta.folio);
    final detalle = await caja.obtenerVenta(venta.id);
    expect(detalle.lineas.single.nombre, 'Hielo en bolsa');
    await caja.cancelarVenta(venta.id);
    expect((await caja.obtenerVenta(venta.id)).cancelada, isTrue);
    expect(
      (await caja.buscarPorCodigo('7502000000017'))!.existenciaPiezas,
      hielo.existenciaPiezas,
    );

    final antes = await caja.obtenerBalanceEnvases();
    final prestamo = await caja.prestarEnvases(
      cliente: 'Don Pedro',
      formato: 'media',
      cantidad: 6,
    );
    expect((await caja.listarPrestamos()).single.id, prestamo.id);
    await caja.devolverPrestamo(prestamo.id);
    final despues = await caja.recibirVacios(formato: 'media', cantidad: 4);
    expect(despues['media']!.bodega, antes['media']!.bodega + 6 + 4);
    expect(despues['media']!.prestados, antes['media']!.prestados);
    expect(await caja.listarPrestamos(), isEmpty);
  });

  test('sin existencias el error llega como stock_insuficiente', () async {
    final p = (await caja.listarProductos()).first;
    await expectLater(
      caja.registrarVenta(
        lineas: [
          LineaVenta(
            productoId: p.id,
            porCaja: false,
            cantidad: p.existenciaPiezas + 1,
          ),
        ],
        metodo: 'tarjeta',
        claveIdempotencia: 'cobro-integracion-2',
      ),
      throwsA(
        isA<FalloApi>().having((f) => f.codigo, 'codigo', 'stock_insuficiente'),
      ),
    );
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
      expect(await terminal.listarProductos(), hasLength(12));

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
