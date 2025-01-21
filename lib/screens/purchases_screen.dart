import 'package:agriproduce/screens/receipt_screen.dart';
import 'package:agriproduce/state_management/transaction_provider.dart';
import 'package:agriproduce/widgets/custom_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/constant/download_report.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class PurchasesScreen extends ConsumerStatefulWidget {
  final bool isAdmin;

  const PurchasesScreen({super.key, required this.isAdmin});

  @override
  _PurchasesScreenState createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends ConsumerState<PurchasesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? errorMessage;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchTransactions() async {
    try {
      await ref.read(transactionProvider.notifier).fetchTransactions(ref);
      setState(() {
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: startDate ?? DateTime.now(),
        end: endDate ?? DateTime.now(),
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  void _clearDateRange() {
    setState(() {
      startDate = null;
      endDate = null;
    });
  }

  Future<void> _deleteTransaction(
      BuildContext context, String transactionId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Are you sure you want to delete this transaction?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await ref
            .read(transactionProvider.notifier)
            .deleteTransaction(ref, transactionId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete transaction: $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final searchQuery = _searchController.text;

    final filteredTransactions = transactions.where((transaction) {
      final searchLower = searchQuery.toLowerCase();
      final matchesQuery = (transaction.supplierName
                  ?.toLowerCase()
                  .contains(searchLower) ??
              false) ||
          (transaction.commodityName?.toLowerCase().contains(searchLower) ??
              false) ||
          (transaction.userName?.toLowerCase().contains(searchLower) ?? false);

      final matchesDate = (startDate == null || endDate == null)
          ? true
          : transaction.transactionDate != null &&
              transaction.transactionDate!
                  .isAfter(startDate!.subtract(const Duration(days: 1))) &&
              transaction.transactionDate!
                  .isBefore(endDate!.add(const Duration(days: 1)));

      return matchesQuery && matchesDate;
    }).toList();

    double totalPrice =
        filteredTransactions.fold(0, (sum, item) => sum + item.price);

    // Calculate the total weight
    double totalWeight =
        filteredTransactions.fold(0.0, (sum, item) => sum + item.weight);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return true;
      },
      child: Scaffold(
        body: errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                          'Error: Failed to load transaction, No internet connection, ensure you are connected',
                          style: const TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: fetchTransactions,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => downloadPdfReport(
                                  ref, _searchController, startDate, endDate),
                              child: const Text('Download PDF Report'),
                            ),
                            TextButton(
                              onPressed: () => downloadCsvReport(context, ref,
                                  _searchController, startDate, endDate),
                              child: const Text('Download CSV Report'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        CustomSearchBar(
                          controller: _searchController,
                          hintText: 'Search by Supplier, Commodity, or User',
                          onChanged: (value) {
                            setState(() {});
                          },
                          onClear: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 2),
                        GestureDetector(
                          onTap: () => _selectDateRange(context),
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  startDate == null && endDate == null
                                      ? 'Filter by Date Range'
                                      : 'Selected Dates: ${DateFormat('yyyy-MM-dd').format(startDate!)} - ${DateFormat('yyyy-MM-dd').format(endDate!)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Row(
                                  children: [
                                    if (startDate != null && endDate != null)
                                      IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: _clearDateRange,
                                      ),
                                    const Icon(
                                      Icons.calendar_today,
                                      color: Colors.deepPurple,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        filteredTransactions.isEmpty
                            ? Center(
                                child: Text(
                                  'No purchases yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : Expanded(
                                child: RefreshIndicator(
                                  onRefresh:
                                      fetchTransactions, // Trigger refresh
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    itemCount: filteredTransactions.length,
                                    itemBuilder: (context, index) {
                                      final transaction =
                                          filteredTransactions[index];
                                      return AnimationConfiguration
                                          .staggeredList(
                                        position: index,
                                        child: SlideAnimation(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ReceiptScreen(
                                                          transaction:
                                                              transaction),
                                                ),
                                              );
                                            },
                                            child: Card(
                                              margin: const EdgeInsets.only(
                                                  bottom: 16.0),
                                              elevation: 0.1,
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                                side: BorderSide(
                                                    color: Colors.grey
                                                        .withOpacity(0.2)),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Supplier: ${transaction.supplierName}',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .deepPurple,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 4),
                                                            Text(
                                                              'Commodity: ${transaction.commodityName}',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 4),
                                                            Text(
                                                              'User: ${transaction.userName}',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        if (widget.isAdmin)
                                                          PopupMenuButton<
                                                              String>(
                                                            onSelected:
                                                                (value) {
                                                              if (value ==
                                                                  'delete') {
                                                                _deleteTransaction(
                                                                    context,
                                                                    transaction
                                                                        .id!);
                                                              }
                                                            },
                                                            itemBuilder:
                                                                (context) => [
                                                              const PopupMenuItem(
                                                                value: 'delete',
                                                                child: Text(
                                                                    'Delete'),
                                                              ),
                                                            ],
                                                          ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'Date: ${DateFormat('yyyy-MM-dd').format(transaction.transactionDate!)}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'Time: ${DateFormat('hh:mm a').format(transaction.transactionDate!)}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Rate: ${NumberFormat('#,##0.00').format(transaction.rate)}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Weight: ${NumberFormat('#,##0.00').format(transaction.weight)}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Amount: ${NumberFormat('#,##0.00').format(transaction.price)}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                        const Divider(
                            height: 10, thickness: 0.05, color: Colors.grey),
                        Column(
                          children: [
                            // ... other widgets
                            const Divider(
                                height: 10,
                                thickness: 0.05,
                                color: Colors.white),
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .start, // Aligns both texts to the left
                              children: [
                                Text(
                                  'Amount: ${NumberFormat('#,##0.00').format(totalPrice)}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                    width:
                                        8), // Add some small space between the texts
                                Text(
                                  '( ${NumberFormat('#,##0.00').format(totalWeight)} kg)',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),

                            Text(
                              'Transactions: ${filteredTransactions.length}',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 130,
                    right: 100,
                    child: FloatingActionButton(
                      onPressed: _scrollToBottom,
                      child: const Icon(Icons.arrow_downward),
                      mini: true,
                      backgroundColor: Colors.deepPurple.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
