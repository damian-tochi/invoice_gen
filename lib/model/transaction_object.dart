import 'package:invoice_gen/model/client_object.dart';
import 'package:invoice_gen/model/items_object.dart';
import 'dart:typed_data';


class TransactionObject {
  ClientObject clientObject;
  String invoiceTitle;
  String invoiceDate;
  String paymentStatus;
  double total;
  String subTotal;
  String taxDeduction;
  Uint8List? signature;
  List<ItemsObject> items;
  int transactionId;
  int invoiceType;

  TransactionObject({
    required this.clientObject,
    required this.invoiceTitle,
    required this.invoiceDate,
    required this.paymentStatus,
    required this.total,
    required this.subTotal,
    required this.taxDeduction,
    this.signature,
    required this.items,
    required this.transactionId,
    required this.invoiceType,
  });
}
