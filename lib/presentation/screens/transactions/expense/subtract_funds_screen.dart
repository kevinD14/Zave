import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:myapp/utils/config/max_amount.dart';
import 'package:myapp/utils/config/event_bus.dart';
import 'package:myapp/utils/db/db_helper_transactions.dart';
import 'package:myapp/utils/db/db_category.dart';
import 'package:myapp/utils/config/format_dates.dart';
import 'package:myapp/utils/widgets/build_label.dart';
import 'package:myapp/presentation/screens/transactions/expense/subtract_confirmation_page.dart';
import 'package:myapp/presentation/screens/transactions/funds_rejected_page.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isButtonEnabled = false;

  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_updateButtonState);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await CategoryDatabase.instance.fetchCategories(
      'gastos',
    );
    setState(() {
      _categories = categories;
      if (!_categories.contains('Otros')) {
        _categories.add('Otros');
      }
    });
  }

  void _updateButtonState() {
    final text = _amountController.text.trim();
    final amount = double.tryParse(text);
    setState(() {
      _isButtonEnabled = amount != null && amount >= 0.01;
    });
  }

  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Añadir gasto',
              textAlign: TextAlign.center,
              style: TextStyle(
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

  Widget _buildAmountField() {
    return TextField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontWeight: FontWeight.bold,
      ),
      cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        MaxAmountFormatter(),
      ],
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary,
        hintText: 'Introduce el monto',
        hintStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(150),
        ),
        prefixIcon: Icon(
          Icons.attach_money,
          color:
              _isButtonEnabled
                  ? Theme.of(context).textTheme.bodyLarge?.color
                  : Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color?.withAlpha(150),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      minLines: 1,
      maxLines: 4,
      maxLength: 150,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontWeight: FontWeight.bold,
      ),
      cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
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
  }

  Widget _buildCategoryDropdown() {
    return Container(
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
        items:
            _categories.map((category) {
              return DropdownMenuItem(value: category, child: Text(category));
            }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value;
          });
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    final formattedDate = formatDate(
      DateFormat('dd/MM/yyyy').format(_selectedDate),
    );
    return GestureDetector(
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
                formattedDate,
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
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _isButtonEnabled ? Colors.red : Colors.grey.shade400,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: _isButtonEnabled ? _saveExpenseAndNavigate : null,
        child: Text(
          'Registrar gasto',
          style: TextStyle(
            color:
                _isButtonEnabled
                    ? Colors.white
                    : Colors.grey.shade400.withAlpha(150),
            fontSize: 24,
          ),
        ),
      ),
    );
  }

  Future<void> _saveExpenseAndNavigate() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) return;

    final amount = double.tryParse(amountText);
    if (amount == null) return;

    final String category = _selectedCategory ?? 'Otros';
    final String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);

    final allTransactions = await TransactionDB().getAllTransactions();

    double currentBalance = 0;
    for (final tx in allTransactions) {
      final double txAmount = tx['amount'] ?? 0;
      final String type = tx['type'] ?? '';
      if (type == 'ingresos') {
        currentBalance += txAmount;
      } else if (type == 'gastos') {
        currentBalance -= txAmount;
      }
    }

    final String description =
        _descriptionController.text.trim().isEmpty
            ? 'Ingreso sin descripción'
            : _descriptionController.text.trim();
    final newBalance = currentBalance - amount;

    if (amount > 9999.99 || newBalance < -9999.99) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FundsRejectedPage(isIncome: false),
        ),
      );
      return;
    }

    await TransactionDB().addTransaction(
      amount,
      category,
      formattedDate,
      'gastos',
      description,
    );

    EventBus().notifyTransactionsUpdated();

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseConfirmationPage(amountAdded: amount),
      ),
    ).then((value) {
      if (value == true && mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    });
  }
}
