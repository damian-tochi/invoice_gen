import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:invoice_gen/components/search_field.dart';
import 'package:invoice_gen/model/client_object.dart';
import '../../db/client_db.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  List<ClientObject> _customers = [];
  String _searchTerm = '';
  bool _sortAscending = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final data = await CustomerDB.instance.getCustomers(
      search: _searchTerm,
      ascending: _sortAscending,
    );
    setState(() => _customers = data);
  }

  void _showCustomerDialog({ClientObject? customer}) {
    final nameController = TextEditingController(text: customer?.clientName);
    final emailController = TextEditingController(text: customer?.clientEmail);
    final phoneController = TextEditingController(text: customer?.clientPhone);
    final addressController = TextEditingController(
      text: customer?.clientAddress,
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(customer == null ? "Add Customer" : "Edit Customer"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Address"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (customer == null) {
                await CustomerDB.instance.addCustomer(
                  ClientObject(
                    clientName: nameController.text,
                    clientEmail: emailController.text,
                    clientPhone: phoneController.text,
                    clientAddress: addressController.text,
                  ),
                );
              } else {
                await CustomerDB.instance.updateCustomer(
                  ClientObject(
                    id: customer.id,
                    clientName: nameController.text,
                    clientEmail: emailController.text,
                    clientPhone: phoneController.text,
                    clientAddress: addressController.text,
                  ),
                );
              }
              Navigator.pop(context);
              _loadCustomers();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _importContact() async {
    if (await FlutterContacts.requestPermission()) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        builder: (_) => ListView(
          children: contacts.map((c) {
            return ListTile(
              title: Text(c.displayName),
              subtitle: Text(c.phones.isNotEmpty ? c.phones.first.number : ''),
              onTap: () async {
                await CustomerDB.instance.addCustomer(
                  ClientObject(
                    clientName: c.displayName,
                    clientEmail: c.emails.isNotEmpty
                        ? c.emails.first.address
                        : '',
                    clientPhone: c.phones.isNotEmpty
                        ? c.phones.first.number
                        : '',
                    clientAddress: '',
                  ),
                );
                Navigator.pop(context);
                _loadCustomers();
              },
            );
          }).toList(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customers"),
        titleTextStyle: TextStyle(fontSize: 16, color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(
              _sortAscending ? Icons.arrow_downward : Icons.arrow_upward,
            ),
            onPressed: () {
              setState(() => _sortAscending = !_sortAscending);
              _loadCustomers();
            },
          ),
          IconButton(
            icon: const Icon(Icons.contacts),
            onPressed: _importContact,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCustomerDialog(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: searchField(
              controller: _searchController,
              label: "Search customers...",
              onPressed: () {
                setState(() => _searchTerm = _searchController.text);
                _loadCustomers();
              },
            ),

            // TextField(
            //   controller: _searchController,
            //   decoration: InputDecoration(
            //     hintText: "Search customers...",
            //     suffixIcon: IconButton(
            //       icon: const Icon(Icons.search),
            //       onPressed: () {
            //         setState(() => _searchTerm = _searchController.text);
            //         _loadCustomers();
            //       },
            //     ),
            //   ),
            // ),
          ),
        ),
      ),
      body: _customers.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("No customers found"),
                  SizedBox(height: 20,),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        Colors.grey[200],
                      ),
                    ),
                    onPressed: () {
                      _showCustomerDialog();
                    },
                    child: Text(
                      'Create Customer',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _customers.length,
              itemBuilder: (context, index) {
                final customer = _customers[index];
                return ListTile(
                  title: Text(customer.clientName),
                  subtitle: Text(customer.clientEmail),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _showCustomerDialog(customer: customer),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await CustomerDB.instance.deleteCustomer(
                            customer.id!,
                          );
                          _loadCustomers();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
