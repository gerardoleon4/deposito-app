import 'producto.dart';

abstract final class UrgenciaResurtido {
  static const agotado = 'agotado';
  static const bajoMinimo = 'bajo_minimo';
  static const porCubrir = 'por_cubrir';
}

/// Producto que conviene pedir al proveedor según su existencia, mínimo y
/// ritmo de ventas.
class SugerenciaResurtido {
  const SugerenciaResurtido({
    required this.producto,
    required this.vendidasPeriodo,
    required this.sugeridoPiezas,
    required this.sugeridoCajas,
    required this.urgencia,
  });

  final Producto producto;
  final int vendidasPeriodo;
  final int sugeridoPiezas;
  final int sugeridoCajas;
  final String urgencia;

  Map<String, Object?> toJson() => {
    'producto': producto.toJson(),
    'vendidasPeriodo': vendidasPeriodo,
    'sugeridoPiezas': sugeridoPiezas,
    'sugeridoCajas': sugeridoCajas,
    'urgencia': urgencia,
  };

  factory SugerenciaResurtido.fromJson(Map<String, Object?> json) =>
      SugerenciaResurtido(
        producto: Producto.fromJson(json['producto']! as Map<String, Object?>),
        vendidasPeriodo: json['vendidasPeriodo']! as int,
        sugeridoPiezas: json['sugeridoPiezas']! as int,
        sugeridoCajas: json['sugeridoCajas']! as int,
        urgencia: json['urgencia']! as String,
      );
}

class ReporteResurtido {
  const ReporteResurtido({
    required this.dia,
    required this.dias,
    required this.cobertura,
    required this.sugerencias,
  });

  final String dia;
  final int dias;
  final int cobertura;
  final List<SugerenciaResurtido> sugerencias;

  Map<String, Object?> toJson() => {
    'dia': dia,
    'dias': dias,
    'cobertura': cobertura,
    'sugerencias': [for (final s in sugerencias) s.toJson()],
  };

  factory ReporteResurtido.fromJson(Map<String, Object?> json) =>
      ReporteResurtido(
        dia: json['dia']! as String,
        dias: json['dias']! as int,
        cobertura: json['cobertura']! as int,
        sugerencias: [
          for (final item in json['sugerencias']! as List<Object?>)
            SugerenciaResurtido.fromJson(item! as Map<String, Object?>),
        ],
      );
}
