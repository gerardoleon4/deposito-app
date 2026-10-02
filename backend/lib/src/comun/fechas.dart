/// Reglas de fechas del proyecto (ver docs/ESTANDARES.md):
/// - Los instantes se guardan y viajan en UTC.
/// - El "día del negocio" se calcula SOLO con [diaNegocio], nunca con
///   `DateTime.now().day` ni con la zona del dispositivo.
library;

/// Fuente de la hora actual. Se inyecta para poder probar con fechas fijas.
typedef Reloj = DateTime Function();

DateTime relojSistema() => DateTime.now().toUtc();

/// Instante en ISO 8601 UTC sin milisegundos: `2026-10-02T18:30:00Z`.
String instanteIso(DateTime instante) {
  final u = instante.toUtc();
  return '${_fecha(u.year, u.month, u.day)}T${_dos(u.hour)}:${_dos(u.minute)}:${_dos(u.second)}Z';
}

/// Día de calendario (`AAAA-MM-DD`) al que pertenece [instante] en la zona
/// del negocio, dada como desfase respecto a UTC (México centro: -6 h).
///
/// Ejemplo: una venta a las 23:59 del 2 de octubre en el local es
/// `2026-10-03T05:59:00Z`, y su día de negocio es `2026-10-02`.
String diaNegocio(DateTime instante, Duration desfase) {
  final local = instante.toUtc().add(desfase);
  return _fecha(local.year, local.month, local.day);
}

/// Rango UTC `[inicio, fin)` que cubre el día de negocio [dia].
({DateTime inicio, DateTime fin}) rangoDiaNegocio(
  String dia,
  Duration desfase,
) {
  final f = parsearFecha(dia);
  if (f == null) throw ArgumentError.value(dia, 'dia', 'No es AAAA-MM-DD');
  final inicio = DateTime.utc(f.year, f.month, f.day).subtract(desfase);
  return (inicio: inicio, fin: inicio.add(const Duration(days: 1)));
}

/// Interpreta `AAAA-MM-DD` y comprueba que la fecha exista (no 2026-02-30).
DateTime? parsearFecha(String texto) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(texto);
  if (m == null) return null;
  final a = int.parse(m[1]!), mes = int.parse(m[2]!), d = int.parse(m[3]!);
  final f = DateTime.utc(a, mes, d);
  if (f.year != a || f.month != mes || f.day != d) return null;
  return f;
}

/// Interpreta un desfase `-06:00` / `+05:30`.
Duration? parsearDesfase(String texto) {
  final m = RegExp(r'^([+-])(\d{2}):(\d{2})$').firstMatch(texto);
  if (m == null) return null;
  final minutos = int.parse(m[2]!) * 60 + int.parse(m[3]!);
  return Duration(minutes: m[1] == '-' ? -minutos : minutos);
}

String _fecha(int a, int m, int d) =>
    '${a.toString().padLeft(4, '0')}-${_dos(m)}-${_dos(d)}';

String _dos(int n) => n.toString().padLeft(2, '0');
