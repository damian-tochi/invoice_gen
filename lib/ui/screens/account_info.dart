import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import '../../app_block/account_cubit.dart';
import '../../components/text_field.dart';
import '../../components/text_field_multiline.dart';
import '../../model/account_info_object.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({Key? key}) : super(key: key);

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl, locCtrl, typeCtrl, phoneCtrl, emailCtrl, noteCtrl;
  String? logoPath;


  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController();
    locCtrl = TextEditingController();
    typeCtrl = TextEditingController();
    phoneCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    noteCtrl = TextEditingController();

    Get.find<AccountCubit>().loadAccountInfo().then((_) {
      final info = Get.find<AccountCubit>().state;
      if (info != null) {
        nameCtrl.text = info.businessName;
        locCtrl.text = info.location;
        typeCtrl.text = info.inventoryType;
        phoneCtrl.text = info.phone;
        emailCtrl.text = info.email;
        noteCtrl.text = info.note;
        logoPath = info.logoPath;
      }
    });
  }

  Future<void> saveAccount(BuildContext context) async {
    final info = AccountInfo(
      businessName: nameCtrl.text,
      location: locCtrl.text,
      inventoryType: typeCtrl.text,
      logoPath: logoPath ?? '',
      phone: phoneCtrl.text,
      email: emailCtrl.text, note: noteCtrl.text,
    );
    Get.find<AccountCubit>().updateAccountInfo(info);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));

  }

  Future<void> pickLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final dir = await getApplicationDocumentsDirectory();
      final saved = await File(picked.path).copy('${dir.path}/${basename(picked.path)}');
      setState(() {
        logoPath = saved.path;
      });
      Get.snackbar('Logo path:', '$logoPath',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Information'), titleTextStyle: TextStyle(fontSize: 16, color: Colors.black),),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: pickLogo,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                  logoPath != null ? FileImage(File(logoPath!)) : null,
                  child: logoPath == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              textField(
                controller: nameCtrl,
                validator: (value) =>
                value!.isEmpty ? 'Enter Business Name' : null,
                label: 'Business Name',
              ),
              const SizedBox(height: 10),
              textField(
                controller: emailCtrl,
                validator: (value) =>
                value!.isEmpty ? 'Enter Business Email' : null,
                label: 'Business Email',
              ),
              const SizedBox(height: 10),
              textField(
                controller: phoneCtrl,
                validator: (value) =>
                value!.isEmpty ? 'Enter Business Phone' : null,
                label: 'Business Phone',
              ),
              const SizedBox(height: 10),
              textField(
                controller: locCtrl,
                validator: (value) =>
                value!.isEmpty ? 'Enter Business Location' : null,
                label: 'Business Location',
              ),
              const SizedBox(height: 10),
              textField(
                controller: typeCtrl,
                validator: (value) =>
                value!.isEmpty ? 'Enter Inventory Type' : null,
                label: 'Business Inventory Type',
              ),
              const SizedBox(height: 10),
              textFieldMultiline(
                controller: noteCtrl,
                validator: (value) =>
                value!.isEmpty ? 'Invoice Note' : null,
                label: 'Invoice Note',
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.grey[200]),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    saveAccount(context);
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
