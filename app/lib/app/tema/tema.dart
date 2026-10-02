import 'package:flutter/material.dart';

import 'colores.dart';

const fuenteTexto = 'Barlow';
const fuenteTitulos = 'Barlow Condensed';

/// Radios del sistema, iguales al prototipo.
abstract final class Radios {
  static const control = 10.0;
  static const tarjeta = 16.0;
  static const imagen = 12.0;
}

ThemeData temaClaro() => _tema(ColoresAnaquel.claro, Brightness.light);

ThemeData temaOscuro() => _tema(ColoresAnaquel.oscuro, Brightness.dark);

ThemeData _tema(ColoresAnaquel c, Brightness brillo) {
  final esquema = ColorScheme(
    brightness: brillo,
    primary: c.lager,
    onPrimary: c.lagerTinta,
    primaryContainer: c.lagerSuave,
    onPrimaryContainer: c.tinta,
    secondary: c.vidrio,
    onSecondary: c.vidrioTinta,
    tertiary: c.verde,
    onTertiary: c.superficie,
    error: c.alerta,
    onError: Colors.white,
    errorContainer: c.alertaSuave,
    onErrorContainer: c.alerta,
    surface: c.superficie,
    onSurface: c.tinta,
    onSurfaceVariant: c.tinta2,
    surfaceContainerLowest: c.superficie,
    surfaceContainerLow: c.superficie2,
    surfaceContainer: c.superficie2,
    surfaceContainerHigh: c.superficie3,
    surfaceContainerHighest: c.superficie3,
    outline: c.linea,
    outlineVariant: c.linea,
    shadow: Colors.black,
    inverseSurface: c.tinta,
    onInverseSurface: c.fondo,
  );

  TextStyle titulo(double tamano, {FontWeight peso = FontWeight.w700}) =>
      TextStyle(
        fontFamily: fuenteTitulos,
        fontSize: tamano,
        fontWeight: peso,
        height: 1.05,
        color: c.tinta,
      );

  TextStyle cuerpo(
    double tamano, {
    FontWeight peso = FontWeight.w400,
    Color? color,
  }) => TextStyle(
    fontFamily: fuenteTexto,
    fontSize: tamano,
    fontWeight: peso,
    height: 1.4,
    color: color ?? c.tinta,
  );

  final textos = TextTheme(
    displayLarge: titulo(56),
    displayMedium: titulo(46),
    displaySmall: titulo(40),
    headlineLarge: titulo(34),
    headlineMedium: titulo(30),
    headlineSmall: titulo(26),
    titleLarge: titulo(24),
    titleMedium: cuerpo(17, peso: FontWeight.w600),
    titleSmall: cuerpo(15, peso: FontWeight.w600),
    bodyLarge: cuerpo(17),
    bodyMedium: cuerpo(15),
    bodySmall: cuerpo(14, color: c.tinta2),
    labelLarge: cuerpo(16, peso: FontWeight.w600),
    labelMedium: cuerpo(14, peso: FontWeight.w500),
    labelSmall: cuerpo(12, peso: FontWeight.w500, color: c.tinta2),
  );

  final forma = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(Radios.control),
  );
  const tamanoMinimo = Size(46, 46);
  const relleno = EdgeInsets.symmetric(horizontal: 16, vertical: 10);

  return ThemeData(
    useMaterial3: true,
    brightness: brillo,
    colorScheme: esquema,
    fontFamily: fuenteTexto,
    textTheme: textos,
    scaffoldBackgroundColor: c.fondo,
    canvasColor: c.fondo,
    dividerColor: c.linea,
    splashFactory: InkSparkle.splashFactory,
    extensions: [c],
    dividerTheme: DividerThemeData(color: c.linea, thickness: 1, space: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: c.superficie,
      foregroundColor: c.tinta,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: titulo(30),
      shape: Border(bottom: BorderSide(color: c.linea)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.lager,
        foregroundColor: c.lagerTinta,
        disabledBackgroundColor: c.superficie3,
        minimumSize: tamanoMinimo,
        padding: relleno,
        shape: forma,
        textStyle: textos.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: c.superficie,
        foregroundColor: c.tinta,
        side: BorderSide(color: c.linea),
        minimumSize: tamanoMinimo,
        padding: relleno,
        shape: forma,
        textStyle: textos.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.tinta,
        minimumSize: tamanoMinimo,
        shape: forma,
        textStyle: textos.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: c.tinta,
        minimumSize: tamanoMinimo,
        shape: forma,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.superficie,
      hintStyle: cuerpo(16, color: c.tinta2),
      labelStyle: cuerpo(16, color: c.tinta2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radios.control),
        borderSide: BorderSide(color: c.linea),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radios.control),
        borderSide: BorderSide(color: c.linea),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radios.control),
        borderSide: BorderSide(color: c.lager, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radios.control),
        borderSide: BorderSide(color: c.alerta),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: c.superficie,
      selectedColor: c.seleccion,
      side: BorderSide(color: c.linea),
      shape: const StadiumBorder(),
      labelStyle: cuerpo(15, peso: FontWeight.w500),
      secondaryLabelStyle: cuerpo(
        15,
        peso: FontWeight.w600,
        color: c.seleccionTinta,
      ),
      checkmarkColor: c.seleccionTinta,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    cardTheme: CardThemeData(
      color: c.superficie,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radios.tarjeta),
        side: BorderSide(color: c.linea),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.superficie,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radios.tarjeta),
      ),
      titleTextStyle: titulo(28),
      contentTextStyle: cuerpo(16, color: c.tinta2),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.superficie,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: c.linea,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Radios.tarjeta),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.tinta,
      contentTextStyle: cuerpo(15, color: c.fondo),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radios.control),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.superficie,
      surfaceTintColor: Colors.transparent,
      indicatorColor: c.lagerSuave,
      height: 70,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => cuerpo(
          13,
          peso: s.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w600,
          color: s.contains(WidgetState.selected) ? c.tinta : c.tinta2,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? c.tinta : c.tinta2,
        ),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: c.lager),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: c.lager,
      selectionColor: c.lager.withValues(alpha: 0.35),
      selectionHandleColor: c.lager,
    ),
  );
}
