import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/account_info_object.dart';

class AccountService {
  static const _key = 'account_info';

  static Future<void> saveAccountInfo(AccountInfo info) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(info.toMap());
    if (kDebugMode) {
      print('Saving account info: $jsonString');
    }
    await prefs.setString(_key, jsonString);
  }

  static Future<AccountInfo?> getAccountInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (kDebugMode) {
      print('Loaded account info: $data');
    }
    if (data == null) return null;
    return AccountInfo.fromMap(json.decode(data));
  }

}
