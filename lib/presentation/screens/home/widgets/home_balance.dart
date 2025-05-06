import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';
import 'package:myapp/utils/config/event_bus.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  double? _balance;
  double _ingresos = 0;
  double _gastos = 0;
  bool _isVisible = true;
  final NumberFormat _numberFormat = NumberFormat("#,##0.00", "en_US");

  @override
  void initState() {
    super.initState();
    _loadBalanceFromDatabase();
    _loadVisibilityPreference();

    EventBus().onTransactionsUpdated.listen((_) => _loadBalanceFromDatabase());
  }

  Future<void> _loadBalanceFromDatabase() async {
    final transactions = await TransactionDB().getAllTransactions();

    double ingresos = 0;
    double gastos = 0;

    for (var transaction in transactions) {
      final tipo = transaction['type'];
      final rawMonto = transaction['amount'];
      final monto = rawMonto is int ? rawMonto.toDouble() : (rawMonto ?? 0.0);

      if (tipo == 'ingresos') {
        ingresos += monto;
      } else if (tipo == 'gastos' || tipo == 'deuda') {
        gastos += monto;
      }
    }

    if (mounted) {
      setState(() {
        _balance = ingresos - gastos;
        _ingresos = ingresos;
        _gastos = gastos;
      });
    }
  }

  Future<void> _loadVisibilityPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isVisible = prefs.getBool('balanceVisible') ?? true;
    });
  }

  Future<void> _toggleVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isVisible = !_isVisible;
    });
    await prefs.setBool('balanceVisible', _isVisible);
  }

  String _formatAmountCapped(double amount) {
    if (amount > 9999.99) {
      return '9,999+';
    }
    return _numberFormat.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    if (_balance == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      'Balance',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.color?.withAlpha(222),
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _toggleVisibility,
                      child: Icon(
                        _isVisible ? Icons.visibility : Icons.visibility_off,
                        size: 20,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.color?.withAlpha(222),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _isVisible ? '\$${_numberFormat.format(_balance)}' : '******',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: (_balance ?? 0) < 0 ? 22 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(10.0, 0.0),
            child: Padding(
              padding: const EdgeInsets.only(right: 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Resumen',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.color?.withAlpha(222),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Ingresos: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.color?.withAlpha(222),
                        ),
                      ),
                      Text(
                        _isVisible ? '\$${_formatAmountCapped(_ingresos)}' : '*****',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Gastos: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.color?.withAlpha(222),
                        ),
                      ),
                      Text(
                        _isVisible ? '\$${_formatAmountCapped(_gastos)}' : '******',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
