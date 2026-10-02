import '../comun/fechas.dart';
import '../servicios/servicio_productos.dart';

/// Productos del prototipo (docs/prototipo) para demos y para que el front
/// pruebe con datos con forma real. Precios en centavos; "-" es vacío.
///
/// Columnas: código | nombre | categoría | presentación | precio |
/// precio caja | piezas por caja | existencia | mínimo | envase |
/// días para caducar
const _tabla = '''
7501064191015|Victoria Mega|cerveza|Mega 1.2 L|4200|48000|12|66|36|mega|120
7501064191022|Corona Mega|cerveza|Mega 1.2 L|4400|50000|12|30|36|mega|95
7501064191039|Modelo Especial|cerveza|Media 355 ml|2400|54000|24|120|48|media|40
7501064191046|Corona Cuarto|cerveza|Cuarto 210 ml|1700|38000|24|200|48|cuarto|20
7501064191053|Indio Mega|cerveza|Mega 1.2 L|4000|46000|12|14|24|mega|6
7501064191060|Pacífico|cerveza|Media 355 ml|2500|56000|24|72|48|media|60
7502000000017|Hielo en bolsa|hielo|Bolsa 5 kg|3500|-|-|18|10|-|-
7502000000024|Coca-Cola|refresco|Botella 600 ml|2200|-|-|40|24|-|150
7502000000031|Agua mineral|refresco|Botella 355 ml|1600|-|-|8|12|-|200
7502000000048|Papas adobadas|botana|Bolsa 45 g|2000|-|-|25|20|-|12
7502000000055|Cacahuates japoneses|botana|Bolsa 100 g|1800|-|-|6|15|-|45
''';

/// Carga los productos de ejemplo. Las caducidades se calculan desde hoy en
/// la zona del negocio para que siempre haya alertas que mostrar.
void cargarDatosEjemplo(
  ServicioProductos productos, {
  required Duration zonaHoraria,
  Reloj reloj = relojSistema,
}) {
  final hoy = reloj();
  for (final linea in _tabla.trim().split('\n')) {
    final c = [for (final x in linea.split('|')) x == '-' ? null : x];
    int? n(int i) => c[i] == null ? null : int.parse(c[i]!);
    productos.crear({
      'codigo': c[0],
      'nombre': c[1],
      'categoria': c[2],
      'presentacion': c[3],
      'precio': n(4),
      'precioCaja': n(5),
      'piezasPorCaja': n(6),
      'existenciaPiezas': n(7),
      'minimo': n(8),
      'envase': c[9],
      'caducidad': n(10) == null
          ? null
          : diaNegocio(hoy.add(Duration(days: n(10)!)), zonaHoraria),
    }, origen: 'Datos de ejemplo');
  }
}
