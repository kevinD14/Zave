import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Debt {
  final int? id;
  final String name;
  final double totalAmount;
  final double remainingAmount;
  final String? nextPaymentDate;
  final String createdAt;

  Debt({
    this.id,
    required this.name,
    required this.totalAmount,
    required this.remainingAmount,
    this.nextPaymentDate,
    required this.createdAt,
  });

  Debt copyWith({
    int? id,
    String? name,
    double? totalAmount,
    double? remainingAmount,
    String? nextPaymentDate,
    String? createdAt,
  }) {
    return Debt(
      id: id ?? this.id,
      name: name ?? this.name,
      totalAmount: totalAmount ?? this.totalAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'totalAmount': totalAmount,
      'remainingAmount': remainingAmount,
      'nextPaymentDate': nextPaymentDate,
      'createdAt': createdAt,
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'],
      name: map['name'],
      totalAmount: map['totalAmount'],
      remainingAmount: map['remainingAmount'],
      nextPaymentDate: map['nextPaymentDate'],
      createdAt: map['createdAt'],
    );
  }
}

class DebtDatabase {
  static final DebtDatabase instance = DebtDatabase._init();
  static Database? _database;

  DebtDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('debt.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE debts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        remainingAmount REAL NOT NULL,
        nextPaymentDate TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> addDebt(Debt debt) async {
    final db = await instance.database;
    return await db.insert('debts', debt.toMap());
  }

  Future<List<Debt>> getAllDebts() async {
    final db = await instance.database;
    final result = await db.query('debts', orderBy: 'createdAt DESC');
    return result.map((e) => Debt.fromMap(e)).toList();
  }

  Future<int> payDebt(int debtId, double paymentAmount) async {
    final db = await instance.database;

    final debt = await db.query('debts', where: 'id = ?', whereArgs: [debtId]);

    if (debt.isEmpty) {
      throw Exception('Deuda no encontrada');
    }

    final currentDebt = Debt.fromMap(debt.first);
    final newRemainingAmount = currentDebt.remainingAmount - paymentAmount;

    final updatedDebt = currentDebt.copyWith(
      remainingAmount: newRemainingAmount <= 0 ? 0 : newRemainingAmount,
    );

    return await db.update(
      'debts',
      updatedDebt.toMap(),
      where: 'id = ?',
      whereArgs: [debtId],
    );
  }

  Future<int> updateDebt(Debt debt) async {
    final db = await instance.database;
    return await db.update(
      'debts',
      debt.toMap(),
      where: 'id = ?',
      whereArgs: [debt.id],
    );
  }

  Future<int> deleteDebt(int id) async {
    final db = await instance.database;
    return await db.delete('debts', where: 'id = ?', whereArgs: [id]);
  }

  Future<Debt?> getDebtById(int id) async {
    final db = await instance.database;
    final result = await db.query('debts', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return Debt.fromMap(result.first);
    }
    return null;
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
