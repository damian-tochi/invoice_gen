import 'package:flutter/material.dart';

import '../model/transaction_object.dart';

class InvoiceOne extends StatefulWidget {
  final TransactionObject transaction;
  final double docWidth;
  final TransformationController controller;
  final double fitScale;
  final bool fitted;
  final Function(double) fitDocumentWidth;

  const InvoiceOne({
    super.key,
    required this.transaction,
    required this.docWidth,
    required this.controller,
    required this.fitScale,
    required this.fitted,
    required this.fitDocumentWidth,
  });

  @override
  State<InvoiceOne> createState() => _InvoiceOneState();
}

class _InvoiceOneState extends State<InvoiceOne> {
  late bool _fitted;

  @override
  void initState() {
    super.initState();
    _fitted = widget.fitted;
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_fitted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.fitDocumentWidth(constraints.maxWidth);
            _fitted = true;
          });
        }

        return InteractiveViewer(
          transformationController: widget.controller,
          boundaryMargin: const EdgeInsets.all(1000),
          minScale: widget.fitScale,
          maxScale: widget.fitScale * 5,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: widget.docWidth,
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 1),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.black,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'INVOICE',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: const Color(0xFF040405),
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(flex: 4),

                    _buildHeader(transaction, context),

                    const SizedBox(height: 40),

                    _buildTableHeader(context),

                    const SizedBox(height: 10),
                    Container(color: Colors.black, height: 1),
                    const SizedBox(height: 20),

                    _buildItemList(transaction, context),

                    Container(color: Colors.black, height: 1),
                    const SizedBox(height: 10),

                    _buildTotals(transaction, context),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: transaction.signature != null
                          ? Image.memory(
                        transaction.signature!,
                        height: 100,
                        width: 150,
                      )
                          : Image.asset(
                        "assets/images/sign.png",
                        height: 100,
                        width: 150,
                      ),
                    ),
                    const Spacer(flex: 4),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(TransactionObject transaction, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ISSUED TO:",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: const Color(0xFF040405),
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                  ),
                  children: [
                    TextSpan(text: transaction.clientObject.clientName),
                    TextSpan(text: transaction.clientObject.clientAddress),
                  ],
                ),
              ),
              if (transaction.paymentStatus != "Paid")
                Column(
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      "PAY TO:",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Amount",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: const Color(0xFF59616D),
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "INVOICE NO:",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "DATE:",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                ),
              ),
              if (transaction.paymentStatus != "Paid")
                Text(
                  "DUE DATE",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                  ),
                ),
            ],
          ),
        ),

        // VALUES
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.transactionId.toString(),
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                transaction.invoiceDate,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                ),
              ),
              if (transaction.paymentStatus != "Paid")
                Text(
                  transaction.invoiceDate,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Expanded(
          flex: 2,
          child: Text("DESCRIPTION", textAlign: TextAlign.start),
        ),
        Expanded(
          flex: 1,
          child: Text("UNIT PRICE", textAlign: TextAlign.center),
        ),
        Expanded(
          flex: 1,
          child: Text("QTY", textAlign: TextAlign.center),
        ),
        Expanded(
          flex: 1,
          child: Text("TOTAL", textAlign: TextAlign.end),
        ),
      ],
    );
  }

  Widget _buildItemList(TransactionObject transaction, BuildContext context) {
    return ListView.builder(
      itemCount: transaction.items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = transaction.items[index];
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(item.description, textAlign: TextAlign.start),
            ),
            Expanded(
              flex: 1,
              child: Text(item.price.toString(), textAlign: TextAlign.center),
            ),
            Expanded(
              flex: 1,
              child:
              Text(item.quantity.toString(), textAlign: TextAlign.center),
            ),
            Expanded(
              flex: 1,
              child: Text(
                "${item.price * item.quantity}",
                textAlign: TextAlign.end,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTotals(TransactionObject transaction, BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("SUBTOTAL"),
            Text(transaction.subTotal),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text("Tax"),
                Text("TOTAL"),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(transaction.taxDeduction),
                Text(transaction.total.toString()),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
