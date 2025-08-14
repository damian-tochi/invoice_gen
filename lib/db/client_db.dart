import 'package:sqflite/sqflite.dart';
import '../model/client_object.dart';
import 'app_db.dart';


class CustomerDB {
  static final CustomerDB instance = CustomerDB._init();
  CustomerDB._init();

  Future<Database> get _db async => await AppDB.instance.database;

  Future<List<ClientObject>> getCustomers({String? search, bool ascending = true}) async {
    final db = await _db;
    String orderBy = 'clientName ${ascending ? 'ASC' : 'DESC'}';
    String where = '';
    List<dynamic> whereArgs = [];

    if (search != null && search.isNotEmpty) {
      where = 'WHERE clientName LIKE ? OR clientEmail LIKE ? OR clientPhone LIKE ?';
      final term = '%$search%';
      whereArgs = [term, term, term];
    }

    final result = await db.rawQuery('SELECT * FROM customers $where ORDER BY $orderBy', whereArgs);
    return result.map((json) => ClientObject.fromMap(json)).toList();
  }

  Future<int> addCustomer(ClientObject customer) async {
    final db = await _db;
    return await db.insert('customers', customer.toMap());
  }

  Future<int> updateCustomer(ClientObject customer) async {
    final db = await _db;
    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await _db;
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }
}
