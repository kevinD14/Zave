import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CategoryDatabase {
  static final CategoryDatabase instance = CategoryDatabase._init();
  static Database? _database;

  CategoryDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('categories.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertCategory(String name, String type) async {
    final db = await instance.database;
    await db.insert('categories', {'name': name, 'type': type});
  }

  Future<List<String>> fetchCategories(String type) async {
    final db = await instance.database;
    final result = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
    );

    return result.map((row) => row['name'] as String).toList();
  }

  Future<void> deleteCategory(String name, String type) async {
    final db = await instance.database;
    await db.delete(
      'categories',
      where: 'name = ? AND type = ?',
      whereArgs: [name, type],
    );
  }

  Future<void> insertDefaultCategoriesIfEmpty() async {
    final db = await database;

    final result = await db.query('categories');
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
    final db = await instance.database;
    db.close();
  }
}
