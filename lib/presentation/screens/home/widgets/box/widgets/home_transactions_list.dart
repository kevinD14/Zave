import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';
import 'package:myapp/utils/config/format_dates.dart';
import 'package:myapp/presentation/screens/transactions_all/details/transaction_detail_screen.dart';
import 'package:myapp/utils/config/event_bus.dart';

class TransactionsList extends StatefulWidget {
  const TransactionsList({super.key});

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();

    EventBus().onTransactionsUpdated.listen((_) {
      _loadTransactions();
    });
  }

  Future<void> _loadTransactions() async {
    final transactions = await TransactionDB().getLastTransactions(
      limit: 10,
    ); // Aumento el límite a 20
    if (!mounted) return;
    setState(() {
      _transactions = transactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    return _buildTransactionList(context, brightness, textColor);
  }

  Widget _buildTransactionList(
    BuildContext context,
    Brightness brightness,
    Color? textColor,
  ) {
    if (_transactions.isEmpty) {
      return Center(
        child: Text(
          'No hay transacciones aún',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: textColor?.withAlpha(178),
          ),
        ),
      );
    }

    final transactions = List<Map<String, dynamic>>.from(_transactions);

    transactions.sort((a, b) {
      final dateA = DateFormat('dd/MM/yyyy').parse(a['date']);
      final dateB = DateFormat('dd/MM/yyyy').parse(b['date']);

      if (dateA.isAtSameMomentAs(dateB)) {
        return (b['id'] as int).compareTo(a['id'] as int);
      } else {
        return dateB.compareTo(dateA);
      }
    });

    if (transactions.length > 10) {
      transactions.removeRange(10, transactions.length);
    }

    final groupedTransactions = <String, List<Map<String, dynamic>>>{};
    for (var transaction in transactions) {
      final date = transaction['date'] ?? '';
      groupedTransactions.putIfAbsent(date, () => []).add(transaction);
    }

    final sortedDates =
        groupedTransactions.keys.toList()..sort((a, b) {
          final dateA = DateFormat('dd/MM/yyyy').parse(a);
          final dateB = DateFormat('dd/MM/yyyy').parse(b);
          return dateB.compareTo(dateA);
        });

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dailyTransactions = groupedTransactions[date]!;

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
                    color: textColor?.withAlpha(178),
                  ),
                ),
              ),
              ...dailyTransactions.map((transaction) {
                final double amount = (transaction['amount'] as num).toDouble();
                final String category =
                    transaction['category'] ?? 'Sin categoría';
                final String type = transaction['type'] ?? 'otros';

                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => TransactionDetailScreen(
                              transaction: transaction,
                            ),
                      ),
                    );
                  },
                  leading: SvgPicture.asset(
                    type == 'ingresos'
                        ? 'assets/icons/payments.svg'
                        : type == 'gastos'
                        ? 'assets/icons/pay.svg'
                        : 'assets/icons/debt.svg',
                    width: 40,
                    height: 40,
                    colorFilter: ColorFilter.mode(
                      textColor ?? Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                  title: Text(
                    type == 'ingresos'
                        ? 'Ingresos'
                        : type == 'gastos'
                        ? 'Gastos'
                        : 'Deuda',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    category,
                    style: TextStyle(fontSize: 14, color: textColor),
                  ),
                  trailing: Text(
                    '${type == 'ingresos' ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: textColor,
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
  }
}
