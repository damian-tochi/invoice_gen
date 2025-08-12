import 'package:flutter/material.dart';
import '../../components/search_field.dart';
import '../../db/transactions_db.dart';
import '../../model/transaction_object.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<TransactionObject> _transactions = [];
  String _searchQuery = '';
  String _sortBy = 'invoiceDate';
  bool _asc = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _loading = true);

    final results = await TransactionDB.instance.getTransactions(
      search: _searchQuery,
      sortBy: _sortBy,
      asc: _asc,
    );

    setState(() {
      _transactions = results;
      _loading = false;
    });
  }

  void _onSearchChanged(String value) {
    _searchQuery = value;
    _loadTransactions();
  }

  void _onSortChange(String field) {
    setState(() {
      if (_sortBy == field) {
        _asc = !_asc;
      } else {
        _sortBy = field;
        _asc = false;
      }
    });
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice History'),
        titleTextStyle: TextStyle(fontSize: 16, color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(_asc ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () => _onSortChange(_sortBy),
          ),
          PopupMenuButton<String>(
            onSelected: _onSortChange,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'invoiceDate',
                child: Text('Sort by Date'),
              ),
              const PopupMenuItem(
                value: 'total',
                child: Text('Sort by Amount'),
              ),
              const PopupMenuItem(
                value: 'name',
                child: Text('Sort by Client Name'),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: searchField(
              label: 'Search by client or item bought',
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTransactions,
              child: _transactions.isEmpty
                  ? const Center(child: Text('No Invoice found'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _transactions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final tx = _transactions[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              tx.clientObject.clientName.isNotEmpty
                                  ? tx.clientObject.clientName[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(tx.invoiceTitle),
                          subtitle: Text(
                            "${tx.clientObject.clientName} • ${tx.invoiceDate}",
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "\$${tx.total.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                tx.paymentStatus,
                                style: TextStyle(
                                  color:
                                      tx.paymentStatus.toLowerCase() == 'paid'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // TODO: open transaction details page
                          },
                        );
                      },
                    ),
            ),
    );
  }
}
