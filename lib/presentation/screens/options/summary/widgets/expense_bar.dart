import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';
import 'package:myapp/utils/config/filter_grf.dart';
import 'package:myapp/presentation/screens/options/summary/summary_screen.dart';

class ExpenseBarChart extends StatelessWidget {
  final FilterType filter;

  const ExpenseBarChart({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getTransactionsFiltered(filter),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = snapshot.data!;
        final expenseCategories = <String, double>{};

        for (var tx in transactions) {
          if (tx['type'] == 'gastos') {
            final category = tx['category'];
            final amount = tx['amount'] as double;
            expenseCategories[category] =
                (expenseCategories[category] ?? 0) + amount;
          }
        }

        if (expenseCategories.isEmpty) {
          return const Center(child: Text(" "));
        }

        final sorted =
            expenseCategories.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

        final top5 = sorted.take(5).toList();
        final othersTotal = sorted
            .skip(5)
            .fold(0.0, (sum, entry) => sum + entry.value);

        if (othersTotal > 0) {
          top5.add(MapEntry("Otras categorías", othersTotal));
        }

        final barChartGroups =
            top5.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value.key;
              final amount = entry.value.value;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: amount,
                    width: 20,
                    color: _getCategoryColor(category),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              );
            }).toList();

        return Card(
          key: const PageStorageKey('expense_chart'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: 1.4,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      minY: 0,
                      maxY: _calculateMaxY(barChartGroups),
                      borderData: FlBorderData(show: true),
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      barGroups: barChartGroups,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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

  Future<List<Map<String, dynamic>>> getTransactionsFiltered(
    FilterType filterType,
  ) async {
    final db = await TransactionDB().database;
    final dateRange = FilterUtils.getDateRange(
      filterType.toString().split('.').last,
    );
    DateTime start = dateRange['start']!;
    DateTime end = dateRange['end']!;

    final result = await db.query('transactions', orderBy: 'date DESC');

    return result.where((tx) {
      final dateStr = tx['date'] as String;
      final parts = dateStr.split('/');
      if (parts.length != 3) return false;
      final date = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();
  }

  double _calculateMaxY(List<BarChartGroupData> barChartGroups) {
    double maxValue = 0;
    for (var group in barChartGroups) {
      for (var rod in group.barRods) {
        if (rod.toY > maxValue) {
          maxValue = rod.toY;
        }
      }
    }
    return (maxValue / 100).ceil() * 100.0;
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
