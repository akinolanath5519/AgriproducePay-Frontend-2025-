import 'package:agriproduce/data_models/sack_collection_model.dart';
import 'package:agriproduce/data_models/sack_return_model.dart';
import 'package:agriproduce/data_models/supplier_model.dart';
import 'package:agriproduce/state_management/sack_provider.dart';
import 'package:agriproduce/state_management/supplier_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SackManagementScreen extends ConsumerStatefulWidget {
  const SackManagementScreen({super.key});

  @override
  ConsumerState<SackManagementScreen> createState() => _SackManagementScreenState();
}

class _SackManagementScreenState extends ConsumerState<SackManagementScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
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
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.name),
                        ))
                    .toList(),
                onChanged: (s) => selectedSupplier = s,
                validator: (v) => v == null ? 'Please select a supplier' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'Collected', child: Text('Collected')),
                  DropdownMenuItem(value: 'Returned', child: Text('Returned')),
                ],
                onChanged: (v) => type = v!,
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Bags Quantity'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter quantity';
                  if (int.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
                onSaved: (v) => quantity = int.parse(v!),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Collected By'),
                onSaved: (v) => proxyName = v ?? '',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
                  await ref.read(sackCollectionNotifierProvider.notifier)
                      .createSackCollection(ref, newCollection);
                } else {
                  final newReturn = SackReturn(
                    id: '',
                    collectionId: 0, // backend decides which collection to return against
                    supplierId: int.parse(selectedSupplier!.id),
                    bagsReturned: quantity,
                    proxyName: proxyName,
                    returnedAt: DateTime.now(),
                  );
                  await ref.read(sackReturnNotifierProvider.notifier)
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
    ref.listen<List<SackCollection>>(sackCollectionNotifierProvider, (_, __) {
      setState(() {}); // rebuild table when collections change
    });

    ref.listen<List<SackReturn>>(sackReturnNotifierProvider, (_, __) {
      setState(() {}); // rebuild table when returns change
    });

    final collections = ref.watch(sackCollectionNotifierProvider);
    final returns = ref.watch(sackReturnNotifierProvider);

    // Merge and sort by date
    final mergedList = <Map<String, dynamic>>[];
    for (var c in collections) {
      mergedList.add({
        'dateTime': c.collectedAt,
        'supplierName': 'Supplier ${c.supplierId}',
        'type': 'Collected',
        'qty': c.bagsCollected,
        'proxy': c.proxyName ?? '-',
      });
    }
    for (var r in returns) {
      mergedList.add({
        'dateTime': r.returnedAt,
        'supplierName': 'Supplier ${r.supplierId}',
        'type': 'Returned',
        'qty': r.bagsReturned,
        'proxy': r.proxyName ?? '-',
      });
    }
    mergedList.sort((a, b) => a['dateTime'].compareTo(b['dateTime']));

    int balance = 0;
    for (var item in mergedList) {
      if (item['type'] == 'Collected') {
        balance += item['qty'] as int;
      } else {
        balance -= item['qty'] as int;
      }
      item['balanceAfter'] = balance;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sack Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSackModal,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('D')),
                    DataColumn(label: Text('Supplier')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Balance After')),
                    DataColumn(label: Text('Qty')),
                    DataColumn(label: Text('Proxy')),
                    DataColumn(label: Text('DateTime')),
                  ],
                  rows: List.generate(
                    mergedList.length,
                    (index) {
                      final item = mergedList[index];
                      return DataRow(cells: [
                        DataCell(Text('${index + 1}')),
                        DataCell(Text(item['supplierName'])),
                        DataCell(Text(item['type'])),
                        DataCell(Text('${item['balanceAfter']}')),
                        DataCell(Text('${item['qty']}')),
                        DataCell(Text(item['proxy'])),
                        DataCell(Text(item['dateTime'].toString().split('.').first)),
                      ]);
                    },
                  ),
                ),
              ),
            ),
    );
  }
}
