import 'dart:convert';

import 'package:invoice_gen/model/preference_object.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PreferenceService {
  static const _key = 'preference_settings';

  static Future<void> save(PreferenceObject settings) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_key, json.encode(settings.toMap()));
  }

  static Future<PreferenceObject?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return null;
    return PreferenceObject.fromMap(json.decode(data));
  }
}
