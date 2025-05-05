import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class TransactionDB {
  static final TransactionDB _instance = TransactionDB._internal();
  factory TransactionDB() => _instance;
  TransactionDB._internal();

  Database? _db;
  final StreamController<List<Map<String, dynamic>>>
  _transactionsStreamController = StreamController.broadcast();

  Stream<List<Map<String, dynamic>>> get transactionsStream =>
      _transactionsStreamController.stream;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'transactions.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
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

  Future<void> addTransaction(
    double amount,
    String category,
    String date,
    String type,
    String description,
  ) async {
    final db = await database;
    await db.insert('transactions', {
      'amount': amount,
      'category': category,
      'date': date,
      'type': type,
      'description': description,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    _fetchTransactions();
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    return await db.query('transactions', orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> getLastTransactions({
    int limit = 5,
  }) async {
    final db = await database;
    return await db.query('transactions', orderBy: 'date DESC', limit: limit);
  }

  Future<void> deleteAllTransactions() async {
    final db = await database;
    await db.delete('transactions');
    _fetchTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    _fetchTransactions();
  }

  Future<void> updateTransaction({
    required int id,
    required double amount,
    required String category,
    required String date,
    required String type,
    required String description,
  }) async {
    final db = await database;
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

  Future<void> _fetchTransactions() async {
    if (!_transactionsStreamController.isClosed) {
      final transactions = await getAllTransactions();
      _transactionsStreamController.sink.add(transactions);
    }
  }

  void dispose() {
    _transactionsStreamController.close();
  }
}
