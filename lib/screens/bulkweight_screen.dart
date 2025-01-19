import 'package:agriproduce/data_models/bulkweight_model.dart';
import 'package:agriproduce/state_management/bulkweight_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BulkWeightScreen extends ConsumerStatefulWidget {
  const BulkWeightScreen({
    Key? key,
  }) : super(key: key);

  @override
  _BulkWeightScreenState createState() => _BulkWeightScreenState();
}

class _BulkWeightScreenState extends ConsumerState<BulkWeightScreen> {
  final TextEditingController _bagsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final List<Map<String, dynamic>> _currentEntries = [];
  int _totalBags = 0;
  double _totalWeight = 0.0;

  @override
  void dispose() {
    _bagsController.dispose();
    _weightController.dispose();
    // Clear the state when the screen is disposed
    _clearState();
    super.dispose();
  }

  void _clearState() {
    setState(() {
      _currentEntries.clear();
      _totalBags = 0;
      _totalWeight = 0.0;
    });
  }

  // Add a new entry to the current transaction
  void _addEntry() {
    final bags = int.tryParse(_bagsController.text);
    final weight = double.tryParse(_weightController.text);

    if (bags != null && weight != null) {
      setState(() {
        _currentEntries.add({
          'bags': bags,
          'weight': weight,
          'timestamp': DateTime.now(),
        });
        _totalBags += bags;
        _totalWeight += weight;
      });
      _bagsController.clear();
      _weightController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter valid numbers for bags and weight.'),
        ),
      );
    }
  }

  // Save the current transaction and display cumulative values
  Future<void> _saveTransaction() async {
    if (_currentEntries.isNotEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Confirm Transaction'),
          content: Text('Are you sure you want to save this transaction?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('No'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        final bulkWeights = ref.read(bulkWeightNotifierProvider);

        // Cumulative values based on existing data
        int cumulativeBags =
            bulkWeights.fold<int>(0, (sum, weight) => sum + weight.bags) +
                _totalBags;
        double cumulativeWeight = bulkWeights.fold<double>(
                0.0, (sum, weight) => sum + weight.weight) +
            _totalWeight;

        try {
          final notifier = ref.read(bulkWeightNotifierProvider.notifier);

          // Create a list of BulkWeight objects
          final bulkWeightsList = _currentEntries.map((entry) {
            return BulkWeight(
              id: 0, // Assuming 0 for new entries, replace with actual logic if needed
              bags: entry['bags'],
              weight: entry['weight'],
              cumulativeBags: cumulativeBags,
              cumulativeWeight: cumulativeWeight,
              transactionId:
                  'transactionId', // Replace with actual transactionId
              adminEmail:
                  'admin@example.com', // Replace with actual admin email
              createdAt: entry['timestamp'], // Use timestamp as createdAt
            );
          }).toList();

          // Save all entries as a single transaction
          await notifier.createBulkWeight(ref, bulkWeightsList);

          setState(() {
            _currentEntries.clear();
            _totalBags = 0;
            _totalWeight = 0.0;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Transaction saved successfully.')),
          );

          // Navigate back to the previous screen
          Navigator.of(context).pop();
        } catch (error) {
          // Detailed debugging message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving transaction: $error')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No entries to save.')),
      );
    }
  }

  // Edit an entry
  void _editEntry(int index) {
    final entry = _currentEntries[index];
    _bagsController.text = entry['bags'].toString();
    _weightController.text = entry['weight'].toString();
    setState(() {
      _totalBags -= entry['bags'] as int; // Cast to int
      _totalWeight -= entry['weight'] as double; // Cast to double
      _currentEntries.removeAt(index);
    });
  }

  // Delete an entry
  void _deleteEntry(int index) {
    setState(() {
      final entry = _currentEntries.removeAt(index);
      _totalBags -= entry['bags'] as int; // Cast to int
      _totalWeight -= entry['weight'] as double; // Cast to double
    });
  }

  // Format timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('dd/MM/yyyy hh:mm a').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bulk Weight'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveTransaction,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display cumulative values (bags and weight)
              if (_totalBags > 0 || _totalWeight > 0.0)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Cumulative: $_totalBags Bags, $_totalWeight kg',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              Divider(),

              // Input fields for new entries
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _bagsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Bags'),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Weight'),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: _addEntry,
                    ),
                  ],
                ),
              ),

              // Display current entries
              if (_currentEntries.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _currentEntries.map((entry) {
                      return ListTile(
                        title: Text(
                          'Bags: ${entry['bags']}, Weight: ${entry['weight']} kg',
                        ),
                        subtitle: Text(
                          'Timestamp: ${_formatTimestamp(entry['timestamp'])}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () =>
                                  _editEntry(_currentEntries.indexOf(entry)),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteEntry(_currentEntries.indexOf(entry)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              SizedBox(height: 64), // Add some space at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
