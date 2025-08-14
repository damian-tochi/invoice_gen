import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:invoice_gen/components/invoice_three.dart';
import 'package:invoice_gen/components/invoice_two.dart';
import 'package:invoice_gen/model/transaction_object.dart';
import '../../app_block/transactions_cubit.dart';
import 'package:get/get.dart';
import '../../app_block/state.dart';
import '../../components/invoice_one.dart';
import '../../db/client_db.dart';
import '../../db/transactions_db.dart';
import '../../helper/generateInvoiceOne.dart';
import '../../helper/generateInvoiceTwo.dart';

class PreviewInvoicePage extends StatefulWidget {
  @override
  State<PreviewInvoicePage> createState() => _PreviewInvoicePageState();
}

class _PreviewInvoicePageState extends State<PreviewInvoicePage> {
  final TransformationController _controller = TransformationController();
  final TransformationController _transformationController =
      TransformationController();

  final GlobalKey _avatarKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  final double docWidth = 800;

  double _fitScale = 0.1;
  bool _fitted = false;

  @override
  Widget build(BuildContext context) {
    final cubit = Get.find<AppBlockCubit>();
    final transaction = cubit.transactionObject;

    void _showOverlay() {
      final renderBox =
          _avatarKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final offset = renderBox.localToGlobal(Offset.zero);

      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: offset.dy + 30,
          left: offset.dx - 65,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      cubit.setInvoice(1);
                      _hideOverlay();
                    },
                    child: const Text('Invoice 1'),
                  ),
                  TextButton(
                    onPressed: () {
                      cubit.setInvoice(2);
                      _hideOverlay();
                    },
                    child: const Text('Invoice 2'),
                  ),
                  TextButton(
                    onPressed: () {
                      cubit.setInvoice(3);
                      _hideOverlay();
                    },
                    child: const Text('Invoice 3'),
                  ),
                  TextButton(
                    onPressed: () {
                      cubit.setInvoice(4);
                      _hideOverlay();
                    },
                    child: const Text('Invoice 4'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      Overlay.of(context).insert(_overlayEntry!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Invoice Preview',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),

            GestureDetector(
              key: _avatarKey,
              onTap: () {
                if (_overlayEntry == null) {
                  _showOverlay();
                } else {
                  _hideOverlay();
                }
              },
              child: SvgPicture.asset(
                'assets/icons/auto_edit.svg',
                width: 24,
                height: 24,
              ),
            ),
          ],
        ),
      ),
      body: transaction == null
          ? const Center(child: Text('No data available.'))
          : Stack(
              children: [
                BlocBuilder<AppBlockCubit, AppBlockState>(
                  bloc: Get.find<AppBlockCubit>(),
                  buildWhen: (previous, current) {
                    return previous.invoice != current.invoice;
                  },
                  builder: (context, state) {
                    return state.invoice == 1
                        ? InvoiceOne(
                            transaction: transaction,
                            docWidth: docWidth,
                            controller: _controller,
                            fitScale: _fitScale,
                            fitted: _fitted,
                            fitDocumentWidth: _fitDocumentWidth,
                          )
                        : state.invoice == 2
                        ? InvoiceTwo(
                            transaction: transaction,
                            docWidth: docWidth,
                            controller: _controller,
                            fitScale: _fitScale,
                            fitted: _fitted,
                            fitDocumentWidth: _fitDocumentWidth,
                          )
                        : state.invoice == 3
                        ? InvoiceThree(
                            transaction: transaction,
                            docWidth: docWidth,
                            controller: _controller,
                            fitScale: _fitScale,
                            fitted: _fitted,
                            fitDocumentWidth: _fitDocumentWidth,
                          )
                        : Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Client: ${transaction.clientObject.clientName}",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Description: ${transaction.items.length} items",
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Amount: ₦${transaction.total.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                const Text(
                                  "Signature:",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                // Image.memory(transaction.signature!, height: 100),
                              ],
                            ),
                          );
                  },
                ),

                Positioned(
                  bottom: 30,
                  right: 30,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: const Size(0, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      saveTransactions(transaction);
                      int selectedInv = Get.find<AppBlockCubit>().selectedInvoice;
                      if (selectedInv == 1) {
                        generateInvoicePdf(transaction);
                      } else if (selectedInv == 2) {
                        generateInvoicePdfTwo(transaction);
                      }
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/download_ico.svg',
                      width: 14,
                      height: 14,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Save/Download',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _fitDocumentWidth(double viewerWidth) {
    double fitScale = viewerWidth / docWidth;

    double offsetX = (viewerWidth - docWidth * fitScale) / 2;

    _transformationController.value = Matrix4.identity()
      ..translate(offsetX, 0) // only horizontal centering
      ..scale(fitScale);
  }

  Future<void> saveTransactions(TransactionObject transaction) async {
    await TransactionDB.instance.saveTransaction(transaction);
  }

}
