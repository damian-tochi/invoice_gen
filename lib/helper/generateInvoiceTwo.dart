import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../model/transaction_object.dart';

import 'package:flutter/services.dart' show rootBundle;

Future<Uint8List> generateInvoicePdfTwo(TransactionObject transaction) async {
  final pdf = pw.Document();

  // Load logo or placeholder images
  final signImage = transaction.signature != null
      ? pw.MemoryImage(transaction.signature!)
      : pw.MemoryImage(
    (await rootBundle.load('assets/images/sign.png')).buffer.asUint8List(),
  );

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "INVOICE",
                style: pw.TextStyle(
                  fontSize: 29,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 20),

              // Invoice info
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Date Issued:", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.Text(transaction.invoiceDate, style: pw.TextStyle(fontSize: 11)),
                      pw.SizedBox(height: 10),
                      pw.Text("Invoice No:", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.Text("9903992", style: pw.TextStyle(fontSize: 11)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Issued To:", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.Text(transaction.clientObject.clientName, style: pw.TextStyle(fontSize: 11)),
                      pw.Text(transaction.clientObject.clientAddress, style: pw.TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Table header
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black),
                ),
                child: pw.Row(
                  children: [
                    _buildHeaderCellPdf("NO", 2),
                    _buildHeaderCellPdf("DESCRIPTION", 8),
                    _buildHeaderCellPdf("QTY", 2),
                    _buildHeaderCellPdf("PRICE", 4),
                    _buildHeaderCellPdf("SUBTOTAL", 4),
                  ],
                ),
              ),

              // Table rows
              ...List.generate(transaction.items.length, (index) {
                final item = transaction.items[index];
                return pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(color: PdfColors.black, width: 1),
                      right: pw.BorderSide(color: PdfColors.black, width: 1),
                    ),
                  ),
                  child: pw.Row(
                    children: [
                      _buildCellPdf("${index + 1}", 2),
                      _buildCellPdf(item.description, 8),
                      _buildCellPdf(item.quantity.toString(), 2),
                      _buildCellPdf(item.price.toString(), 4),
                      _buildCellPdf("${item.price * item.quantity}", 4),
                    ],
                  ),
                );
              }),

              // Grand Total
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black),
                ),
                padding: const pw.EdgeInsets.all(10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text("GRAND TOTAL", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(width: 20),
                    pw.Text("${transaction.total}", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Footer: Notes & Signature
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Note:", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.Text("9903992", style: pw.TextStyle(fontSize: 11)),
                    ],
                  ),
                  pw.Image(signImage, height: 100, width: 150),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );

  return pdf.save();
}

pw.Expanded _buildHeaderCellPdf(String text, int flex) {
  return pw.Expanded(
    flex: flex,
    child: pw.Container(
      padding: const pw.EdgeInsets.all(5),
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 1))),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
      ),
    ),
  );
}

pw.Expanded _buildCellPdf(String text, int flex) {
  return pw.Expanded(
    flex: flex,
    child: pw.Container(
      padding: const pw.EdgeInsets.all(5),
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 1))),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 10)),
    ),
  );
}

