import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:myapp/presentation/screens/options/summary/widgets/income_chart.dart';
import 'package:myapp/presentation/screens/options/summary/widgets/expense_chart.dart';
import 'package:myapp/presentation/screens/options/summary/widgets/income_bar.dart';
import 'package:myapp/presentation/screens/options/summary/widgets/expense_bar.dart';
import 'package:myapp/presentation/screens/options/summary/widgets/income_transfer.dart';
import 'package:myapp/presentation/screens/options/summary/widgets/expense_transfer.dart';
import 'package:myapp/presentation/screens/options/summary/widgets/card_summary.dart';

// Enum que define los tipos de filtros disponibles para mostrar los datos
enum FilterType { hoy, semana, mes, seisMeses, general }

// Pantalla principal del resumen completo
class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0; // Índice para alternar entre ingresos y gastos
  FilterType _selectedFilter =
      FilterType.general; // Filtro de tiempo seleccionado
  late final AnimationController
  _controller; // Controlador para la animación del botón de recarga

  @override
  void initState() {
    super.initState();

    // Inicializa el controlador de animación con una duración de 500ms
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    // Libera los recursos del controlador de animación al destruir el widget
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define el color de fondo según el tema actual (oscuro o claro)
    final bgColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF232525)
        : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Resumen completo"),
        actions: [
          // Botón de recarga con animación de rotación
          IconButton(
            onPressed: () async {
              await _controller.forward(from: 0); // Ejecuta animación
              setState(() {}); // Refresca la pantalla
            },
            icon: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: child,
                );
              },
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const BalanceCard(), // Tarjeta que muestra el balance general
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(10),
                isSelected: [_selectedIndex == 0, _selectedIndex == 1],
                onPressed: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Ingresos',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Gastos',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Menú desplegable para seleccionar el filtro de tiempo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<FilterType>(
                      dropdownColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      value: _selectedFilter,
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedFilter = newValue;
                          });
                        }
                      },
                      isExpanded: true,
                      iconEnabledColor: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.color,
                      items: [
                        DropdownMenuItem(
                          value: FilterType.hoy,
                          child: Text(
                            "Hoy",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: FilterType.semana,
                          child: Text(
                            "Esta semana (Lunes - Domingo)",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: FilterType.mes,
                          child: Text(
                            "Últimos 30 días",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: FilterType.seisMeses,
                          child: Text(
                            "Últimos 6 meses",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: FilterType.general,
                          child: Text(
                            "General",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Sección de contenido dinámico según la pestaña activa (ingresos o gastos)
            if (_selectedIndex == 0) ...[
              IncomeChart(filter: _selectedFilter),
              IncomeBarChart(filter: _selectedFilter),
              IncomeTransferWidget(filter: _selectedFilter),
            ] else ...[
              ExpenseChart(filter: _selectedFilter),
              ExpenseBarChart(filter: _selectedFilter),
              ExpenseTransferWidget(filter: _selectedFilter),
            ],
          ],
        ),
      ),
    );
  }
}
