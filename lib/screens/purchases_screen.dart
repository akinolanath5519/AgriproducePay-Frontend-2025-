
import 'package:agriproduce/screens/receipt_screen.dart';
import 'package:agriproduce/state_management/transaction_provider.dart';
import 'package:agriproduce/theme/app_theme.dart';
import 'package:agriproduce/utilis/formatter.dart';
import 'package:agriproduce/widgets/custom_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/constant/download_report.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:agriproduce/data_models/transaction_model.dart';




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
  String? selectedCondition;
  TransactionType? selectedTransactionType;

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
        startDate = DateTime(picked.start.year, picked.start.month,
            picked.start.day); // Reset to start of the day
        endDate = DateTime(picked.end.year, picked.end.month, picked.end.day,
            23, 59, 59); // Set to end of the day
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
    BuildContext context,
    String transactionId,
  ) async {
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
        // Display a more user-friendly error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete transaction, check your internet connection',
            ),
          ),
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

  void _editTransaction(BuildContext context, Transaction transaction) {
    final TextEditingController weightController = TextEditingController(
        text: NumberFormat('#,##0.00').format(transaction.weight));
    final TextEditingController rateController = TextEditingController(
        text: NumberFormat('#,##0.00').format(transaction.rate));
    final TextEditingController commodityController =
        TextEditingController(text: transaction.commodityName ?? '');
    final TextEditingController supplierController =
        TextEditingController(text: transaction.supplierName ?? '');
    final TextEditingController dateController = TextEditingController(
        text: DateFormat('dd-MM-yyyy').format(transaction.transactionDate!));

    String selectedUnit = transaction.unit;

    final Map<String, double> unitWeights = {
      'Metric tonne': 1000.0,
      'Polythene': 1027.0,
      'Tare': 1014.0,
      'Jute': 1040.0,
    };

// Dynamically set unitWeight based on selectedUnit, with a default fallback to 'Polythene'
    double unitWeight = unitWeights[selectedUnit] ?? unitWeights['Polythene']!;

    double _calculateTotalPrice(double weight, double rate) {
      return (weight / unitWeight) * rate;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Transaction'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(labelText: 'Weight'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedUnit,
                  decoration: const InputDecoration(labelText: 'Unit'),
                  items: unitWeights.keys.map((String unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedUnit = newValue!;
                      unitWeight = unitWeights[selectedUnit]!;
                    });
                  },
                ),
                SizedBox(height: 6),
                TextField(
                  controller: rateController,
                  decoration: const InputDecoration(labelText: 'Rate'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 6),
                TextField(
                  controller: commodityController,
                  decoration:
                      const InputDecoration(labelText: 'Commodity Name'),
                ),
                SizedBox(height: 6),
                TextField(
                  controller: supplierController,
                  decoration: const InputDecoration(labelText: 'Supplier Name'),
                ),
                SizedBox(height: 6),
                TextField(
                  controller: dateController,
                  decoration:
                      const InputDecoration(labelText: 'Transaction Date'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: transaction.transactionDate!,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      dateController.text =
                          DateFormat('dd-MM-yyyy').format(pickedDate);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                double weight = NumberFormat('#,##0.00')
                    .parse(weightController.text)
                    .toDouble();
                double rate = NumberFormat('#,##0.00')
                    .parse(rateController.text)
                    .toDouble();
                double price = _calculateTotalPrice(weight, rate);

                // Preserve the original time component
                DateTime selectedDate =
                    DateFormat('dd-MM-yyyy').parse(dateController.text);
                DateTime updatedDate = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  transaction.transactionDate!.hour,
                  transaction.transactionDate!.minute,
                  transaction.transactionDate!.second,
                );

                final updatedTransaction = transaction.copyWith(
                  weight: weight,
                  unit: selectedUnit,
                  price: price,
                  rate: rate,
                  commodityName: commodityController.text,
                  supplierName: supplierController.text,
                  transactionDate:
                      updatedDate, // Use the updated date with original time
                );

                ref.read(transactionProvider.notifier).updateTransaction(
                    ref, transaction.id!, updatedTransaction);

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
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
              !transaction.transactionDate!.isBefore(startDate!) &&
              !transaction.transactionDate!.isAfter(endDate!
                  .add(const Duration(days: 1))
                  .subtract(const Duration(seconds: 1)));

      final matchesCondition = (selectedCondition == null || selectedCondition == 'All')
          ? true
          : transaction.commodityCondition?.toLowerCase() ==
              selectedCondition?.toLowerCase();

      final matchesTransactionType = (selectedTransactionType == null)
          ? true
          : transaction.transactionType == selectedTransactionType;

      return matchesQuery && matchesDate && matchesCondition && matchesTransactionType;
    }).toList();

    // Sort transactions by transactionDate in descending order
    filteredTransactions
        .sort((a, b) => b.transactionDate!.compareTo(a.transactionDate!));

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
                    Row(
                      mainAxisSize:
                          MainAxisSize.min, // Center the content horizontally
                      children: [
                        const Icon(Icons.wifi_off, color: Colors.red),
                        const SizedBox(
                            width:
                                6.0), // Add some spacing between icon and text
                        Flexible(
                          child: Text(
                            'Unable to load transaction. Please check your internet connection and try again.',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
                        
                        // Scrollable Transaction Type Filter Buttons
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              const SizedBox(width: 4),
                              _buildTransactionTypeButton('All', null),
                              const SizedBox(width: 8),
                              _buildTransactionTypeButton('Purchase', TransactionType.PURCHASE),
                              const SizedBox(width: 8),
                              _buildTransactionTypeButton('Sale', TransactionType.SALE),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () => _selectDateRange(context),
                                child: Container(
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(1.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        startDate == null && endDate == null
                                            ? 'Filter by Date Range'
                                            : 'Dates: ${DateFormat('dd-MM-yyyy').format(startDate!)} - ${DateFormat('dd-MM-yyyy').format(endDate!)}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Row(
                                        children: [
                                          if (startDate != null &&
                                              endDate != null)
                                            IconButton(
                                              icon: const Icon(Icons.clear),
                                              onPressed: _clearDateRange,
                                            ),
                                          const Icon(Icons.calendar_today,
                                              color: AppColors.orangeAccent),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                value: selectedCondition,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  border: OutlineInputBorder(),
                                ),
                                hint: const Text('Condition',
                                    style: TextStyle(fontSize: 12)),
                                items: ['All','Wet', 'Dry'].map((String condition) {
                                  return DropdownMenuItem<String>(
                                    value: condition,
                                    child: Text(condition),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedCondition = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        // Total Summary Cards - Placed below the condition dropdown
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // Total Amount Card
                            Expanded(
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Amount',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${NumberFormat('#,##0.00').format(totalPrice)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            
                            // Total Weight Card
                            Expanded(
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Weight',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${NumberFormat('#,##0.00').format(totalWeight)} kg',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            
                            // Total Transactions Card
                            Expanded(
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Transactions',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        filteredTransactions.length.toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        filteredTransactions.isEmpty
                            ? Center(
                                child: Text(
                                  'No transactions found',
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
                                                              '${transaction.transactionType == TransactionType.PURCHASE ? 'Supplier' : 'Customer'}: ${transaction.supplierName}',
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
                                                              'Sales Rep: ${transaction.userName}',
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
                                                              } else if (value ==
                                                                  'edit') {
                                                                _editTransaction(
                                                                    context,
                                                                    transaction);
                                                              }
                                                            },
                                                            itemBuilder:
                                                                (context) => [
                                                              const PopupMenuItem(
                                                                value: 'edit',
                                                                child: Text(
                                                                    'Edit'),
                                                              ),
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
                                                      'Type: ${transaction.transactionType == TransactionType.PURCHASE ? 'Purchase' : 'Sale'}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: transaction.transactionType == TransactionType.PURCHASE 
                                                            ? Colors.green 
                                                            : Colors.orange,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'Date: ${(transaction.transactionDate!.toDateFormatted())}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'Time: ${DateFormat('hh:mm a').format(transaction.transactionDate!.toLocal().add(Duration(hours: -transaction.transactionDate!.toLocal().timeZoneOffset.inHours)))}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Commodity: ${transaction.commodityName}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Commodity condition: ${transaction.commodityCondition}',
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
                                                      'Weight: ${NumberFormat('#,##0.00').format(transaction.weight)} kg',
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

  Widget _buildTransactionTypeButton(String label, TransactionType? type) {
    final isSelected = selectedTransactionType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTransactionType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}