import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';
import 'package:myapp/utils/config/format_dates.dart';
import 'package:myapp/presentation/screens/options/summary/summary_screen.dart';

class IncomeTransferWidget extends StatelessWidget {
  final FilterType filter;
  const IncomeTransferWidget({super.key, required this.filter});

  Future<List<Map<String, dynamic>>> _loadIncomeTransfers() async {
    final db = TransactionDB();
    final all = await db.getAllTransactions();

    DateTime start;
    DateTime end;

    final now = DateTime.now();
    switch (filter.toString().split('.').last) {
      case 'hoy':
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'semana':
        start = _getStartOfWeek();
        end = _getEndOfWeek();
        break;
      case 'mes':
        start = _getStartOfMonth();
        end = now;
        break;
      case 'seisMeses':
        start = _getStartOfLast6Months();
        end = now;
        break;
      case 'general':
      default:
        start = DateTime(2000);
        end = DateTime(2100);
    }

    final filtered =
        all.where((tx) {
          final parts = (tx['date'] as String).split('/');
          if (parts.length != 3) return false;
          final date = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
          return !date.isBefore(start) && !date.isAfter(end);
        }).toList();

    return filtered.where((tx) => tx['type'] == 'ingresos').toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadIncomeTransfers(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        final transfers = snap.data!;
        if (transfers.isEmpty) {
          return const SizedBox.shrink();
        }

        transfers.sort((a, b) {
          final da = DateFormat('dd/MM/yyyy').parse(a['date']);
          final db = DateFormat('dd/MM/yyyy').parse(b['date']);
          if (da.isAtSameMomentAs(db)) {
            return (b['id'] as int).compareTo(a['id'] as int);
          }
          return db.compareTo(da);
        });
        final grouped = <String, List<Map<String, dynamic>>>{};
        for (var tx in transfers) {
          grouped.putIfAbsent(tx['date'], () => []).add(tx);
        }
        final dates =
            grouped.keys.toList()..sort((a, b) {
              final da = DateFormat('dd/MM/yyyy').parse(a);
              final db = DateFormat('dd/MM/yyyy').parse(b);
              return db.compareTo(da);
            });

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dates.length,
          itemBuilder: (context, i) {
            final date = dates[i];
            final dayList = grouped[date]!;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22.0,
                      vertical: 4.0,
                    ),
                    child: Text(
                      formatDate(date),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.color?.withAlpha(221),
                      ),
                    ),
                  ),
                  // Entradas de ese día
                  ...dayList.map((tx) {
                    final amount = (tx['amount'] as num).toDouble();
                    return ListTile(
                      leading: SvgPicture.asset(
                        'assets/icons/payments.svg',
                        width: 40,
                        height: 40,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).textTheme.bodyLarge?.color ??
                              Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                      title: const Text(
                        'Ingreso',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        tx['category'] ?? 'Sin categoría',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.color?.withAlpha(221),
                        ),
                      ),
                      trailing: Text(
                        '+\$${amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  DateTime _getStartOfWeek() {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  DateTime _getEndOfWeek() {
    final now = DateTime.now();
    final end = now.add(Duration(days: DateTime.sunday - now.weekday));
    return DateTime(end.year, end.month, end.day, 23, 59, 59);
  }

  DateTime _getStartOfMonth() {
    final now = DateTime.now();
    return now.subtract(const Duration(days: 30));
  }

  DateTime _getStartOfLast6Months() {
    final now = DateTime.now();
    int m = now.month - 6, y = now.year;
    if (m <= 0) {
      y -= 1;
      m += 12;
    }
    return DateTime(y, m, 1);
  }
}
