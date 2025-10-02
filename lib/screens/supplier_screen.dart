import 'dart:typed_data';
import 'package:agriproduce/data_models/supplier_model.dart';
import 'package:agriproduce/state_management/supplier_provider.dart';
import 'package:agriproduce/utilis/snack_bar.dart';
import 'package:agriproduce/widgets/custom_list_tile.dart';
import 'package:agriproduce/widgets/custom_search_bar.dart';
import 'package:agriproduce/widgets/custom_text_field.dart';
import 'package:agriproduce/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:csv/csv.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';


class SupplierScreen extends ConsumerStatefulWidget {
  const SupplierScreen({super.key});

  @override
  _SupplierScreenState createState() => _SupplierScreenState();
}

class _SupplierScreenState extends ConsumerState<SupplierScreen> {
  bool isLoading = false;
  bool isCreating = false;
  bool isUpdating = false;
  bool isDeleting = false;
  String searchTerm = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSuppliers() async {
    setState(() => isLoading = true);
    try {
      final suppliers = ref.read(supplierNotifierProvider);
      if (suppliers.isEmpty) {
        await ref.read(supplierNotifierProvider.notifier).fetchSuppliers(ref);
      }
    } catch (error) {
      showErrorSnackbar(context, 'Error fetching suppliers: $error');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSupplierDialog(BuildContext context, {Supplier? supplier}) {
    final theme = Theme.of(context);
    final nameController = TextEditingController(text: supplier?.name);
    final contactController = TextEditingController(text: supplier?.contact);
    final addressController = TextEditingController(text: supplier?.address);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: theme.mediumBorderRadius),
            title: Text(
              supplier == null ? 'Add Supplier' : 'Edit Supplier',
              style: theme.textTheme.titleLarge,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(controller: nameController, label: 'Name'),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: contactController,
                    label: 'Contact',
                    hintText: 'Enter contact number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(controller: addressController, label: 'Address'),
                  if (isCreating || isUpdating)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: theme.mediumBorderRadius),
                ),
                onPressed: () async {
                  setStateDialog(() {
                    isCreating = supplier == null;
                    isUpdating = supplier != null;
                  });

                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    showErrorSnackbar(context, 'Supplier name is required.');
                    setStateDialog(() {
                      isCreating = false;
                      isUpdating = false;
                    });
                    return;
                  }

                  try {
                    if (supplier == null) {
                      await ref.read(supplierNotifierProvider.notifier).createSupplier(
                            ref,
                            Supplier(id: '', name: name, contact: contactController.text, address: addressController.text),
                          );
                      showSuccessSnackbar(context, 'Supplier added successfully!');
                    } else {
                      await ref.read(supplierNotifierProvider.notifier).updateSupplier(
                            ref,
                            supplier.id,
                            Supplier(
                                id: supplier.id,
                                name: name,
                                contact: contactController.text,
                                address: addressController.text),
                          );
                      showSuccessSnackbar(context, 'Supplier updated successfully!');
                    }
                    _fetchSuppliers();
                    Navigator.of(context).pop();
                  } catch (error) {
                    showErrorSnackbar(context, 'Operation failed: $error');
                  } finally {
                    setStateDialog(() {
                      isCreating = false;
                      isUpdating = false;
                    });
                  }
                },
                child: Text(supplier == null ? 'Add' : 'Save', style: theme.textTheme.labelLarge),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String supplierId) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: theme.mediumBorderRadius),
        title: Text('Delete Supplier', style: theme.textTheme.titleLarge),
        content: Text('Are you sure you want to delete this supplier? This action cannot be undone.', style: theme.textTheme.bodyLarge),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: theme.mediumBorderRadius),
            ),
            onPressed: () async {
              setState(() => isDeleting = true);
              try {
                await ref.read(supplierNotifierProvider.notifier).deleteSupplier(ref, supplierId);
                _fetchSuppliers();
                Navigator.of(context).pop();
                showSuccessSnackbar(context, 'Supplier deleted successfully!');
              } catch (error) {
                showErrorSnackbar(context, 'Failed to delete supplier: $error');
              } finally {
                setState(() => isDeleting = false);
              }
            },
            child: Text('Delete', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> downloadSupplierCsvReport(BuildContext context) async {
    try {
      final suppliers = ref.read(supplierNotifierProvider);
      if (suppliers.isEmpty) {
        showErrorSnackbar(context, 'No supplier data available.');
        return;
      }

      List<List<dynamic>> rows = [
        ['Name', 'Contact', 'Address'],
        ...suppliers.map((s) => [s.name, s.contact, s.address])
      ];

      String csvData = const ListToCsvConverter().convert(rows);
      final params = SaveFileDialogParams(
        fileName: 'suppliers.csv',
        mimeTypesFilter: ['text/csv'],
        data: Uint8List.fromList(csvData.codeUnits),
      );
      final path = await FlutterFileDialog.saveFile(params: params);

      if (path != null) {
        showSuccessSnackbar(context, 'CSV saved to $path');
      }
    } catch (e) {
      showErrorSnackbar(context, 'Error generating CSV: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suppliers = ref.watch(supplierNotifierProvider);
    final filteredSuppliers = suppliers
        .where((s) => s.name.toLowerCase().contains(searchTerm.toLowerCase()) || (s.contact ?? '').contains(searchTerm))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Suppliers', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => downloadSupplierCsvReport(context),
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: CustomSearchBar(
                  controller: searchController,
                  hintText: 'Search Suppliers',
                  onChanged: (val) => setState(() => searchTerm = val),
                  onClear: () => setState(() {
                    searchTerm = '';
                    searchController.clear();
                  }),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchSuppliers,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredSuppliers.length,
                    itemBuilder: (context, index) {
                      final supplier = filteredSuppliers[index];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: theme.mediumBorderRadius,
                          boxShadow: [theme.subtleShadow],
                        ),
                        child: CustomListTile(
                          title: supplier.name,
                          subtitle: 'Contact: ${supplier.contact}\nAddress: ${supplier.address}',
                          onEdit: () => _showSupplierDialog(context, supplier: supplier),
                          onDelete: () => _showDeleteConfirmationDialog(context, supplier.id),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (isLoading)
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(color: Colors.white),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSupplierDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
