/// Formatos de envase retornable.
const formatosEnvase = {'mega', 'media', 'cuarto'};

/// Producto tal como lo describe docs/API.md. Lo usan el backend y la app,
/// así los campos nunca se desincronizan.
class Producto {
  const Producto({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.categoria,
    this.presentacion,
    required this.precio,
    this.precioCaja,
    this.piezasPorCaja,
    required this.existenciaPiezas,
    required this.minimo,
    this.envase,
    this.caducidad,
    this.foto,
    required this.creado,
    required this.actualizado,
  });

  final String id;
  final String codigo;
  final String nombre;
  final String categoria;
  final String? presentacion;

  /// Centavos por pieza.
  final int precio;

  /// Centavos por caja; va junto con [piezasPorCaja].
  final int? precioCaja;
  final int? piezasPorCaja;
  final int existenciaPiezas;
  final int minimo;

  /// `mega`, `media`, `cuarto` o `null`.
  final String? envase;

  /// `AAAA-MM-DD`.
  final String? caducidad;
  final String? foto;

  /// ISO 8601 UTC.
  final String creado;
  final String actualizado;

  bool get seVendePorCaja => piezasPorCaja != null;

  bool get bajoMinimo => existenciaPiezas < minimo;

  factory Producto.fromJson(Map<String, Object?> j) => Producto(
    id: j['id'] as String,
    codigo: j['codigo'] as String,
    nombre: j['nombre'] as String,
    categoria: j['categoria'] as String,
    presentacion: j['presentacion'] as String?,
    precio: j['precio'] as int,
    precioCaja: j['precioCaja'] as int?,
    piezasPorCaja: j['piezasPorCaja'] as int?,
    existenciaPiezas: j['existenciaPiezas'] as int,
    minimo: j['minimo'] as int,
    envase: j['envase'] as String?,
    caducidad: j['caducidad'] as String?,
    foto: j['foto'] as String?,
    creado: j['creado'] as String,
    actualizado: j['actualizado'] as String,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'codigo': codigo,
    'nombre': nombre,
    'categoria': categoria,
    'presentacion': presentacion,
    'precio': precio,
    'precioCaja': precioCaja,
    'piezasPorCaja': piezasPorCaja,
    'existenciaPiezas': existenciaPiezas,
    'minimo': minimo,
    'envase': envase,
    'caducidad': caducidad,
    'foto': foto,
    'creado': creado,
    'actualizado': actualizado,
  };
}
