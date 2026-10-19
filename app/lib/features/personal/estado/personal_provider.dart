import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/proveedores.dart';

/// El personal del depósito, activos e inactivos, por nombre.
final usuariosProvider = AsyncNotifierProvider<UsuariosNotifier, List<Usuario>>(
  UsuariosNotifier.new,
  retry: (_, _) => null,
);

class UsuariosNotifier extends AsyncNotifier<List<Usuario>> {
  @override
  Future<List<Usuario>> build() async =>
      (await ref.watch(apiProvider.future)).listarUsuarios();

  Future<void> refrescar() async {
    final api = await ref.read(apiProvider.future);
    state = await AsyncValue.guard(api.listarUsuarios);
  }

  /// Los errores llegan como `FalloApi`.
  Future<Usuario> crear({
    required String nombre,
    required String rol,
    required String pin,
    String? pinAutoriza,
  }) async {
    final api = await ref.read(apiProvider.future);
    final u = await api.crearUsuario(
      nombre: nombre,
      rol: rol,
      pin: pin,
      pinAutoriza: pinAutoriza,
    );
    await refrescar();
    return u;
  }

  Future<Usuario> editar(
    String id, {
    String? nombre,
    String? rol,
    bool? activo,
    String? pin,
    required String pinAutoriza,
  }) async {
    final api = await ref.read(apiProvider.future);
    final u = await api.editarUsuario(
      id,
      nombre: nombre,
      rol: rol,
      activo: activo,
      pin: pin,
      pinAutoriza: pinAutoriza,
    );
    await refrescar();
    return u;
  }
}

/// Quién está en la caja (inició turno con su PIN). Se guarda en las
/// ventas, la apertura y el corte. `null` mientras nadie entra o si no hay
/// personal registrado.
final usuarioActualProvider = NotifierProvider<UsuarioActual, Usuario?>(
  UsuarioActual.new,
);

class UsuarioActual extends Notifier<Usuario?> {
  @override
  Usuario? build() => null;

  void entrar(Usuario u) => state = u;

  void salir() => state = null;
}

/// La cuenta maestra que se capturó al configurar la caja. Se crea en el
/// servidor en cuanto arranca (antes no existe).
typedef CuentaMaestra = ({String negocio, String nombre, String pin});

final cuentaMaestraPendienteProvider =
    NotifierProvider<CuentaMaestraPendiente, CuentaMaestra?>(
      CuentaMaestraPendiente.new,
    );

class CuentaMaestraPendiente extends Notifier<CuentaMaestra?> {
  @override
  CuentaMaestra? build() => null;

  void guardar(CuentaMaestra cuenta) => state = cuenta;

  /// Crea al dueño y el nombre del negocio si la base no tiene personal, y
  /// deja al dueño en la caja. Si ya había personal (una base existente), no
  /// toca nada.
  Future<void> aplicar() async {
    final cuenta = state;
    if (cuenta == null) return;
    final api = await ref.read(apiProvider.future);
    if ((await api.listarUsuarios()).isEmpty) {
      final dueno = await api.crearUsuario(
        nombre: cuenta.nombre,
        rol: 'dueno',
        pin: cuenta.pin,
      );
      await api.guardarAjustes({'nombreNegocio': cuenta.negocio});
      ref.read(usuarioActualProvider.notifier).entrar(dueno);
    }
    state = null;
    ref.invalidate(usuariosProvider);
  }
}

/// Etiqueta del rol: `dueno` → `Dueño`.
String etiquetaRol(String rol) => switch (rol) {
  'dueno' => 'Dueño',
  'gerente' => 'Gerente',
  _ => 'Cajero',
};

/// `Ana Martínez` → `AM`.
String inicialesDe(String nombre) => nombre
    .split(' ')
    .where((p) => p.isNotEmpty)
    .take(2)
    .map((p) => p[0].toUpperCase())
    .join();
