import 'package:agriproduce/constant/number_to_words.dart';
import 'package:agriproduce/data_models/commodity_model.dart';
import 'package:agriproduce/data_models/supplier_model.dart';
import 'package:agriproduce/data_models/transaction_model.dart';
import 'package:agriproduce/state_management/commodity_provider.dart';
import 'package:agriproduce/state_management/supplier_provider.dart';
import 'package:agriproduce/state_management/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
  String _selectedUnit = 'Metric tonne';
  Commodity? _selectedCommodity;
  Supplier? _selectedSupplier;
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

  @override
  void initState() {
    super.initState();
    ref.read(commodityNotifierProvider.notifier).fetchCommodities(ref);
    ref.read(supplierNotifierProvider.notifier).fetchSuppliers(ref);
    _weightController.addListener(_calculateTotalPrice);
    if (widget.isAdmin) {
      _rateController.addListener(_calculateTotalPrice);
    }
    _loadSelectedCommodity();
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
        orElse: () => Commodity(
            id: '', name: '', rate: 0.0), // Return a default Commodity object
      );
      if (selectedCommodity.name.isNotEmpty) {
        setState(() {
          _selectedCommodity = selectedCommodity;
          _commodityController.text = selectedCommodity.name;
          _rateController.text = selectedCommodity.rate.toString();
          _calculateTotalPrice();
        });
      }
    }
  }

  Future<void> _saveSelectedCommodity(String commodityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCommodity', commodityName);
  }

  void _calculateTotalPrice() {
    if (_weightController.text.isNotEmpty) {
      double weight = double.tryParse(_weightController.text) ?? 0;
      double unitWeight = _unitWeights[_selectedUnit] ?? 1000.0;
      double rate =
          double.tryParse(_rateController.text.replaceAll(',', '')) ?? 0;
      _totalPrice = (weight / unitWeight) * rate;
      _priceInWords = convertNumberToWords(_totalPrice);
      setState(() {});
    } else {
      setState(() {
        _totalPrice = 0.0;
        _priceInWords = '';
      });
    }
  }

  void _showSaveTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Transaction'),
          content: const Text('Do you want to save this transaction?'),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() == true) {
                  final double enteredRate = double.tryParse(
                          _rateController.text.replaceAll(',', '')) ??
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
                      backgroundColor:
                          Colors.green, // Set the background color to green
                      duration: const Duration(seconds: 1),
                    ),
                  );

                  Navigator.of(context).pop();
                  _resetFields();
                  Navigator.pushReplacementNamed(context, '/purchases');
                }
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _resetFields() {
    _weightController.clear();
    _rateController.clear();
    _commodityController.clear();
    _supplierController.clear();
    setState(() {
      _selectedCommodity = null;
      _selectedSupplier = null;
      _totalPrice = 0.0;
      _priceInWords = '';
      _transactionDate = DateTime.now();
    });
  }

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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: TextFormField(
                            controller: _weightController,
                            decoration: InputDecoration(
                              labelText: 'Weight',
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter weight';
                              }
                              double? weight = double.tryParse(value);
                              if (weight == null || weight <= 0) {
                                return 'Please enter a valid number';
                              }
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
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          items: _units.map((String unit) {
                            return DropdownMenuItem<String>(
                                value: unit, child: Text(unit));
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedUnit = newValue!;
                              _calculateTotalPrice();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _rateController,
                    decoration: InputDecoration(
                      labelText: 'Rate',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: widget.isAdmin, // Enable only for admin
                    validator: (value) {
                      if (widget.isAdmin && (value == null || value.isEmpty)) {
                        return 'Please enter rate';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (widget.isAdmin) {
                        String formattedValue = value.replaceAll(',', '');
                        if (formattedValue.isNotEmpty) {
                          formattedValue = NumberFormat('#,##0')
                              .format(int.tryParse(formattedValue) ?? 0);
                        }

                        _rateController.value = _rateController.value.copyWith(
                          text: formattedValue,
                          selection: TextSelection.collapsed(
                              offset: formattedValue.length),
                        );

                        _calculateTotalPrice();
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      // Trigger the dropdown
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Stack(
                        children: [
                          // The SearchField widget takes up the full width of the container
                          SearchField<Commodity>(
                            controller: _commodityController,
                            suggestions: commodities
                                .map((Commodity commodity) =>
                                    SearchFieldListItem<Commodity>(
                                        commodity.name,
                                        item: commodity))
                                .toList(),
                            onSuggestionTap: (suggestion) {
                              setState(() {
                                _selectedCommodity = suggestion.item;
                                _commodityController.text =
                                    _selectedCommodity?.name ?? '';
                                _rateController.text =
                                    _selectedCommodity?.rate.toString() ?? '';
                                _calculateTotalPrice();
                                _saveSelectedCommodity(
                                    _selectedCommodity!.name);
                              });
                              FocusScope.of(context).unfocus();
                            },
                            hint: 'Select Commodity or type..',
                            validator: (value) {
                              if (widget.isAdmin &&
                                  value != null &&
                                  value.isNotEmpty) {
                                _selectedCommodity = Commodity(
                                  id: '', // Null for id
                                  name: value,
                                  rate: double.tryParse(_rateController.text) ??
                                      0.0,
                                );
                              }
                              return null;
                            },
                          ),
                          // Positioned search icon
                          Positioned(
                            right: 30,
                            top: 12,
                            child: Icon(
                              Icons.search,
                              color: Colors.grey[600],
                            ),
                          ),
                          // Positioned down arrow icon
                          Positioned(
                            right:
                                10, // Position it near the right edge to avoid overlap
                            top: 12, // Align vertically with the search icon
                            child: Icon(
                              Icons.arrow_drop_down, // Down arrow icon
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      // Trigger the dropdown
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Stack(
                        children: [
                          // The SearchField widget takes up the full width of the container
                          SearchField<Supplier>(
                            controller: _supplierController,
                            suggestions: suppliers
                                .map((Supplier supplier) =>
                                    SearchFieldListItem<Supplier>(supplier.name,
                                        item: supplier))
                                .toList(),
                            onSuggestionTap: (suggestion) {
                              setState(() {
                                _selectedSupplier = suggestion.item;
                                _supplierController.text =
                                    _selectedSupplier?.name ?? '';
                              });
                              FocusScope.of(context).unfocus();
                            },
                            hint: 'Select Supplier or type..',
                            validator: (value) {
                              if (_selectedSupplier == null ||
                                  _selectedSupplier!.name.isEmpty) {
                                _selectedSupplier = Supplier(
                                  id: '', // Null for id
                                  name: "General Supplier",
                                  contact: '',
                                  address: '',
                                );
                              }
                              return null;
                            },
                          ),
                          // Positioned search icon
                          Positioned(
                            right: 30,
                            top: 12,
                            child: Icon(
                              Icons.search,
                              color: Colors.grey[600],
                            ),
                          ),
                          // Positioned down arrow icon
                          Positioned(
                            right:
                                10, // Position it near the right edge to avoid overlap
                            top: 12, // Align vertically with the search icon
                            child: Icon(
                              Icons.arrow_drop_down, // Down arrow icon
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Amount: ${NumberFormat('#,##0.00').format(_totalPrice)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'In Words: $_priceInWords',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16.0),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(400, 50),
                      ),
                      onPressed: _showSaveTransactionDialog,
                      child: const Text('Save Transaction'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
