// Revisa que nadie cambie las versiones fijas del proyecto para que compile
// con un Flutter viejo (lo que pasó en el PR #7 con sqlite3 2.x).
//
// Uso: dart .github/scripts/verificar_versiones.dart [rama_base]
// Con rama_base (por ejemplo origin/develop) también rechaza dependencias
// que bajen de versión respecto a esa rama.
//
// La versión fija sale de ci.yml (setup-dart y flutter-version). Para subir
// de versión se cambia ahí, en los pubspec.yaml y en AGENTS.md; si falta
// alguno, este script dice cuál.
import 'dart:io';

const ci = '.github/workflows/ci.yml';
const agentes = 'AGENTS.md';
const pubspecs = ['backend/pubspec.yaml', 'app/pubspec.yaml'];

void main(List<String> args) {
  final base = args.isEmpty ? null : args.first;
  final errores = <String>[];

  final textoCi = File(ci).readAsStringSync();
  final dart = RegExp(r'sdk:\s*(\d+\.\d+\.\d+)').firstMatch(textoCi)?.group(1);
  final flutter = RegExp(r'flutter-version:\s*(\d+\.\d+\.\d+)')
      .firstMatch(textoCi)
      ?.group(1);
  if (dart == null || flutter == null) {
    stderr.writeln('$ci: no encontré la versión de Dart o de Flutter.');
    exit(1);
  }
  final sdkFijo = '^$dart';

  final textoAgentes = File(agentes).readAsStringSync();
  if (!textoAgentes.contains('Flutter $flutter, Dart $dart')) {
    errores.add(
      '$agentes: debe decir "Flutter $flutter, Dart $dart" como $ci.',
    );
  }

  for (final ruta in pubspecs) {
    final texto = File(ruta).readAsStringSync();

    final sdk = RegExp(
      r'^environment:\s*\n\s+sdk:\s*(.+)$',
      multiLine: true,
    ).firstMatch(texto)?.group(1)?.trim().replaceAll(RegExp(r'''['"]'''), '');
    if (sdk != sdkFijo) {
      errores.add('$ruta: el SDK debe ser $sdkFijo y dice "$sdk".');
    }

    final actuales = dependencias(texto);
    actuales.forEach((nombre, restriccion) {
      if (restriccion == 'any') {
        errores.add(
          '$ruta: "$nombre: any" no está permitido; fija una versión.',
        );
      }
    });

    if (base != null) {
      final anterior = textoEnRama(base, ruta);
      if (anterior == null) continue;
      dependencias(anterior).forEach((nombre, antes) {
        final ahora = actuales[nombre];
        if (ahora == null) return;
        final vAntes = version(antes), vAhora = version(ahora);
        if (vAntes != null && vAhora != null && compara(vAhora, vAntes) < 0) {
          errores.add('$ruta: $nombre bajó de "$antes" a "$ahora".');
        }
      });
    }
  }

  if (errores.isEmpty) {
    stdout.writeln('Versiones correctas.');
    return;
  }
  stderr
    ..writeln('Hay versiones que no coinciden con las fijas del proyecto:\n')
    ..writeln(errores.map((e) => '  - $e').join('\n'))
    ..writeln(
      '\nSi no compila en tu máquina, actualiza Flutter a la versión de '
      'AGENTS.md en lugar de bajar versiones. Si de verdad hay que cambiarlas, '
      'se acuerda con el equipo y se cambia en el mismo PR en $ci, '
      'los pubspec.yaml y $agentes.',
    );
  exit(1);
}

/// Dependencias con su restricción escrita en una línea (`  nombre: ^1.2.3`).
/// Las que usan `path:` o `sdk:` en líneas aparte no tienen versión y se omiten.
Map<String, String> dependencias(String texto) {
  final resultado = <String, String>{};
  String? seccion;
  for (final linea in texto.split('\n')) {
    final encabezado = RegExp(r'^(\w+):').firstMatch(linea);
    if (encabezado != null) {
      seccion = encabezado.group(1);
      continue;
    }
    if (seccion != 'dependencies' && seccion != 'dev_dependencies') continue;
    final m = RegExp(r'^  (\w+):\s*(\S.*)$').firstMatch(linea);
    if (m != null) {
      resultado[m.group(1)!] = m
          .group(2)!
          .trim()
          .replaceAll(RegExp(r'''['"]'''), '');
    }
  }
  return resultado;
}

/// Primera versión x.y.z que aparece en la restricción (`^3.6.0`, `>=2.0.0 <3.0.0`).
List<int>? version(String restriccion) {
  final m = RegExp(r'(\d+)\.(\d+)\.(\d+)').firstMatch(restriccion);
  return m == null
      ? null
      : [for (var i = 1; i <= 3; i++) int.parse(m.group(i)!)];
}

int compara(List<int> a, List<int> b) {
  for (var i = 0; i < 3; i++) {
    if (a[i] != b[i]) return a[i].compareTo(b[i]);
  }
  return 0;
}

String? textoEnRama(String rama, String ruta) {
  final r = Process.runSync('git', ['show', '$rama:$ruta']);
  return r.exitCode == 0 ? r.stdout as String : null;
}
