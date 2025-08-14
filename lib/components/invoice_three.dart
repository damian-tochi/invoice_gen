import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/transaction_object.dart';

class InvoiceThree extends StatefulWidget {
  final TransactionObject transaction;
  final double docWidth;
  final TransformationController controller;
  final double fitScale;
  final bool fitted;
  final Function(double) fitDocumentWidth;

  const InvoiceThree({
    super.key,
    required this.transaction,
    required this.docWidth,
    required this.controller,
    required this.fitScale,
    required this.fitted,
    required this.fitDocumentWidth,
  });

  @override
  State<InvoiceThree> createState() => _InvoiceThreeState();
}

class _InvoiceThreeState extends State<InvoiceThree> {
  late bool _fitted;

  @override
  void initState() {
    super.initState();
    _fitted = widget.fitted;
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final client = transaction.clientObject;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'INVOICE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'No: ${transaction.transactionId}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            client.clientName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(client.clientEmail),
          Text(client.clientPhone),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date: ${transaction.invoiceDate}',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              Text(
                transaction.paymentStatus.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  color: transaction.paymentStatus == 'paid'
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Table(
            border: TableBorder.all(color: Colors.grey.shade300, width: 0.5),
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[200]),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              ...transaction.items.map((item) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(item.description),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(item.quantity.toString()),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(NumberFormat.currency(symbol: '₦').format(item.price)),
                  ),
                ],
              )),
            ],
          ),

          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total: ${NumberFormat.currency(symbol: '₦').format(transaction.total)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
