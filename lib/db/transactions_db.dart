import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:typed_data';
import '../helper/transaction_id_helper.dart';
import '../model/client_object.dart';
import '../model/items_object.dart';
import '../model/transaction_object.dart';
import 'app_db.dart';
import 'client_db.dart';

class TransactionDB {
  static final TransactionDB instance = TransactionDB._init();
  TransactionDB._init();

  Future<Database> get _db async => await AppDB.instance.database;

  // Future<int> addTransaction(TransactionObject tx, int clientId) async {
  //   final db = await _db;
  //
  //   int transactionId = await db.insert('transactions', {
  //     'clientId': clientId,
  //     'invoiceTitle': tx.invoiceTitle,
  //     'invoiceDate': tx.invoiceDate,
  //     'paymentStatus': tx.paymentStatus,
  //     'total': tx.total,
  //     'subTotal': tx.subTotal,
  //     'taxDeduction': tx.taxDeduction,
  //     'signature': tx.signature,
  //     'transactionId': tx.transactionId,
  //   });
  //
  //   for (var item in tx.items) {
  //     await db.insert('transaction_items', {
  //       'transactionId': transactionId,
  //       'description': item.description,
  //       'price': item.price,
  //       'quantity': item.quantity,
  //     });
  //   }
  //
  //   return transactionId;
  // }

  // Future<List<TransactionObject>> getTransactions({
  //   String? search,
  //   String sortBy = 'invoiceDate',
  //   bool asc = false,
  // }) async {
  //   final db = await _db;
  //
  //   String order = '$sortBy ${asc ? 'ASC' : 'DESC'}';
  //   String where = '';
  //   List<dynamic> whereArgs = [];
  //
  //   if (search != null && search.isNotEmpty) {
  //     where = 'WHERE customers.clientName LIKE ? OR invoiceTitle LIKE ?';
  //     final s = '%$search%';
  //     whereArgs = [s, s];
  //   }
  //
  //   final result = await db.rawQuery('''
  //     SELECT transactions.*,
  //            customers.id as cId,
  //            customers.clientName,
  //            customers.clientEmail,
  //            customers.clientPhone,
  //            customers.clientAddress
  //     FROM transactions
  //     INNER JOIN customers ON transactions.clientId = customers.id
  //     $where
  //     ORDER BY $order
  //   ''', whereArgs);
  //
  //   List<TransactionObject> transactions = [];
  //   for (var row in result) {
  //     final itemsRes = await db.query(
  //       'transaction_items',
  //       where: 'transactionId = ?',
  //       whereArgs: [row['id']],
  //     );
  //
  //     transactions.add(
  //       TransactionObject(
  //         clientObject: ClientObject(
  //           id: row['cId'] as int?,
  //           clientName: row['clientName'] as String,
  //           clientEmail: row['clientEmail'] as String,
  //           clientPhone: row['clientPhone'] as String,
  //           clientAddress: row['clientAddress'] as String,
  //         ),
  //         invoiceTitle: row['invoiceTitle'] as String,
  //         invoiceDate: row['invoiceDate'] as String,
  //         paymentStatus: row['paymentStatus'] as String,
  //         total: row['total'] as double,
  //         subTotal: row['subTotal'] as String,
  //         taxDeduction: row['taxDeduction'] as String,
  //         signature: row['signature'] as Uint8List?,
  //         items: itemsRes
  //             .map(
  //               (item) => ItemsObject(
  //             description: item['description'] as String,
  //             price: item['price'] as double,
  //             quantity: item['quantity'] as int,
  //           ),
  //         )
  //             .toList(), transactionId: row['transactionId'] as int,
  //       ),
  //     );
  //   }
  //   return transactions;
  // }

  Future<int> addTransaction(TransactionObject tx, int clientId) async {
    final db = await _db;

    final rowId = await db.insert('transactions', {
      'clientId': clientId,
      'invoiceTitle': tx.invoiceTitle,
      'invoiceDate': tx.invoiceDate,
      'paymentStatus': tx.paymentStatus,
      'total': tx.total,
      'subTotal': tx.subTotal,
      'taxDeduction': tx.taxDeduction,
      'signature': tx.signature,
      'transactionId': tx.transactionId,
      'invoiceType': tx.invoiceType,
    });

    for (var item in tx.items) {
      await db.insert('transaction_items', {
        'transactionId': rowId, // link by PK
        'description': item.description,
        'price': item.price,
        'quantity': item.quantity,
      });
    }

    return rowId;
  }

  Future<List<TransactionObject>> getTransactions({
    String? search,
    String sortBy = 'invoiceDate',
    bool asc = false,
  }) async {
    final db = await _db;
    String order = '$sortBy ${asc ? 'ASC' : 'DESC'}';
    String where = '';
    List<dynamic> whereArgs = [];

    if (search != null && search.isNotEmpty) {
      where = 'WHERE customers.clientName LIKE ? OR transactions.invoiceTitle LIKE ?';
      final s = '%$search%';
      whereArgs = [s, s];
    }

    final result = await db.rawQuery('''
    SELECT transactions.*, 
           customers.id as cId, 
           customers.clientName, 
           customers.clientEmail, 
           customers.clientPhone, 
           customers.clientAddress
    FROM transactions
    INNER JOIN customers ON transactions.clientId = customers.id
    $where
    ORDER BY $order
  ''', whereArgs);

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
            id: row['cId'] as int?,
            clientName: row['clientName'] as String,
            clientEmail: row['clientEmail'] as String,
            clientPhone: row['clientPhone'] as String,
            clientAddress: row['clientAddress'] as String,
          ),
          invoiceTitle: row['invoiceTitle'] as String,
          invoiceDate: row['invoiceDate'] as String,
          paymentStatus: row['paymentStatus'] as String,
          total: (row['total'] as num).toDouble(),
          subTotal: row['subTotal'] as String,
          taxDeduction: row['taxDeduction'] as String,
          signature: row['signature'] as Uint8List?,
          items: itemsRes.map((item) => ItemsObject(
            description: item['description'] as String,
            price: (item['price'] as num).toDouble(),
            quantity: item['quantity'] as int,
          )).toList(),
          transactionId: row['transactionId'] as int,
          invoiceType: row['invoiceType'] as int,
        ),
      );
    }
    return transactions;
  }

  Future<void> updateTransaction(TransactionObject tx, int clientId) async {
    final db = await _db;

    await db.update(
      'transactions',
      {
        'clientId': clientId,
        'invoiceTitle': tx.invoiceTitle,
        'invoiceDate': tx.invoiceDate,
        'paymentStatus': tx.paymentStatus,
        'total': tx.total,
        'subTotal': tx.subTotal,
        'taxDeduction': tx.taxDeduction,
        'signature': tx.signature,
        'transactionId': tx.transactionId,
        'invoiceType': tx.invoiceType,
      },
      where: 'transactionId = ?',
      whereArgs: [tx.transactionId],
    );
  }

  Future<bool> transactionExists(int transactionId) async {
    final db = await _db;
    final result = await db.query(
      'transactions',
      where: 'transactionId = ?',
      whereArgs: [transactionId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<void> saveTransaction(TransactionObject transaction) async {
    final client = transaction.clientObject;
    int clientId;

    if (client.id != null) {
      await CustomerDB.instance.updateCustomer(client);
      clientId = client.id!;
    } else {
      clientId = await CustomerDB.instance.addCustomer(client);
    }

    final exists = await transactionExists(
      transaction.transactionId,
    );

    if (!exists) {
      await addTransaction(transaction, clientId);
      await TransactionIdManager.setNextTransactionId(transaction.transactionId);
    } else {
      await updateTransaction(transaction, clientId);
      debugPrint("✏ Transaction already exists — updated instead of inserting.");
    }
  }

}

