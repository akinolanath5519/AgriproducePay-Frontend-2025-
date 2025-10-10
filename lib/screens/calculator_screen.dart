// ignore_for_file: deprecated_member_use

import 'package:agriproduce/constant/number_to_words.dart';
import 'package:agriproduce/data_models/commodity_model.dart';
import 'package:agriproduce/data_models/supplier_model.dart';
import 'package:agriproduce/data_models/transaction_model.dart';
import 'package:agriproduce/state_management/commodity_provider.dart';
import 'package:agriproduce/state_management/supplier_provider.dart';
import 'package:agriproduce/state_management/transaction_provider.dart';
import 'package:agriproduce/utilis/formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:searchfield/searchfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  final bool isAdmin;

  const CalculatorScreen({super.key, required this.isAdmin});

  @override
  CalculatorScreenState createState() => CalculatorScreenState();
}

class CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _commodityController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _selectedUnit = 'Polythene';
  Commodity? _selectedCommodity;
  Supplier? _selectedSupplier;
  double _totalPrice = 0.0;
  String _priceInWords = '';
  DateTime _transactionDate = DateTime.now();
  String? _selectedCondition;
  TransactionType _selectedTransactionType = TransactionType.PURCHASE; // Default to purchase

  final List<String> _units = ['Metric tonne', 'Tare', 'Polythene', 'Jute'];
  final Map<String, double> _unitWeights = {
    'Metric tonne': 1000.0,
    'Polythene': 1027.0,
    'Tare': 1014.0,
    'Jute': 1040.0,
  };
  final List<String> _conditions = ['Dry', 'Wet'];

  @override
  void initState() {
    super.initState();
    ref.read(commodityNotifierProvider.notifier).fetchCommodities(ref);
    ref.read(supplierNotifierProvider.notifier).fetchSuppliers(ref);

    _weightController.addListener(_calculateTotalPrice);
    if (widget.isAdmin) _rateController.addListener(_calculateTotalPrice);

    _loadSelectedCommodity();
    _loadLastEnteredRate();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _rateController.dispose();
    _commodityController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedCommodity() async {
    final prefs = await SharedPreferences.getInstance();
    final commodityName = prefs.getString('selectedCommodity');
    if (commodityName != null) {
      final commodities = ref.read(commodityNotifierProvider);
      final selectedCommodity = commodities.firstWhere(
        (commodity) => commodity.name == commodityName,
        orElse: () => Commodity(id: '', name: '', rate: 0.0),
      );
      if (selectedCommodity.name.isNotEmpty) {
        setState(() {
          _selectedCommodity = selectedCommodity;
          _commodityController.text = selectedCommodity.name;
          _rateController.text = selectedCommodity.rate.toFormatted();
          _calculateTotalPrice();
        });
      }
    }
  }

  Future<void> _loadLastEnteredRate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRate = prefs.getDouble('lastEnteredRate') ?? 0.0;
    if (lastRate > 0) {
      setState(() {
        _rateController.text = lastRate.toFormatted();
      });
    }
  }

  Future<void> _saveLastEnteredRate(double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('lastEnteredRate', rate);
  }

  Future<void> _saveSelectedCommodity(String commodityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCommodity', commodityName);
  }

  void _calculateTotalPrice() {
    double weight = double.tryParse(_weightController.text) ?? 0;
    double rate =
        double.tryParse(_rateController.text.replaceAll(',', '')) ?? 0;
    double unitWeight = _unitWeights[_selectedUnit] ?? 1000.0;

    setState(() {
      _totalPrice = weight > 0 ? (weight / unitWeight) * rate : 0.0;
      _priceInWords = _totalPrice > 0 ? convertNumberToWords(_totalPrice) : '';
    });
  }

  void _resetFields() {
    _weightController.clear();
    _commodityController.clear();
    _supplierController.clear();
    setState(() {
      _selectedCommodity = null;
      _selectedSupplier = null;
      _totalPrice = 0.0;
      _priceInWords = '';
      _transactionDate = DateTime.now();
      _selectedTransactionType = TransactionType.PURCHASE; // Reset to purchase
    });
  }

  void _showSaveTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Transaction'),
        content: const Text('Do you want to save this transaction?'),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState?.validate() == true) {
                final double enteredRate =
                    double.tryParse(_rateController.text.replaceAll(',', '')) ??
                        0.0;
                final double rateToSave = enteredRate > 0
                    ? enteredRate
                    : (_selectedCommodity?.rate ?? 0.0);

                final transaction = Transaction(
                  weight: double.tryParse(_weightController.text) ?? 0,
                  unit: _selectedUnit,
                  price: _totalPrice,
                  commodityName: _commodityController.text,
                  supplierName: _selectedSupplier?.name ?? '',
                  rate: rateToSave,
                  transactionDate: _transactionDate,
                  commodityCondition: _selectedCondition,
                  transactionType: _selectedTransactionType, // Add transaction type
                );

                ref
                    .read(transactionProvider.notifier)
                    .addTransaction(ref, transaction);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Transaction saved successfully!',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 1),
                  ),
                );

                _saveLastEnteredRate(rateToSave);
                _rateController.text = rateToSave.toFormatted();
                Navigator.of(context).pop();
                _resetFields();
              }
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
        ],
      ),
    );
  }

  // ------------------ Helper Widgets ------------------

  Widget _buildTransactionTypeDropdown() {
    return DropdownButtonFormField<TransactionType>(
      value: _selectedTransactionType,
      decoration: InputDecoration(
        labelText: 'Transaction Type',
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!)),
      ),
      items: TransactionType.values
          .map((type) => DropdownMenuItem(
                value: type,
                child: Text(
                  type == TransactionType.PURCHASE ? 'Purchase' : 'Sale',
                  style: TextStyle(
                    color: type == TransactionType.PURCHASE 
                        ? Colors.green 
                        : Colors.orange,
                  ),
                ),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedTransactionType = value!;
        });
      },
      validator: (value) {
        if (value == null) return 'Please select transaction type';
        return null;
      },
    );
  }

  Widget _buildWeightUnitRow() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextFormField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Weight',
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!)),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter weight';
                double? weight = double.tryParse(value);
                if (weight == null || weight <= 0)
                  return 'Please enter a valid number';
                return null;
              },
            ),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedUnit,
            decoration: InputDecoration(
              labelText: 'Select Unit',
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!)),
            ),
            items: _units
                .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedUnit = value!;
                _calculateTotalPrice();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRateField() {
  return TextFormField(
    controller: _rateController,
    decoration: InputDecoration(
      labelText: 'Rate',
      border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!)),
    ),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    enabled: widget.isAdmin,
    validator: (value) {
      if (widget.isAdmin && (value == null || value.isEmpty)) {
        return 'Please enter rate';
      }
      return null;
    },
    onChanged: (value) {
      if (!widget.isAdmin) return;

      // Just update the total price dynamically, no formatting yet
      _calculateTotalPrice();
    },
    onEditingComplete: () {
      // Format only when user finishes typing
      double rate = double.tryParse(_rateController.text.replaceAll(',', '')) ?? 0.0;
      _rateController.text = rate.toFormatted();
      _saveLastEnteredRate(rate);
    },
  );
}

  Widget _buildSearchField<T>({
    required TextEditingController controller,
    required List<T> suggestions,
    required String hint,
    required void Function(T) onSelected,
    String? Function(String?)? validator,
    required String Function(T) displayText,
  }) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Stack(
          children: [
            SearchField<T>(
              controller: controller,
              suggestions: suggestions
                  .map((item) =>
                      SearchFieldListItem<T>(displayText(item), item: item))
                  .toList(),
              onSuggestionTap: (suggestion) {
                onSelected(suggestion.item as T);
                FocusScope.of(context).unfocus();
              },
              hint: hint,
              validator: validator,
            ),
            Positioned(
                right: 30,
                top: 12,
                child: Icon(Icons.search, color: Colors.grey[600])),
            Positioned(
                right: 10,
                top: 12,
                child: Icon(Icons.arrow_drop_down, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCondition,
      decoration: InputDecoration(
        labelText: 'Commodity Condition',
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!)),
      ),
      items: _conditions
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (value) => setState(() => _selectedCondition = value!),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please select a condition';
        return null;
      },
    );
  }

  Widget _buildAmountDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amount: ${_totalPrice.toFormatted()}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('In Words: $_priceInWords',
            style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  // ------------------ Build Method ------------------

  @override
  Widget build(BuildContext context) {
    final commodities = ref.watch(commodityNotifierProvider);
    final suppliers = ref.watch(supplierNotifierProvider);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return true;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16.0),
                
                // Transaction Type Dropdown - Added at the top
                _buildTransactionTypeDropdown(),
                const SizedBox(height: 16.0),
                
                _buildWeightUnitRow(),
                const SizedBox(height: 16.0),
                _buildRateField(),
                const SizedBox(height: 16.0),
                _buildSearchField<Commodity>(
                  controller: _commodityController,
                  suggestions: commodities,
                  hint: 'Select Commodity or type..',
                  displayText: (c) => c.name,
                  validator: (value) {
                    if (widget.isAdmin && value != null && value.isNotEmpty) {
                      _selectedCommodity = Commodity(
                        id: '',
                        name: value,
                        rate: double.tryParse(
                                _rateController.text.replaceAll(',', '')) ??
                            0.0,
                      );
                    }
                    return null;
                  },
                  onSelected: (c) {
                    setState(() {
                      _selectedCommodity = c;
                      _commodityController.text = c.name;
                      _rateController.text = c.rate.toFormatted();
                      _calculateTotalPrice();
                      _saveSelectedCommodity(c.name);
                      _saveLastEnteredRate(c.rate);
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                _buildSearchField<Supplier>(
                  controller: _supplierController,
                  suggestions: suppliers,
                  hint: _selectedTransactionType == TransactionType.PURCHASE 
                      ? 'Select Supplier or type..' 
                      : 'Select Customer or type..',
                  displayText: (s) => s.name,
                  validator: (value) {
                    if (_selectedSupplier == null ||
                        _selectedSupplier!.name.isEmpty) {
                      _selectedSupplier = Supplier(
                          id: '',
                          name: _selectedTransactionType == TransactionType.PURCHASE
                              ? 'General Supplier'
                              : 'General Customer',
                          contact: '',
                          address: '');
                    }
                    return null;
                  },
                  onSelected: (s) {
                    setState(() {
                      _selectedSupplier = s;
                      _supplierController.text = s.name;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                _buildConditionDropdown(),
                const SizedBox(height: 16.0),
                _buildAmountDisplay(),
                const SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(400, 50)),
                    onPressed: _showSaveTransactionDialog,
                    child: Text(
                      _selectedTransactionType == TransactionType.PURCHASE
                          ? 'Save Purchase'
                          : 'Save Sale',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}