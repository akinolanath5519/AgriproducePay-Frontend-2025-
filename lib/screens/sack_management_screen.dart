import 'package:agriproduce/widgets/custom_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:agriproduce/data_models/sack_model.dart';
import 'package:agriproduce/state_management/sack_provider.dart';

class SackManagementScreen extends ConsumerStatefulWidget {
  const SackManagementScreen({super.key});

  @override
  _SackManagementScreenState createState() => _SackManagementScreenState();
}

class _SackManagementScreenState extends ConsumerState<SackManagementScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sackRecordsProvider.notifier).fetchSacks(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sackRecords = ref.watch(sackRecordsProvider);
    final filteredSackRecords = _filterSackRecords(sackRecords);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sack Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildSearchField(), // Custom Search Bar
            SizedBox(height: 10),
            Expanded(
              child: filteredSackRecords.isEmpty
                  ? _buildEmptyState(context)
                  : _buildSackTable(filteredSackRecords),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewSackRecord,
        tooltip: 'Add New Record',
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchField() {
    return CustomSearchBar(
      controller: searchController,
      hintText: 'Search by supplier name',
      onChanged: (_) => setState(() {}),
      onClear: () => setState(() {}),
    );
  }

  Widget _buildSackTable(List<SackRecord> sackRecords) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Supplier')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Bags Collected')),
          DataColumn(label: Text('Bags Returned')),
          DataColumn(label: Text('Bags Remaining')),
          DataColumn(label: Text('Actions')),
        ],
        rows: sackRecords.map((sackRecord) {
          return DataRow(
            cells: [
              DataCell(Text(sackRecord.supplierName)),
              DataCell(Text(DateFormat('yyyy-MM-dd').format(sackRecord.date))),
              DataCell(
                TextField(
                  controller: TextEditingController(
                      text: sackRecord.bagsCollected.toString()),
                  keyboardType: TextInputType.number,
                  onSubmitted: (value) {
                    final updatedRecord = sackRecord.copyWith(
                      bagsCollected: int.parse(value),
                    );
                    ref
                        .read(sackRecordsProvider.notifier)
                        .updateSack(updatedRecord);
                  },
                ),
              ),
              DataCell(
                TextField(
                  controller: TextEditingController(
                      text: sackRecord.bagsReturned.toString()),
                  keyboardType: TextInputType.number,
                  onSubmitted: (value) {
                    final updatedRecord = sackRecord.copyWith(
                      bagsReturned: int.parse(value),
                    );
                    ref
                        .read(sackRecordsProvider.notifier)
                        .updateSack(updatedRecord);
                  },
                ),
              ),
              DataCell(Text(sackRecord.bagsRemaining.toString())),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editSackRecord(sackRecord),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _showDeleteConfirmation(sackRecord.id),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        'No sacks available.',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  List<SackRecord> _filterSackRecords(List<SackRecord> sackRecords) {
    final query = searchController.text.toLowerCase();
    return sackRecords.where((sack) {
      return sack.supplierName.toLowerCase().contains(query);
    }).toList();
  }

  void _addNewSackRecord() {
    final newRecord = SackRecord(
      id: DateTime.now().toString(),
      supplierName: 'New Supplier',
      date: DateTime.now(),
      bagsCollected: 0,
      bagsReturned: 0,
    );

    ref.read(sackRecordsProvider.notifier).addSack(newRecord);
  }

  void _editSackRecord(SackRecord sackRecord) {
    // Handle edit logic
  }

  void _showDeleteConfirmation(String sackId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Sack Record'),
          content: Text('Are you sure you want to delete this record?'),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(sackRecordsProvider.notifier).deleteSack(sackId);
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Options'),
          content: Column(
            children: [
              // Implement date filters if required.
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
