import 'package:flutter/material.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';
import 'package:myapp/utils/config/event_bus.dart';

Future<void> confirmDeleteTransaction(
  BuildContext context,
  Map<String, dynamic> transaction,
) async {
  final amount = (transaction['amount'] as num).toDouble();
  final type = transaction['type'];

  final changeText =
      type == 'ingresos'
          ? 'Se restarán \$${amount.toStringAsFixed(2)} del balance.'
          : 'Se sumarán \$${amount.toStringAsFixed(2)} al balance.';

  final confirm = await showDialog<bool>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(
            '¿Eliminar transacción?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (type == 'deuda')
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Esta acción no modificará su saldo pendiente en la deuda',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              Text(
                '$changeText\n\n¿Estás seguro de que deseas eliminarla?',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);

                final allTransactions =
                    await TransactionDB().getAllTransactions();

                double currentBalance = 0;
                for (final tx in allTransactions) {
                  final double txAmount = (tx['amount'] as num).toDouble();
                  final String txType = tx['type'] ?? '';
                  if (txType == 'ingresos') {
                    currentBalance += txAmount;
                  } else if (txType == 'gastos' || txType == 'deuda') {
                    currentBalance -= txAmount;
                  }
                }

                double newBalance;
                bool shouldReject = false;
                String rejectionMessage = '';

                if (type == 'ingresos') {
                  newBalance = currentBalance - amount;
                  if (newBalance < -9999.99) {
                    shouldReject = true;
                    rejectionMessage =
                        'No se puede eliminar la transacción porque el saldo sería menor a \$-9,999.99.';
                  }
                } else {
                  newBalance = currentBalance + amount;
                  if (newBalance > 9999.99) {
                    shouldReject = true;
                    rejectionMessage =
                        'No se puede eliminar la transacción porque el saldo superaría \$9,999.99.';
                  }
                }

                if (shouldReject) {
                  if (context.mounted) {
                    await _showRejectionDialog(context, rejectionMessage);
                  }
                  return;
                }

                await TransactionDB().deleteTransaction(transaction['id']);

                EventBus().notifyTransactionsUpdated();

                if (context.mounted) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
  );

  if (confirm != true) return;
}

Future<void> _showRejectionDialog(BuildContext context, String message) async {
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text('Error', style: TextStyle(color: Colors.white)),
          content: Text(message, style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Aceptar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
  );
}
