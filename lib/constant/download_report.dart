import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:agriproduce/state_management/transaction_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'dart:typed_data';

Future<void> downloadPdfReport(
  WidgetRef ref,
  TextEditingController searchController,
  DateTime? startDate,
  DateTime? endDate,
) async {
  final transactions = ref.read(transactionProvider);
  final searchLower = searchController.text.toLowerCase();

  final filteredTransactions = transactions.where((transaction) {
    final matchesQuery = (transaction.supplierName
                ?.toLowerCase()
                .contains(searchLower) ??
            false) ||
        (transaction.userName?.toLowerCase().contains(searchLower) ?? false);

    final transactionDate = transaction.transactionDate;
    if (transactionDate == null) return false;

    // Strict date range filtering
    if (startDate != null && endDate != null) {
      // Normalize dates to compare only the year, month, and day
      final normalizedStartDate =
          DateTime(startDate.year, startDate.month, startDate.day);
      final normalizedEndDate =
          DateTime(endDate.year, endDate.month, endDate.day);
      final normalizedTransactionDate = DateTime(
          transactionDate.year, transactionDate.month, transactionDate.day);

      // Check if the transaction date is within the selected range (inclusive)
      final isAfterStart = normalizedTransactionDate
          .isAfter(normalizedStartDate.subtract(Duration(days: 1)));
      final isBeforeEnd = normalizedTransactionDate
          .isBefore(normalizedEndDate.add(Duration(days: 1)));

      return matchesQuery && isAfterStart && isBeforeEnd;
    } else {
      // If no date range is selected, include all transactions that match the query
      return matchesQuery;
    }
  }).toList();

  

  final totalPrice =
      filteredTransactions.fold(0.0, (sum, item) => sum + item.price);
  final totalWeight =
      filteredTransactions.fold(0.0, (sum, item) => sum + item.weight);
  final totalBags =
      filteredTransactions.fold(0.0, (sum, item) => sum + (item.weight / 85));
  final averageRate =
      totalWeight > 0 ? (totalPrice / totalWeight) * 1000 : 0.0; // Per tonne

  final pdf = pw.Document();

  const int rowsPerPage = 20;
  final totalPages = (filteredTransactions.length / rowsPerPage).ceil();

  for (int page = 0; page < totalPages; page++) {
    final start = page * rowsPerPage;
    final end = start + rowsPerPage;
    final transactionsOnPage = filteredTransactions.sublist(
      start,
      end > filteredTransactions.length ? filteredTransactions.length : end,
    );

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                'Purchases Report',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.deepPurple,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Date Range: ${startDate != null && endDate != null ? '${DateFormat('yyyy-MM-dd').format(startDate)} - ${DateFormat('yyyy-MM-dd').format(endDate)}' : 'All Dates'}',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.deepPurple, thickness: 1),
              pw.SizedBox(height: 8),

              // Transactions Table
              // ignore: deprecated_member_use
              pw.Table.fromTextArray(
                headers: [
                  'S/N',
                  'Date',
                  'Supplier',
                  'Sales Rep',
                  'Time',
                  'Rate(tonne)',
                  'Weight (kg)',
                  'Amount',
                  'Bag',
                  'Remark',
                ],
                data: transactionsOnPage.asMap().entries.map((entry) {
                  final index = entry.key + 1 + start;
                  final transaction = entry.value;
                  return [
                    index.toString(),
                    DateFormat('dd-MM-yyyy')
                        .format(transaction.transactionDate!),
                    transaction.supplierName ?? '',
                    transaction.userName ?? '',
                    DateFormat('hh:mm a').format(transaction.transactionDate!),
                    NumberFormat('#,##0.00').format(transaction.rate),
                    NumberFormat('#,##0.00').format(transaction.weight),
                    NumberFormat('#,##0.00').format(transaction.price),
                    (transaction.weight / 85).toStringAsFixed(2),
                    '', // Placeholder for Remark
                  ];
                }).toList(),
                cellStyle: pw.TextStyle(fontSize: 10),
                headerStyle: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(color: PdfColors.deepPurple),
                cellAlignments: {
                  5: pw.Alignment.centerRight, // Rate
                  6: pw.Alignment.centerRight, // Weight
                  7: pw.Alignment.centerRight, // Amount
                  8: pw.Alignment.centerRight, // Bag
                },
              ),

              // Summary Section on Last Page
              if (page == totalPages - 1) ...[
                pw.SizedBox(height: 16),
                pw.Divider(color: PdfColors.deepPurple, thickness: 1),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Summary',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.deepPurple,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Total Weight: ${NumberFormat('#,##0.00').format(totalWeight)} kg',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  'Total Amount: ${NumberFormat('#,##0.00').format(totalPrice)}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  'Total No of Bags: ${NumberFormat('#,##0.00').format(totalBags)}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  'Average Rate (tonne): ${NumberFormat('#,##0.00').format(averageRate)}',
                  style: pw.TextStyle(fontSize: 12),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

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
    // Request storage permissions for Android 13+
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          debugPrint('Storage permission denied. Status: ${status}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Storage permission not granted')),
          );
          return;
        }
      }

      // Handle Android 13+ permission for manage external storage
      if (await Permission.manageExternalStorage.isDenied) {
        final managePermission =
            await Permission.manageExternalStorage.request();
        if (!managePermission.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please allow manage storage in settings')),
          );
          return;
        }
      }
    }

    // Fetch and filter transactions
    final transactions = ref.read(transactionProvider);
    final searchLower = searchController.text.toLowerCase();

    final filteredTransactions = transactions.where((transaction) {
      final matchesQuery = (transaction.supplierName
                  ?.toLowerCase()
                  .contains(searchLower) ??
              false) ||
          (transaction.userName?.toLowerCase().contains(searchLower) ?? false);

      final transactionDate = transaction.transactionDate;
      if (transactionDate == null) return false;

      // Strict date range filtering
      if (startDate != null && endDate != null) {
        // Normalize dates to compare only the year, month, and day
        final normalizedStartDate =
            DateTime(startDate.year, startDate.month, startDate.day);
        final normalizedEndDate =
            DateTime(endDate.year, endDate.month, endDate.day);
        final normalizedTransactionDate = DateTime(
            transactionDate.year, transactionDate.month, transactionDate.day);

        // Check if the transaction date is within the selected range (inclusive)
        final isAfterStart = normalizedTransactionDate
            .isAfter(normalizedStartDate.subtract(Duration(days: 1)));
        final isBeforeEnd = normalizedTransactionDate
            .isBefore(normalizedEndDate.add(Duration(days: 1)));

        return matchesQuery && isAfterStart && isBeforeEnd;
      } else {
        // If no date range is selected, include all transactions that match the query
        return matchesQuery;
      }
    }).toList();

  
    // Calculate totals
    final totalPrice =
        filteredTransactions.fold(0.0, (sum, item) => sum + item.price);
    final totalWeight =
        filteredTransactions.fold(0.0, (sum, item) => sum + item.weight);
    final totalBags =
        filteredTransactions.fold(0.0, (sum, item) => sum + (item.weight / 85));
    final averageRate =
        totalWeight > 0 ? (totalPrice / totalWeight) * 1000 : 0.0; // Per tonne

    // Prepare CSV rows
    List<List<dynamic>> rows = [
      [
        'S/N',
        'Date',
        'Supplier',
        'Sales Rep',
        'Time',
        'Rate',
        'Weight',
        'Amount',
        'Bag',
        'Remark',
      ],
      ...filteredTransactions.asMap().entries.map((entry) {
        final index = entry.key + 1; // Serial number
        final transaction = entry.value;
        return [
          index.toString(),
          DateFormat('dd-MM-yyyy').format(transaction.transactionDate!),
          transaction.supplierName ?? '',
          transaction.userName ?? '',
          DateFormat('hh:mm a').format(transaction.transactionDate!),
          transaction.rate.toStringAsFixed(2),
          transaction.weight.toStringAsFixed(2),
          NumberFormat('#,##0.00').format(transaction.price),
          (transaction.weight / 85).toStringAsFixed(2), // Bag calculation
          '', // Placeholder for Remark
        ];
      }).toList(),
      // Totals row
      [
        '',
        '',
        '',
        '',
        '',
        'Avg Rate: ${NumberFormat('#,##0.00').format(averageRate)}',
        'Total Weight: ${NumberFormat('#,##0.00').format(totalWeight)} kg',
        'Total Amount: ${NumberFormat('#,##0.00').format(totalPrice)}',
        'Total Bags: ${NumberFormat('#,##0.00').format(totalBags)}',
        '',
      ],
    ];

    // Convert rows to CSV
    String csvData = const ListToCsvConverter().convert(rows);

    // Save CSV using file picker
    final params = SaveFileDialogParams(
      fileName: 'purchases_report.csv',
      mimeTypesFilter: ['text/csv'],
      data: Uint8List.fromList(csvData.codeUnits),
    );

    final path = await FlutterFileDialog.saveFile(params: params);

    if (path == null) {
      debugPrint('No path selected');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('CSV report saved to $path')),
    );
  } catch (e, stackTrace) {
    debugPrint('Error: $e');
    debugPrint('StackTrace: $stackTrace');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error generating report: $e')),
    );
  }
}
