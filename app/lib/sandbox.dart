import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/tema/tema.dart';
import 'core/config/configuracion.dart';
import 'features/inicio/elegir_modo.dart';
import 'features/inicio/pantalla_carga.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [preferenciasProvider.overrideWithValue(prefs)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: temaClaro(),
        darkTheme: temaOscuro(),
        themeMode: ThemeMode.light,
        home: const _CargaYModo(),
      ),
    ),
  );
}

class _CargaYModo extends StatefulWidget {
  const _CargaYModo();
  @override
  State<_CargaYModo> createState() => _CargaYModoState();
}

class _CargaYModoState extends State<_CargaYModo> {
  bool _carga = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _carga = false);
    });
  }

  @override
  Widget build(BuildContext context) =>
      _carga ? const PantallaCarga() : const ElegirModo();
}
