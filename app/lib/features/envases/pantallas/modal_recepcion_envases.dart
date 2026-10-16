import 'package:flutter/material.dart';
import '../../../../app/tema/colores.dart';
import '../datos/modelos_envases.dart';

/// 5.2 Flujo de Recepción (Cliente trae vacíos)
/// Panel emergente (Bottom Sheet) para recibir botellas retornables vacías y
/// aplicar el crédito correspondiente al ticket actual.
class ModalRecepcionEnvases extends StatefulWidget {
  const ModalRecepcionEnvases({
    super.key,
    required this.alConfirmar,
    this.cantidadInicial = 1,
    this.formatoInicial = TipoFormatoEnvase.media,
  });

  /// Retorna la cantidad recibida, el formato y el crédito monetario total calculado.
  final void Function(
    int cantidad,
    TipoFormatoEnvase formato,
    double creditoTotal,
  )
  alConfirmar;
  final int cantidadInicial;
  final TipoFormatoEnvase formatoInicial;

  static Future<void> mostrar({
    required BuildContext context,
    required void Function(
      int cantidad,
      TipoFormatoEnvase formato,
      double creditoTotal,
    )
    alConfirmar,
    int cantidadInicial = 1,
    TipoFormatoEnvase formatoInicial = TipoFormatoEnvase.media,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalRecepcionEnvases(
        alConfirmar: alConfirmar,
        cantidadInicial: cantidadInicial,
        formatoInicial: formatoInicial,
      ),
    );
  }

  @override
  State<ModalRecepcionEnvases> createState() => _ModalRecepcionEnvasesState();
}

class _ModalRecepcionEnvasesState extends State<ModalRecepcionEnvases> {
  late int _cantidad;
  late TipoFormatoEnvase _formato;

  @override
  void initState() {
    super.initState();
    _cantidad = widget.cantidadInicial.clamp(1, 999);
    _formato = widget.formatoInicial;
  }

  double get _creditoTotal => _cantidad * _formato.precioDeposito;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;

    return Container(
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        14,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Asa de arrastre
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: c.linea,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Cabecera
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: c.verde.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.recycling_rounded,
                      color: c.verde,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recepción de Envases Vacíos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: c.tinta,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Descuenta del ticket el valor de los vacíos que entrega el cliente',
                          style: TextStyle(fontSize: 13, color: c.tinta2),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: c.tinta2,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Selector de Formato
              Text(
                'Formato de envase:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c.tinta,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: TipoFormatoEnvase.values.map((f) {
                    final seleccionado = _formato == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        selected: seleccionado,
                        showCheckmark: false,
                        avatar: Icon(
                          f.icono,
                          size: 18,
                          color: seleccionado ? Colors.white : c.azul,
                        ),
                        label: Text(
                          '${f.etiqueta} (\$${f.precioDeposito.toStringAsFixed(0)} c/u)',
                          style: TextStyle(
                            fontWeight: seleccionado
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: seleccionado ? Colors.white : c.tinta,
                            fontSize: 14,
                          ),
                        ),
                        selectedColor: c.azul,
                        backgroundColor: c.superficie2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: seleccionado ? Colors.transparent : c.linea,
                          ),
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _formato = f);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Controles gigantes [-] [Número] [+]
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: c.superficie2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.linea),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Botón menos gigante
                    Material(
                      color: _cantidad > 1
                          ? c.superficie
                          : c.superficie.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      elevation: _cantidad > 1 ? 1 : 0,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _cantidad > 1
                            ? () => setState(() => _cantidad--)
                            : null,
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: Icon(
                            Icons.remove_rounded,
                            size: 36,
                            color: _cantidad > 1 ? c.tinta : c.linea,
                          ),
                        ),
                      ),
                    ),

                    // Número central de cantidad
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_cantidad',
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            color: c.tinta,
                            height: 1.0,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          _cantidad == 1
                              ? 'envase recibido'
                              : 'envases recibidos',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: c.tinta2,
                          ),
                        ),
                      ],
                    ),

                    // Botón más gigante
                    Material(
                      color: c.azul,
                      borderRadius: BorderRadius.circular(16),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => setState(() => _cantidad++),
                        child: const SizedBox(
                          width: 64,
                          height: 64,
                          child: Icon(
                            Icons.add_rounded,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Indicador de Crédito verde destacado
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: c.verdeSuave,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: c.verde.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: c.verde,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Crédito a descontar:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: c.verde,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '-\$${_creditoTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: c.verde,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botón de acción ancho: "Aplicar Crédito al Ticket"
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.alConfirmar(_cantidad, _formato, _creditoTotal);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.verde,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.arrow_downward_rounded, size: 22),
                  label: Text(
                    'Aplicar Crédito al Ticket (-\$${_creditoTotal.toStringAsFixed(2)})',
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
