import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';
import 'package:myapp/utils/db/db_category.dart';
import 'package:myapp/utils/config/event_bus.dart';
import 'package:myapp/utils/config/max_amount.dart';
import 'package:myapp/utils/config/format_dates.dart';
import 'package:myapp/utils/widgets/build_label.dart';
import 'package:myapp/presentation/screens/transactions_all/details/funds_feedback_pages.dart';
import 'package:myapp/presentation/screens/options/categories/edit_categories_screen.dart';

/// Pantalla para editar una transacción existente.
class EditTransactionScreen extends StatefulWidget {
  /// Transacción que se va a editar (contiene los datos actuales).
  final Map<String, dynamic> transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

/// Estado asociado a la pantalla de edición de transacción.
class _EditTransactionScreenState extends State<EditTransactionScreen> {
  /// Controlador para el campo de monto.
  final TextEditingController _amountController = TextEditingController();
  /// Controlador para el campo de descripción.
  final TextEditingController _descriptionController = TextEditingController();
  /// Suscripción para escuchar actualizaciones de categorías.
  StreamSubscription? _categorySubscription;
  /// Categoría seleccionada actualmente.
  String? _selectedCategory;
  /// Fecha seleccionada actualmente.
  DateTime? _selectedDate;
  /// Indica si el botón de guardar está habilitado.
  bool _isButtonEnabled = false;

  /// Lista de categorías disponibles.
  List<String> _categories = [];

  @override
  void initState() {
    // Inicializa los campos con los datos de la transacción recibida.
    // También configura los listeners y carga las categorías.
    super.initState();
    final tx = widget.transaction;
    _amountController.text = tx['amount'].toString();
    _descriptionController.text = tx['description'] ?? '';
    _selectedCategory = tx['category'];
    _selectedDate = DateFormat('dd/MM/yyyy').parse(tx['date']);
    // Actualiza el estado del botón cuando cambia el monto.
    _amountController.addListener(_updateButtonState);
    _updateButtonState();
    _loadCategories(tx['type']);
    // Escucha eventos para recargar categorías si hay cambios.
    _categorySubscription = EventBus().onCategoriesUpdated.listen((event) {
      _loadCategories(tx['type']);
    });
  }

  /// Carga la lista de categorías según el tipo de transacción.
  Future<void> _loadCategories(String type) async {
    final categories = await CategoryDatabase.instance.fetchCategories(type);
    setState(() {
      _categories = categories;
      // Siempre agrega la categoría "Otros" si no está presente.
      if (!_categories.contains('Otros')) _categories.add('Otros');
      // Si la transacción es de tipo "Balance inicial" y no está en la lista, la agrega.
      if (widget.transaction['category'] == 'Balance inicial' &&
          !_categories.contains('Balance inicial')) {
        _categories.add('Balance inicial');
      }
    });
  }

  /// Habilita o deshabilita el botón de guardar según el monto ingresado.
  void _updateButtonState() {
    final text = _amountController.text.trim();
    final amount = double.tryParse(text);
    setState(() {
      _isButtonEnabled = amount != null && amount >= 0.01;
    });
  }

  /// Guarda los cambios realizados en la transacción, validando los datos y mostrando feedback.
  Future<void> _saveChanges() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null) return;

    final description =
        _descriptionController.text.trim().isEmpty
            ? 'Sin descripción'
            : _descriptionController.text.trim();

    final formattedDate = DateFormat(
      'dd/MM/yyyy',
    ).format(_selectedDate ?? DateTime.now());

    final transactions = await TransactionDB().getAllTransactions();

    double ingresos = 0;
    double gastos = 0;

    for (var transaction in transactions) {
      final tipo = transaction['type'];
      final rawMonto = transaction['amount'];
      final monto = rawMonto is int ? rawMonto.toDouble() : (rawMonto ?? 0.0);

      if (transaction['id'] == widget.transaction['id']) continue;

      if (tipo == 'ingresos') {
        ingresos += monto;
      } else if (tipo == 'gastos' || tipo == 'deuda') {
        gastos += monto;
      }
    }

    final isIncome = widget.transaction['type'] == 'ingresos';

    final newBalance =
        isIncome
            ? ingresos + amount - gastos
            : ingresos -
                (gastos - (widget.transaction['amount'] as double) + amount);

    if (amount > 9999.99 || newBalance > 9999.99 || newBalance < -9999.99) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FundsRejectedPage(isIncome: isIncome),
        ),
      );
      return;
    }

    await TransactionDB().updateTransaction(
      id: widget.transaction['id'],
      amount: amount,
      category: _selectedCategory ?? 'Otros',
      date: formattedDate,
      type: widget.transaction['type'],
      description: description,
    );

    EventBus().notifyTransactionsUpdated();

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FundsSuccessPage()),
    ).then((value) {
      if (value == true && mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _categorySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.transaction['type'] == 'ingresos';

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            Text(
              'Editar ${isIncome ? "ingreso" : "gasto"}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            buildLabel('Monto'),
            const SizedBox(height: 8),
            _buildAmountField(),
            const SizedBox(height: 24),
            buildLabel('Categoría'),
            const SizedBox(height: 8),
            _buildCategoryDropdown(),
            const SizedBox(height: 24),
            buildLabel('Descripción'),
            const SizedBox(height: 8),
            _buildDescriptionField(),
            const SizedBox(height: 24),
            buildLabel('Fecha'),
            const SizedBox(height: 8),
            _buildDatePicker(),
            const SizedBox(height: 40),
            _buildSaveButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField() => TextField(
    controller: _amountController,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      MaxAmountFormatter(),
    ],
    style: TextStyle(
      color: Theme.of(context).textTheme.bodyLarge?.color,
      fontWeight: FontWeight.bold,
    ),
    decoration: InputDecoration(
      filled: true,
      fillColor: Theme.of(context).colorScheme.secondary,
      prefixIcon: Icon(
        Icons.attach_money,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      hintText: 'Introduce el monto',
      hintStyle: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(150),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );

  Widget _buildDescriptionField() => TextField(
    controller: _descriptionController,
    minLines: 1,
    maxLines: 4,
    maxLength: 150,
    style: TextStyle(
      color: Theme.of(context).textTheme.bodyLarge?.color,
      fontWeight: FontWeight.bold,
    ),
    decoration: InputDecoration(
      counterText: '',
      filled: true,
      fillColor: Theme.of(context).colorScheme.secondary,
      hintText: 'Descripción (opcional)',
      hintStyle: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(150),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );

  Widget _buildCategoryDropdown() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              borderRadius: BorderRadius.circular(15),
              dropdownColor: Theme.of(context).colorScheme.secondary,
              iconEnabledColor:
                  _selectedCategory == null
                      ? Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(150)
                      : Theme.of(context).textTheme.bodyLarge?.color,
              decoration: const InputDecoration(border: InputBorder.none),
              hint: Text(
                'Selecciona una categoría',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(150),
                ),
              ),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.add, size: 20, color: Theme.of(context).textTheme.bodyLarge?.color,),
            padding: EdgeInsets.zero,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent, 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditCategoriesPage()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() => GestureDetector(
    onTap: _selectDate,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              formatSelectedDate(_selectedDate),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Icon(
            Icons.calendar_today,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ],
      ),
    ),
  );

  Widget _buildSaveButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _isButtonEnabled
                ? Theme.of(context).colorScheme.tertiary
                : Colors.grey.shade400,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: _isButtonEnabled ? _saveChanges : null,
      child: Text(
        'Guardar cambios',
        style: TextStyle(
          color:
              _isButtonEnabled
                  ? Colors.black
                  : Colors.grey.shade400.withAlpha(150),
          fontSize: 24,
        ),
      ),
    ),
  );

  Future<void> _selectDate() async {
    final DateTime initialDate =
        _selectedDate ??
        DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(initialDate.year - 5),
      lastDate: DateTime(initialDate.year + 5),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
