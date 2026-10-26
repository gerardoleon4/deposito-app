import '../comun/fechas.dart';
import 'producto.dart';

/// Días hacia adelante que se revisan las caducidades si no se pide otro.
const diasAlertaCaducidad = 15;

/// Máximo de días que acepta `GET /api/v1/alertas?dias=`.
const maxDiasAlertaCaducidad = 365;

/// Tipos de alerta, en el orden en que se listan.
abstract final class TiposAlerta {
  static const agotado = 'agotado';
  static const pocoStock = 'poco_stock';
  static const caducado = 'caducado';
  static const porCaducar = 'por_caducar';

  static const orden = [agotado, pocoStock, caducado, porCaducar];
}

/// Un producto por resurtir o por revisar (`GET /api/v1/alertas`).
class Alerta {
  const Alerta({
    required this.tipo,
    required this.producto,
    this.diasParaCaducar,
  });

  /// Uno de [TiposAlerta].
  final String tipo;
  final Producto producto;

  /// Días de hoy a la caducidad: `0` caduca hoy, negativo ya caducó. `null`
  /// en las alertas de existencia.
  final int? diasParaCaducar;

  bool get esDeExistencia =>
      tipo == TiposAlerta.agotado || tipo == TiposAlerta.pocoStock;

  /// Alerta de existencia de [p]: `agotado`, `poco_stock` o `null`.
  static String? tipoExistencia(Producto p) {
    if (!p.bajoMinimo) return null;
    return p.existenciaPiezas == 0
        ? TiposAlerta.agotado
        : TiposAlerta.pocoStock;
  }

  factory Alerta.fromJson(Map<String, Object?> j) => Alerta(
    tipo: j['tipo'] as String,
    producto: Producto.fromJson((j['producto'] as Map).cast()),
    diasParaCaducar: j['diasParaCaducar'] as int?,
  );

  Map<String, Object?> toJson() => {
    'tipo': tipo,
    'producto': producto.toJson(),
    'diasParaCaducar': diasParaCaducar,
  };
}

/// Alertas de [productos] para el día de negocio [hoy] (`AAAA-MM-DD`),
/// revisando caducidades hasta [dias] días adelante, ya ordenadas como dice
/// docs/API.md. La usan el servidor y la API falsa de la app.
List<Alerta> calcularAlertas(
  Iterable<Producto> productos, {
  required String hoy,
  required int dias,
}) {
  final dia = parsearFecha(hoy) ?? (throw ArgumentError.value(hoy, 'hoy'));
  final alertas = <Alerta>[];
  for (final p in productos) {
    final tipo = Alerta.tipoExistencia(p);
    if (tipo != null) alertas.add(Alerta(tipo: tipo, producto: p));

    final caducidad = p.caducidad == null ? null : parsearFecha(p.caducidad!);
    if (caducidad == null || p.existenciaPiezas == 0) continue;
    final faltan = caducidad.difference(dia).inDays;
    if (faltan > dias) continue;
    alertas.add(
      Alerta(
        tipo: faltan < 0 ? TiposAlerta.caducado : TiposAlerta.porCaducar,
        producto: p,
        diasParaCaducar: faltan,
      ),
    );
  }
  alertas.sort(_comparar);
  return alertas;
}

int _comparar(Alerta a, Alerta b) {
  final porTipo = TiposAlerta.orden
      .indexOf(a.tipo)
      .compareTo(TiposAlerta.orden.indexOf(b.tipo));
  if (porTipo != 0) return porTipo;
  final porUrgencia = a.tipo == TiposAlerta.pocoStock
      // Menos existencia respecto al mínimo primero: a/ma < b/mb sin dividir.
      ? (a.producto.existenciaPiezas * b.producto.minimo).compareTo(
          b.producto.existenciaPiezas * a.producto.minimo,
        )
      : (a.diasParaCaducar ?? 0).compareTo(b.diasParaCaducar ?? 0);
  if (porUrgencia != 0) return porUrgencia;
  return a.producto.nombre.compareTo(b.producto.nombre);
}
