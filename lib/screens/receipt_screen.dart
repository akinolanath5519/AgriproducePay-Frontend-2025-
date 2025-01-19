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
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 20),

                // Receipt Title
                pw.Text(
                  'Receipt',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.deepPurple,
                  ),
                ),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 10),

                // Company Information Section
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors
                        .grey100, // Light grey background for a soft look
                    border:
                        pw.Border.all(color: PdfColors.deepPurple, width: 1.5),
                    borderRadius: pw.BorderRadius.circular(
                        12), // Slightly rounder corners
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Company Information',
                        style: pw.TextStyle(
                          fontSize: 22, // Larger font size for prominence
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.deepPurple,
                          letterSpacing:
                              0.5, // Adding some letter spacing for clarity
                        ),
                      ),
                      pw.SizedBox(
                          height:
                              10), // Adding space between the title and content
                      _buildTransactionDetailRow(
                        'Company Name:',
                        companyInfo.name,
                        textStyle:
                            pw.TextStyle(fontSize: 14, color: PdfColors.black),
                      ),
                      _buildTransactionDetailRow(
                        'Address:',
                        companyInfo.address,
                        textStyle:
                            pw.TextStyle(fontSize: 14, color: PdfColors.black),
                      ),
                      _buildTransactionDetailRow(
                        'Phone:',
                        companyInfo.phone,
                        textStyle:
                            pw.TextStyle(fontSize: 14, color: PdfColors.black),
                      ),
                      _buildTransactionDetailRow(
                        'Email:',
                        companyInfo.email,
                        textStyle:
                            pw.TextStyle(fontSize: 14, color: PdfColors.black),
                      ),
                      pw.SizedBox(height: 15),
                      pw.Divider(color: PdfColors.deepPurple, thickness: 1.5),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Transaction Details Section
                pw.Container(
                  padding: const pw.EdgeInsets.all(
                      15), // Increased padding for better spacing
                  decoration: pw.BoxDecoration(
                    color: PdfColors
                        .grey200, // Light grey background for subtle contrast
                    border: pw.Border.all(
                        color: PdfColors.orangeAccent,
                        width: 1.5), // Thicker border for prominence
                    borderRadius: pw.BorderRadius.circular(
                        10), // More rounded corners for a modern look
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Transaction Details',
                        style: pw.TextStyle(
                          fontSize: 22, // Larger font for emphasis
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.orangeAccent,
                          letterSpacing:
                              0.8, // Improved spacing between letters for readability
                        ),
                      ),
                      pw.SizedBox(
                          height:
                              12), // Increased space between title and content
                      _buildTransactionDetailRow(
                        'Commodity:',
                        widget.transaction.commodityName,
                        textStyle:
                            pw.TextStyle(fontSize: 14, color: PdfColors.black),
                      ),
                      _buildTransactionDetailRow(
                        'Supplier:',
                        widget.transaction.supplierName,
                        textStyle:
                            pw.TextStyle(fontSize: 14, color: PdfColors.black),
                      ),
                      _buildTransactionDetailRow(
                        'Paid by:',
                        widget.transaction.userName ?? 'Unknown',
                        textStyle:
                            pw.TextStyle(fontSize: 14, color: PdfColors.black),
                      ),
                      _buildTransactionDetailRow(
                        'Weight:',
                        '${widget.transaction.weight} kg',
                        textStyle:
                            pw.TextStyle(fontSize: 14, color: PdfColors.black),
                      ),
                      _buildTransactionDetailRow(
                        'Price:',
                        '\$${widget.transaction.price.toStringAsFixed(2)}',
                        textStyle:
                            pw.TextStyle(fontSize: 14, color: PdfColors.black),
                      ),
                      _buildTransactionDetailRow(
                        'Date:',
                        DateFormat('yyyy-MM-dd')
                            .format(widget.transaction.transactionDate!),
                        textStyle:
                            pw.TextStyle(fontSize: 14, color: PdfColors.black),
                      ),
                      _buildTransactionDetailRow(
                        'Time:',
                        DateFormat('HH:mm:ss')
                            .format(widget.transaction.transactionDate!),
                        textStyle:
                            pw.TextStyle(fontSize: 14, color: PdfColors.black),
                      ),
                      pw.SizedBox(
                          height: 12), // Space after details for better layout
                      pw.Divider(
                          color: PdfColors.orangeAccent,
                          thickness: 1.5), // Divider with more prominence
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Footer Section: Thank You Note
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Divider(thickness: 1.5, color: PdfColors.grey),
                      pw.Text(
                        'Thank you for doing business with us!',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontStyle: pw.FontStyle.italic,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(8.0),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey200, // Light grey background
                          borderRadius:
                              pw.BorderRadius.all(pw.Radius.circular(5)),
                        ),
                        child: pw.Text(
                          'Created and developed by Mattwolkins Technologies\n'
                          'For inquiries, contact us at: 08064523813 or 09073699985',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.black,
                            fontWeight: pw.FontWeight.normal,
                            letterSpacing: 0.5,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      )
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
  pw.Widget _buildTransactionDetailRow(String label, String value,
      {pw.TextStyle? textStyle}) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '$label ',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 14,
            color: PdfColors.black,
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: textStyle ??
                pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.black,
                ),
          ),
        ),
      ],
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
                  padding: pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blueGrey, // Professional blue-gray header
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Text(
                    'Receipt',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.SizedBox(height: 16),

                // Company info
                pw.Text(
                  'Company Name: ${companyInfo.name}',
                  style: pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Address: ${companyInfo.address}',
                  style: pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Phone: ${companyInfo.phone}',
                  style: pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Email: ${companyInfo.email}',
                  style: pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 20),

                // Transaction details section
                pw.Text(
                  'Transaction Details:',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Commodity: ${widget.transaction.commodityName}',
                          style: pw.TextStyle(fontSize: 14)),
                      pw.Text('Supplier: ${widget.transaction.supplierName}',
                          style: pw.TextStyle(fontSize: 14)),
                      pw.Text('Weight: ${widget.transaction.weight} kg',
                          style: pw.TextStyle(fontSize: 14)),
                      pw.Text(
                          'Price: \$${widget.transaction.price.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 14)),
                      pw.Text(
                          'Date: ${DateFormat('yyyy-MM-dd').format(widget.transaction.transactionDate!)}',
                          style: pw.TextStyle(fontSize: 14)),
                    ],
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
                          fontSize: 24,
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
                            'Company Info',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
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
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Divider(
                              thickness: 0.4, color: Colors.deepPurple),
                          const SizedBox(height: 6),
                          _buildTransactionInfoRow(Icons.shopping_bag,
                              'Commodity:', widget.transaction.commodityName),
                          _buildTransactionInfoRow(Icons.person, 'Supplier:',
                              widget.transaction.supplierName),
                          _buildTransactionInfoRow(Icons.scale, 'Weight:',
                              '${widget.transaction.weight} kg'),
                          _buildTransactionInfoRow(Icons.attach_money, 'Price:',
                              '${widget.transaction.price.toStringAsFixed(2)}'),
                          _buildTransactionInfoRow(
                              Icons.date_range,
                              'Date:',
                              DateFormat('yyyy-MM-dd')
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
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 5),
          Expanded(
            // Ensure the text takes up available space
            child: Text(
              value,
              style: const TextStyle(fontSize: 18),
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
                style: const TextStyle(fontSize: 18, color: Colors.black),
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
