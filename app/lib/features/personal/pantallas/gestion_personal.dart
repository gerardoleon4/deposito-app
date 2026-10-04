import 'package:flutter/material.dart';

import '../../../../app/tema/colores.dart';
import '../widgets/modal_alta_empleado.dart';
import '../widgets/bottom_sheet_gestion_accesos.dart';
import 'seguridad_respaldo.dart';
import '../../auth/pantallas/login_diario.dart';

class EmpleadoPrueba {
  final String id;
  final String nombre;
  final String iniciales;
  final String rol;
  final bool activo;
  final bool esDueno;

  EmpleadoPrueba(
    this.id,
    this.nombre,
    this.iniciales,
    this.rol,
    this.activo,
    this.esDueno,
  );
}

class GestionPersonal extends StatefulWidget {
  const GestionPersonal({super.key});

  @override
  State<GestionPersonal> createState() => _GestionPersonalState();
}

class _GestionPersonalState extends State<GestionPersonal> {
  final List<EmpleadoPrueba> _empleados = [
    EmpleadoPrueba('1', 'MSACUATA', 'MS', 'Dueño/Admin', true, true),
    EmpleadoPrueba('2', 'Sofía Vega', 'SO', 'Gerente', true, false),
    EmpleadoPrueba('3', 'Ana Martínez', 'AN', 'Cajero', true, false),
  ];

  EmpleadoPrueba? _empleadoSeleccionado;

  void _abrirAlta() {
    showDialog(
      context: context,
      builder: (_) => ModalAltaEmpleado(
        alGuardar: (nombre, rol, pin) {
          setState(() {
            _empleados.add(
              EmpleadoPrueba(
                DateTime.now().toString(),
                nombre,
                nombre.substring(0, 2).toUpperCase(),
                rol,
                true,
                false,
              ),
            );
          });
        },
      ),
    );
  }

  void _abrirGestion(EmpleadoPrueba emp) {
    if (emp.esDueno) return;

    setState(() => _empleadoSeleccionado = emp);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BottomSheetGestionAccesos(
        nombre: emp.nombre,
        rol: emp.rol,
        alSuspender: () {
          Navigator.pop(context);
        },
      ),
    ).then((_) {
      if (mounted) setState(() => _empleadoSeleccionado = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;

    return Scaffold(
      backgroundColor: c.fondo,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            const SizedBox(height: 16),
            Text(
              'ADMINISTRACIÓN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c.azul,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gestión de Personal',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: c.tinta,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginDiario()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.azul,
                    side: BorderSide(color: c.azul.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Salir',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SeguridadRespaldo(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.tinta,
                    side: BorderSide(color: c.linea),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Seguridad y respaldo',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: _abrirAlta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.azul,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Agregar Empleado',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Tabla
            Container(
              decoration: BoxDecoration(
                color: c.fondo,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.linea),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'NOMBRE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: c.tinta2,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'ROL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: c.tinta2,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Text(
                          'ESTADO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: c.tinta2,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Filas
                  ..._empleados.asMap().entries.map((entry) {
                    final isLast = entry.key == _empleados.length - 1;
                    final emp = entry.value;
                    final isSelected = emp == _empleadoSeleccionado;

                    return Column(
                      children: [
                        Container(
                          decoration: isSelected
                              ? BoxDecoration(
                                  color: c.azul.withValues(alpha: 0.05),
                                  border: Border.all(color: c.azul, width: 1.5),
                                  borderRadius: BorderRadius.circular(8),
                                )
                              : null,
                          margin: isSelected
                              ? const EdgeInsets.all(4)
                              : EdgeInsets.zero,
                          child: InkWell(
                            onTap: emp.esDueno
                                ? null
                                : () => _abrirGestion(emp),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSelected ? 16 : 20,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  // Nombre
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: c.azul.withValues(
                                              alpha: 0.08,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              emp.iniciales,
                                              style: TextStyle(
                                                color: c.azul,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            emp.nombre,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: c.tinta,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Rol
                                  Expanded(
                                    flex: 2,
                                    child: emp.esDueno
                                        ? Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: c.azul.withValues(
                                                  alpha: 0.08,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                'Dueño/Admin',
                                                style: TextStyle(
                                                  color: c.azul,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            emp.rol,
                                            style: TextStyle(
                                              color: c.tinta,
                                              fontSize: 15,
                                            ),
                                          ),
                                  ),
                                  // Estado
                                  Text(
                                    emp.activo ? 'Activo' : 'Inactivo',
                                    style: TextStyle(
                                      color: c.azul,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (!isLast && !isSelected) const Divider(height: 1),
                      ],
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 48),
            Center(
              child: Text(
                'Desarrollado por Equipo Umizommi',
                style: TextStyle(
                  fontSize: 12,
                  color: c.tinta2.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
