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
      try {
        await ref
            .read(bulkWeightNotifierProvider.notifier)
            .deleteBulkWeight(ref, bulkWeight.id.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Entry deleted successfully.')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting entry: $error')),
        );
      }
    }

    Future<void> _showDeleteDialog(
        BuildContext context, BulkWeight bulkWeight) async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete this entry?'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Delete'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteEntry(context, bulkWeight);
                },
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

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Edit Entry'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: bagsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Number of Bags'),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Weight (kg)'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    // Parse updated values
                    final updatedBags = int.parse(bagsController.text);
                    final updatedWeight = double.parse(weightController.text);

                    // Create an updated BulkWeight object
                    final updatedBulkWeight = BulkWeight(
                      id: bulkWeight.id,
                      transactionId: bulkWeight.transactionId,
                      bags: updatedBags,
                      weight: updatedWeight,
                      cumulativeBags:
                          bulkWeight.cumulativeBags, // Use existing value
                      cumulativeWeight:
                          bulkWeight.cumulativeWeight, // Use existing value
                      adminEmail: bulkWeight.adminEmail, // Use existing value
                      createdAt: bulkWeight.createdAt,
                    );

                    // Update the entry via the provider
                    await ref
                        .read(bulkWeightNotifierProvider.notifier)
                        .updateBulkWeight(
                            ref, bulkWeight.id.toString(), updatedBulkWeight);

                    // Close the dialog and refresh the list
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Entry updated successfully.')),
                    );
                  } catch (error) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating entry: $error')),
                    );
                  }
                },
                child: Text('Save'),
              ),
            ],
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

               

                return GestureDetector(
                  onLongPress: () {
                    // Show the edit and delete buttons on long press
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Options'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.edit,
                                  color: Colors.deepPurple,
                                ),
                                title: Text('Edit Entry'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _editEntry(context, bulkWeight);
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text('Delete Entry'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _showDeleteDialog(context, bulkWeight);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
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
                        SizedBox(height: 12),
                        Text(
                          'Date: ${DateFormat('yyyy-MM-dd – HH:mm').format(bulkWeight.createdAt)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
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
