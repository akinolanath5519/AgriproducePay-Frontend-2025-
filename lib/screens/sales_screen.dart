import 'package:agriproduce/screens/sales_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/state_management/bulkweight_provider.dart';
import 'package:agriproduce/data_models/bulkweight_model.dart';
import 'package:intl/intl.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch bulk weights when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bulkWeightNotifierProvider.notifier).fetchBulkWeights(ref);
    });
  }

  Future<void> _refreshData() async {
    await ref.read(bulkWeightNotifierProvider.notifier).fetchBulkWeights(ref);
  }

  void _showOptionsDialog(BuildContext context, String transactionId,
      List<BulkWeight> transactionWeights) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Options'),
          content: Text('Choose an action for this transaction.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTransaction(context, transactionId);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTransaction(
      BuildContext context, String transactionId) async {
    try {
      await ref
          .read(bulkWeightNotifierProvider.notifier)
          .deleteTransaction(ref, transactionId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction deleted successfully.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting transaction: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bulkWeights = ref.watch(bulkWeightNotifierProvider);

    // Group bulk weights by transaction ID
    final Map<String, List<BulkWeight>> groupedBulkWeights = {};
    for (var bulkWeight in bulkWeights) {
      if (!groupedBulkWeights.containsKey(bulkWeight.transactionId)) {
        groupedBulkWeights[bulkWeight.transactionId] = [];
      }
      groupedBulkWeights[bulkWeight.transactionId]!.add(bulkWeight);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Screen'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: bulkWeights.isEmpty
            ? Center(child: Text('No bulk weights found.'))
            : ListView.builder(
                itemCount: groupedBulkWeights.keys.length,
                itemBuilder: (context, index) {
                  final transactionId =
                      groupedBulkWeights.keys.elementAt(index);
                  final transactionWeights = groupedBulkWeights[transactionId]!;

                  // Get the last entry to display cumulative values
                  final lastEntry = transactionWeights.last;

                  // Format the date and time
                  final formattedDate = DateFormat('yyyy-MM-dd – hh:mm a')
                      .format(lastEntry.createdAt);

                  return GestureDetector(
                      onLongPress: () {
                        _showOptionsDialog(
                            context, transactionId, transactionWeights);
                      },
                      onDoubleTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SalesDetailsScreen(
                              transactionId: transactionId,
                            ),
                          ),
                        ).then((_) {
                          // Refresh the data after returning from the SalesDetailsScreen
                          ref
                              .read(bulkWeightNotifierProvider.notifier)
                              .fetchBulkWeights(ref);
                        });
                      },
                      child: Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12), // Slightly more rounded corners
                        ),
                        elevation:
                            4, // Increased elevation for better shadow effect
                        shadowColor: Colors.black
                            .withOpacity(0.2), // Softer shadow color
                        child: Padding(
                          padding: const EdgeInsets.all(
                              16), // Added padding inside the card
                          child: ListTile(
                            contentPadding: EdgeInsets
                                .zero, // Removes the default padding from ListTile
                            title: Text(
                              '${index + 1}: Date: $formattedDate',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors
                                    .deepPurple, // Highlight the title in a distinct color
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    height:
                                        8), // Increased spacing for better readability
                                Text(
                                  'Cumulative Bags: ${NumberFormat('#,##0').format(lastEntry.cumulativeBags)}',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight
                                        .w600, // Slightly bolder for emphasis
                                    fontSize:
                                        15, // Increased font size for better readability
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        4), // Increased spacing between the two values
                                Text(
                                  'Cumulative Weight: ${NumberFormat('#,##0.00').format(lastEntry.cumulativeWeight)} kg',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ));
                },
              ),
      ),
    );
  }
}
