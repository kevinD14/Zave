import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Modelo de datos para representar una deuda.
class Debt {
  // Identificador único de la deuda.
  final int? id;
  // Nombre de la deuda o acreedor.
  final String name;
  // Monto total de la deuda.
  final double totalAmount;
  // Monto restante por pagar.
  final double remainingAmount;
  // Fecha del próximo pago (puede ser null).
  final String? nextPaymentDate;
  // Fecha de creación de la deuda.
  final String createdAt;

  // Constructor de la clase Debt.
  Debt({
    this.id,
    required this.name,
    required this.totalAmount,
    required this.remainingAmount,
    this.nextPaymentDate,
    required this.createdAt,
  });

  // Crea una copia de la deuda con valores actualizados.
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

  // Convierte la deuda a un mapa para almacenar en la base de datos.
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

  // Crea una instancia de Debt a partir de un mapa (de la base de datos).
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

// Clase para gestionar la base de datos de deudas.
class DebtDatabase {
  // Instancia singleton para acceder a la base de datos.
  static final DebtDatabase instance = DebtDatabase._init();
  // Referencia a la base de datos SQLite.
  static Database? _database;

  // Constructor privado para el patrón singleton.
  DebtDatabase._init();

  // Devuelve la base de datos, inicializándola si es necesario.
  Future<Database> get database async {
    // Si la base de datos ya está inicializada, la retorna.
    if (_database != null) return _database!;
    // Inicializa la base de datos si no existe.
    _database = await _initDB('debt.db');
    return _database!;
  }

  // Inicializa la base de datos en la ruta especificada.
  Future<Database> _initDB(String fileName) async {
    // Obtiene la ruta de almacenamiento de bases de datos.
    final dbPath = await getDatabasesPath();
    // Construye la ruta completa del archivo de base de datos.
    final path = join(dbPath, fileName);

    // Abre la base de datos y ejecuta _createDB si es la primera vez.
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Crea la tabla de deudas si no existe.
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

  // Inserta una nueva deuda en la base de datos.
  Future<int> addDebt(Debt debt) async {
    final db = await instance.database;
    // Inserta la deuda y retorna el id generado.
    return await db.insert('debts', debt.toMap());
  }

  // Obtiene la lista de todas las deudas ordenadas por fecha de creación descendente.
  Future<List<Debt>> getAllDebts() async {
    final db = await instance.database;
    // Consulta todas las deudas ordenadas por fecha de creación descendente.
    final result = await db.query('debts', orderBy: 'createdAt DESC');
    // Convierte cada registro del resultado en una instancia de Debt.
    return result.map((e) => Debt.fromMap(e)).toList();
  }

  // Realiza un pago a una deuda, actualizando el monto restante.
  Future<int> payDebt(int debtId, double paymentAmount) async {
    final db = await instance.database;

    // Busca la deuda por su id.
    final debt = await db.query('debts', where: 'id = ?', whereArgs: [debtId]);

    // Si no se encuentra la deuda, lanza una excepción.
    if (debt.isEmpty) {
      throw Exception('Deuda no encontrada');
    }

    // Obtiene la deuda actual desde el primer resultado.
    final currentDebt = Debt.fromMap(debt.first);
    // Calcula el nuevo monto restante después del pago.
    final newRemainingAmount = currentDebt.remainingAmount - paymentAmount;

    // Crea una nueva instancia de Debt con el monto actualizado (no menor a 0).
    final updatedDebt = currentDebt.copyWith(
      remainingAmount: newRemainingAmount <= 0 ? 0 : newRemainingAmount,
    );

    // Actualiza la deuda en la base de datos y retorna la cantidad de filas modificadas.
    return await db.update(
      'debts',
      updatedDebt.toMap(),
      where: 'id = ?',
      whereArgs: [debtId],
    );
  }

  // Actualiza una deuda existente en la base de datos.
  Future<int> updateDebt(Debt debt) async {
    final db = await instance.database;
    // Actualiza la deuda y retorna la cantidad de filas modificadas.
    return await db.update(
      'debts',
      debt.toMap(),
      where: 'id = ?',
      whereArgs: [debt.id],
    );
  }

  // Elimina una deuda de la base de datos por su id.
  Future<int> deleteDebt(int id) async {
    final db = await instance.database;
    // Elimina la deuda y retorna la cantidad de filas eliminadas.
    return await db.delete('debts', where: 'id = ?', whereArgs: [id]);
  }

  // Obtiene una deuda por su id, retorna null si no existe.
  Future<Debt?> getDebtById(int id) async {
    final db = await instance.database;
    // Busca la deuda por id.
    final result = await db.query('debts', where: 'id = ?', whereArgs: [id]);

    // Si encuentra la deuda, la retorna como objeto Debt.
    if (result.isNotEmpty) {
      return Debt.fromMap(result.first);
    }
    // Si no existe, retorna null.
    return null;
  }

  // Cierra la base de datos.
  Future<void> close() async {
    // Obtiene la instancia de la base de datos y la cierra.
    final db = await instance.database;
    await db.close();
  }
}
