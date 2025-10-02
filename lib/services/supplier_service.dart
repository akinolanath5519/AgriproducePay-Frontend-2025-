import 'dart:convert';
import 'package:agriproduce/constant/appLogger.dart';
import 'package:agriproduce/constant/httpError.dart';
import 'package:agriproduce/data_models/supplier_model.dart';
import 'package:agriproduce/utilis/api_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ---------------- LOCAL SUPPLIER CACHE ----------------
class LocalSupplierService {
  void saveSupplier(Supplier supplier) =>
      AppLogger.logInfo('💾 Saved locally: ${supplier.toJson()}');

  List<Supplier> getAllSuppliers() {
    AppLogger.logInfo('📦 Returning cached suppliers (currently empty)');
    return [];
  }

  bool isDataCached() => false;

  void deleteSupplier(String id) =>
      AppLogger.logInfo('🗑 Deleted locally: $id');
}

/// ---------------- REMOTE SUPPLIER SERVICE ----------------
class SupplierService {
  final LocalSupplierService localService = LocalSupplierService();

  /// Create supplier
  Future<void> createSupplier(WidgetRef ref, Supplier supplier) async {
    localService.saveSupplier(supplier);
    try {
      await apiPost(ref, '/suppliers/supplier', supplier.toJson());
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to create supplier: $e', e, stackTrace);
    }
  }

  /// Get all suppliers
  Future<List<Supplier>> getSuppliers(WidgetRef ref) async {
    if (localService.isDataCached()) {
      AppLogger.logInfo('📦 Loaded suppliers from cache');
      return localService.getAllSuppliers();
    }

    try {
      final response = await apiGet(ref, '/suppliers/supplier', json: false);
      if (response.body.isEmpty) return [];

      final List<dynamic> supplierList = jsonDecode(response.body);
      final suppliers =
          supplierList.map((json) => Supplier.fromJson(json)).toList();

      suppliers.forEach(localService.saveSupplier);
      return suppliers;
    } catch (e, stackTrace) {
      HttpErrorHandler.handleJsonDecodingError('decode suppliers', e);
      AppLogger.logError('❌ Error fetching suppliers: $e', e, stackTrace);
    }

    return localService.getAllSuppliers();
  }

  /// Update supplier
  Future<void> updateSupplier(
      WidgetRef ref, String id, Supplier supplier) async {
    localService.saveSupplier(supplier);
    try {
      await apiPut(ref, '/suppliers/supplier/$id', supplier.toJson());
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to update supplier: $e', e, stackTrace);
    }
  }

  /// Delete supplier
  Future<void> deleteSupplier(WidgetRef ref, String id) async {
    localService.deleteSupplier(id);
    try {
      await apiDelete(ref, '/suppliers/supplier/$id');
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to delete supplier: $e', e, stackTrace);
    }
  }
}
