import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:agriproduce/state_management/transaction_provider.dart';
import 'package:path_provider/path_provider.dart';

Future<void> downloadPdfReport(
    WidgetRef ref,
    TextEditingController searchController,
    DateTime? startDate,
    DateTime? endDate) async {
  final transactions = ref.read(transactionProvider);
  final searchLower = searchController.text.toLowerCase();

  final filteredTransactions = transactions.where((transaction) {
    final matchesQuery = (transaction.supplierName
                ?.toLowerCase()
                .contains(searchLower) ??
            false) ||
        (transaction.commodityName?.toLowerCase().contains(searchLower) ??
            false) ||
        (transaction.userName?.toLowerCase().contains(searchLower) ?? false);

    final matchesDate = (startDate == null || endDate == null) ||
        (transaction.transactionDate != null &&
            transaction.transactionDate!
                .isAfter(startDate!.subtract(const Duration(days: 1))) &&
            transaction.transactionDate!
                .isBefore(endDate!.add(const Duration(days: 1))));

    return matchesQuery && matchesDate;
  }).toList();

  final totalPrice =
      filteredTransactions.fold(0.0, (sum, item) => sum + item.price);
  final totalWeight =
      filteredTransactions.fold(0.0, (sum, item) => sum + item.weight);
  final totalBags =
      filteredTransactions.fold(0.0, (sum, item) => sum + (item.weight / 85));

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Purchases Report',
                style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.deepPurple),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Date Range: ${startDate != null && endDate != null ? '${DateFormat('yyyy-MM-dd').format(startDate!)} - ${DateFormat('yyyy-MM-dd').format(endDate!)}' : 'All Dates'}',
                style: pw.TextStyle(fontSize: 16, color: PdfColors.grey),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.deepPurple, thickness: 2),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                headers: [
                  'S/N',
                  'Date',
                  'Supplier',
                  'Commodity',
                  'User',
                  'Time',
                  'Rate',
                  'Weight',
                  'Amount',
                  'Bag',
                  'Remark',
                ],
                data: [
                  ...filteredTransactions.asMap().entries.map((entry) {
                    final index = entry.key + 1; // Serial number
                    final transaction = entry.value;
                    return [
                      index.toString(),
                      DateFormat('yyyy-MM-dd')
                          .format(transaction.transactionDate!),
                      transaction.supplierName ?? '',
                      transaction.commodityName ?? '',
                      transaction.userName ?? '',
                      DateFormat('hh:mm a')
                          .format(transaction.transactionDate!),
                      transaction.rate.toStringAsFixed(2),
                      transaction.weight.toStringAsFixed(2),
                      NumberFormat('#,##0.00').format(transaction.price),
                      (transaction.weight / 85)
                          .toStringAsFixed(2), // Bag calculation
                      '', // Placeholder for Remark
                    ];
                  }).toList(),
                  [
                    'Total',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    totalWeight.toStringAsFixed(2),
                    NumberFormat('#,##0.00').format(totalPrice),
                    totalBags.toStringAsFixed(2),
                    '',
                  ],
                ],
                cellStyle: pw.TextStyle(fontSize: 8),
                headerStyle: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(color: PdfColors.deepPurple),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.deepPurple, thickness: 2),
              pw.SizedBox(height: 8),
              pw.Text(
                'Summary',
                style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.deepPurple),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Total Weight: ${totalWeight.toStringAsFixed(2)} kg',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                'Total Amount: ${NumberFormat('#,##0.00').format(totalPrice)}',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                'Total No of Bags: ${totalBags.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

Future<void> downloadCsvReport(
  BuildContext context,
  WidgetRef ref,
  TextEditingController searchController,
  DateTime? startDate,
  DateTime? endDate,
) async {
  try {
    // Fetch transactions and filter
    final transactions = ref.read(transactionProvider);
    final searchLower = searchController.text.toLowerCase();

    final filteredTransactions = transactions.where((transaction) {
      final matchesQuery = (transaction.supplierName
                  ?.toLowerCase()
                  .contains(searchLower) ??
              false) ||
          (transaction.commodityName?.toLowerCase().contains(searchLower) ??
              false) ||
          (transaction.userName?.toLowerCase().contains(searchLower) ?? false);

      final matchesDate = (startDate == null || endDate == null) ||
          (transaction.transactionDate != null &&
              transaction.transactionDate!
                  .isAfter(startDate!.subtract(const Duration(days: 1))) &&
              transaction.transactionDate!
                  .isBefore(endDate!.add(const Duration(days: 1))));

      return matchesQuery && matchesDate;
    }).toList();

    // Prepare CSV rows
    List<List<dynamic>> rows = [
      [
        'S/N',
        'Date',
        'Supplier',
        'Commodity',
        'User',
        'Time',
        'Rate',
        'Weight',
        'Amount',
        'Bag',
        'Remark'
      ],
      ...filteredTransactions.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final transaction = entry.value;
        return [
          index.toString(),
          DateFormat('yyyy-MM-dd')
              .format(transaction.transactionDate ?? DateTime.now()),
          transaction.supplierName ?? '',
          transaction.commodityName ?? '',
          transaction.userName ?? '',
          DateFormat('HH:mm')
              .format(transaction.transactionDate ?? DateTime.now()),
          transaction.rate.toStringAsFixed(2),
          transaction.weight.toStringAsFixed(2),
          NumberFormat('#,##0.00').format(transaction.price),
          (transaction.weight / 85).toStringAsFixed(2),
          '',
        ];
      }).toList(),
    ];

    // Convert rows to CSV
    String csvData = const ListToCsvConverter().convert(rows);

    // Get the directory to save the file
    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/Download/purchases_report.csv';
    debugPrint('Saving CSV to: $path'); // Add this line for debugging

    // Write data to the file
    final file = File(path);
    await file.writeAsString(csvData);

    // Notify success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('CSV report saved to $path')),
    );
  } catch (e, stackTrace) {
    // Log and notify errors
    debugPrint('Error: $e');
    debugPrint('StackTrace: $stackTrace');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error generating report: $e')),
    );
  }
}
