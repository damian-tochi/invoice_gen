import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:invoice_gen/model/client_object.dart';
import 'package:invoice_gen/model/items_object.dart';
import 'package:invoice_gen/model/transaction_object.dart';
import 'package:invoice_gen/ui/screens/preview_invoice.dart';
import 'package:signature/signature.dart';
import 'dart:typed_data';
import '../../app_block/transactions_cubit.dart';
import '../../components/date_field.dart';
import '../../components/dropdown_menu.dart';
import '../../components/text_field.dart';
import '../../constants/preferences_service.dart';
import '../../db/client_db.dart';
import '../../helper/transaction_id_helper.dart';

class CreateInvoicePage extends StatefulWidget {
  const CreateInvoicePage({super.key});

  @override
  _CreateInvoicePageState createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends State<CreateInvoicePage> {
  final _formKey = GlobalKey<FormState>();
  final List<ItemsObject> _items = [];

  final _titleController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientAddressController = TextEditingController();
  final _invoiceDateController = TextEditingController();

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  String _selectedStatus = 'Pending';

  double get subtotal => _items.fold(0.0, (sum, item) {
    return sum + (item.quantity * item.price);
  });
  double _tax = 0.0;

  double get tax => subtotal * _tax;

  double get total => subtotal + tax;

  List<ClientObject> _customers = [];

  ClientObject? _selectedCustomer;

  String _searchTerm = '';

  final bool _sortAscending = true;

  String? _signaturePath;

  bool loadSavedSignature = false;

  Future<void> _loadPrefs() async {
    final prefs = await PreferenceService.load();
    if (prefs != null) {
      setState(() {
        double tax = prefs.taxDeduction;
        _signaturePath = prefs.signaturePath;
        _tax = tax / 100;
      });
    }
  }

  void _addItem() {
    setState(() {
      ItemsObject item = ItemsObject(description: '', quantity: 1, price: 0.0);
      _items.add(item);
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadCustomers() async {
    final data = await CustomerDB.instance.getCustomers(
      search: _searchTerm,
      ascending: _sortAscending,
    );
    setState(() => _customers = data);
  }

  Future<void> _loadCustomersAndShowDialog() async {
    await _loadCustomers();
    _showCustomersDialog();
  }

  void _showCustomersDialog() {
    List<ClientObject> filteredCustomers = List.from(_customers);

    void filterCustomers(String query) {
      _searchTerm = query;
      filteredCustomers = _customers
          .where(
            (c) =>
                c.clientName.toLowerCase().contains(query.toLowerCase()) ||
                c.clientEmail.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Import Customer"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: "Search customer...",
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        filterCustomers(value);
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    width: double.maxFinite,
                    child: Expanded(
                      child: filteredCustomers.isEmpty
                          ? const Center(child: Text("No matching customers"))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredCustomers.length,
                              itemBuilder: (context, index) {
                                final customer = filteredCustomers[index];
                                return ListTile(
                                  title: Text(customer.clientName),
                                  subtitle: Text(customer.clientEmail),
                                  onTap: () {
                                    Navigator.pop(context, customer);
                                  },
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
    ).then((selected) {
      if (selected != null && selected is ClientObject) {
        setState(() {
          _selectedCustomer = selected;
          _clientAddressController.text = _selectedCustomer!.clientAddress;
          _clientNameController.text = _selectedCustomer!.clientName;
          _clientEmailController.text = _selectedCustomer!.clientEmail;
        });
      }
    });
  }

  Future<void> _submitInvoice(AppBlockCubit cubit) async {
    if (!_formKey.currentState!.validate()) return;

    if (_signatureController.isEmpty && !loadSavedSignature) {
      Get.snackbar(
        'Missing Signature',
        'Please provide a signature before submitting.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      Uint8List? signatureBytes = await _signatureController.toPngBytes();

      if (signatureBytes == null && _signaturePath != null) {
        signatureBytes = await File(_signaturePath!).readAsBytes();
      }

      if (signatureBytes == null) {
        Get.snackbar(
          'Error',
          'Unable to load signature.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      var transactionId = await TransactionIdManager.getNextTransactionId();

      final client = _selectedCustomer ??
          ClientObject(
            clientAddress: _clientAddressController.text,
            clientName: _clientNameController.text,
            clientEmail: _clientEmailController.text,
            clientPhone: '',
          );

      final transactionObject = TransactionObject(
        clientObject: client,
        invoiceTitle: _titleController.text,
        invoiceDate: _invoiceDateController.text,
        paymentStatus: _selectedStatus,
        total: total,
        subTotal: subtotal.toString(),
        taxDeduction: tax.toString(),
        signature: signatureBytes,
        items: _items,
        transactionId: transactionId,
        invoiceType: cubit.selectedInvoice
      );

      cubit.transactionObject = transactionObject;

      Get.to(() => PreviewInvoicePage());
    } catch (e, stackTrace) {
      Get.snackbar(
        'Error',
        'Failed to prepare invoice: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      if (kDebugMode) {
        print("Error: $e\n$stackTrace");
      }
    }
  }


  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      _invoiceDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _invoiceDateController.dispose();
    super.dispose();
  }

  void importSignature() {
    setState(() {
      loadSavedSignature = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Create Invoice',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),

            GestureDetector(
              onTap: _loadCustomersAndShowDialog,
              child: SvgPicture.asset(
                'assets/icons/filter_ico.svg',
                width: 24,
                height: 24,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),

              textField(
                controller: _titleController,
                validator: (value) =>
                    value!.isEmpty ? 'Enter invoice title' : null,
                label: 'Invoice Title',
              ),
              const SizedBox(height: 16),

              textField(
                controller: _clientNameController,
                validator: (value) =>
                    value!.isEmpty ? 'Enter client name' : null,
                label: 'Client Name',
              ),

              const SizedBox(height: 16),

              textField(
                controller: _clientEmailController,
                validator: (value) =>
                    value!.isEmpty ? 'Enter client email' : null,
                label: 'Client Email',
              ),
              const SizedBox(height: 16),

              textField(
                controller: _clientAddressController,
                validator: (value) =>
                    value!.isEmpty ? 'Enter client address' : null,
                label: 'Client Address',
              ),
              const SizedBox(height: 16),

              dateField(
                controller: _invoiceDateController,
                validator: (value) =>
                    value!.isEmpty ? 'Select transaction date' : null,
                label: 'Transaction Date',
                pickDate: _pickDate,
              ),
              const SizedBox(height: 16),

              dropdownMenu<String>(
                value: _selectedStatus,
                items: ['Paid', 'Pending', 'Overdue'],
                onChanged: (val) {
                  setState(() {
                    _selectedStatus = val!;
                  });
                },
                label: 'Payment Status',
              ),
              const SizedBox(height: 24),

              const Text(
                'Items purchased',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ..._items.asMap().entries.map((entry) {
                int index = entry.key;
                var item = entry.value;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        textField(
                          onChanged: (val) => item.description = val,
                          validator: (value) =>
                              value!.isEmpty ? 'Enter item description' : null,
                          label: 'Description',
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: textField(
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  item.quantity = int.tryParse(val) ?? 1;
                                  setState(() {});
                                },
                                validator: (value) =>
                                    value!.isEmpty ? 'Enter quantity' : null,
                                label: 'Quantity',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: textField(
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  item.price = double.tryParse(val) ?? 0.0;
                                  setState(() {});
                                },
                                validator: (value) =>
                                    value!.isEmpty ? 'Enter price' : null,
                                label: 'Price',
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeItem(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                onPressed: _addItem,
              ),

              const SizedBox(height: 24),
              const Divider(thickness: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildAmountRow('Subtotal', subtotal),
                    _buildAmountRow('Tax (${(_tax * 100).toInt()}%)', tax),
                    const SizedBox(height: 4),
                    _buildAmountRow('Total', total, bold: true),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Signature',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              loadSavedSignature
                  ? Image.file(File(_signaturePath!), height: 150)
                  : Signature(
                      controller: _signatureController,
                      height: 150,
                      backgroundColor: Colors.grey[200]!,
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_signaturePath != null && loadSavedSignature == false)
                    TextButton(
                      onPressed: () => importSignature(),
                      child: const Text('Import'),
                    ),
                  Spacer(),
                  TextButton(
                    onPressed: () => {
                      setState(() {
                        loadSavedSignature = false;
                      }),
                      _signatureController.clear(),
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.grey[200]),
                ),
                onPressed: () {
                  final cubit = Get.find<AppBlockCubit>();
                  _submitInvoice(cubit);
                },
                child: const Text(
                  'Preview Invoice',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '$label: ₦${amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontSize: bold ? 16 : 14,
        ),
      ),
    );
  }
}
