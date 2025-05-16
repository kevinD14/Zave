import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';

// Widget que muestra el balance financiero, ingresos, gastos y conteo de transacciones
class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  double? _balance; // Balance total (ingresos - gastos)
  double _ingresos = 0; // Monto total de ingresos
  double _gastos = 0; // Monto total de gastos

  // Formato para mostrar montos con separador de miles y 2 decimales
  final NumberFormat _numberFormat = NumberFormat("#,##0.00", "en_US");

  // Contadores de transacciones
  int _ingresosCount = 0;
  int _gastosCount = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadBalanceFromDatabase(); // Carga datos desde la base de datos
  }

  // Se ejecuta si el widget se actualiza externamente
  @override
  void didUpdateWidget(covariant BalanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadBalanceFromDatabase();
  }

  // Carga las transacciones desde la base de datos y calcula montos y conteos
  Future<void> _loadBalanceFromDatabase() async {
    final transactions = await TransactionDB().getAllTransactions();

    double ingresos = 0;
    double gastos = 0;
    int ingresosCount = 0;
    int gastosCount = 0;

    // Recorre todas las transacciones para sumar montos y contarlas
    for (var transaction in transactions) {
      final tipo = transaction['type'];
      final rawMonto = transaction['amount'];
      final monto = rawMonto is int ? rawMonto.toDouble() : (rawMonto ?? 0.0);

      if (tipo == 'ingresos') {
        ingresos += monto;
        ingresosCount++;
      } else if (tipo == 'gastos') {
        gastos += monto;
        gastosCount++;
      }
    }

    // Actualiza el estado con los nuevos valores
    setState(() {
      _balance = ingresos - gastos;
      _ingresos = ingresos;
      _gastos = gastos;
      _ingresosCount = ingresosCount;
      _gastosCount = gastosCount;
      _totalCount = ingresosCount + gastosCount;
    });
  }

  // Limita el monto a $9,999+ si excede ese valor
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
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Sección principal: muestra el balance y los ingresos/gastos
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    const SizedBox(height: 8),
                    Text(
                      '\$${_numberFormat.format(_balance)}',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: (_balance ?? 0) < 0 ? 22 : 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Columna derecha: ingresos y gastos detallados
              Transform.translate(
                offset: const Offset(10.0, 0.0),
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                            '\$${_formatAmountCapped(_ingresos)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
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
                            '\$${_formatAmountCapped(_gastos)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
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

          const Divider(thickness: 0.6, color: Colors.white24),
          const SizedBox(height: 6),

          // Título de sección de transacciones
          Text(
            "Transacciones ",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(
                context,
              ).textTheme.bodyLarge?.color?.withAlpha(222),
            ),
          ),

          const SizedBox(height: 6),
          // Conteo de ingresos, gastos y total
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(
                  context,
                ).textTheme.bodyLarge?.color?.withAlpha(180),
              ),
              children: [
                const TextSpan(text: 'Ingresos: '),
                TextSpan(
                  text: '$_ingresosCount  ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                const TextSpan(text: '• Gastos: '),
                TextSpan(
                  text: '$_gastosCount  ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                const TextSpan(text: '• Total: '),
                TextSpan(
                  text: '$_totalCount',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
