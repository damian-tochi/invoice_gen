import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../model/transaction_object.dart';


Future<Uint8List> generateInvoicePdf(TransactionObject transaction) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Spacer(flex: 1),

            // Header
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    height: 1.2,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Text(
                  'INVOICE',
                  style: pw.TextStyle(
                    color: PdfColor.fromInt(0xFF040405),
                    fontSize: 25,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),

            pw.Spacer(flex: 4),

            // Issued to & Invoice Info
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // Issued To
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "ISSUED TO:",
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        "${transaction.clientObject.clientName}\n${transaction.clientObject.clientAddress}",
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.normal,
                        ),
                      ),
                      if (transaction.paymentStatus != "Paid") ...[
                        pw.SizedBox(height: 30),
                        pw.Text(
                          "PAY TO:",
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          "Amount",
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.normal,
                            color: PdfColor.fromInt(0xFF59616D),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),

                // Labels
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("INVOICE NO:", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text("DATE:", style: pw.TextStyle(fontSize: 10)),
                      if (transaction.paymentStatus != "Paid")
                        pw.Text("DUE DATE", style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),

                // Values
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("000001", style: pw.TextStyle(fontSize: 10)),
                      pw.Text(transaction.invoiceDate, style: pw.TextStyle(fontSize: 10)),
                      if (transaction.paymentStatus != "Paid")
                        pw.Text(transaction.invoiceDate, style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 40),

            // Table Header
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Text("DESCRIPTION", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text("UNIT PRICE", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text("QTY", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text("TOTAL", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Container(height: 1, color: PdfColors.black),
            pw.SizedBox(height: 20),

            // Items
            ...transaction.items.map((item) {
              return pw.Row(
                children: [
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(item.description, style: pw.TextStyle(fontSize: 10)),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(item.price.toString(), style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(item.quantity.toString(), style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      (item.price * item.quantity).toString(),
                      style: pw.TextStyle(fontSize: 10),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              );
            }).toList(),

            pw.Container(height: 1, color: PdfColors.black),
            pw.SizedBox(height: 10),

            // Subtotal & Totals
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("SUBTOTAL", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.Text(transaction.subTotal, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 1),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Spacer(),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Tax", style: pw.TextStyle(fontSize: 10)),
                    pw.Text("TOTAL", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(width: 10),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(transaction.taxDeduction, style: pw.TextStyle(fontSize: 10)),
                    pw.Text(transaction.total.toString(), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 10),

            // Signature
            if (transaction.signature != null)
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Image(
                  pw.MemoryImage(transaction.signature!),
                  height: 100,
                  width: 150,
                ),
              )
            else
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text("[Signature Placeholder]", style: pw.TextStyle(fontSize: 10)),
              ),

            pw.Spacer(flex: 4),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
