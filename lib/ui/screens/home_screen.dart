import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:invoice_gen/ui/screens/preview_invoice.dart';

import '../../app_block/account_cubit.dart';
import '../../app_block/transactions_cubit.dart';
import '../../components/drawer_menu.dart';
import '../../components/image_doc_card.dart';
import '../../model/account_info_object.dart';
import 'create_invoice.dart';

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  AccountInfo? info;

  @override
  void initState() {
    super.initState();
    Get.find<AccountCubit>().loadAccountInfo().then((_) {
      final loadedInfo = Get.find<AccountCubit>().state;
      if (mounted) {
        setState(() {
          info = loadedInfo;
        });
      }
    });
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta! / MediaQuery.of(context).size.width;
    _controller.value += delta;
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (_controller.value > 0.3) {
      _openDrawer();
    }
  }

  void _openDrawer() => Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 1200),
      reverseTransitionDuration: const Duration(milliseconds: 1200),
      pageBuilder: (_, _, _) {
        return Material(
          color: Colors.transparent,
          child: DrawerMenuScreen(onClose: _closeDrawer),
        );
      },
      transitionsBuilder: (_, animation, _, child) {
        return Stack(
          children: [
            AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                return Container(
                  color: Colors.white.withOpacity(animation.value),
                );
              },
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ],
        );
      },
    ),
  );

  void _closeDrawer() => Navigator.of(context).pop();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<AppBlockCubit>(context);
    return GestureDetector(
      onHorizontalDragUpdate: _handleHorizontalDragUpdate,
      onHorizontalDragEnd: _handleHorizontalDragEnd,
      onTap: () {},
      child: Scaffold(
        key: _scaffoldKey,
        drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.2,
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Hero(
                tag: 'profileImage',
                createRectTween: (begin, end) => RectTween(begin: begin, end: end),
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: _openDrawer,
                    child: CircleAvatar(
                      radius: 18.5,
                      backgroundImage: (info != null && info!.logoPath.isNotEmpty)
                          ? FileImage(File(info!.logoPath))
                          : null,
                      child: (info == null || info!.logoPath.isEmpty)
                          ? Icon(Icons.person, color: Colors.black87, size: 18)
                          : null,
                    ),
                  )
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.green,
                ),
                child: const Text(
                  'Custom Design',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          padding: EdgeInsets.symmetric(horizontal: 20),
          color: Colors.grey[100],
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Text(
                  'Samples',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 350,
                  child: Center(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 10,
                          ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        final image = cubit.images[index];
                        return Align(
                          alignment: Alignment.center,
                          child: ImageDocCard(image: image),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.grey[200]),
                  ),
                  onPressed: () {
                    Get.to(() => const CreateInvoicePage());
                    // Get.to(() => PreviewInvoicePage());
                  },
                  child: const Text(
                    'Create Invoice',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),

                const SizedBox(height: 40),

                Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white,
                    border: const Border(
                      bottom: BorderSide(color: Colors.white70, width: 1.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Recent Invoices',
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              padding: const EdgeInsets.all(0),
                              iconSize: 25,
                              icon: const Icon(
                                Icons.chevron_right,
                                color: Colors.black87,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'None',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

