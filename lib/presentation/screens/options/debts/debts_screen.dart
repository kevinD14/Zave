import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/utils/config/format_dates.dart';
import 'package:myapp/utils/db/db_debts.dart';
import 'package:myapp/utils/config/event_bus.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';

// Esta clase representa la pantalla de la deuda donde el usuario puede ver, agregar y pagar deudas.
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
    _loadDebts(); // Carga las deudas al iniciar la pantalla.
  }

  // Método para cargar todas las deudas desde la base de datos.
  Future<void> _loadDebts() async {
    final data = await DebtDatabase.instance.getAllDebts(); // Obtiene las deudas de la base de datos.
    if (!mounted) return; // Verifica que el widget aún esté montado.
    setState(() {
      debts = data; // Actualiza el estado con las deudas obtenidas.
    });
  }

  // Método para mostrar un diálogo de adición de deuda.
  Future<void> _showAddDebtDialog() async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    DateTime? selectedDate; // Variable para almacenar la fecha seleccionada.

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

              // Campo para ingresar el nombre de la deuda.
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la deuda',
                ),
              ),

              // Campo para ingresar el monto de la deuda.
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),

              // Selector de fecha para la próxima fecha de pago.
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
                        setState(() => selectedDate = date); // Establece la fecha seleccionada.
                      }
                    },
                    child: Text(
                      selectedDate != null
                          ? DateFormat('dd/MM/yyyy').format(selectedDate!) // Muestra la fecha seleccionada.
                          : 'Seleccionar',
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [

            // Botón para cancelar la operación.
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pop(context),
            ),

            // Botón para guardar la nueva deuda.
            TextButton(
              child: const Text(
                'Guardar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                final amount = double.tryParse(amountController.text) ?? 0.0;
                if (name.isEmpty || amount <= 0) return;

                // Crea un objeto de deuda con los datos ingresados.
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

                // Agrega la deuda a la base de datos.
                await DebtDatabase.instance.addDebt(debt);

                if (!mounted) return;
                Navigator.pop(context);
                _loadDebts(); // Recarga las deudas para actualizar la lista.
              },
            ),
          ],
        );
      },
    );
  }

  // Método para mostrar un diálogo de pago de deuda.
  Future<void> _payDebtDialog(Debt debt) async {
    // Controlador para el monto de pago de la deuda.
    final amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(

          // Título del cuadro de diálogo, mostrando el nombre de la deuda.
          title: Text(
            'Pagar deuda: ${debt.name}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          // Campo de texto donde el usuario ingresa el monto a pagar.
          content: TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'Monto a pagar'),
            keyboardType: TextInputType.number,
          ),
          actions: [

            // Botón para cancelar la operación.
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pop(context),
            ),

            // Botón para realizar el pago de la deuda.
            TextButton(
              child: const Text(
                'Pagar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              // Intentar parsear el monto a pagar desde el campo de texto.
              onPressed: () async {
                final amount = double.tryParse(amountController.text) ?? 0;

                 // Validar que el monto sea válido (mayor que 0 y no mayor que la cantidad restante de la deuda).
                if (amount <= 0 || amount > debt.remainingAmount) return;

                // Actualizar la deuda con el pago realizado.
                await DebtDatabase.instance.payDebt(debt.id!, amount);
                final String description = ' '; // Descripción vacía para la transacción.

                // Fecha de la transacción.
                final transactionDate = DateFormat(
                  'dd/MM/yyyy',
                ).format(DateTime.now());

                // Registrar la transacción en la base de datos.
                await TransactionDB().addTransaction(
                  amount,
                  debt.name,
                  transactionDate,
                  'deuda',
                  description,
                );

                // Notificar a los suscriptores que las transacciones han sido actualizadas.
                EventBus().notifyTransactionsUpdated();

                if (!mounted) return;
                Navigator.pop(context);
                _loadDebts(); // Recargar las deudas después del pago.
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editDebtDialog(Debt debt) async {
    // Controladores para los campos de edición de deuda.
    final nameController = TextEditingController(text: debt.name);
    final amountController = TextEditingController(
      text: debt.totalAmount.toString(),
    );

    // Convertir la fecha de pago de la deuda a un objeto DateTime, si está presente.
    DateTime? selectedDate =
        debt.nextPaymentDate != null
            ? DateFormat('dd/MM/yyyy').parse(debt.nextPaymentDate!)
            : null;

    // Mostrar el cuadro de diálogo para editar la deuda.
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          // Título del cuadro de diálogo de edición.
          title: const Text(
            'Editar Deuda',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Campo de texto para editar el nombre de la deuda.
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la deuda',
                ),
              ),

              // Campo de texto para editar el monto total de la deuda.
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Monto total'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),

              // Fila para seleccionar la fecha de pago.
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
                      // Mostrar el selector de fecha para la fecha de pago.
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      // Si se selecciona una fecha, actualizar el valor seleccionado.
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

            // Botón para cancelar la operación de edición.
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pop(context),
            ),

            // Botón para guardar los cambios en la deuda.
            TextButton(
              child: const Text(
                'Guardar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                // Obtener los nuevos valores ingresados.
                final newName = nameController.text.trim();
                final newAmount =
                    double.tryParse(amountController.text) ?? debt.totalAmount;

                // Validar que el nuevo monto sea mayor que la deuda restante.
                if (newName.isEmpty ||
                    newAmount < debt.totalAmount - debt.remainingAmount) {
                  return;
                }

                // Crear una nueva instancia de la deuda con los valores actualizados.
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

                // Actualizar la deuda en la base de datos.
                await DebtDatabase.instance.updateDebt(updatedDebt);

                if (!mounted) return;
                Navigator.pop(context);
                _loadDebts(); // Recargar las deudas después de la actualización.
              },
            ),
          ],
        );
      },
    );
  }

  // Función para confirmar la eliminación de una deuda
  Future<void> _confirmDeleteDebt(int id) async {
    // Muestra un cuadro de diálogo de confirmación
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

    // Si el usuario confirma la eliminación
    if (confirm == true) {
      await DebtDatabase.instance.deleteDebt(id); // Elimina la deuda de la base de datos
      if (mounted) _loadDebts(); // Recarga la lista de deudas si el widget está montado
    }
  }

  // Método build que genera la interfaz del widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Deudas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDebtDialog, // Muestra el diálogo para añadir una deuda
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
              ? Center( // Si no hay deudas, muestra un mensaje
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
                  final isPaid = debt.remainingAmount <= 0; // Verificamos si la deuda está pagada

                  // Devuelve un card con la información de la deuda
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
