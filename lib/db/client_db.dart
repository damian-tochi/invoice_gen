import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/client_object.dart';


class CustomerDB {
  static final CustomerDB instance = CustomerDB._init();
  static Database? _database;

  CustomerDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('customers.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientName TEXT NOT NULL,
        clientEmail TEXT,
        clientPhone TEXT,
        clientAddress TEXT
      )
    ''');
  }

  Future<List<ClientObject>> getCustomers({String? search, bool ascending = true}) async {
    final db = await instance.database;
    String orderBy = 'clientName ${ascending ? 'ASC' : 'DESC'}';
    String where = '';
    List<dynamic> whereArgs = [];

    if (search != null && search.isNotEmpty) {
      where = 'WHERE clientName LIKE ? OR clientEmail LIKE ? OR clientPhone LIKE ?';
      final searchTerm = '%$search%';
      whereArgs = [searchTerm, searchTerm, searchTerm];
    }

    final result = await db.rawQuery('SELECT * FROM customers $where ORDER BY $orderBy', whereArgs);
    return result.map((json) => ClientObject.fromMap(json)).toList();
  }

  Future<int> addCustomer(ClientObject customer) async {
    final db = await instance.database;
    return await db.insert('customers', customer.toMap());
  }

  Future<int> updateCustomer(ClientObject customer) async {
    final db = await instance.database;
    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await instance.database;
    return await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
