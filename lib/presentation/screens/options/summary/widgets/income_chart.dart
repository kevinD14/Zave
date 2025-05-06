import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';
import 'package:myapp/utils/config/filter_grf.dart';
import 'package:myapp/presentation/screens/options/summary/summary_screen.dart';

class IncomeChart extends StatelessWidget {
  final FilterType filter;

  const IncomeChart({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getTransactionsFiltered(filter.toString().split('.').last),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = snapshot.data!;
        final incomeCategories = <String, double>{};

        for (var tx in transactions) {
          if (tx['type'] == 'ingresos') {
            final category = tx['category'];
            final amount = tx['amount'] as double;

            incomeCategories[category] =
                (incomeCategories[category] ?? 0) + amount;
          }
        }

        if (incomeCategories.isEmpty) {
          return Center(
            child: Text(
              "Sin ingresos registrados",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          );
        }

        final sortedCategories =
            incomeCategories.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

        final topCategories = sortedCategories.take(5).toList();

        final otherCategoriesTotal = sortedCategories
            .skip(5)
            .fold(0.0, (sum, entry) => sum + entry.value);

        if (otherCategoriesTotal > 0) {
          topCategories.add(MapEntry("Otras categorías", otherCategoriesTotal));
        }

        final total = topCategories.fold(
          0.0,
          (sum, entry) => sum + entry.value,
        );

        final sections =
            topCategories.map((entry) {
              final percentage = ((entry.value / total) * 100).toStringAsFixed(
                1,
              );
              return PieChartSectionData(
                value: entry.value,
                color: _getCategoryColor(entry.key),
                title: '$percentage%',
                titleStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();

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
                Text(
                  "Ingresos por Categoría",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: 1.4,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 5,
                      centerSpaceRadius: 50,
                      sections: sections,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 15,
                  runSpacing: 8,
                  children:
                      topCategories.map((e) {
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

  Future<List<Map<String, dynamic>>> getTransactionsFiltered(
    String filterType,
  ) async {
    final db = await TransactionDB().database;

    final dateRange = FilterUtils.getDateRange(filterType);
    final start = dateRange['start']!;
    final end = dateRange['end']!;

    final result = await db.query('transactions', orderBy: 'date DESC');

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

  String convertDateToSqlFormat(String date) {
    List<String> parts = date.split('/');
    return "${parts[2]}-${parts[1]}-${parts[0]}";
  }

  Color _getCategoryColor(String category) {
    final hash = category.codeUnits.fold(0, (prev, elem) => prev + elem);
    final hue = (hash * 37) % 360;
    return HSLColor.fromAHSL(1.0, hue.toDouble(), 0.6, 0.6).toColor();
  }
}

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
