import '../comun/errores.dart';
import '../comun/fechas.dart';
import '../db/repositorio_ajustes.dart';
import '../db/repositorio_productos.dart';
import '../db/repositorio_resurtido.dart';
import '../modelos/resurtido.dart';

const diasResurtidoPorOmision = 30;
const maxDiasResurtido = 90;
const coberturaResurtidoPorOmision = 7;
const maxCoberturaResurtido = 30;

/// Sugerencias de compra basadas en existencias actuales, mínimos y ventas
/// históricas del periodo.
class ServicioResurtido {
  ServicioResurtido({
    required this._repoProductos,
    required this._repoResurtido,
    required this._repoAjustes,
    this._reloj = relojSistema,
  });

  final RepositorioProductos _repoProductos;
  final RepositorioResurtido _repoResurtido;
  final RepositorioAjustes _repoAjustes;
  final Reloj _reloj;

  ReporteResurtido calcular({String? dias, String? cobertura}) {
    final ventana = dias == null ? diasResurtidoPorOmision : int.tryParse(dias);
    final errores = <String, String>{};
    if (ventana == null || ventana < 1 || ventana > maxDiasResurtido) {
      errores['dias'] = 'Debe ser un entero de 1 a $maxDiasResurtido';
    }
    final diasCobertura = cobertura == null
        ? coberturaResurtidoPorOmision
        : int.tryParse(cobertura);
    if (diasCobertura == null ||
        diasCobertura < 1 ||
        diasCobertura > maxCoberturaResurtido) {
      errores['cobertura'] = 'Debe ser un entero de 1 a $maxCoberturaResurtido';
    }
    if (errores.isNotEmpty) {
      throw ErrorApi.datosInvalidos(errores);
    }

    final v = ventana!;
    final c = diasCobertura!;
    final hoy = diaNegocio(_reloj(), _repoAjustes.zonaHoraria);
    final desde = diaNegocio(
      parsearFecha(hoy)!.subtract(Duration(days: v - 1)),
      Duration.zero,
    );

    final vendidas = _repoResurtido.piezasVendidasPorProducto(desde, hoy);
    final productos = _repoProductos.listar();

    final sugerencias = <SugerenciaResurtido>[];
    for (final p in productos) {
      final vendidasPeriodo = vendidas[p.id] ?? 0;
      // Redondeo entero hacia arriba de (vendidasPeriodo * c / v) sin doubles.
      final demandaCobertura = vendidasPeriodo == 0
          ? 0
          : (vendidasPeriodo * c + v - 1) ~/ v;
      final objetivo = demandaCobertura > p.minimo
          ? demandaCobertura
          : p.minimo;

      if (p.existenciaPiezas < objetivo || p.bajoMinimo) {
        final faltante = objetivo > p.existenciaPiezas
            ? objetivo - p.existenciaPiezas
            : 1;
        final ppc = p.piezasPorCaja ?? 0;
        final cajas = ppc > 1 ? (faltante + ppc - 1) ~/ ppc : 0;
        final urgencia = p.existenciaPiezas <= 0
            ? UrgenciaResurtido.agotado
            : (p.bajoMinimo
                  ? UrgenciaResurtido.bajoMinimo
                  : UrgenciaResurtido.porCubrir);
        sugerencias.add(
          SugerenciaResurtido(
            producto: p,
            vendidasPeriodo: vendidasPeriodo,
            sugeridoPiezas: faltante,
            sugeridoCajas: cajas,
            urgencia: urgencia,
          ),
        );
      }
    }

    sugerencias.sort((a, b) {
      final cmpUrgencia = _pesoUrgencia(a.urgencia)
          .compareTo(_pesoUrgencia(b.urgencia));
      if (cmpUrgencia != 0) return cmpUrgencia;
      final cmpVentas = b.vendidasPeriodo.compareTo(a.vendidasPeriodo);
      if (cmpVentas != 0) return cmpVentas;
      return a.producto.nombre.compareTo(b.producto.nombre);
    });

    return ReporteResurtido(
      dia: hoy,
      dias: v,
      cobertura: c,
      sugerencias: sugerencias,
    );
  }

  static int _pesoUrgencia(String urgencia) => switch (urgencia) {
    UrgenciaResurtido.agotado => 0,
    UrgenciaResurtido.bajoMinimo => 1,
    _ => 2,
  };
}
