import '../comun/errores.dart';
import '../comun/fechas.dart';
import '../db/repositorio_ajustes.dart';
import '../db/repositorio_productos.dart';
import '../modelos/alerta.dart';
import '../modelos/evento.dart';
import '../modelos/producto.dart';
import '../ws/hub.dart';

/// Alertas de existencia y caducidad, y el aviso `alerta.nueva`.
///
/// Recuerda en memoria qué alerta de existencia tiene cada producto para
/// avisar solo cuando empeora. Arranca con lo que ya está bajo su mínimo:
/// reiniciar el servidor no repite avisos.
class ServicioAlertas {
  ServicioAlertas({
    required this._repoProductos,
    required this._repoAjustes,
    required this._hub,
    this._reloj = relojSistema,
  }) {
    for (final p in _repoProductos.bajoMinimo()) {
      _existencia[p.id] = Alerta.tipoExistencia(p)!;
    }
  }

  final RepositorioProductos _repoProductos;
  final RepositorioAjustes _repoAjustes;
  final Hub _hub;
  final Reloj _reloj;
  final _existencia = <String, String>{};

  /// [dias] viene de la URL: texto o `null` (por omisión
  /// [diasAlertaCaducidad]).
  Map<String, Object?> listar({String? dias}) {
    final ventana = dias == null ? diasAlertaCaducidad : int.tryParse(dias);
    if (ventana == null || ventana < 1 || ventana > maxDiasAlertaCaducidad) {
      throw ErrorApi.datosInvalidos({
        'dias': 'Debe ser un entero de 1 a $maxDiasAlertaCaducidad',
      });
    }
    final hoy = diaNegocio(_reloj(), _repoAjustes.zonaHoraria);
    final hasta = diaNegocio(
      parsearFecha(hoy)!.add(Duration(days: ventana)),
      Duration.zero,
    );
    final alertas = calcularAlertas(
      _repoProductos.candidatosAlerta(hasta),
      hoy: hoy,
      dias: ventana,
    );
    return {
      'dia': hoy,
      'dias': ventana,
      'alertas': [for (final a in alertas) a.toJson()],
    };
  }

  /// Se llama DESPUÉS de confirmar un cambio a [producto], junto con
  /// `producto.actualizado`. Avisa si su alerta de existencia empeoró.
  void revisar(Producto producto) {
    final antes = _existencia[producto.id];
    final ahora = Alerta.tipoExistencia(producto);
    if (ahora == null) {
      _existencia.remove(producto.id);
      return;
    }
    _existencia[producto.id] = ahora;
    if (ahora == antes || ahora == TiposAlerta.pocoStock && antes != null) {
      return;
    }
    _hub.emitir(TiposEvento.alertaNueva, {
      'alerta': Alerta(tipo: ahora, producto: producto).toJson(),
    });
  }

  /// Un producto eliminado ya no tiene alerta.
  void olvidar(String productoId) => _existencia.remove(productoId);
}
