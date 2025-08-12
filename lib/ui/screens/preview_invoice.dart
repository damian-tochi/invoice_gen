import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../app_block/transactions_cubit.dart';
import 'package:get/get.dart';
import '../../app_block/state.dart';
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
                        ? LayoutBuilder(
                            builder: (context, constraints) {
                              if (!_fitted) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  _fitDocumentWidth(constraints.maxWidth);
                                  _fitted = true;
                                });
                              }

                              return InteractiveViewer(
                                transformationController: _controller,
                                boundaryMargin: const EdgeInsets.all(1000),
                                minScale: _fitScale,
                                maxScale: _fitScale * 5,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: docWidth,
                                        minHeight: constraints.maxHeight,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                      color: const Color(
                                                        0xFF040405,
                                                      ),
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(flex: 4),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "ISSUED TO:",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                            color: Colors.black,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w600,
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
                                                              fontSize: 10,
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

                                                    if (transaction
                                                            .paymentStatus !=
                                                        "Paid")
                                                      Column(
                                                        children: [
                                                          SizedBox(height: 30),
                                                          Text(
                                                            "PAY TO:",
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .copyWith(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                          Text(
                                                            "Amount",
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .copyWith(
                                                                  color: Color(
                                                                    0xFF59616D,
                                                                  ),
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
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
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      "INVOICE NO:",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                            color: Colors.black,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),

                                                    Text(
                                                      "DATE:",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                            color: Colors.black,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                          ),
                                                    ),

                                                    if (transaction
                                                            .paymentStatus !=
                                                        "Paid")
                                                      Text(
                                                        "DUE DATE",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge!
                                                            .copyWith(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                            ),
                                                      ),
                                                  ],
                                                ),
                                              ),

                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      "000001",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                            color: Colors.black,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                          ),
                                                    ),
                                                    Text(
                                                      transaction.invoiceDate,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                            color: Colors.black,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                          ),
                                                    ),
                                                    if (transaction
                                                            .paymentStatus !=
                                                        "Paid")
                                                      Text(
                                                        transaction.invoiceDate,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge!
                                                            .copyWith(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                            ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 40),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "DESCRIPTION",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                        color: Colors.black,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                  textAlign: TextAlign.start,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  "UNIT PRICE",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                        color: Colors.black,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  "QTY",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                        color: Colors.black,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  "TOTAL",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                        color: Colors.black,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                  textAlign: TextAlign.end,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 10),
                                          Container(
                                            color: Colors.black,
                                            height: 1,
                                          ),
                                          const SizedBox(height: 20),

                                          ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            itemCount: transaction.items.length,
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      transaction
                                                          .items[index]
                                                          .description,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                            color: Colors.black,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                          ),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      transaction
                                                          .items[index]
                                                          .price
                                                          .toString(),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                            color: Colors.black,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                          ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      transaction
                                                          .items[index]
                                                          .quantity
                                                          .toString(),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                            color: Colors.black,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                          ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      "${transaction.items[index].price * transaction.items[index].quantity}",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                            color: Colors.black,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                          ),
                                                      textAlign: TextAlign.end,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),

                                          Container(
                                            color: Colors.black,
                                            height: 1,
                                          ),
                                          const SizedBox(height: 10),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "SUBTOTAL",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                      color: Colors.black,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              Text(
                                                transaction.subTotal,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                      color: Colors.black,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 1),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Spacer(),

                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    "Tax",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .copyWith(
                                                          color: Colors.black,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                        ),
                                                  ),

                                                  Text(
                                                    "TOTAL",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .copyWith(
                                                          color: Colors.black,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ],
                                              ),

                                              SizedBox(width: 10),

                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    transaction.taxDeduction,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .copyWith(
                                                          color: Colors.black,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                        ),
                                                    textAlign: TextAlign.end,
                                                  ),

                                                  Text(
                                                    transaction.total
                                                        .toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .copyWith(
                                                          color: Colors.black,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                    textAlign: TextAlign.end,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 10),

                                          // SIGNATURE
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
                          )
                        : state.invoice == 2
                        ? LayoutBuilder(
                            builder: (context, constraints) {
                              if (!_fitted) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  _fitDocumentWidth(constraints.maxWidth);
                                  _fitted = true;
                                });
                              }
                              return InteractiveViewer(
                                transformationController: _controller,
                                boundaryMargin: const EdgeInsets.all(
                                  double.infinity,
                                ),
                                minScale: _fitScale,
                                maxScale: _fitScale * 5,
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
                                              minWidth: docWidth,
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

                                                // Image.memory(transaction.signature!, height: 100),
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
                          )
                        : state.invoice == 3
                        ? Padding(
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
                          )
                        : Container();
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

  void _fitDocumentWidth(double viewerWidth) {
    double fitScale = viewerWidth / docWidth;

    double offsetX = (viewerWidth - docWidth * fitScale) / 2;

    _transformationController.value = Matrix4.identity()
      ..translate(offsetX, 0) // only horizontal centering
      ..scale(fitScale);
  }
}

enum TriangleDirection { left, right, up, down }

class TrianglePainter extends CustomPainter {
  final Color color;
  final TriangleDirection direction;

  const TrianglePainter({required this.color, required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    switch (direction) {
      case TriangleDirection.left:
        path.moveTo(size.width, 0);
        path.lineTo(0, size.height / 2);
        path.lineTo(size.width, size.height);
        break;
      case TriangleDirection.right:
        path.moveTo(0, 0);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(0, size.height);
        break;
      case TriangleDirection.up:
        path.moveTo(0, size.height);
        path.lineTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        break;
      case TriangleDirection.down:
        path.moveTo(0, 0);
        path.lineTo(size.width / 2, size.height);
        path.lineTo(size.width, 0);
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Future<void> transactionPdf() async {
//   final pdf = pw.Document();
//   final image = pw.MemoryImage(
//     (await rootBundle.load('assets/channelle.jpg')).buffer.asUint8List(),
//   );
//
//   try {
//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Center(
//             child: pw.Container(
//               padding: const pw.EdgeInsets.all(20),
//               margin:
//               const pw.EdgeInsets.only(bottom: 10, left: 10, right: 10),
//               decoration: pw.BoxDecoration(
//                 color: PdfColor.fromInt(Colors.white.value),
//                 borderRadius: pw.BorderRadius.circular(8),
//               ),
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 mainAxisAlignment: pw.MainAxisAlignment.center,
//                 children: [
//                   pw.SizedBox(
//                     height: 20,
//                   ),
//                   pw.Container(
//                       width: 50.0, height: 50.0, child: pw.Image(image)),
//                   pw.SizedBox(
//                     height: 5,
//                   ),
//                   pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                     children: [
//                       pw.Text(
//                         "Amount",
//                         style: pw.TextStyle(
//                           color: PdfColor.fromHex("#59616D"),
//                           fontSize: 12,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                       pw.RichText(
//                         text: pw.TextSpan(
//                           style: pw.TextStyle(
//                             color: PdfColor.fromHex('#040405'),
//                             fontSize: 14,
//                             fontWeight: pw.FontWeight.bold,
//                           ),
//                           children: [
//                             pw.TextSpan(text: '+ $symbol$wholeNumber'),
//                             // Whole number part
//                             pw.TextSpan(text: '.$decimalPart'),
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                   pw.SizedBox(
//                     height: 20,
//                   ),
//                   pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                     children: [
//                       pw.Text(
//                         "Recipient",
//                         style: pw.TextStyle(
//                           color: PdfColor.fromHex("#59616D"),
//                           fontSize: 12,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                       pw.Text(
//                         transaction!.submittedByUsername,
//                         style: pw.TextStyle(
//                           color: PdfColor.fromHex("#040405"),
//                           fontSize: 12,
//                           fontWeight: pw.FontWeight.normal,
//                         ),
//                       ),
//                     ],
//                   ),
//                   pw.SizedBox(
//                     height: 20,
//                   ),
//                   pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                     children: [
//                       pw.Text(
//                         "Recipient’s Account",
//                         style: pw.TextStyle(
//                           color: PdfColor.fromHex("#59616D"),
//                           fontSize: 12,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                       pw.Text(
//                         transaction!.accountNo,
//                         style: pw.TextStyle(
//                           color: PdfColor.fromHex("#040405"),
//                           fontSize: 12,
//                           fontWeight: pw.FontWeight.normal,
//                         ),
//                       ),
//                     ],
//                   ),
//                   pw.SizedBox(
//                     height: 20,
//                   ),
//                   pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                     children: [
//                       pw.Text(
//                         "Recipient’s Bank",
//                         style: pw.TextStyle(
//                           color: PdfColor.fromHex("#59616D"),
//                           fontSize: 12,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                       pw.Text(
//                         "Channelle MFB",
//                         style: pw.TextStyle(
//                           color: PdfColor.fromHex("#040405"),
//                           fontSize: 12,
//                           fontWeight: pw.FontWeight.normal,
//                         ),
//                       ),
//                     ],
//                   ),
//                   pw.SizedBox(
//                     height: 20,
//                   ),
//                   pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                     children: [
//                       pw.Text(
//                         "Remark",
//                         style: pw.TextStyle(
//                           color: PdfColor.fromHex("#59616D"),
//                           fontSize: 12,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                       pw.Text(
//                         "",
//                         style: pw.TextStyle(
//                           color: PdfColor.fromHex("#040405"),
//                           fontSize: 12,
//                           fontWeight: pw.FontWeight.normal,
//                         ),
//                       ),
//                     ],
//                   ),
//                   pw.SizedBox(
//                     height: 20,
//                   ),
//                   pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                     children: [
//                       pw.Text(
//                         "Transaction Type",
//                         style: pw.TextStyle(
//                           color: PdfColor.fromHex("#59616D"),
//                           fontSize: 12,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                       pw.Text(
//                         transaction!.transactionType.value,
//                         style: pw.TextStyle(
//                           color: PdfColor.fromHex("#040405"),
//                           fontSize: 12,
//                           fontWeight: pw.FontWeight.normal,
//                         ),
//                       ),
//                     ],
//                   ),
//                   pw.SizedBox(
//                     height: 20,
//                   ),
//                   pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                     children: [
//                       pw.Text(
//                         "Debit Account",
//                         style: pw.TextStyle(
//                           color: PdfColor.fromHex("#59616D"),
//                           fontSize: 12,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                       pw.Text(
//                         transaction!.accountNo,
//                         style: pw.TextStyle(
//                           color: PdfColor.fromHex("#040405"),
//                           fontSize: 12,
//                           fontWeight: pw.FontWeight.normal,
//                         ),
//                       ),
//                     ],
//                   ),
//                   pw.SizedBox(
//                     height: 20,
//                   ),
//                   pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                     children: [
//                       pw.Text(
//                         "Date & Time",
//                         style: pw.TextStyle(
//                           color: PdfColor.fromHex("#59616D"),
//                           fontSize: 12,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                       pw.Text(
//                         convertListToDateString(transaction!.date),
//                         style: pw.TextStyle(
//                           color: PdfColor.fromHex("#040405"),
//                           fontSize: 12,
//                           fontWeight: pw.FontWeight.normal,
//                         ),
//                       ),
//                     ],
//                   ),
//                   pw.SizedBox(
//                     height: 20,
//                   ),
//                   pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                     children: [
//                       pw.Text(
//                         "Status",
//                         style: pw.TextStyle(
//                           color: PdfColor.fromHex("#59616D"),
//                           fontSize: 12,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                       pw.Text(
//                         "Successful",
//                         style: pw.TextStyle(
//                           color: PdfColor.fromHex("#040405"),
//                           fontSize: 12,
//                           fontWeight: pw.FontWeight.normal,
//                         ),
//                       ),
//                     ],
//                   ),
//                   pw.SizedBox(
//                     height: 20,
//                   ),
//                 ],
//               ),
//             ),
//           ); // Center
//         },
//       ),
//     );
//
//     final Directory? directory;
//     if (Platform.isIOS) {
//       directory = await getApplicationDocumentsDirectory();
//     } else {
//       directory = await getDownloadsDirectory();
//     }
//     if (directory == null) {
//       redFailedAlert("Document directory not available", context);
//       return;
//     }
//     final path =
//         '${directory.path}/transaction_receipt-${convertListToDateString(transaction!.date)}.pdf';
//     final file = File(path);
//     await file.writeAsBytes(await pdf.save());
//
//     showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Receipt Generated'),
//           content: Text('Receipt has been saved to $path as PDF'),
//           actions: [
//             Padding(
//               padding:
//               const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
//               child: CustomButton(
//                 onTap: () {
//                   Navigator.of(context).pop();
//                   OpenFile.open(path);
//                 },
//                 color: primaryColor,
//                 label: "View",
//               ),
//             ),
//           ],
//         ));
//   } catch (e) {
//     debugPrint("$e");
//     redFailedAlert("$e", context);
//   }
// }
