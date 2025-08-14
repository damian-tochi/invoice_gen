import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionIdManager {
  static const _transactionKey = 'nextTransactionId';
  static const _initializedKey = 'transactionIdInitialized';
  static int? _nextTransactionId;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyInitialized = prefs.getBool(_initializedKey) ?? false;

    if (!alreadyInitialized) {
      _nextTransactionId = 100000 + Random().nextInt(900000);
      await prefs.setInt(_transactionKey, _nextTransactionId!);
      await prefs.setBool(_initializedKey, true);
    } else {
      _nextTransactionId = prefs.getInt(_transactionKey) ?? 0;
    }
  }

  static Future<int> getNextTransactionId() async {
    final prefs = await SharedPreferences.getInstance();
    _nextTransactionId = (prefs.getInt(_transactionKey) ?? 0) + 1;
    return _nextTransactionId!;
  }

  static Future<void> setNextTransactionId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    _nextTransactionId = id;
    await prefs.setInt(_transactionKey, id);
  }

}
