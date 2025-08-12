import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoice_gen/model/client_object.dart';
import 'package:invoice_gen/model/items_object.dart';
import 'package:invoice_gen/model/transaction_object.dart';
import 'state.dart';

class AppBlockCubit extends Cubit<AppBlockState> {
  AppBlockCubit() : super(AppBlockState().init());

  List<String> images = [
    "assets/images/inv-1.jpg",
    "assets/images/inv-2.jpg",
    "assets/images/inv-3.jpg",
    "assets/images/inv-4.png",
  ];

  int selectedInvoice = 1;
  int invoiceTax = 0;

  ClientObject? client;
  List<ItemsObject>? items;
  TransactionObject? transactionObject;

  List<ItemsObject> itemsS = [
    ItemsObject(description: 'Shoe', quantity: 5, price: 200),
    ItemsObject(description: 'Bag', quantity: 5, price: 200),
  ];

  // TransactionObject transactionObject = TransactionObject(
  //   clientObject: ClientObject(
  //     clientAddress: "clientAddress",
  //     clientName: "clientName",
  //     clientEmail: "clientEmail",
  //     clientPhone: '08076976876',
  //   ),
  //   invoiceTitle: "invoiceTitle",
  //   invoiceDate: "invoiceDate",
  //   paymentStatus: "Paids",
  //   total: 800,
  //   subTotal: "subTotal",
  //   taxDeduction: "taxDeduction",
  //   items: [
  //     ItemsObject(description: 'Shoe', quantity: 5, price: 200),
  //     ItemsObject(description: 'Bag', quantity: 5, price: 200),
  //     ItemsObject(description: 'Bag of fresh sliced Tomatoes dipped in Gbegiri sauce and Suya condiments.', quantity: 3, price: 200),
  //     ItemsObject(description: 'Shoe', quantity: 5, price: 200),
  //     ItemsObject(description: 'Bag', quantity: 1, price: 500),
  //     ItemsObject(description: 'Bag', quantity: 7, price: 300),
  //     ItemsObject(description: 'Bag', quantity: 1, price: 200),
  //     ItemsObject(description: 'Bag', quantity: 9, price: 800),
  //     ItemsObject(description: 'Shoe', quantity: 5, price: 200),
  //     ItemsObject(description: 'Phone', quantity: 5, price: 3000),
  //   ],
  // );

  void setInvoice(int invoice) {
    emit(state.copyWith(invoice: invoice));
  }
}
