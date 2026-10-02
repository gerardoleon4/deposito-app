import 'package:deposito_backend/src/comun/fechas.dart';
import 'package:test/test.dart';

void main() {
  const mexico = Duration(hours: -6);

  group('diaNegocio', () {
    test(
      'una venta a las 23:59 del local cuenta en ese día, aunque en UTC ya sea el siguiente',
      () {
        // 2 de octubre 23:59 en México = 3 de octubre 05:59 UTC.
        expect(
          diaNegocio(DateTime.utc(2026, 10, 3, 5, 59), mexico),
          '2026-10-02',
        );
      },
    );

    test('una venta a las 00:01 del local cuenta en el día nuevo', () {
      expect(diaNegocio(DateTime.utc(2026, 10, 3, 6, 1), mexico), '2026-10-03');
    });

    test('ignora la zona del dispositivo: usa el instante en UTC', () {
      final local = DateTime.utc(2026, 10, 3, 5, 59).toLocal();
      expect(diaNegocio(local, mexico), '2026-10-02');
    });

    test('cambio de año', () {
      expect(diaNegocio(DateTime.utc(2027, 1, 1, 5, 0), mexico), '2026-12-31');
    });
  });

  test('rangoDiaNegocio cubre de medianoche a medianoche local en UTC', () {
    final r = rangoDiaNegocio('2026-10-02', mexico);
    expect(r.inicio, DateTime.utc(2026, 10, 2, 6));
    expect(r.fin, DateTime.utc(2026, 10, 3, 6));
    expect(diaNegocio(r.inicio, mexico), '2026-10-02');
    expect(
      diaNegocio(r.fin.subtract(const Duration(seconds: 1)), mexico),
      '2026-10-02',
    );
  });

  test('instanteIso es UTC sin milisegundos', () {
    expect(
      instanteIso(DateTime.utc(2026, 10, 2, 18, 30, 0, 456)),
      '2026-10-02T18:30:00Z',
    );
  });

  test('parsearFecha rechaza fechas que no existen', () {
    expect(parsearFecha('2026-02-28'), isNotNull);
    expect(parsearFecha('2026-02-30'), isNull);
    expect(parsearFecha('2026-13-01'), isNull);
    expect(parsearFecha('2026-1-01'), isNull);
  });

  test('parsearDesfase', () {
    expect(parsearDesfase('-06:00'), const Duration(hours: -6));
    expect(parsearDesfase('+05:30'), const Duration(hours: 5, minutes: 30));
    expect(parsearDesfase('-6'), isNull);
  });
}
