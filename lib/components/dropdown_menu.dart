import 'package:flutter/material.dart';


Widget dropdownMenu<T>({
  required String label,
  required List<T> items,
  required T? value,
  required void Function(T?) onChanged,
  String? Function(T?)? validator,
  String Function(T)? itemLabelBuilder,
  IconData? icon,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 1.0),
    child: DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(fontSize: 13, fontStyle: FontStyle.normal, color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        labelStyle: TextStyle(fontSize: 13),
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemLabelBuilder != null ? itemLabelBuilder(item) : item.toString()),
        );
      }).toList(),
    ),
  );
}
