import 'package:agriproduce/data_models/supplier_model.dart';
import 'package:agriproduce/services/supplier_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final supplierServiceProvider = Provider<SupplierService>((ref) {
  final service = SupplierService();
  // You can't `await` in a normal provider, so call `init()` in main or splash screen!
  return service;
});

class SupplierNotifier extends StateNotifier<List<Supplier>> {
  final SupplierService _supplierService;
  SupplierNotifier(this._supplierService) : super([]);

  // Fetch suppliers
  Future<void> fetchSuppliers(WidgetRef ref) async {
    try {
      final fetchedSuppliers = await _supplierService.getSuppliers(ref);
      state = fetchedSuppliers;
    } catch (error) {
      print('Error fetching suppliers: $error');
      rethrow;
    }
  }

  // Create a new supplier
  Future<void> createSupplier(WidgetRef ref, Supplier supplier) async {
    await _supplierService.createSupplier(ref, supplier);
    addSupplier(supplier); // Add supplier to the state immediately
  }

  // Update an existing supplier
  Future<void> updateSupplier(
      WidgetRef ref, String supplierId, Supplier supplier) async {
    await _supplierService.updateSupplier(ref, supplierId, supplier);
    updateSupplierInState(
        supplierId, supplier); // Update supplier in state immediately
  }

  // Delete a supplier
  Future<void> deleteSupplier(WidgetRef ref, String supplierId) async {
    await _supplierService.deleteSupplier(ref, supplierId);
    deleteSupplierInState(supplierId); // Remove supplier from state immediately
  }

  // Directly update local state for Add, Update, and Delete operations
  void addSupplier(Supplier supplier) {
    state = [...state, supplier];
  }

  void updateSupplierInState(String supplierId, Supplier updatedSupplier) {
    state = [
      for (final supplier in state)
        if (supplier.id == supplierId) updatedSupplier else supplier
    ];
  }

  void deleteSupplierInState(String supplierId) {
    state = state.where((supplier) => supplier.id != supplierId).toList();
  }
}

final supplierNotifierProvider =
    StateNotifierProvider<SupplierNotifier, List<Supplier>>((ref) {
  final supplierService = ref.watch(supplierServiceProvider);
  return SupplierNotifier(supplierService);
});
