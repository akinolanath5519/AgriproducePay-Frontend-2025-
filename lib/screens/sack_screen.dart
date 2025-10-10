import 'package:agriproduce/data_models/sack_model.dart';
import 'package:agriproduce/data_models/supplier_model.dart';
import 'package:agriproduce/state_management/sack_provider.dart';
import 'package:agriproduce/state_management/supplier_provider.dart';
import 'package:agriproduce/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SackManagementScreen extends ConsumerStatefulWidget {
  const SackManagementScreen({super.key});

  @override
  ConsumerState<SackManagementScreen> createState() =>
      _SackManagementScreenState();
}

class _SackManagementScreenState extends ConsumerState<SackManagementScreen> {
  bool _loading = true;
  String _selectedTypeFilter = 'All';
  String? _selectedSupplierFilterId;
  String? _selectedSupplierId; // for table view

 @override
void initState() {
  super.initState();
  _checkAndFetchData();
}

Future<void> _checkAndFetchData() async {
  final collections = ref.read(sackCollectionNotifierProvider);
  final returns = ref.read(sackReturnNotifierProvider);
  final suppliers = ref.read(supplierNotifierProvider);

  // ✅ Only fetch if data is empty
  if (collections.isEmpty || returns.isEmpty || suppliers.isEmpty) {
    setState(() => _loading = true);
    await _fetchData();
  } else {
    setState(() => _loading = false);
  }
}

Future<void> _fetchData() async {
  try {
    await ref.read(sackCollectionNotifierProvider.notifier).fetchSackCollections(ref);
    await ref.read(sackReturnNotifierProvider.notifier).fetchSackReturns(ref);
    await ref.read(supplierNotifierProvider.notifier).fetchSuppliers(ref);
  } catch (_) {}
  setState(() => _loading = false);
}


  Future<void> _showSackModal() async {
    final _formKey = GlobalKey<FormState>();
    Supplier? selectedSupplier;
    String type = 'Collected';
    int quantity = 0;
    String proxyName = '';

    final suppliers = ref.read(supplierNotifierProvider);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Sack Entry'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Supplier>(
                value: selectedSupplier,
                decoration: const InputDecoration(labelText: 'Supplier'),
                items: suppliers
                    .map((s) =>
                        DropdownMenuItem(value: s, child: Text(s.name)))
                    .toList(),
                onChanged: (s) => selectedSupplier = s,
                validator: (v) =>
                    v == null ? 'Please select a supplier' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(
                      value: 'Collected', child: Text('Collected')),
                  DropdownMenuItem(
                      value: 'Returned', child: Text('Returned')),
                ],
                onChanged: (v) => type = v!,
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Bags Quantity'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter quantity';
                  if (int.tryParse(v) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
                onSaved: (v) => quantity = int.parse(v!),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Collected By'),
                onSaved: (v) => proxyName = v ?? '',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                if (type == 'Collected') {
                  final newCollection = SackCollection(
                    id: '',
                    supplierId: int.parse(selectedSupplier!.id),
                    bagsCollected: quantity,
                    proxyName: proxyName,
                    collectedAt: DateTime.now(),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await ref
                      .read(sackCollectionNotifierProvider.notifier)
                      .createSackCollection(ref, newCollection);
                } else {
                  final newReturn = SackReturn(
                    id: '',
                    collectionId: 0,
                    supplierId: int.parse(selectedSupplier!.id),
                    bagsReturned: quantity,
                    proxyName: proxyName,
                    returnedAt: DateTime.now(),
                  );
                  await ref
                      .read(sackReturnNotifierProvider.notifier)
                      .createSackReturn(ref, newReturn);
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<SackCollection>>(sackCollectionNotifierProvider,
        (_, __) => setState(() {}));
    ref.listen<List<SackReturn>>(sackReturnNotifierProvider,
        (_, __) => setState(() {}));

    final collections = ref.watch(sackCollectionNotifierProvider);
    final returns = ref.watch(sackReturnNotifierProvider);
    final suppliers = ref.watch(supplierNotifierProvider);

    // Merge records
    final mergedList = <Map<String, dynamic>>[];
    for (var c in collections) {
      final supplier = suppliers.firstWhere(
        (s) => s.id == c.supplierId.toString(),
        orElse: () =>
            Supplier(id: c.supplierId.toString(), name: 'Unknown'),
      );
      mergedList.add({
        'dateTime': c.collectedAt,
        'supplierName': supplier.name,
        'supplierId': supplier.id,
        'type': 'Collected',
        'qty': c.bagsCollected,
        'proxy': c.proxyName ?? '-',
      });
    }
    for (var r in returns) {
      final supplier = suppliers.firstWhere(
        (s) => s.id == r.supplierId.toString(),
        orElse: () =>
            Supplier(id: r.supplierId.toString(), name: 'Unknown'),
      );
      mergedList.add({
        'dateTime': r.returnedAt,
        'supplierName': supplier.name,
        'supplierId': supplier.id,
        'type': 'Returned',
        'qty': r.bagsReturned,
        'proxy': r.proxyName ?? '-',
      });
    }

    // Apply filters
    final filteredList = mergedList.where((item) {
      final typeMatch = _selectedTypeFilter == 'All' ||
          item['type'] == _selectedTypeFilter;
      final supplierMatch = _selectedSupplierFilterId == null ||
          item['supplierId'] == _selectedSupplierFilterId;
      return typeMatch && supplierMatch;
    }).toList();

    filteredList.sort((a, b) => a['dateTime'].compareTo(b['dateTime']));

    // If in supplier view, restrict to that supplier
    final analyticsSource = _selectedSupplierId == null
        ? filteredList
        : filteredList
            .where((item) => item['supplierId'] == _selectedSupplierId)
            .toList();

    // Analytics
    int balance = 0;
    int totalCollected = 0;
    int totalReturned = 0;
    for (var item in analyticsSource) {
      if (item['type'] == 'Collected') {
        balance += item['qty'] as int;
        totalCollected += item['qty'] as int;
      } else {
        balance -= item['qty'] as int;
        totalReturned += item['qty'] as int;
      }
      item['balanceAfter'] = balance;
    }

    List<Map<String, dynamic>> supplierTable = [];
    if (_selectedSupplierId != null) {
      supplierTable = analyticsSource;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sack Management',
            style: AppText.appTitle),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSackModal,
        child: const Icon(Icons.add),
      ),
      body: AppBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Filters
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        DropdownButton<String>(
                          value: _selectedTypeFilter,
                          items: const [
                            DropdownMenuItem(
                                value: 'All', child: Text('All')),
                            DropdownMenuItem(
                                value: 'Collected',
                                child: Text('Collected')),
                            DropdownMenuItem(
                                value: 'Returned',
                                child: Text('Returned')),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedTypeFilter = v!),
                        ),
                        const SizedBox(width: 16),
                        DropdownButton<String>(
                          hint: const Text('Filter by Supplier'),
                          value: _selectedSupplierFilterId,
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('All Suppliers')),
                            ...suppliers.map((s) => DropdownMenuItem(
                                value: s.id, child: Text(s.name))),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedSupplierFilterId = v),
                        ),
                        const Spacer(),
                        IconButton(
                            onPressed: _fetchData,
                            icon: const Icon(Icons.refresh)),
                      ],
                    ),
                  ),
                  // Analytics
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAnalyticsCard(
                            'Total Collected',
                            totalCollected,
                            AppColors.successGreen),
                        _buildAnalyticsCard(
                            'Total Returned',
                            totalReturned,
                            AppColors.orangeAccent),
                        _buildAnalyticsCard(
                            'Net Balance',
                            balance,
                            AppColors.primary),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _selectedSupplierId == null
                        ? ListView.builder(
                            itemCount: suppliers.length,
                            itemBuilder: (context, index) {
                              final supplier = suppliers[index];
                              return Card(
                                child: ListTile(
                                  title: Text(supplier.name,
                                      style: AppText.cardTitle),
                                  trailing: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedSupplierId =
                                            supplier.id;
                                      });
                                    },
                                    child: const Text('View Sacks'),
                                  ),
                                ),
                              );
                            },
                          )
                        : Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () => setState(
                                      () =>
                                          _selectedSupplierId = null),
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text(
                                      'Back to Suppliers'),
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text('D')),
                                      DataColumn(label: Text('Type')),
                                      DataColumn(
                                          label:
                                              Text('Balance After')),
                                      DataColumn(label: Text('Qty')),
                                      DataColumn(label: Text('Proxy')),
                                      DataColumn(
                                          label: Text('DateTime')),
                                    ],
                                    rows: List.generate(
                                      supplierTable.length,
                                      (index) {
                                        final item =
                                            supplierTable[index];
                                        return DataRow(cells: [
                                          DataCell(Text(
                                              '${index + 1}')),
                                          DataCell(Text(item['type'])),
                                          DataCell(Text(
                                              '${item['balanceAfter']}')),
                                          DataCell(Text(
                                              '${item['qty']}')),
                                          DataCell(Text(item['proxy'])),
                                          DataCell(Text(item['dateTime']
                                              .toString()
                                              .split('.')
                                              .first)),
                                        ]);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, int value, Color color) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 110,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: AppText.cardTitle),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: AppText.cardValue.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
