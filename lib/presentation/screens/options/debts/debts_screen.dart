import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/utils/config/format_dates.dart';
import 'package:myapp/utils/db/db_debts.dart';
import 'package:myapp/utils/config/event_bus.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  List<Debt> debts = [];

  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

  Future<void> _loadDebts() async {
    final data = await DebtDatabase.instance.getAllDebts();
    if (!mounted) return;
    setState(() {
      debts = data;
    });
  }

  Future<void> _showAddDebtDialog() async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Nueva Deuda',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la deuda',
                ),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Próxima fecha: ',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null && mounted) {
                        setState(() => selectedDate = date);
                      }
                    },
                    child: Text(
                      selectedDate != null
                          ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                          : 'Seleccionar',
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text(
                'Guardar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                final amount = double.tryParse(amountController.text) ?? 0.0;
                if (name.isEmpty || amount <= 0) return;

                final debt = Debt(
                  name: name,
                  totalAmount: amount,
                  remainingAmount: amount,
                  nextPaymentDate:
                      selectedDate != null
                          ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                          : null,
                  createdAt: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                );

                await DebtDatabase.instance.addDebt(debt);

                if (!mounted) return;
                Navigator.pop(context);
                _loadDebts();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _payDebtDialog(Debt debt) async {
    final amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            'Pagar deuda: ${debt.name}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'Monto a pagar'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text(
                'Pagar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount <= 0 || amount > debt.remainingAmount) return;

                await DebtDatabase.instance.payDebt(debt.id!, amount);
                final String description = ' ';

                final transactionDate = DateFormat(
                  'dd/MM/yyyy',
                ).format(DateTime.now());
                await TransactionDB().addTransaction(
                  amount,
                  debt.name,
                  transactionDate,
                  'deuda',
                  description,
                );

                EventBus().notifyTransactionsUpdated();

                if (!mounted) return;
                Navigator.pop(context);
                _loadDebts();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editDebtDialog(Debt debt) async {
    final nameController = TextEditingController(text: debt.name);
    final amountController = TextEditingController(
      text: debt.totalAmount.toString(),
    );
    DateTime? selectedDate =
        debt.nextPaymentDate != null
            ? DateFormat('dd/MM/yyyy').parse(debt.nextPaymentDate!)
            : null;

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Editar Deuda',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la deuda',
                ),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Monto total'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Próxima fecha: ',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null && mounted) {
                        setState(() => selectedDate = date);
                      }
                    },
                    child: Text(
                      selectedDate != null
                          ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                          : 'Seleccionar',
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text(
                'Guardar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                final newName = nameController.text.trim();
                final newAmount =
                    double.tryParse(amountController.text) ?? debt.totalAmount;

                if (newName.isEmpty ||
                    newAmount < debt.totalAmount - debt.remainingAmount) {
                  return;
                }

                final updatedDebt = debt.copyWith(
                  name: newName,
                  totalAmount: newAmount,
                  remainingAmount:
                      newAmount - (debt.totalAmount - debt.remainingAmount),
                  nextPaymentDate:
                      selectedDate != null
                          ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                          : null,
                );

                await DebtDatabase.instance.updateDebt(updatedDebt);

                if (!mounted) return;
                Navigator.pop(context);
                _loadDebts();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteDebt(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            '¿Eliminar deuda?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Esta acción no se puede deshacer.',
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodyLarge?.color?.withAlpha(204),
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: const Text(
                'Eliminar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await DebtDatabase.instance.deleteDebt(id);
      if (mounted) _loadDebts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Deudas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDebtDialog,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          "Añadir deuda",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor:
            Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).colorScheme.tertiary
                : null,
      ),
      body:
          debts.isEmpty
              ? Center(
                child: Text(
                  'Sin deudas actualmente.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : ListView.builder(
                itemCount: debts.length,
                itemBuilder: (context, index) {
                  final debt = debts[index];
                  final isPaid = debt.remainingAmount <= 0;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Theme.of(context).colorScheme.secondary,
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            debt.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              text: 'Monto total: ',
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      '\$${debt.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              text: 'Saldo restante: ',
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      '\$${debt.remainingAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (debt.nextPaymentDate != null)
                            Text.rich(
                              TextSpan(
                                text: 'Próxima fecha: ',
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                ),
                                children: [
                                  TextSpan(
                                    text: formatDate(debt.nextPaymentDate!),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!isPaid)
                                IconButton(
                                  icon: Icon(
                                    Icons.payment,
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                  ),
                                  onPressed: () => _payDebtDialog(debt),
                                ),
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                ),
                                onPressed: () => _editDebtDialog(debt),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                ),
                                onPressed: () => _confirmDeleteDebt(debt.id!),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
