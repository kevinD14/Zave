import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';
import 'package:myapp/utils/config/format_dates.dart';
import 'package:myapp/presentation/screens/transactions_all/details/transaction_detail_screen.dart';
import 'package:myapp/utils/config/event_bus.dart';

/// Widget de estado que muestra una lista de transacciones recientes,
/// agrupadas por fecha y actualizadas automáticamente mediante EventBus.
class TransactionsList extends StatefulWidget {
  const TransactionsList({super.key});

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  // Lista que contiene las transacciones cargadas desde la base de datos
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions(); // Carga inicial de transacciones

    // Escucha eventos del EventBus para recargar la lista cuando haya cambios
    EventBus().onTransactionsUpdated.listen((_) {
      _loadTransactions();
    });
  }

  /// Carga las últimas transacciones desde la base de datos
  Future<void> _loadTransactions() async {
    final transactions = await TransactionDB().getLastTransactions();
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

    // Construye el widget de lista
    return _buildTransactionList(context, brightness, textColor);
  }

  /// Construye la lista de transacciones agrupadas por fecha
  Widget _buildTransactionList(
    BuildContext context,
    Brightness brightness,
    Color? textColor,
  ) {
    // Si no hay transacciones, muestra un mensaje
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

    // Crea una copia de la lista original para ordenarla sin modificar el estado
    final transactions = List<Map<String, dynamic>>.from(_transactions);

    // Ordena las transacciones por fecha (más recientes primero) y por ID si hay igualdad
    transactions.sort((a, b) {
      final dateA = DateFormat('dd/MM/yyyy').parse(a['date']);
      final dateB = DateFormat('dd/MM/yyyy').parse(b['date']);

      if (dateA.isAtSameMomentAs(dateB)) {
        return (b['id'] as int).compareTo(a['id'] as int);
      } else {
        return dateB.compareTo(dateA);
      }
    });

    // Limita la lista a un máximo de 10 transacciones
    if (transactions.length > 10) {
      transactions.removeRange(10, transactions.length);
    }

    // Agrupa las transacciones por fecha
    final groupedTransactions = <String, List<Map<String, dynamic>>>{};
    for (var transaction in transactions) {
      final date = transaction['date'] ?? '';
      groupedTransactions.putIfAbsent(date, () => []).add(transaction);
    }

    // Ordena las fechas de forma descendente
    final sortedDates =
        groupedTransactions.keys.toList()..sort((a, b) {
          final dateA = DateFormat('dd/MM/yyyy').parse(a);
          final dateB = DateFormat('dd/MM/yyyy').parse(b);
          return dateB.compareTo(dateA);
        });

    // Construye la lista visualmente usando ListView
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
                  formatDate(date), // Usa función personalizada para formatear la fecha
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor?.withAlpha(178),
                  ),
                ),
              ),
              // Muestra cada transacción del día
              ...dailyTransactions.map((transaction) {
                final double amount = (transaction['amount'] as num).toDouble();
                final String category =
                    transaction['category'] ?? 'Sin categoría';
                final String type = transaction['type'] ?? 'otros';

                return ListTile(
                  onTap: () {
                    // Abre pantalla de detalles al tocar una transacción
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

                  // Icono de tipo de transacción
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

                  // Título según el tipo
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

                  // Subtítulo con la categoría
                  subtitle: Text(
                    category,
                    style: TextStyle(fontSize: 14, color: textColor),
                  ),

                  // Monto mostrado como positivo o negativo
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
