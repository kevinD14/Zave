import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';
import 'package:myapp/utils/config/filter_grf.dart';
import 'package:myapp/presentation/screens/options/summary/summary_screen.dart';

// Widget de gráfico de pastel para mostrar los gastos por categoría
class ExpenseChart extends StatelessWidget {
  final FilterType filter; // Filtro de tiempo (por ejemplo: diario, semanal, mensual)

  const ExpenseChart({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      // Obtiene las transacciones filtradas según el tipo de filtro (string)
      future: getTransactionsFiltered(filter.toString().split('.').last),
      builder: (context, snapshot) {

        // Muestra un indicador de carga mientras se esperan los datos
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = snapshot.data!;
        final expenseCategories = <String, double>{}; // Mapa para acumular totales por categoría

        // Agrupa y suma los gastos por categoría
        for (var tx in transactions) {
          if (tx['type'] == 'gastos') {
            final category = tx['category'];
            final amount = tx['amount'] as double;
            expenseCategories[category] =
                (expenseCategories[category] ?? 0) + amount;
          }
        }

        // Si no hay gastos registrados, muestra un mensaje
        if (expenseCategories.isEmpty) {
          return Center(
            child: Text(
              "Sin gastos registrados",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          );
        }

        // Ordena las categorías de mayor a menor gasto
        final sorted =
            expenseCategories.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

        // Toma las 5 primeras categorías con más gasto
        final top5 = sorted.take(5).toList();

        // Suma el resto de las categorías para mostrar como "Otras"
        final othersTotal = sorted
            .skip(5)
            .fold(0.0, (sum, entry) => sum + entry.value);

        // Si hay otras categorías, se agrega como una entrada más
        if (othersTotal > 0) {
          top5.add(MapEntry("Otras categorías", othersTotal));
        }

        // Suma total de los gastos (para calcular porcentajes)
        final total = top5.fold(0.0, (sum, entry) => sum + entry.value);

        // Secciones del gráfico de pastel
        final sections =
            top5.map((entry) {
              final percentage = ((entry.value / total) * 100).toStringAsFixed(
                1,
              );
              return PieChartSectionData(
                value: entry.value,
                color: _getCategoryColor(entry.key), // Color generado por categoría
                title: '$percentage%',
                titleStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();

        // UI final del gráfico
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [

                // Título del gráfico
                Text(
                  "Gastos por Categoría",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),

                // Gráfico de pastel
                AspectRatio(
                  aspectRatio: 1.3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 5,
                      centerSpaceRadius: 50,
                      sections: sections,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Leyenda de categorías (color + nombre)
                Wrap(
                  spacing: 15,
                  runSpacing: 8,
                  children:
                      top5.map((e) {
                        return _Legend(
                          color: _getCategoryColor(e.key),
                          label: e.key,
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Método para obtener transacciones filtradas por rango de fecha
  Future<List<Map<String, dynamic>>> getTransactionsFiltered(
    String filterType,
  ) async {
    final db = await TransactionDB().database;

    // Obtiene el rango de fechas a partir del tipo de filtro
    final dateRange = FilterUtils.getDateRange(filterType);
    final start = dateRange['start']!;
    final end = dateRange['end']!;

    // Consulta todas las transacciones
    final result = await db.query('transactions', orderBy: 'date DESC');

    // Filtra solo las que estén dentro del rango de fechas
    return result.where((tx) {
      final dateStr = tx['date'] as String;
      final dateParts = dateStr.split('/');
      if (dateParts.length != 3) return false;
      final date = DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
      );
      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();
  }

  // Genera un color único para cada categoría según su nombre
  Color _getCategoryColor(String category) {
    final hash = category.codeUnits.fold(0, (prev, elem) => prev + elem);
    final hue = (hash * 37) % 360;
    return HSLColor.fromAHSL(1.0, hue.toDouble(), 0.6, 0.6).toColor();
  }
}

// Widget auxiliar para mostrar una leyenda con color y nombre de categoría
class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ],
    );
  }
}
