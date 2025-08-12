import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:invoice_gen/model/account_info_object.dart';
import 'package:invoice_gen/ui/screens/PreferencesPage.dart';
import 'package:invoice_gen/ui/screens/account_info.dart';
import 'package:invoice_gen/ui/screens/customers_page.dart';
import 'package:invoice_gen/ui/screens/transactions_page.dart';

import '../app_block/account_cubit.dart';

class DrawerMenuScreen extends StatefulWidget {
  final VoidCallback onClose;

  const DrawerMenuScreen({super.key, required this.onClose});

  @override
  State<DrawerMenuScreen> createState() => _DrawerMenuScreenState();
}

class _DrawerMenuScreenState extends State<DrawerMenuScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
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
      duration: const Duration(milliseconds: 500),
    );
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta! / MediaQuery.of(context).size.width;
    _controller.value += delta;
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (_controller.value <= 0.3) {
      widget.onClose();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: GestureDetector(
        onHorizontalDragUpdate: _handleHorizontalDragUpdate,
        onHorizontalDragEnd: _handleHorizontalDragEnd,
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            top: 30,
            bottom: 20,
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.black87),
                      iconSize: 20,
                      onPressed: widget.onClose,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 10, bottom: 70),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Hero(
                        tag: 'profileImage',
                        createRectTween: (begin, end) {
                          return RectTween(begin: begin, end: end);
                        },
                        child: Material(
                          color: Colors.transparent,
                          child: info != null
                              ? CircleAvatar(
                                  radius: 50,
                                  backgroundImage: info!.logoPath != ''
                                      ? FileImage(File(info!.logoPath))
                                      : null,
                                  child: info!.logoPath == ''
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.black87,
                                          size: 50,
                                        )
                                      : null,
                                )
                              : const Icon(
                                  Icons.person,
                                  color: Colors.black87,
                                  size: 50,
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        info != null ? info!.businessName : 'John Doe',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildMenuOption(
                        'Invoice History',
                        'View previously generated invoices',
                        () {
                          Get.to(() => TransactionsPage());
                        },
                      ),
                      _buildMenuOption(
                        'Account information',
                        'Update your company details or create new one.',
                        () {
                          Get.to(() => AccountInfoPage());
                        },
                      ),
                      _buildMenuOption(
                        'Preferences',
                        'Set tax deductions, signature, dominant colors, etc.',
                        () {
                          Get.to(() => PreferencePage());
                        },
                      ),
                      _buildMenuOption(
                        'Saved Customers',
                        'Manage your saved customer details and emails.',
                        () {
                          Get.to(() => CustomerPage());
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Version 0.0.1 (1)",
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    String title,
    String description,
    Function() clickAction,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: double.infinity,
      padding: const EdgeInsets.only(left: 15, right: 4, top: 15, bottom: 15),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(color: Colors.white70, width: 1.0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.black87),
            iconSize: 30,
            onPressed: clickAction,
          ),
        ],
      ),
    );
  }
}
