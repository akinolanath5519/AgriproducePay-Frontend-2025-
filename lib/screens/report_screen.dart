import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:agriproduce/state_management/transaction_provider.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      await ref.read(transactionProvider.notifier).fetchTransactions(ref);
      setState(() {
        errorMessage = null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _openFile(String filePath) async {
    final result = await OpenFile.open(filePath);

    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open the file: ${result.message}')),
      );
    }
  }

  Future<void> _downloadCsvReport() async {
    // Request storage permission
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission is required.')),
      );
      return; // Exit the method if permission is not granted
    }

    // Proceed with the CSV generation and file saving
    final transactions = ref.read(transactionProvider);

    final List<List<dynamic>> rows = [
      ['Date', 'Commodity', 'Price', 'Weight'],
    ];

    for (var transaction in transactions) {
      rows.add([
        transaction.transactionDate,
        transaction.commodityName,
        transaction.price,
        transaction.weight,
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);

    try {
      // Get the directory for saving the file
      final directory = Directory('/storage/emulated/0/Download');
      final file = File('${directory.path}/transaction_report.csv');

      // Write the CSV data to the file
      await file.writeAsString(csvData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV saved to ${file.path}')),
      );

      // Open the file after saving
      await _openFile(file.path);
    } catch (e) {
      // Handle any file writing errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving CSV: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(
                    child: Text(
                      errorMessage!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.red),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDownloadButtons(),
                        const SizedBox(height: 24),
                        _buildSectionCard(
                          'Analytics Summary',
                          _buildSummaryCard(transactions),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionCard(
                          'Commodity Reports',
                          _buildCommodityReports(transactions),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionCard(
                          'Supplier Insights',
                          _buildSupplierReports(transactions),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionCard(
                          'User Specific Reports',
                          _buildUserReports(transactions),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildDownloadButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _downloadCsvReport,
          icon: const Icon(Icons.table_chart),
          label: const Text("Download CSV"),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, Widget child) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Theme.of(context).primaryColor.withOpacity(0.2),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(title),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSummaryCard(List transactions) {
    final totalTransactions = transactions.length;
    final totalRevenue = transactions.fold<double>(
        0, (sum, transaction) => sum + transaction.price);
    final totalWeight = transactions.fold<double>(
        0, (sum, transaction) => sum + transaction.weight);

    final avgTransactionValue =
        totalWeight > 0 ? totalRevenue / totalWeight : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryRow('Total Transactions',
            NumberFormat('#,##0').format(totalTransactions)),
        _buildSummaryRow('Total Purchases',
            '${NumberFormat('#,##0.00').format(totalRevenue)}'),
        _buildSummaryRow('Total Weight',
            '${NumberFormat('#,##0.00').format(totalWeight)} kg'),
        _buildSummaryRow('Average Transaction Rate',
            '${NumberFormat('#,##0.00').format(avgTransactionValue)}'),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
              softWrap: true,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommodityReports(List transactions) {
    final commodityRevenue = <String, double>{};
    final commodityVolume = <String, double>{};
    for (var transaction in transactions) {
      commodityRevenue.update(
          transaction.commodityName, (value) => value + transaction.price,
          ifAbsent: () => transaction.price);
      commodityVolume.update(
          transaction.commodityName, (value) => value + transaction.weight,
          ifAbsent: () => transaction.weight);
    }

    final topCommoditiesByRevenue = commodityRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCommoditiesByVolume = commodityVolume.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        _buildReportRow(
            'Top Commodities by Purchases',
            topCommoditiesByRevenue.isNotEmpty
                ? '${topCommoditiesByRevenue[0].key}: ${NumberFormat('#,##0.00').format(topCommoditiesByRevenue[0].value)}'
                : 'No data'),
        _buildReportRow(
            'Top Commodities by Volume',
            topCommoditiesByVolume.isNotEmpty
                ? '${topCommoditiesByVolume[0].key}: ${NumberFormat('#,##0.00').format(topCommoditiesByVolume[0].value)} kg'
                : 'No data'),
      ],
    );
  }

  Widget _buildSupplierReports(List transactions) {
    final supplierRevenue = <String, double>{};
    for (var transaction in transactions) {
      supplierRevenue.update(
          transaction.supplierName, (value) => value + transaction.price,
          ifAbsent: () => transaction.price);
    }

    final topSuppliersByRevenue = supplierRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        _buildReportRow(
            'Top Suppliers by Revenue',
            topSuppliersByRevenue.isNotEmpty
                ? '${topSuppliersByRevenue[0].key}: ${NumberFormat('#,##0.00').format(topSuppliersByRevenue[0].value)}'
                : 'No data'),
      ],
    );
  }

  Widget _buildUserReports(List transactions) {
    return const Text("User-specific report implementation here.");
  }

  Widget _buildReportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}