import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/state_management/bulkweight_provider.dart';
import 'package:agriproduce/data_models/bulkweight_model.dart';
import 'package:intl/intl.dart';

class SalesDetailsScreen extends ConsumerWidget {
  final String transactionId;

  const SalesDetailsScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bulkWeights = ref.watch(bulkWeightNotifierProvider);

    // Filter bulk weights by transaction ID
    final transactionWeights = bulkWeights
        .where((bulkWeight) => bulkWeight.transactionId == transactionId)
        .toList();

    Future<void> _deleteEntry(
        BuildContext context, BulkWeight bulkWeight) async {

      // Show loading indicator

      try {
        // Perform the delete operation
        await ref
            .read(bulkWeightNotifierProvider.notifier)
            .deleteBulkWeight(ref, bulkWeight.id.toString());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Entry deleted successfully.')),
        );
      } catch (error) {
        // Close the loading indicator
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting entry: $error')),
        );
      }
    }

    void _showDeleteDialog(BuildContext context, BulkWeight bulkWeight) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete this entry?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteEntry(context, bulkWeight);
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );
    }

    void _editEntry(BuildContext context, BulkWeight bulkWeight) {
      final bagsController =
          TextEditingController(text: bulkWeight.bags.toString());
      final weightController =
          TextEditingController(text: bulkWeight.weight.toString());
      bool isLoading = false;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Edit Entry'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: bagsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Number of Bags',
                        errorText: bagsController.text.isEmpty ||
                                (double.tryParse(bagsController.text) ?? 0) <= 0
                            ? 'Enter a valid number'
                            : null,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        errorText: weightController.text.isEmpty ||
                                (double.tryParse(weightController.text) ?? 0) <=
                                    0
                            ? 'Enter a valid weight'
                            : null,
                      ),
                    ),
                    if (isLoading)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            try {
                              final updatedBags =
                                  double.tryParse(bagsController.text);
                              final updatedWeight =
                                  double.tryParse(weightController.text);

                              if (updatedBags == null ||
                                  updatedWeight == null ||
                                  updatedBags <= 0 ||
                                  updatedWeight <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Invalid input values.')),
                                );
                                return;
                              }

                              setState(() {
                                isLoading = true;
                              });

                              final updatedBulkWeight = BulkWeight(
                                id: bulkWeight.id,
                                transactionId: bulkWeight.transactionId,
                                bags: updatedBags,
                                weight: updatedWeight,
                                cumulativeBags: bulkWeight.cumulativeBags,
                                cumulativeWeight: bulkWeight.cumulativeWeight,
                                adminEmail: bulkWeight.adminEmail,
                                createdAt: bulkWeight.createdAt,
                              );

                              await ref
                                  .read(bulkWeightNotifierProvider.notifier)
                                  .updateBulkWeight(
                                      ref,
                                      bulkWeight.id.toString(),
                                      updatedBulkWeight);

                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Entry updated successfully.')),
                              );
                            } catch (error) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Error updating entry: $error')),
                              );
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                    child: Text('Save'),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Details'),
      ),
      body: transactionWeights.isEmpty
          ? Center(child: Text('No details found for this transaction.'))
          : ListView.builder(
              itemCount: transactionWeights.length,
              itemBuilder: (context, index) {
                final bulkWeight = transactionWeights[index];

                // Adjust the date time here
                final DateTime localCreatedAt = bulkWeight.createdAt.toLocal();
                final int timeOffset = localCreatedAt.timeZoneOffset.inHours;
                final adjustedDate =
                    localCreatedAt.add(Duration(hours: -timeOffset));
                final formattedDate =
                    DateFormat('dd-MM-yyyy – hh:mm a').format(adjustedDate);

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0.1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: $formattedDate',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors
                                .deepPurple, // Highlight the title in a distinct color
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Weight #${index + 1}: ${bulkWeight.bags} bags',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Weight: ${NumberFormat('#,##0.00').format(bulkWeight.weight)} kg',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                _editEntry(context, bulkWeight);
                              },
                              icon: Icon(Icons.edit, color: Colors.deepPurple),
                              label: Text(
                                'Edit',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                _showDeleteDialog(context, bulkWeight);
                              },
                              icon: Icon(Icons.delete, color: Colors.red),
                              label: Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
