import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';
import 'package:myapp/utils/config/format_dates.dart';
import 'package:myapp/presentation/screens/options/summary/summary_screen.dart';

// Widget que muestra una lista de transacciones de tipo "gastos"
class ExpenseTransferWidget extends StatelessWidget {
  final FilterType filter;
  const ExpenseTransferWidget({super.key, required this.filter});

  // Carga las transacciones de tipo "gastos" filtradas por el tipo de filtro (hoy, semana, mes, etc.)
  Future<List<Map<String, dynamic>>> _loadExpenseTransfers() async {
    final db = TransactionDB(); // Instancia de la base de datos
    final all = await db.getAllTransactions(); // Carga todas las transacciones

    DateTime start;
    DateTime end;

    // Establece el rango de fechas según el filtro
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
        start = DateTime(2000);
        end = DateTime(2100);
        break;
      default:
        start = DateTime(2000);
        end = now;
    }

    // Filtra las transacciones por fecha
    final filtered = all.where((tx) {
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

    // Retorna solo las transacciones de tipo "gastos"
    return filtered.where((tx) => tx['type'] == 'gastos').toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadExpenseTransfers(), // Llama al método que carga los datos
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        final transfers = snap.data!;
        if (transfers.isEmpty) {
          return Center(
            child: Text(
              ' ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(
                  context,
                ).textTheme.bodyLarge?.color?.withAlpha(178),
              ),
            ),
          );
        }

        // Ordena las transacciones por fecha descendente y por id si tienen la misma fecha
        transfers.sort((a, b) {
          final da = DateFormat('dd/MM/yyyy').parse(a['date']);
          final db = DateFormat('dd/MM/yyyy').parse(b['date']);
          if (da.isAtSameMomentAs(db)) {
            return (b['id'] as int).compareTo(a['id'] as int);
          }
          return db.compareTo(da);
        });

        // Agrupa las transacciones por fecha
        final grouped = <String, List<Map<String, dynamic>>>{};
        for (var tx in transfers) {
          grouped.putIfAbsent(tx['date'] as String, () => []).add(tx);
        }

        // Ordena las fechas de forma descendente
        final dates = grouped.keys.toList()
          ..sort((a, b) {
            final da = DateFormat('dd/MM/yyyy').parse(a);
            final db = DateFormat('dd/MM/yyyy').parse(b);
            return db.compareTo(da);
          });

        // Construye la lista de widgets
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dates.length,
          itemBuilder: (context, idx) {
            final date = dates[idx];
            final dayList = grouped[date]!;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado con la fecha
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

                  // Lista de transacciones del día
                  ...dayList.map((tx) {
                    final amount = (tx['amount'] as num).toDouble();
                    return ListTile(
                      leading: SvgPicture.asset(
                        'assets/icons/pay.svg',
                        width: 40,
                        height: 40,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).textTheme.bodyLarge?.color ??
                              Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                      title: const Text(
                        'Gastos',
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
                        '-\$${amount.toStringAsFixed(2)}',
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

  // Obtiene el inicio de la semana actual (lunes)
  DateTime _getStartOfWeek() {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  // Obtiene el final de la semana actual (domingo a las 23:59:59)
  DateTime _getEndOfWeek() {
    final now = DateTime.now();
    final end = now.add(Duration(days: DateTime.sunday - now.weekday));
    return DateTime(end.year, end.month, end.day, 23, 59, 59);
  }

  // Obtiene la fecha correspondiente a hace 30 días (inicio del "mes")
  DateTime _getStartOfMonth() {
    final now = DateTime.now();
    return now.subtract(const Duration(days: 30));
  }

  // Obtiene el inicio de los últimos 6 meses
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
