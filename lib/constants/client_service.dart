import 'dart:convert';
import 'package:invoice_gen/model/client_object.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ClientService {
  static const _key = 'customers';

  static Future<List<ClientObject>> getCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final List decoded = json.decode(data);
    return decoded.map((e) => ClientObject.fromMap(e)).toList();
  }

  static Future<void> saveCustomers(List<ClientObject> customers) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(customers.map((e) => e.toMap()).toList());
    await prefs.setString(_key, encoded);
  }

  static Future<void> addCustomer(ClientObject customer) async {
    final customers = await getCustomers();
    customers.add(customer);
    await saveCustomers(customers);
  }

  static Future<void> updateCustomer(ClientObject updated) async {
    final customers = await getCustomers();
    final index = customers.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      customers[index] = updated;
      await saveCustomers(customers);
    }
  }

  static Future<void> deleteCustomer(String id) async {
    final customers = await getCustomers();
    customers.removeWhere((c) => c.id == id);
    await saveCustomers(customers);
  }
}
