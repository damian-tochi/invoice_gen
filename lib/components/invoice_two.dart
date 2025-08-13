import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../model/transaction_object.dart';
import 'TrianglePainter.dart';


class InvoiceTwo extends StatefulWidget {
  final TransactionObject transaction;
  final double docWidth;
  final TransformationController controller;
  final double fitScale;
  final bool fitted;
  final Function(double) fitDocumentWidth;

  const InvoiceTwo({
    super.key,
    required this.transaction,
    required this.docWidth,
    required this.controller,
    required this.fitScale,
    required this.fitted,
    required this.fitDocumentWidth,
  });

  @override
  State<InvoiceTwo> createState() => _InvoiceTwoState();
}

class _InvoiceTwoState extends State<InvoiceTwo> {
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
          boundaryMargin: const EdgeInsets.all(
            double.infinity,
          ),
          minScale: widget.fitScale,
          maxScale: widget.fitScale * 5,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.white70,
                    ],
                  ),
                ),
                padding: EdgeInsets.all(20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: widget.docWidth,
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Spacer(flex: 1),

                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.start,
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                    color: Color(
                                      0xFF040405,
                                    ),
                                    fontSize: 29,
                                    fontWeight:
                                    FontWeight
                                        .w700,
                                  ),
                                  children:
                                  const <TextSpan>[
                                    TextSpan(
                                      text: 'INVOICE',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Spacer(flex: 1),

                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 4,
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .start,
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text(
                                      "Date Issued:",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                        color: Colors
                                            .black,
                                        fontSize: 11,
                                        fontWeight:
                                        FontWeight
                                            .w600,
                                      ),
                                    ),

                                    Text(
                                      transaction
                                          .invoiceDate,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                        color: Colors
                                            .black,
                                        fontSize: 11,
                                        fontWeight:
                                        FontWeight
                                            .w300,
                                      ),
                                    ),

                                    SizedBox(height: 10),

                                    Text(
                                      "Invoice No:",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                        color: Colors
                                            .black,
                                        fontSize: 11,
                                        fontWeight:
                                        FontWeight
                                            .w600,
                                      ),
                                    ),

                                    Text(
                                      "9903992",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                        color: Colors
                                            .black,
                                        fontSize: 11,
                                        fontWeight:
                                        FontWeight
                                            .w300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text(
                                      "Issued To:",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                        color: Colors
                                            .black,
                                        fontSize: 11,
                                        fontWeight:
                                        FontWeight
                                            .w600,
                                      ),
                                    ),

                                    RichText(
                                      text: TextSpan(
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                          color: Color(
                                            0xFF040405,
                                          ),
                                          fontSize:
                                          11,
                                          fontWeight:
                                          FontWeight
                                              .w300,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: transaction
                                                .clientObject
                                                .clientName,
                                          ),
                                          TextSpan(
                                            text: transaction
                                                .clientObject
                                                .clientAddress,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Spacer(flex: 1),

                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                _buildHeaderCell("NO", 2),
                                _verticalDivider(),
                                _buildHeaderCell(
                                  "DESCRIPTION",
                                  8,
                                ),
                                _verticalDivider(),
                                _buildHeaderCell(
                                  "QTY",
                                  2,
                                ),
                                _verticalDivider(),
                                _buildHeaderCell(
                                  "PRICE",
                                  4,
                                ),
                                _verticalDivider(),
                                _buildHeaderCell(
                                  "SUBTOTAL",
                                  4,
                                ),
                              ],
                            ),
                          ),

                          ListView.builder(
                            scrollDirection:
                            Axis.vertical,
                            itemCount:
                            transaction.items.length,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics:
                            const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                    right: BorderSide(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .stretch,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding:
                                          const EdgeInsets.symmetric(
                                            vertical:
                                            5,
                                            horizontal:
                                            5,
                                          ),
                                          alignment:
                                          Alignment
                                              .center,
                                          child: Text(
                                            "${index + 1}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                              color: Colors
                                                  .black,
                                              fontSize:
                                              10,
                                              fontWeight:
                                              FontWeight.w300,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        color:
                                        Colors.black,
                                      ),
                                      Expanded(
                                        flex: 8,
                                        child: Container(
                                          padding:
                                          const EdgeInsets.symmetric(
                                            vertical:
                                            5,
                                            horizontal:
                                            5,
                                          ),
                                          child: Text(
                                            transaction
                                                .items[index]
                                                .description,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                              color: Colors
                                                  .black,
                                              fontSize:
                                              10,
                                              fontWeight:
                                              FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        color:
                                        Colors.black,
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding:
                                          const EdgeInsets.symmetric(
                                            vertical:
                                            5,
                                            horizontal:
                                            5,
                                          ),
                                          alignment:
                                          Alignment
                                              .center,
                                          child: Text(
                                            transaction
                                                .items[index]
                                                .quantity
                                                .toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                              color: Colors
                                                  .black,
                                              fontSize:
                                              10,
                                              fontWeight:
                                              FontWeight.w300,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        color:
                                        Colors.black,
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                          padding:
                                          const EdgeInsets.symmetric(
                                            vertical:
                                            5,
                                            horizontal:
                                            5,
                                          ),
                                          alignment:
                                          Alignment
                                              .center,
                                          child: Text(
                                            transaction
                                                .items[index]
                                                .price
                                                .toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                              color: Colors
                                                  .black,
                                              fontSize:
                                              10,
                                              fontWeight:
                                              FontWeight.w300,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        color:
                                        Colors.black,
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                          padding:
                                          const EdgeInsets.symmetric(
                                            vertical:
                                            5,
                                            horizontal:
                                            5,
                                          ),
                                          alignment:
                                          Alignment
                                              .center,
                                          child: Text(
                                            "${transaction.items[index].price * transaction.items[index].quantity}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                              color: Colors
                                                  .black,
                                              fontSize:
                                              10,
                                              fontWeight:
                                              FontWeight.w300,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                right: BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                top: BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                bottom: BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                            ),
                            padding:
                            const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            child: Row(
                              children: [
                                Spacer(),
                                Text(
                                  "GRAND TOTAL",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                    color:
                                    Colors.black,
                                    fontSize: 9,
                                    fontWeight:
                                    FontWeight
                                        .w600,
                                  ),
                                  textAlign:
                                  TextAlign.center,
                                ),

                                SizedBox(width: 20),
                                Text(
                                  "${transaction.total}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                    color:
                                    Colors.black,
                                    fontSize: 11,
                                    fontWeight:
                                    FontWeight
                                        .w600,
                                  ),
                                  textAlign:
                                  TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),

                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  Text(
                                    "Note:",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                      color: Colors
                                          .black,
                                      fontSize: 11,
                                      fontWeight:
                                      FontWeight
                                          .w600,
                                    ),
                                  ),

                                  Text(
                                    "9903992",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                      color: Colors
                                          .black,
                                      fontSize: 11,
                                      fontWeight:
                                      FontWeight
                                          .w300,
                                    ),
                                  ),
                                ],
                              ),

                              Column(
                                children: [
                                  transaction.signature !=
                                      null
                                      ? Image.memory(
                                    transaction
                                        .signature!,
                                    height: 100,
                                    width: 150,
                                  )
                                      : Image.asset(
                                    "assets/images/sign.png",
                                    height: 100,
                                    width: 150,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Spacer(flex: 4),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const Positioned(
                top: -3,
                right: -4,
                child: CustomPaint(
                  size: Size(70, 40),
                  painter: TrianglePainter(
                    color: Colors.purple,
                    direction: TriangleDirection.down,
                  ),
                ),
              ),

              const Positioned(
                top: -4,
                right: -5,
                child: CustomPaint(
                  size: Size(80, 130),
                  painter: TrianglePainter(
                    color: Colors.blue,
                    direction: TriangleDirection.left,
                  ),
                ),
              ),

              const Positioned(
                bottom: -5,
                left: -5,
                child: CustomPaint(
                  size: Size(40, 70),
                  painter: TrianglePainter(
                    color: Colors.blue,
                    direction: TriangleDirection.right,
                  ),
                ),
              ),

              const Positioned(
                bottom: -5,
                left: -5,
                child: CustomPaint(
                  size: Size(140, 80),
                  painter: TrianglePainter(
                    color: Colors.purple,
                    direction: TriangleDirection.up,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCell(String title, int flex) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(3),
          child: AutoSizeText(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 6,
              fontWeight: FontWeight.w600,
            ),
            maxFontSize: 10,
            minFontSize: 10,
            maxLines: 1,
          ),
        ),
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 30, color: Colors.black);
  }
}
