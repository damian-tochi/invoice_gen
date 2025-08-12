import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:typed_data';
import '../model/client_object.dart';
import '../model/items_object.dart';
import '../model/transaction_object.dart';

class TransactionDB {
  static final TransactionDB instance = TransactionDB._init();
  static Database? _database;

  TransactionDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('transactions.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientName TEXT,
        invoiceTitle TEXT,
        invoiceDate TEXT,
        paymentStatus TEXT,
        total REAL,
        subTotal TEXT,
        taxDeduction TEXT,
        signature BLOB
      )
    ''');

    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transactionId INTEGER,
        name TEXT,
        price REAL,
        quantity INTEGER
      )
    ''');
  }

  Future<int> addTransaction(TransactionObject tx) async {
    final db = await instance.database;

    // Insert transaction
    int transactionId = await db.insert('transactions', {
      'clientName': tx.clientObject.clientName,
      'invoiceTitle': tx.invoiceTitle,
      'invoiceDate': tx.invoiceDate,
      'paymentStatus': tx.paymentStatus,
      'total': tx.total,
      'subTotal': tx.subTotal,
      'taxDeduction': tx.taxDeduction,
      'signature': tx.signature,
    });

    // Insert items
    for (var item in tx.items) {
      await db.insert('transaction_items', {
        'transactionId': transactionId,
        'description': item.description,
        'price': item.price,
        'quantity': item.quantity,
      });
    }

    return transactionId;
  }

  Future<List<TransactionObject>> getTransactions({
    String? search,
    String sortBy = 'invoiceDate',
    bool asc = false,
  }) async {
    final db = await instance.database;

    String order = '$sortBy ${asc ? 'ASC' : 'DESC'}';
    String where = '';
    List<dynamic> whereArgs = [];

    if (search != null && search.isNotEmpty) {
      where = 'WHERE clientName LIKE ? OR invoiceTitle LIKE ?';
      final s = '%$search%';
      whereArgs = [s, s];
    }

    final result = await db.rawQuery(
      'SELECT * FROM transactions $where ORDER BY $order',
      whereArgs,
    );

    List<TransactionObject> transactions = [];
    for (var row in result) {
      final itemsRes = await db.query(
        'transaction_items',
        where: 'transactionId = ?',
        whereArgs: [row['id']],
      );

      transactions.add(
        TransactionObject(
          clientObject: ClientObject(
            clientName: row['clientName'] as String,
            clientAddress: row['clientAddress'] as String,
            clientPhone: row['clientPhone'] as String,
            clientEmail: row['clientEmail'] as String,
          ),
          invoiceTitle: row['invoiceTitle'] as String,
          invoiceDate: row['invoiceDate'] as String,
          paymentStatus: row['paymentStatus'] as String,
          total: row['total'] as double,
          subTotal: row['subTotal'] as String,
          taxDeduction: row['taxDeduction'] as String,
          signature: row['signature'] as Uint8List?,
          items: itemsRes
              .map(
                (item) => ItemsObject(
                  description: item['description'] as String,
                  price: item['price'] as double,
                  quantity: item['quantity'] as int,
                ),
              )
              .toList(),
        ),
      );
    }
    return transactions;
  }
}
