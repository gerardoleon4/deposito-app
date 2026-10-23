import 'package:deposito_backend/src/db/base_datos.dart';
import 'package:deposito_backend/src/db/migraciones.dart';
import 'package:test/test.dart';

void main() {
  test(
    'los números de migración empiezan en 1, son consecutivos y no se repiten',
    () {
      final numeros = [for (final m in migraciones) m.numero];
      expect(numeros, List.generate(numeros.length, (i) => i + 1));
    },
  );

  test('todas las migraciones aplican sobre una base vacía', () {
    final db = abrirBaseDatos(enMemoria);
    addTearDown(db.close);
    final aplicadas = aplicarMigraciones(db);
    expect(aplicadas, [for (final m in migraciones) m.numero]);
    expect(versionEsquema(db), migraciones.last.numero);
  });

  test('volver a aplicar no hace nada ni pide respaldo', () {
    final db = abrirBaseDatos(enMemoria);
    addTearDown(db.close);
    aplicarMigraciones(db);
    var pidioRespaldo = false;
    final aplicadas = aplicarMigraciones(
      db,
      rutaRespaldo: (_) {
        pidioRespaldo = true;
        return null;
      },
    );
    expect(aplicadas, isEmpty);
    expect(pidioRespaldo, isFalse);
  });

  test('el código de barras es único solo entre productos activos', () {
    final db = abrirBaseDatos(enMemoria);
    addTearDown(db.close);
    aplicarMigraciones(db);
    void insertar(String id, int eliminado) => db.execute(
      "INSERT INTO productos (id, codigo, nombre, nombre_busqueda, categoria, precio, eliminado, creado, actualizado) "
      "VALUES (?, '750', 'X', 'x', 'c', 100, ?, 't', 't')",
      [id, eliminado],
    );
    insertar('p_1', 1);
    insertar('p_2', 0); // El eliminado no bloquea el código.
    expect(() => insertar('p_3', 0), throwsA(anything));
  });

  test('la base rechaza existencias negativas y precioCaja sin piezasPorCaja', () {
    final db = abrirBaseDatos(enMemoria);
    addTearDown(db.close);
    aplicarMigraciones(db);
    const sql =
        'INSERT INTO productos (id, codigo, nombre, nombre_busqueda, categoria, precio, '
        'precio_caja, piezas_por_caja, existencia_piezas, creado, actualizado) '
        "VALUES (?, ?, 'X', 'x', 'c', 100, ?, ?, ?, 't', 't')";
    expect(
      () => db.execute(sql, ['p_1', 'a', null, null, -1]),
      throwsA(anything),
    );
    expect(
      () => db.execute(sql, ['p_2', 'b', 500, null, 0]),
      throwsA(anything),
    );
  });

  test(
    'la base no permite dos turnos de caja abiertos ni cerrar sin corte',
    () {
      final db = abrirBaseDatos(enMemoria);
      addTearDown(db.close);
      aplicarMigraciones(db);
      const abrir =
          'INSERT INTO turnos (id, apertura, dia_negocio, fondo) '
          "VALUES (?, 't', '2026-10-24', 0)";
      db.execute(abrir, ['tur_1']);
      expect(() => db.execute(abrir, ['tur_2']), throwsA(anything));
      expect(
        () => db.execute("UPDATE turnos SET abierto = 0 WHERE id = 'tur_1'"),
        throwsA(anything),
        reason: 'un corte necesita cierre, esperado, contado y diferencia',
      );
    },
  );
}
