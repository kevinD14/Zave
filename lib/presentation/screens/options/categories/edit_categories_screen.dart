import 'package:flutter/material.dart';
import 'package:myapp/utils/db/db_category.dart';
import 'package:myapp/utils/config/event_bus.dart';

class EditCategoriesPage extends StatefulWidget {
  const EditCategoriesPage({super.key});

  @override
  State<EditCategoriesPage> createState() => _EditCategoriesPageState();
}

class _EditCategoriesPageState extends State<EditCategoriesPage> {
  final TextEditingController _controller = TextEditingController();
  String selectedType = 'ingresos';

  Map<String, List<String>> categories = {'ingresos': [], 'gastos': []};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final ingresos = await CategoryDatabase.instance.fetchCategories(
      'ingresos',
    );
    final gastos = await CategoryDatabase.instance.fetchCategories('gastos');
    setState(() {
      categories['ingresos'] = ingresos;
      categories['gastos'] = gastos;
    });
  }

  Future<void> _addCategory() async {
    final newCategory = _controller.text.trim();
    if (newCategory.isNotEmpty &&
        !categories[selectedType]!.contains(newCategory)) {
      await CategoryDatabase.instance.insertCategory(newCategory, selectedType);
      EventBus().notifyCategoriesUpdated();
      setState(() {
        categories[selectedType]!.add(newCategory);
        _controller.clear();
      });
    }
  }

  Future<void> _deleteCategory(String category) async {
    await CategoryDatabase.instance.deleteCategory(category, selectedType);
    setState(() {
      categories[selectedType]!.remove(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Categorías'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [
                selectedType == 'ingresos',
                selectedType == 'gastos',
              ],
              onPressed: (index) async {
                setState(() {
                  selectedType = index == 0 ? 'ingresos' : 'gastos';
                });
              },
              borderRadius: BorderRadius.circular(10),
              renderBorder: false,
              constraints: const BoxConstraints(minHeight: 45),
              children: List.generate(2, (index) {
                final isSelected =
                    (index == 0 && selectedType == 'ingresos') ||
                    (index == 1 && selectedType == 'gastos');
                final text = index == 0 ? 'Ingresos' : 'Gastos';

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  color: isSelected ? color : Colors.grey.withAlpha(300),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? textColor : Colors.grey.withAlpha(180),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
                    controller: _controller,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: 'Nueva categoría',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.color?.withAlpha(204),
                      ),
                      filled: true,
                      fillColor: color,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      counter: const SizedBox.shrink(),
                    ),
                    maxLength: 15,
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  height: 60,
                  width: 120,
                  child: ElevatedButton(
                    onPressed: _addCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Agregar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children:
                    categories[selectedType]!
                        .map(
                          (cat) => Card(
                            color: color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              title: Text(
                                cat,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                ),
                                onPressed: () => _deleteCategory(cat),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
