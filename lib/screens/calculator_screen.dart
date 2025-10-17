import 'package:agriproduce/constant/number_to_words.dart';
import 'package:agriproduce/data_models/commodity_model.dart';
import 'package:agriproduce/data_models/supplier_model.dart';
import 'package:agriproduce/data_models/transaction_model.dart';
import 'package:agriproduce/state_management/commodity_provider.dart';
import 'package:agriproduce/state_management/supplier_provider.dart';
import 'package:agriproduce/state_management/transaction_provider.dart';
import 'package:agriproduce/state_management/auth_provider.dart';
import 'package:agriproduce/utilis/formatter.dart';
import 'package:agriproduce/widgets/custom_dropdown.dart';
import 'package:agriproduce/widgets/custom_button.dart';
import 'package:agriproduce/widgets/custom_search_field.dart';
import 'package:agriproduce/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

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
  String? _selectedCondition;
  Commodity? _selectedCommodity;
  Supplier? _selectedSupplier;
  TransactionType _selectedTransactionType = TransactionType.PURCHASE;

  double _totalPrice = 0.0;
  String _priceInWords = '';
  DateTime _transactionDate = DateTime.now();

  final List<String> _units = ['Metric tonne', 'Tare', 'Polythene', 'Jute'];
  final Map<String, double> _unitWeights = {
    'Metric tonne': 1000.0,
    'Polythene': 1027.0,
    'Tare': 1014.0,
    'Jute': 1040.0,
  };
  final List<String> _conditions = ['Dry', 'Wet'];

  bool get isAdmin {
    final user = ref.read(userProvider);
    return user?.role.toLowerCase() == 'admin';
  }

  @override
  void initState() {
    super.initState();
    ref.read(commodityNotifierProvider.notifier).fetchCommodities(ref);
    ref.read(supplierNotifierProvider.notifier).fetchSuppliers(ref);
    _weightController.addListener(_calculateTotalPrice);
    if (isAdmin) _rateController.addListener(_calculateTotalPrice);
    _loadSelectedCommodity();
    _loadLastEnteredRate();
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
      _selectedTransactionType = TransactionType.PURCHASE;
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
                    double.tryParse(_rateController.text.replaceAll(',', '')) ?? 0.0;
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
                  transactionType: _selectedTransactionType,
                );

                ref.read(transactionProvider.notifier).addTransaction(ref, transaction);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaction saved successfully!'),
                    backgroundColor: Colors.green,
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

  @override
  Widget build(BuildContext context) {
    final commodities = ref.watch(commodityNotifierProvider);
    final suppliers = ref.watch(supplierNotifierProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              CustomDropdownField<TransactionType>(
                label: 'Transaction Type',
                items: TransactionType.values,
                value: _selectedTransactionType,
                displayText: (t) => t == TransactionType.PURCHASE ? 'Purchase' : 'Sale',
                onChanged: (value) =>
                    setState(() => _selectedTransactionType = value!),
              ),
              const SizedBox(height: 16),

              // Weight + Unit
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(labelText: 'Weight'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Enter weight' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomDropdownField<String>(
                      label: 'Unit',
                      items: _units,
                      value: _selectedUnit,
                      displayText: (u) => u,
                      onChanged: (v) {
                        setState(() {
                          _selectedUnit = v!;
                          _calculateTotalPrice();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Rate field
              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(labelText: 'Rate'),
                keyboardType: TextInputType.number,
                enabled: isAdmin, // ✅ enabled only for admin users
                onChanged: (_) => _calculateTotalPrice(),
              ),
              const SizedBox(height: 16),

              // ✅ Reusable Search Fields
              CustomSearchField<Commodity>(
                controller: _commodityController,
                suggestions: commodities,
                hint: 'Select Commodity or type...',
                displayText: (c) => c.name,
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
              const SizedBox(height: 16),

              CustomSearchField<Supplier>(
                controller: _supplierController,
                suggestions: suppliers,
                hint: _selectedTransactionType == TransactionType.PURCHASE
                    ? 'Select Supplier or type...'
                    : 'Select Customer or type...',
                displayText: (s) => s.name,
                onSelected: (s) {
                  setState(() {
                    _selectedSupplier = s;
                    _supplierController.text = s.name;
                  });
                },
              ),
              const SizedBox(height: 16),

              CustomDropdownField<String>(
                label: 'Commodity Condition',
                items: _conditions,
                value: _selectedCondition,
                displayText: (c) => c,
                onChanged: (v) => setState(() => _selectedCondition = v),
              ),
              const SizedBox(height: 16),

              Text('Amount: ${_totalPrice.toFormatted()}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('In Words: $_priceInWords',
                  style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Save ${_selectedTransactionType == TransactionType.PURCHASE ? "Purchase" : "Sale"}',
                onPressed: _showSaveTransactionDialog,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                elevation: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
