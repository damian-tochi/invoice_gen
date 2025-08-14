import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class AppDB {
  static final AppDB instance = AppDB._init();
  static Database? _database;

  AppDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientName TEXT NOT NULL,
        clientEmail TEXT,
        clientPhone TEXT,
        clientAddress TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientId INTEGER NOT NULL,
        invoiceTitle TEXT,
        invoiceDate TEXT,
        paymentStatus TEXT,
        total REAL,
        subTotal TEXT,
        taxDeduction TEXT,
        signature BLOB,
        transactionId INTEGER NOT NULL,
        invoiceType INTEGER NOT NULL,
        FOREIGN KEY (clientId) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transactionId INTEGER NOT NULL,
        description TEXT,
        price REAL,
        quantity INTEGER,
        FOREIGN KEY (transactionId) REFERENCES transactions (id) ON DELETE CASCADE
      )
    ''');
  }
}
