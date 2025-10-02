import 'package:agriproduce/state_management/companyInfo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:agriproduce/data_models/transaction_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ReceiptScreen extends ConsumerStatefulWidget {
  final Transaction transaction;

  const ReceiptScreen({super.key, required this.transaction});

  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCompanyInfo();
  }

  Future<void> _fetchCompanyInfo() async {
    try {
      final companyInfos = ref.read(companyInfoNotifierProvider);
      if (companyInfos.isEmpty) {
        await ref
            .read(companyInfoNotifierProvider.notifier)
            .fetchCompanyInfos(ref);
      }
    } catch (error) {
      print("Error fetching company information: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveReceiptAsPDF(BuildContext context, companyInfo) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Receipt Title Section
                pw.Row(
                  children: [
                    pw.Text(
                      'Receipt',
                      style: pw.TextStyle(
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.deepPurple,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),

                // Company Information Section
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(8),
                    border:
                        pw.Border.all(color: PdfColors.deepPurple, width: 0.4),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Company Information',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Divider(thickness: 0.4, color: PdfColors.deepPurple),
                      pw.SizedBox(height: 6),
                      _buildCompanyInfoRowForPDF('Name:', companyInfo.name),
                      _buildCompanyInfoRowForPDF(
                          'Address:', companyInfo.address),
                      _buildCompanyInfoRowForPDF('Phone:', companyInfo.phone),
                      _buildCompanyInfoRowForPDF('Email:', companyInfo.email),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                // Transaction Details Section
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(8),
                    border:
                        pw.Border.all(color: PdfColors.deepPurple, width: 0.4),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Transaction Details',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Divider(thickness: 0.4, color: PdfColors.deepPurple),
                      _buildTransactionDetailRow(
                          'Receipt ID:', widget.transaction.id ?? 'N/A'),
                      _buildTransactionDetailRow(
                          'Supplier:', widget.transaction.supplierName!),
                      _buildTransactionDetailRow(
                          'Commodity:', widget.transaction.commodityName!),
                      _buildTransactionDetailRow(
                        'Weight:',
                        '${NumberFormat('#,##0.00').format(widget.transaction.weight)} kg',
                      ),
                      _buildTransactionDetailRow(
                        'Amount:',
                        '${NumberFormat('#,##0.00').format(widget.transaction.price)}',
                      ),
                      _buildTransactionDetailRow(
                        'Date:',
                        DateFormat('dd-MM-yyyy')
                            .format(widget.transaction.transactionDate!),
                      ),
                      _buildTransactionDetailRow(
                        'Time:',
                        DateFormat('hh:mm:ss a')
                            .format(widget.transaction.transactionDate!),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                // Footer: Thank You Note
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Thank you for doing business with us!',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontStyle: pw.FontStyle.italic,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Designed by Mattwolkins Global Enterprises (09073699985,08064523813)',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontStyle: pw.FontStyle.normal,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
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

  // Helper method to build transaction details rows
  pw.Widget _buildTransactionDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '$label ',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build company info row for PDF
  pw.Widget _buildCompanyInfoRowForPDF(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '$label ',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _shareReceipt(BuildContext context, dynamic companyInfo) async {
    try {
      // Create the PDF document
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header with company logo or title
                pw.Container(
                  padding: pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blueGrey, // Professional blue-gray header
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
                  ),
                  child: pw.Row(
                    children: [
                      // Optionally add a company logo here

                      pw.SizedBox(width: 10),
                      pw.Text(
                        'Receipt',
                        style: pw.TextStyle(
                          fontSize: 30,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Company Info Section
                pw.Text(
                  'Company: ${companyInfo.name}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Address: ${companyInfo.address}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  'Phone: ${companyInfo.phone}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  'Email: ${companyInfo.email}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 20),

                // Transaction Details Section with Table
                pw.Text(
                  'Transaction Details',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  border: pw.TableBorder.all(color: PdfColors.grey),
                  cellAlignment: pw.Alignment.centerLeft,
                  headers: [
                    'Receipt ID',
                    'Supplier',
                    'Weight (kg)',
                    'Amount',
                    'Date',
                  ],
                  data: [
                    [
                      widget.transaction.id ?? 'N/A',
                      widget.transaction.supplierName,
                      widget.transaction.weight,
                      widget.transaction.commodityName,
                      widget.transaction.price.toStringAsFixed(2),
                      DateFormat('yyyy-MM-dd')
                          .format(widget.transaction.transactionDate!),
                    ],
                  ],
                  headerStyle: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: pw.BoxDecoration(
                    color: PdfColors.blueGrey,
                  ),
                  cellStyle: pw.TextStyle(fontSize: 12),
                ),

                pw.SizedBox(height: 20),

                // Footer Section
                pw.Divider(color: PdfColors.grey),
                pw.SizedBox(height: 8),
                pw.Center(
                  child: pw.Text(
                    'Thank you for your business!',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Center(
                  child: pw.Text(
                    'Designed by Mattwolkins Global Enterprises (09073699985,08064523813)',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.yellow, // Set the color to yellow
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Save the PDF to a temporary directory
      final output = await getTemporaryDirectory(); // Get the temp directory
      final file =
          File("${output.path}/receipt.pdf"); // Define the PDF file path
      await file
          .writeAsBytes(await pdf.save()); // Write the PDF content to the file

      // Share the PDF file
      await Share.shareXFiles([XFile(file.path)],
          text: 'Receipt for ${widget.transaction.commodityName}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share receipt: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyInfos = ref.watch(companyInfoNotifierProvider);
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Receipt')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (companyInfos.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Receipt')),
        body: const Center(child: Text('No company info available.')),
      );
    }

    final companyInfo = companyInfos.first;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Receipt'),
          actions: [
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: () {
                _saveReceiptAsPDF(context, companyInfo);
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                _shareReceipt(context, companyInfo);
              },
            ),
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0), // Padding around the content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Receipt Title Section
                  Row(
                    children: const [
                      Icon(Icons.receipt_long,
                          size: 32, color: Colors.deepPurple),
                      SizedBox(width: 10),
                      Text(
                        'Receipt',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Company Information Section
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0.1,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Company Information',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const Divider(
                              thickness: 0.4, color: Colors.deepPurple),
                          const SizedBox(height: 6),
                          _buildCompanyInfoRow(
                              Icons.business, 'Name:', companyInfo.name),
                          _buildCompanyInfoRow(Icons.location_on, 'Address:',
                              companyInfo.address),
                          _buildCompanyInfoRow(
                              Icons.phone, 'Phone:', companyInfo.phone),
                          _buildCompanyInfoRow(
                              Icons.email, 'Email:', companyInfo.email),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Transaction Details Section
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0.1,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transaction Details',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const Divider(
                              thickness: 0.4, color: Colors.deepPurple),
                          _buildTransactionInfoRow(Icons.receipt, 'Receipt ID:',
                              widget.transaction.id ?? 'N/A'),
                          _buildTransactionInfoRow(Icons.person, 'Supplier:',
                              widget.transaction.supplierName!),
                          _buildTransactionInfoRow(Icons.person, 'Commodity:',
                              widget.transaction.commodityName!),
                          _buildTransactionInfoRow(
                            Icons.scale,
                            'Weight:',
                            '${NumberFormat('#,##0.00').format(widget.transaction.weight)} kg',
                          ),
                          _buildTransactionInfoRow(
                            Icons.attach_money,
                            'Amount:',
                            '${NumberFormat('#,##0.00').format(widget.transaction.price)}',
                          ),
                          _buildTransactionInfoRow(
                              Icons.date_range,
                              'Date:',
                              DateFormat('dd-MM-yyyy')
                                  .format(widget.transaction.transactionDate!)),
                          _buildTransactionInfoRow(
                              Icons.access_time,
                              'Time:',
                              DateFormat('hh:mm:ss a')
                                  .format(widget.transaction.transactionDate!)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Footer: Thank You Note
                  Center(
                    child: Text(
                      'Thank you for doing business with us!',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            )));
  }

  // Helper method to build company info row with icons
  // In the widget where transaction info is displayed
  Widget _buildTransactionInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Adjust vertical alignment for long text
        children: [
          Icon(icon, size: 22, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 5),
          Expanded(
            // Ensure the text takes up available space
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis, // Adds ellipsis for long text
              softWrap:
                  true, // Automatically wraps text when it exceeds available space
            ),
          ),
        ],
      ),
    );
  }

  // For company information, use a similar approach
  Widget _buildCompanyInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the top
        children: [
          Icon(icon, size: 22, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12, color: Colors.black),
                children: [
                  TextSpan(
                    text: '$label ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
              softWrap: true, // Ensures wrapping
            ),
          ),
        ],
      ),
    );
  }
}
