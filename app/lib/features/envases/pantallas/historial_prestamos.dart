import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/tema/colores.dart';
import '../datos/modelos_envases.dart';
import '../estado/envases_provider.dart';
import 'modal_retorno_deposito.dart';

/// 5.5 Historial de Préstamos Activos
/// Vista de lista/tabla de clientes que deben envases (fiados), con filtro por
/// nombre, destaque en ámbar para los de más de 7 días, y botón de acción rápida "Recibir".
class HistorialPrestamos extends ConsumerStatefulWidget {
  const HistorialPrestamos({super.key});

  @override
  ConsumerState<HistorialPrestamos> createState() => _HistorialPrestamosState();
}

class _HistorialPrestamosState extends ConsumerState<HistorialPrestamos> {
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final estado = ref.watch(envasesProvider);
    final ancho = MediaQuery.of(context).size.width;
    final esIpad = ancho > 700;

    final prestamosFiltrados = estado.prestamosActivos.where((p) {
      if (_busqueda.isEmpty) return true;
      final q = _busqueda.toLowerCase();
      final nombre = p.cliente.toLowerCase();
      final tel = p.telefono?.toLowerCase() ?? '';
      return nombre.contains(q) || tel.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        backgroundColor: c.superficie,
        elevation: 0,
        title: Text(
          'Préstamos de Envases Activos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: c.tinta,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: c.linea, height: 1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Buscador de texto ancho: "Buscar por nombre del cliente"
            Container(
              padding: const EdgeInsets.all(20),
              color: c.superficie,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) => setState(() => _busqueda = val),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre del cliente o teléfono...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: c.superficie2,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: c.linea),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: c.linea),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: c.azul, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: c.superficie2,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: c.linea),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          size: 20,
                          color: c.azul,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${prestamosFiltrados.length} pendientes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: c.tinta,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Lista o Tabla de préstamos
            Expanded(
              child: prestamosFiltrados.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 64,
                            color: c.linea,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _busqueda.isEmpty
                                ? 'No hay préstamos activos'
                                : 'No se encontraron clientes con "$_busqueda"',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: c.tinta2,
                            ),
                          ),
                        ],
                      ),
                    )
                  : esIpad
                  ? _TablaPrestamosIpad(
                      prestamos: prestamosFiltrados,
                      alRecibir: (p) => _abrirRecibir(context, p),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: prestamosFiltrados.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final p = prestamosFiltrados[i];
                        return _TarjetaPrestamoMovil(
                          prestamo: p,
                          alRecibir: () => _abrirRecibir(context, p),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirRecibir(BuildContext context, PrestamoEnvase p) {
    ModalRetornoDeposito.mostrar(
      context: context,
      clienteInicial: p.cliente,
      prestamoId: p.id,
      cantidadSugerida: p.cantidad,
      formatoInicial: p.formato,
    );
  }
}

/// Tarjeta móvil para visualización limpia vertical
class _TarjetaPrestamoMovil extends StatelessWidget {
  const _TarjetaPrestamoMovil({
    required this.prestamo,
    required this.alRecibir,
  });

  final PrestamoEnvase prestamo;
  final VoidCallback alRecibir;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final esVencido = prestamo.esVencido;
    final fechaStr = DateFormat('dd/MM/yyyy • hh:mm a').format(prestamo.fecha);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: esVencido ? const Color(0xFFF59E0B) : c.linea,
          width: esVencido ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: esVencido
                    ? const Color(0xFFFEF3C7)
                    : c.azul.withValues(alpha: 0.1),
                child: Text(
                  prestamo.cliente.isNotEmpty
                      ? prestamo.cliente[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: esVencido ? const Color(0xFFD97706) : c.azul,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prestamo.cliente,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: esVencido ? const Color(0xFFB45309) : c.tinta,
                      ),
                    ),
                    if (prestamo.telefono != null)
                      Text(
                        prestamo.telefono!,
                        style: TextStyle(fontSize: 13, color: c.tinta2),
                      ),
                  ],
                ),
              ),
              if (esVencido)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${prestamo.diasAntiguedad} días',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${prestamo.cantidad} envases (${prestamo.formato.etiqueta})',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: c.tinta,
                    ),
                  ),
                  Text(
                    fechaStr,
                    style: TextStyle(fontSize: 12, color: c.tinta2),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: alRecibir,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.verde,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text(
                  'Recibir',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tabla iPad con columnas ordenadas y legibilidad inmediata
class _TablaPrestamosIpad extends StatelessWidget {
  const _TablaPrestamosIpad({required this.prestamos, required this.alRecibir});

  final List<PrestamoEnvase> prestamos;
  final void Function(PrestamoEnvase p) alRecibir;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: c.superficie,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.linea),
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(c.superficie2),
            horizontalMargin: 20,
            columnSpacing: 24,
            dataRowMinHeight: 68,
            dataRowMaxHeight: 80,
            columns: const [
              DataColumn(
                label: Text(
                  'Cliente',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Fecha / Antigüedad',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Formato',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Pendientes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Acción',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: prestamos.map((p) {
              final esVencido = p.esVencido;
              final fechaStr = DateFormat(
                'dd/MM/yyyy • hh:mm a',
              ).format(p.fecha);

              return DataRow(
                color: esVencido
                    ? WidgetStateProperty.all(const Color(0xFFFFFBEB))
                    : null,
                cells: [
                  DataCell(
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: esVencido
                              ? const Color(0xFFFEF3C7)
                              : c.azul.withValues(alpha: 0.1),
                          child: Text(
                            p.cliente.isNotEmpty
                                ? p.cliente[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: esVencido
                                  ? const Color(0xFFD97706)
                                  : c.azul,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                p.cliente,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: esVencido
                                      ? const Color(0xFFB45309)
                                      : c.tinta,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (p.telefono != null)
                                Text(
                                  p.telefono!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: c.tinta2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(fechaStr, style: const TextStyle(fontSize: 13)),
                        if (esVencido)
                          Text(
                            '⚠️ Hace ${p.diasAntiguedad} días (Vencido)',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD97706),
                            ),
                          ),
                      ],
                    ),
                  ),
                  DataCell(Text(p.formato.etiqueta)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: esVencido
                            ? const Color(0xFFFEF3C7)
                            : c.superficie2,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: esVencido ? const Color(0xFFF59E0B) : c.linea,
                        ),
                      ),
                      child: Text(
                        '${p.cantidad} pzs',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: esVencido ? const Color(0xFFB45309) : c.tinta,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    ElevatedButton.icon(
                      onPressed: () => alRecibir(p),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.verde,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text(
                        'Recibir',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
