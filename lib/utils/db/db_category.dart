// Importa sqflite para el manejo de base de datos SQLite en Flutter.
import 'package:sqflite/sqflite.dart';
// Importa path para construir rutas de archivos de base de datos.
import 'package:path/path.dart';

// Clase para gestionar la base de datos de categorías.
class CategoryDatabase {
  // Instancia singleton para acceder a la base de datos.
  static final CategoryDatabase instance = CategoryDatabase._init();
  // Referencia a la base de datos SQLite.
  static Database? _database;

  // Constructor privado para el patrón singleton.
  CategoryDatabase._init();

  // Devuelve la base de datos, inicializándola si es necesario.
  Future<Database> get database async {
    // Si la base de datos ya está inicializada, la retorna.
    if (_database != null) return _database!;
    // Inicializa la base de datos si no existe.
    _database = await _initDB('categories.db');
    return _database!;
  }

  // Inicializa la base de datos en la ruta especificada.
  Future<Database> _initDB(String filePath) async {
    // Obtiene la ruta de almacenamiento de bases de datos.
    final dbPath = await getDatabasesPath();
    // Construye la ruta completa del archivo de base de datos.
    final path = join(dbPath, filePath);

    // Abre la base de datos y ejecuta _createDB si es la primera vez.
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Crea la tabla de categorías si no existe.
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');
  }

  // Inserta una nueva categoría en la base de datos.
  Future<void> insertCategory(String name, String type) async {
    final db = await instance.database;
    await db.insert('categories', {'name': name, 'type': type});
  }

  // Obtiene la lista de nombres de categorías según el tipo.
  Future<List<String>> fetchCategories(String type) async {
    final db = await instance.database;
    final result = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
    );

    // Retorna solo los nombres de las categorías.
    return result.map((row) => row['name'] as String).toList();
  }

  // Elimina una categoría específica según nombre y tipo.
  Future<void> deleteCategory(String name, String type) async {
    final db = await instance.database;
    // Elimina la categoría correspondiente.
    await db.delete(
      'categories',
      where: 'name = ? AND type = ?',
      whereArgs: [name, type],
    );
  }

  // Inserta categorías por defecto si la tabla está vacía.
  Future<void> insertDefaultCategoriesIfEmpty() async {
    // Obtiene la instancia de la base de datos.
    final db = await database;

    // Consulta todas las categorías existentes.
    final result = await db.query('categories');
    // Si no hay categorías, inserta las predeterminadas.
    if (result.isEmpty) {
      final defaultCategories = {
        'ingresos': ['Salario', 'Ventas', 'Premios'],
        'gastos': ['Comida', 'Transporte', 'Ocio'],
      };

      for (final type in defaultCategories.keys) {
        for (final name in defaultCategories[type]!) {
          await db.insert('categories', {'name': name, 'type': type});
        }
      }
    }
  }

  Future close() async {
    // Obtiene la instancia de la base de datos y la cierra.
    final db = await instance.database;
    db.close();
  }
}
