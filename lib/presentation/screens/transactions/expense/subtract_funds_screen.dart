import 'dart:async';
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
import 'package:myapp/presentation/screens/options/categories/edit_categories_screen.dart';

// Pantalla para añadir transacciones de tipo "gastos"
class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  // Controlador para el campo de monto ingresado.
  final TextEditingController _amountController = TextEditingController();

  // Controlador para la descripción de la transacción.
  final TextEditingController _descriptionController = TextEditingController();

  // Suscripción para escuchar actualizaciones de las categorías.
  StreamSubscription? _categorySubscription;

  // Categoría seleccionada por el usuario.
  String? _selectedCategory;

  // Fecha seleccionada para la transacción (por defecto es hoy).
  DateTime _selectedDate = DateTime.now();

  // Indica si el botón de guardar está habilitado o no.
  bool _isButtonEnabled = false;

  // Lista de categorías disponibles para gastos.
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();

    // Se añade un listener al campo de monto para habilitar/deshabilitar el botón.
    _amountController.addListener(_updateButtonState);

    // Carga las categorías desde la base de datos.
    _loadCategories();

    // Se suscribe al evento de actualización de categorías.
    _categorySubscription = EventBus().onCategoriesUpdated.listen((event) {
      _loadCategories(); // Vuelve a cargar las categorías si hay cambios.
    });
  }

  // Función que carga las categorías desde la base de datos filtrando por "gastos".
  Future<void> _loadCategories() async {
    final categories = await CategoryDatabase.instance.fetchCategories(
      'gastos',
    );
    setState(() {
      _categories = categories;

      // Asegura que siempre exista la categoría "Otros".
      if (!_categories.contains('Otros')) {
        _categories.add('Otros');
      }
    });
  }

  // Función que actualiza el estado del botón según si el monto es válido.
  void _updateButtonState() {
    final text = _amountController.text.trim();
    final amount = double.tryParse(text);
    setState(() {
      _isButtonEnabled = amount != null && amount >= 0.01;
    });
  }

  // Muestra un selector de fecha y actualiza la fecha seleccionada si el usuario elige una.
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
        _selectedDate = picked; // Actualiza la fecha si se eligió una válida.
      });
    }
  }

  @override
  void dispose() {
    // Libera los controladores y cancela la suscripción para evitar fugas de memoria.
    _amountController.dispose();
    _descriptionController.dispose();
    _categorySubscription?.cancel();
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

      // Cuerpo principal de la pantalla con paddings laterales.
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        // Utiliza ListView para que el contenido sea scrollable si hay overflow.
        child: ListView(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Añadir gasto',
              textAlign: TextAlign.center,

              // Título principal de la pantalla.
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Etiqueta y campo de texto para el monto.
            const SizedBox(height: 40),
            buildLabel('Monto'),
            const SizedBox(height: 8),
            _buildAmountField(),
            const SizedBox(height: 24),

            // Etiqueta y menú desplegable para seleccionar categoría.
            buildLabel('Categoría'),
            const SizedBox(height: 8),
            _buildCategoryDropdown(),
            const SizedBox(height: 24),

            // Etiqueta y campo de texto para la descripción.
            buildLabel('Descripción'),
            const SizedBox(height: 8),
            _buildDescriptionField(),
            const SizedBox(height: 24),

            // Etiqueta y botón para seleccionar la fecha.
            buildLabel('Fecha'),
            const SizedBox(height: 8),
            _buildDatePicker(),
            const SizedBox(height: 40),

            // Botón para guardar el gasto.
            _buildSaveButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget que construye el campo de texto para ingresar el monto.
  Widget _buildAmountField() {
    return TextField(
      controller: _amountController, // Asocia el controlador al campo.
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ), // Solo números y punto decimal.
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontWeight: FontWeight.bold,
      ),
      cursorColor: Theme.of(context).textTheme.bodyLarge?.color,

      // Filtros para restringir el formato del número (hasta 2 decimales).
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        MaxAmountFormatter(), // Formateador personalizado para limitar el valor.
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
          color: _isButtonEnabled
              ? Theme.of(context).textTheme.bodyLarge?.color
              : Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(150),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Widget que construye el campo de texto para ingresar la descripción.
  Widget _buildDescriptionField() {
    return TextField(
      controller:
          _descriptionController, // Controlador para acceder al texto ingresado.
      minLines: 1,
      maxLines: 4, // Permite que el campo crezca hasta 4 líneas.
      maxLength: 150, // Límite de caracteres.
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

  // Widget que construye el menú desplegable para elegir categoría.
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

            // Dropdown para seleccionar categoría
            child: DropdownButtonFormField<String>(
              value: _selectedCategory, // Categoría seleccionada actualmente
              borderRadius: BorderRadius.circular(15),
              dropdownColor: Theme.of(context).colorScheme.secondary,
              iconEnabledColor: _selectedCategory == null
                  ? Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(150)
                  : Theme.of(context).textTheme.bodyLarge?.color,
              decoration: const InputDecoration(border: InputBorder.none),
              hint: Text(
                'Selecciona una categoría',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color?.withAlpha(150),
                ),
              ),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),

              // Lista de opciones del Dropdown
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

        // Botón para añadir nuevas categorías
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              Icons.add,
              size: 20,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
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

  // Widget que construye campo para elegir fecha de la transacción.
  Widget _buildDatePicker() {
    // Convierte la fecha seleccionada a formato legible
    final formattedDate = formatDate(
      DateFormat('dd/MM/yyyy').format(_selectedDate),
    );

    return GestureDetector(
      onTap: _selectDate, // Abre el selector de fecha al tocar el campo
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

  // Widget que construye boton de guardar transacción.
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
        onPressed: _isButtonEnabled
            ? _saveExpenseAndNavigate
            : null, // Solo habilitado si los datos son válidos
        child: Text(
          'Registrar gasto',
          style: TextStyle(
            color: _isButtonEnabled
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

    // Obtiene todas las transacciones para calcular el balance actual
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

    // Obtiene la descripción o asigna una por defecto
    final String description = _descriptionController.text.trim().isEmpty
        ? 'Ingreso sin descripción'
        : _descriptionController.text.trim();
    final newBalance = currentBalance - amount;

    // Rechaza si excede los límites de balance permitidos
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

    // Guarda la transacción como gasto
    await TransactionDB().addTransaction(
      amount,
      category,
      formattedDate,
      'gastos',
      description,
    );

    // Notifica a otras partes de la app que se ha actualizado la base de datos
    EventBus().notifyTransactionsUpdated();

    // Navega a la página de confirmación
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
