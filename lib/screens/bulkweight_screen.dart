import 'package:agriproduce/data_models/bulkweight_model.dart';
import 'package:agriproduce/state_management/bulkweight_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';



class BulkWeightScreen extends ConsumerStatefulWidget {
  const BulkWeightScreen({Key? key}) : super(key: key);

  @override
  _BulkWeightScreenState createState() => _BulkWeightScreenState();
}

class _BulkWeightScreenState extends ConsumerState<BulkWeightScreen> {
  final TextEditingController _bagsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final List<Map<String, dynamic>> _currentEntries = [];
  double _totalBags = 0.0;
  double _totalWeight = 0.0;
  int? _editingIndex;
  bool isSaving = false;

  @override
  void dispose() {
    _bagsController.dispose();
    _weightController.dispose();
    _clearState();
    super.dispose();
  }

  void _clearState() {
    setState(() {
      _currentEntries.clear();
      _totalBags = 0.0;
      _totalWeight = 0.0;
      _editingIndex = null;
    });
  }

  void _addEntry() {
    final bags = double.tryParse(_bagsController.text);
    final weight = double.tryParse(_weightController.text);

    if (bags != null && weight != null && bags > 0 && weight > 0) {
      setState(() {
        if (_editingIndex != null) {
          _totalBags -= _currentEntries[_editingIndex!]['bags'] as double;
          _totalWeight -= _currentEntries[_editingIndex!]['weight'] as double;

          _currentEntries[_editingIndex!] = {
            'bags': bags,
            'weight': weight,
            'timestamp': DateTime.now(),
            'index': _currentEntries[_editingIndex!]['index'],
          };

          _totalBags += bags;
          _totalWeight += weight;
          _editingIndex = null;
        } else {
          _currentEntries.add({
            'bags': bags,
            'weight': weight,
            'timestamp': DateTime.now(),
            'index': _currentEntries.length + 1,
          });
          _totalBags += bags;
          _totalWeight += weight;
        }
      });
      _bagsController.text = bags.toString();
      _weightController.clear();
    } else {
      _showErrorSnackbar('Please enter valid numbers greater than zero for bags and weight.');
    }
  }

  Future<void> _saveTransaction() async {
    if (_currentEntries.isNotEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            'Confirm Transaction',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to save this transaction?',
            style: GoogleFonts.roboto(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                'Yes',
                style: GoogleFonts.roboto(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'No',
                style: GoogleFonts.roboto(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

      if (confirm == true) {
        setState(() {
          isSaving = true;
        });

        final bulkWeights = ref.read(bulkWeightNotifierProvider);

        double cumulativeBags =
            bulkWeights.fold<double>(0.0, (sum, weight) => sum + weight.bags) +
                _totalBags;
        double cumulativeWeight = bulkWeights.fold<double>(
                0.0, (sum, weight) => sum + weight.weight) +
            _totalWeight;

        try {
          final notifier = ref.read(bulkWeightNotifierProvider.notifier);
          final transactionId = Uuid().v4();

          final bulkWeightsList = _currentEntries.map((entry) {
            return BulkWeight(
              id: null,
              bags: entry['bags'],
              weight: entry['weight'],
              cumulativeBags: cumulativeBags.toInt(),
              cumulativeWeight: cumulativeWeight,
              transactionId: transactionId,
              adminEmail: null,
              createdAt: entry['timestamp'],
            );
          }).toList();

          await notifier.createBulkWeight(ref, bulkWeightsList);

          setState(() {
            _currentEntries.clear();
            _totalBags = 0.0;
            _totalWeight = 0.0;
            isSaving = false;
          });

          _showSuccessSnackbar('Transaction saved successfully.');
          Navigator.of(context).pop();
        } catch (error) {
          setState(() {
            isSaving = false;
          });
          _showErrorSnackbar('Error saving transaction: $error');
        }
      }
    } else {
      _showErrorSnackbar('No entries to save.');
    }
  }

  void _editEntry(int index) {
    final entry = _currentEntries[index];
    _bagsController.text = entry['bags'].toString();
    _weightController.text = entry['weight'].toString();
    setState(() {
      _editingIndex = index;
    });
  }

  void _deleteEntry(int index) {
    setState(() {
      final entry = _currentEntries.removeAt(index);
      _totalBags -= entry['bags'] as double;
      _totalWeight -= entry['weight'] as double;
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('dd/MM/yyyy hh:mm a').format(timestamp);
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.roboto(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.roboto(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bulk Weight',
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: _saveTransaction,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_totalBags > 0 || _totalWeight > 0.0)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Cumulative: ${NumberFormat('#,##0').format(_totalBags.toInt())} Bags, ${NumberFormat('#,##0.0000').format(_totalWeight)} kg',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  Divider(color: Colors.deepPurple.withOpacity(0.2)),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _bagsController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Bags',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _weightController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Weight',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.deepPurple),
                          onPressed: _addEntry,
                        ),
                      ],
                    ),
                  ),

                  if (_currentEntries.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _currentEntries.map((entry) {
                          final index = _currentEntries.indexOf(entry);
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              title: Text(
                                'Weigh ${entry['index']}: Bags: ${entry['bags']}, Weight: ${entry['weight']} kg',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                'Time: ${_formatTimestamp(entry['timestamp'])}',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        color: Colors.deepPurple),
                                    onPressed: () => _editEntry(index),
                                    splashColor:
                                        Colors.deepPurple.withOpacity(0.2),
                                    padding: EdgeInsets.zero,
                                  ),
                                  SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteEntry(index),
                                    splashColor: Colors.red.withOpacity(0.2),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  SizedBox(height: 64),
                ],
              ),
            ),
          ),
          if (isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.deepPurple,
                ),
              ),
            ),
        ],
      ),
    );
  }
}