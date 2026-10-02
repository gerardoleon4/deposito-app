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
    fondo: Color(0xFFE4ECEE),
    superficie: Color(0xFFFFFFFF),
    superficie2: Color(0xFFF1F5F6),
    superficie3: Color(0xFFE7EEF0),
    tinta: Color(0xFF1B2226),
    tinta2: Color(0xFF56646B),
    linea: Color(0xFFCFDADE),
    vidrio: Color(0xFF3A2518),
    vidrio2: Color(0xFF4E3322),
    vidrioTinta: Color(0xFFF6E7D2),
    vidrioTinta2: Color(0xFFC9AE8E),
    lager: Color(0xFFF0A500),
    lagerTinta: Color(0xFF2A1A00),
    lagerSuave: Color(0xFFFFF1CC),
    verde: Color(0xFF2E6B4E),
    verdeSuave: Color(0xFFDDEFE5),
    alerta: Color(0xFFB8322A),
    alertaSuave: Color(0xFFF9E0DD),
    azul: Color(0xFF2F6690),
    seleccion: Color(0xFF3A2518),
    seleccionTinta: Color(0xFFF6E7D2),
    fondoCerveza: Color(0xFFF5E3C3),
    fondoRefresco: Color(0xFFF4DEDC),
    fondoBotana: Color(0xFFF7E6C8),
    fondoHielo: Color(0xFFD9ECF4),
    fondoOtro: Color(0xFFE5E9EA),
    sombra: [
      BoxShadow(color: Color(0x0F142328), blurRadius: 2, offset: Offset(0, 1)),
      BoxShadow(
        color: Color(0x2E142328),
        blurRadius: 24,
        spreadRadius: -12,
        offset: Offset(0, 8),
      ),
    ],
  );

  static const oscuro = ColoresAnaquel(
    fondo: Color(0xFF0F171A),
    superficie: Color(0xFF172226),
    superficie2: Color(0xFF1F2C31),
    superficie3: Color(0xFF26353B),
    tinta: Color(0xFFE7EEF0),
    tinta2: Color(0xFF9AAAB0),
    linea: Color(0xFF2E3E44),
    vidrio: Color(0xFF24160D),
    vidrio2: Color(0xFF352216),
    vidrioTinta: Color(0xFFF3E1C7),
    vidrioTinta2: Color(0xFFB89A78),
    lager: Color(0xFFF4B324),
    lagerTinta: Color(0xFF2A1A00),
    lagerSuave: Color(0xFF3A2C0C),
    verde: Color(0xFF5BB287),
    verdeSuave: Color(0xFF193428),
    alerta: Color(0xFFE8645B),
    alertaSuave: Color(0xFF3A1A18),
    azul: Color(0xFF6FA8D6),
    seleccion: Color(0xFFF4B324),
    seleccionTinta: Color(0xFF2A1A00),
    fondoCerveza: Color(0xFF3A2E1C),
    fondoRefresco: Color(0xFF3A2322),
    fondoBotana: Color(0xFF3B301E),
    fondoHielo: Color(0xFF1D3440),
    fondoOtro: Color(0xFF2A3336),
    sombra: [
      BoxShadow(color: Color(0x4D000000), blurRadius: 2, offset: Offset(0, 1)),
      BoxShadow(
        color: Color(0x99000000),
        blurRadius: 28,
        spreadRadius: -14,
        offset: Offset(0, 10),
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
