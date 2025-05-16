import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

// Clase para gestionar la base de datos de transacciones.
class TransactionDB {
  // Instancia singleton para acceder a la base de datos.
  static final TransactionDB _instance = TransactionDB._internal();
  // Constructor factory para retornar siempre la misma instancia.
  factory TransactionDB() => _instance;
  // Constructor privado para el patrón singleton.
  TransactionDB._internal();

  // Referencia a la base de datos SQLite.
  Database? _db;
  // Controlador de stream para emitir la lista de transacciones a los listeners.
  final StreamController<List<Map<String, dynamic>>>
  _transactionsStreamController = StreamController.broadcast();

  // Getter para acceder al stream de transacciones.
  Stream<List<Map<String, dynamic>>> get transactionsStream =>
      _transactionsStreamController.stream;

  // Devuelve la base de datos, inicializándola si es necesario.
  Future<Database> get database async {
    // Si la base de datos ya está inicializada, la retorna.
    if (_db != null) return _db!;
    // Inicializa la base de datos si no existe.
    _db = await _initDB();
    return _db!;
  }

  // Inicializa la base de datos y crea la tabla de transacciones si es necesario.
  Future<Database> _initDB() async {
    // Obtiene la ruta de almacenamiento de bases de datos.
    final dbPath = await getDatabasesPath();
    // Construye la ruta completa del archivo de base de datos.
    final path = join(dbPath, 'transactions.db');

    // Abre la base de datos y crea la tabla si es la primera vez.
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Crea la tabla de transacciones con los campos necesarios.
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL,
            category TEXT,
            date TEXT,
            type TEXT,
            description TEXT
          )
        ''');
      },
    );
  }

  // Inserta una nueva transacción en la base de datos.
  Future<void> addTransaction(
    double amount,
    String category,
    String date,
    String type,
    String description,
  ) async {
    final db = await database;
    // Inserta la transacción y reemplaza si ya existe una con el mismo id.
    await db.insert('transactions', {
      'amount': amount,
      'category': category,
      'date': date,
      'type': type,
      'description': description,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    _fetchTransactions();
  }

  // Obtiene la lista de todas las transacciones ordenadas por id descendente.
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    // Consulta todas las transacciones ordenadas por id descendente.
    return await db.query('transactions', orderBy: 'id DESC');
  }

  // Obtiene las últimas transacciones según el límite especificado.
  Future<List<Map<String, dynamic>>> getLastTransactions({
    int limit = 10,
  }) async {
    final db = await database;

    // Consulta todas las transacciones ordenadas por fecha ascendente.
    final all = await db.query('transactions', orderBy: 'date ASC');

    // Cuenta la cantidad total de transacciones.
    final count = all.length;

    // Si hay menos transacciones que el límite, retorna todas.
    if (count <= limit) return all;

    // Retorna solo las últimas transacciones según el límite.
    return all.sublist(count - limit);
  }

  // Elimina todas las transacciones de la base de datos.
  Future<void> deleteAllTransactions() async {
    final db = await database;
    // Elimina todos los registros de la tabla de transacciones.
    await db.delete('transactions');
    _fetchTransactions();
  }

  // Elimina una transacción específica por su id.
  Future<void> deleteTransaction(int id) async {
    final db = await database;
    // Elimina la transacción con el id especificado.
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    _fetchTransactions();
  }

  // Actualiza los datos de una transacción existente.
  Future<void> updateTransaction({
    required int id,
    required double amount,
    required String category,
    required String date,
    required String type,
    required String description,
  }) async {
    final db = await database;
    // Actualiza la transacción en la base de datos.
    await db.update(
      'transactions',
      {
        'amount': amount,
        'category': category,
        'date': date,
        'type': type,
        'description': description,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    _fetchTransactions();
  }

  // Obtiene todas las transacciones y las emite por el stream si el controlador está abierto.
  Future<void> _fetchTransactions() async {
    // Solo emite si el stream no está cerrado.
    if (!_transactionsStreamController.isClosed) {
      // Obtiene todas las transacciones actuales.
      final transactions = await getAllTransactions();
      // Emite la lista de transacciones a los listeners del stream.
      _transactionsStreamController.sink.add(transactions);
    }
  }

  // Cierra el controlador del stream para liberar recursos.
  void dispose() {
    // Cierra el stream controller.
    _transactionsStreamController.close();
  }
}
