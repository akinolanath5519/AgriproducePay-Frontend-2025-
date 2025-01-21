import 'package:agriproduce/data_models/supplier_model.dart';
import 'package:agriproduce/state_management/supplier_provider.dart';
import 'package:agriproduce/widgets/custom_list_tile.dart'; // Import CustomListTile
import 'package:agriproduce/widgets/custom_text_field.dart'; // Import CustomTextField
import 'package:agriproduce/widgets/custom_search_bar.dart'; // Import CustomSearchBar
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupplierScreen extends ConsumerStatefulWidget {
  const SupplierScreen({super.key});

  @override
  _SupplierScreenState createState() => _SupplierScreenState();
}

class _SupplierScreenState extends ConsumerState<SupplierScreen> {
  bool isLoading = false; // For fetching suppliers
  bool isCreating = false; // For adding a new supplier
  String searchTerm = '';
  TextEditingController searchController = TextEditingController();

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
    setState(() {
      isLoading = true; // Show loading when fetching suppliers
    });

    try {
      final suppliers = ref.read(supplierNotifierProvider);
      if (suppliers.isEmpty) {
        await ref.read(supplierNotifierProvider.notifier).fetchSuppliers(ref);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching suppliers')),
      );
    } finally {
      setState(() {
        isLoading = false; // Hide loading after fetching is complete
      });
    }
  }

  void _showSupplierDialog(BuildContext context, {Supplier? supplier}) {
    final nameController = TextEditingController(text: supplier?.name);
    final contactController = TextEditingController(text: supplier?.contact);
    final addressController = TextEditingController(text: supplier?.address);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text(supplier == null ? 'Add Supplier' : 'Edit Supplier'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(controller: nameController, label: 'Name'),
                SizedBox(height: 12.0),
                CustomTextField(
                  controller: contactController,
                  label: 'Contact',
                  hintText: 'Enter contact number',
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 12.0),
                CustomTextField(
                    controller: addressController, label: 'Address'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  isCreating = true; // Show loading indicator when creating
                });

                if (supplier == null) {
                  await _createSupplier(nameController.text,
                      contactController.text, addressController.text);
                } else {
                  await _updateSupplier(supplier.id, nameController.text,
                      contactController.text, addressController.text);
                }
              },
              child: Text(supplier == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createSupplier(
      String name, String contact, String address) async {
    try {
      await ref.read(supplierNotifierProvider.notifier).createSupplier(ref,
          Supplier(id: '', name: name, contact: contact, address: address));
      _fetchSuppliers(); // Re-fetch after adding a new supplier
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error adding supplier')));
    } finally {
      setState(() {
        isCreating = false; // Hide loading indicator after creation
      });
    }
  }

  Future<void> _updateSupplier(
      String id, String name, String contact, String address) async {
    try {
      await ref.read(supplierNotifierProvider.notifier).updateSupplier(ref, id,
          Supplier(id: id, name: name, contact: contact, address: address));
      _fetchSuppliers(); // Re-fetch after updating a supplier
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error updating supplier')));
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String supplierId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text('Delete Supplier'),
          content: Text(
              'Are you sure you want to delete this supplier? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              onPressed: () async {
                try {
                  await ref
                      .read(supplierNotifierProvider.notifier)
                      .deleteSupplier(ref, supplierId);
                  _fetchSuppliers(); // Re-fetch after deleting supplier
                  Navigator.of(context).pop();
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting supplier')));
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(supplierNotifierProvider);

    final filteredSuppliers = suppliers
        .where((supplier) =>
            supplier.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
            supplier.contact.contains(searchTerm))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Suppliers')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                CustomSearchBar(
                  controller: searchController,
                  hintText: 'Search Suppliers',
                  onChanged: (value) {
                    setState(() {
                      searchTerm = value;
                    });
                  },
                  onClear: () {
                    setState(() {
                      searchTerm = '';
                      searchController.clear();
                    });
                  },
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchSuppliers,
                    child: ListView.builder(
                      itemCount: filteredSuppliers.length,
                      itemBuilder: (context, index) {
                        final supplier = filteredSuppliers[index];
                        return CustomListTile(
                          title: supplier.name,
                          subtitle:
                              'Contact: ${supplier.contact}\nAddress: ${supplier.address}',
                          onEdit: () =>
                              _showSupplierDialog(context, supplier: supplier),
                          onDelete: () => _showDeleteConfirmationDialog(
                              context, supplier.id),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSupplierDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
