import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';
import 'package:myapp/utils/config/format_dates.dart';
import 'package:myapp/presentation/screens/transactions_all/details/transaction_detail_screen.dart';

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  late Future<List<Map<String, dynamic>>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    _transactionsFuture = TransactionDB().getAllTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text(
          'Transacciones',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error cargando transacciones'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No hay transacciones aún',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          final transactions = List<Map<String, dynamic>>.from(snapshot.data!);

          transactions.sort((a, b) {
            final dateA = DateFormat('dd/MM/yyyy').parse(a['date']);
            final dateB = DateFormat('dd/MM/yyyy').parse(b['date']);

            if (dateA.isAtSameMomentAs(dateB)) {
              return (b['id'] as int).compareTo(a['id'] as int);
            } else {
              return dateB.compareTo(dateA);
            }
          });

          Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
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
                          color: Colors.white.withAlpha(150),
                        ),
                      ),
                    ),
                    ...dailyTransactions.map((transaction) {
                      final double amount =
                          (transaction['amount'] as num?)?.toDouble() ?? 0.0;
                      final String category =
                          transaction['category'] ?? 'Sin categoría';
                      final String type = transaction['type'] ?? 'otros';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => TransactionDetailScreen(
                                    transaction: transaction,
                                  ),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: SvgPicture.asset(
                            type == 'ingresos'
                                ? 'assets/icons/payments.svg'
                                : type == 'gastos'
                                ? 'assets/icons/pay.svg'
                                : 'assets/icons/debt.svg',
                            width: 40,
                            height: 40,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
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
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            category,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withAlpha(220),
                            ),
                          ),
                          trailing: Text(
                            '${type == 'ingresos' ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
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
      ),
    );
  }
}
