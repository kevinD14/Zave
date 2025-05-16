import 'package:flutter/material.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';
import 'package:myapp/utils/config/event_bus.dart';

// Muestra un diálogo de confirmación antes de eliminar una transacción.
// Valida los límites del balance antes de proceder con la eliminación.
Future<void> confirmDeleteTransaction(
  BuildContext context,
  Map<String, dynamic> transaction,
) async {
  // Obtiene el monto y tipo de la transacción a eliminar.
  final amount = (transaction['amount'] as num).toDouble();
  final type = transaction['type'];

  // Determina el mensaje de cambio de balance según el tipo de transacción.
  final changeText = type == 'ingresos'
      ? 'Se restarán \$${amount.toStringAsFixed(2)} del balance.'
      : 'Se sumarán \$${amount.toStringAsFixed(2)} al balance.';

  // Muestra el diálogo de confirmación con detalles de la transacción y advertencias si aplica.
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text(
        '¿Eliminar transacción?',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Si la transacción es de tipo deuda, muestra advertencia especial.
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
        // Botón para cancelar la eliminación.
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        // Botón para confirmar la eliminación. Realiza validaciones antes de eliminar.
        TextButton(
          onPressed: () async {
            Navigator.pop(ctx);

            // Obtiene todas las transacciones para calcular el balance actual.
            final allTransactions = await TransactionDB().getAllTransactions();

            double currentBalance = 0;
            for (final tx in allTransactions) {
              final double txAmount = (tx['amount'] as num).toDouble();
              final String txType = tx['type'] ?? '';
              // Suma o resta al balance según el tipo de transacción.
              if (txType == 'ingresos') {
                currentBalance += txAmount;
              } else if (txType == 'gastos' || txType == 'deuda') {
                currentBalance -= txAmount;
              }
            }

            double newBalance;
            bool shouldReject = false;
            String rejectionMessage = '';

            // Valida que el balance no sobrepase los límites permitidos después de la eliminación.
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

            // Si no pasa la validación, muestra un diálogo de rechazo y no elimina.
            if (shouldReject) {
              if (context.mounted) {
                await _showRejectionDialog(context, rejectionMessage);
              }
              return;
            }

            // Elimina la transacción de la base de datos.
            await TransactionDB().deleteTransaction(transaction['id']);

            // Notifica a la app que las transacciones han cambiado.
            EventBus().notifyTransactionsUpdated();

            // Cierra los diálogos y regresa a la pantalla principal.
            if (context.mounted) {
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          },
          child: const Text(
            'Eliminar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  // Si el usuario cancela, no hace nada.
  if (confirm != true) return;
}

// Muestra un diálogo de error si la eliminación no es permitida por los límites del balance.
Future<void> _showRejectionDialog(BuildContext context, String message) async {
  // Verifica que el contexto siga montado antes de mostrar el diálogo.
  if (!context.mounted) return;

  // Muestra el diálogo de error con el mensaje correspondiente.
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text('Error', style: TextStyle(color: Colors.white)),
      content: Text(message, style: TextStyle(color: Colors.white70)),
      actions: [
        /// Botón para cerrar el diálogo de error.
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
