import 'package:deposito_backend/deposito_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/proveedores.dart';
import '../../../core/tiempo_real/tiempo_real.dart';

/// Catálogo completo, al día con el WebSocket:
/// - `producto.actualizado` lo agrega o reemplaza sin volver a pedir todo.
/// - Al reconectarse vuelve a pedir la lista completa (regla del contrato).
final productosProvider =
    AsyncNotifierProvider<ProductosNotifier, List<Producto>>(
      ProductosNotifier.new,
      retry: (_, _) => null,
    );

class ProductosNotifier extends AsyncNotifier<List<Producto>> {
  @override
  Future<List<Producto>> build() async {
    final api = await ref.watch(apiProvider.future);
    ref.listen(eventosProvider, (_, siguiente) {
      final evento = siguiente.value;
      if (evento != null) _alEvento(evento);
    });
    return _ordenar(await api.listarProductos());
  }

  /// Vuelve a pedir la lista sin mostrar "cargando" (jalar para refrescar).
  Future<void> refrescar() async {
    final api = await ref.read(apiProvider.future);
    state = await AsyncValue.guard(
      () async => _ordenar(await api.listarProductos()),
    );
  }

  void _alEvento(Evento e) {
    switch (e.tipo) {
      case TiposEvento.productoActualizado:
        final p = Producto.fromJson((e.datos['producto'] as Map).cast());
        final actual = state.value;
        if (actual == null) return;
        state = AsyncData(_ordenar([...actual.where((x) => x.id != p.id), p]));
      case eventoReconectado:
        refrescar();
    }
  }

  static List<Producto> _ordenar(List<Producto> lista) => lista
    ..sort(
      (a, b) =>
          normalizarBusqueda(a.nombre).compareTo(normalizarBusqueda(b.nombre)),
    );
}

/// Filtro local: el catálogo de un depósito cabe completo en memoria.
List<Producto> filtrarProductos(
  List<Producto> lista, {
  String busqueda = '',
  String? categoria,
}) {
  final q = normalizarBusqueda(busqueda);
  return [
    for (final p in lista)
      if ((categoria == null || p.categoria == categoria) &&
          (q.isEmpty ||
              normalizarBusqueda(p.nombre).contains(q) ||
              p.codigo.contains(q)))
        p,
  ];
}

/// Categorías presentes, en orden alfabético.
List<String> categoriasDe(List<Producto> lista) =>
    {for (final p in lista) p.categoria}.toList()..sort();

/// Producto con ese código de barras, o `null`.
Producto? porCodigo(List<Producto> lista, String codigo) {
  final c = codigo.trim();
  for (final p in lista) {
    if (p.codigo == c) return p;
  }
  return null;
}
