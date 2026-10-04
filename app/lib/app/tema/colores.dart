import 'package:flutter/material.dart';

/// Paleta de Anaquel, tomada del prototipo (docs/prototipo).
///
/// - vidrio: café de botella, para la barra lateral y encabezados.
/// - lager: ámbar de cerveza, el acento de acciones principales.
/// - verde / alerta / azul: estados.
///
/// Se lee con `context.colores` (ver [ColoresContexto]).
@immutable
class ColoresAnaquel extends ThemeExtension<ColoresAnaquel> {
  const ColoresAnaquel({
    required this.fondo,
    required this.superficie,
    required this.superficie2,
    required this.superficie3,
    required this.tinta,
    required this.tinta2,
    required this.linea,
    required this.vidrio,
    required this.vidrio2,
    required this.vidrioTinta,
    required this.vidrioTinta2,
    required this.lager,
    required this.lagerTinta,
    required this.lagerSuave,
    required this.verde,
    required this.verdeSuave,
    required this.alerta,
    required this.alertaSuave,
    required this.azul,
    required this.seleccion,
    required this.seleccionTinta,
    required this.fondoCerveza,
    required this.fondoRefresco,
    required this.fondoBotana,
    required this.fondoHielo,
    required this.fondoOtro,
    required this.sombra,
  });

  final Color fondo;
  final Color superficie;
  final Color superficie2;
  final Color superficie3;
  final Color tinta;
  final Color tinta2;
  final Color linea;
  final Color vidrio;
  final Color vidrio2;
  final Color vidrioTinta;
  final Color vidrioTinta2;
  final Color lager;
  final Color lagerTinta;
  final Color lagerSuave;
  final Color verde;
  final Color verdeSuave;
  final Color alerta;
  final Color alertaSuave;
  final Color azul;
  final Color seleccion;
  final Color seleccionTinta;
  final Color fondoCerveza;
  final Color fondoRefresco;
  final Color fondoBotana;
  final Color fondoHielo;
  final Color fondoOtro;
  final List<BoxShadow> sombra;

  static const claro = ColoresAnaquel(
    fondo: Color(0xFFFFFFFF),
    superficie: Color(0xFFFFFFFF),
    superficie2: Color(0xFFF9FAFB),
    superficie3: Color(0xFFF4F8FF),
    tinta: Color(0xFF111827),
    tinta2: Color(0xFF1F2937),
    linea: Color(0xFFE5E7EB),
    vidrio: Color(0xFF1F2937),
    vidrio2: Color(0xFF111827),
    vidrioTinta: Color(0xFFFFFFFF),
    vidrioTinta2: Color(0xFF9CA3AF),
    lager: Color(0xFF4285F4),
    lagerTinta: Color(0xFFFFFFFF),
    lagerSuave: Color(0xFFF4F8FF),
    verde: Color(0xFF15803D),
    verdeSuave: Color(0xFFF0FDF4),
    alerta: Color(0xFFEF4444),
    alertaSuave: Color(0xFFFEF2F2),
    azul: Color(0xFF4285F4),
    seleccion: Color(0xFF4285F4),
    seleccionTinta: Color(0xFFFFFFFF),
    fondoCerveza: Color(0xFFF4F8FF),
    fondoRefresco: Color(0xFFFEF2F2),
    fondoBotana: Color(0xFFFFFBEB),
    fondoHielo: Color(0xFFF0FDF4),
    fondoOtro: Color(0xFFF9FAFB),
    sombra: [
      BoxShadow(
        color: Color(0x12000000), // 7% negro
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
    ],
  );

  static const oscuro = ColoresAnaquel(
    fondo: Color(0xFF111827),
    superficie: Color(0xFF1F2937),
    superficie2: Color(0xFF374151),
    superficie3: Color(0xFF4B5563),
    tinta: Color(0xFFF9FAFB),
    tinta2: Color(0xFFE5E7EB),
    linea: Color(0xFF374151),
    vidrio: Color(0xFF111827),
    vidrio2: Color(0xFF1F2937),
    vidrioTinta: Color(0xFFFFFFFF),
    vidrioTinta2: Color(0xFF9CA3AF),
    lager: Color(0xFF4285F4),
    lagerTinta: Color(0xFFFFFFFF),
    lagerSuave: Color(0xFF1E3A8A),
    verde: Color(0xFF22C55E),
    verdeSuave: Color(0xFF14532D),
    alerta: Color(0xFFEF4444),
    alertaSuave: Color(0xFF7F1D1D),
    azul: Color(0xFF60A5FA),
    seleccion: Color(0xFF4285F4),
    seleccionTinta: Color(0xFFFFFFFF),
    fondoCerveza: Color(0xFF1E3A8A),
    fondoRefresco: Color(0xFF7F1D1D),
    fondoBotana: Color(0xFF78350F),
    fondoHielo: Color(0xFF14532D),
    fondoOtro: Color(0xFF374151),
    sombra: [
      BoxShadow(
        color: Color(0x3D000000), // 24% negro
        blurRadius: 60,
        offset: Offset(0, 24),
      ),
    ],
  );

  /// Fondo de la ilustración de un producto según su categoría.
  Color fondoCategoria(String categoria) => switch (categoria) {
    'cerveza' => fondoCerveza,
    'refresco' => fondoRefresco,
    'botana' => fondoBotana,
    'hielo' => fondoHielo,
    _ => fondoOtro,
  };

  @override
  ColoresAnaquel copyWith() => this;

  @override
  ColoresAnaquel lerp(ColoresAnaquel? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}

extension ColoresContexto on BuildContext {
  ColoresAnaquel get colores => Theme.of(this).extension<ColoresAnaquel>()!;
}
