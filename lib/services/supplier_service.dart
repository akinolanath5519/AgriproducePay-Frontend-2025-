import 'dart:convert';
import 'package:agriproduce/constant/appLogger.dart';
import 'package:agriproduce/constant/httpError.dart';
import 'package:agriproduce/data_models/supplier_model.dart';
import 'package:agriproduce/services/subscription_plan_service.dart';
import 'package:agriproduce/utilis/api_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ---------------- LOCAL SUPPLIER CACHE ----------------
class LocalSupplierService {
  final Map<String, Supplier> _cache = {};

  void saveSupplier(Supplier supplier) {
    _cache[supplier.id] = supplier;
    AppLogger.logInfo('💾 Saved locally: ${supplier.toJson()}');
  }

  List<Supplier> getAllSuppliers() {
    AppLogger.logInfo('📦 Returning cached suppliers');
    return _cache.values.toList();
  }

  bool isDataCached() => _cache.isNotEmpty;

  void deleteSupplier(String id) {
    _cache.remove(id);
    AppLogger.logInfo('🗑 Deleted locally: $id');
  }
}

/// ---------------- SUPPLIER SERVICE WITH SUBSCRIPTION CHECK ----------------
class SupplierService {
  final LocalSupplierService localService = LocalSupplierService();
  final SubscriptionPlanService subscriptionService = SubscriptionPlanService();

  /// Check if user has active subscription
  Future<bool> _hasActiveSubscription(WidgetRef ref) async {
    final data = await subscriptionService.checkActiveSubscription(ref);
    return data['hasActive'] == true;
  }

  /// Create supplier
  Future<void> createSupplier(WidgetRef ref, Supplier supplier) async {
    localService.saveSupplier(supplier); // Always save locally

    // Only save remotely if user has active subscription
    if (await _hasActiveSubscription(ref)) {
      try {
        await apiPost(ref, '/suppliers/supplier', supplier.toJson());
      } catch (e, stackTrace) {
        AppLogger.logError('❌ Failed to create supplier remotely: $e', e, stackTrace);
      }
    } else {
      AppLogger.logInfo('⚠️ User has no active subscription. Supplier saved locally only.');
    }
  }

  /// Get all suppliers
  Future<List<Supplier>> getSuppliers(WidgetRef ref) async {
    if (!await _hasActiveSubscription(ref)) {
      AppLogger.logInfo('⚠️ No active subscription. Returning local suppliers only.');
      return localService.getAllSuppliers();
    }

    try {
      final response = await apiGet(ref, '/suppliers/supplier', json: false);
      if (response.body.isEmpty) return localService.getAllSuppliers();

      final List<dynamic> supplierList = jsonDecode(response.body);
      final suppliers = supplierList.map((json) => Supplier.fromJson(json)).toList();

      suppliers.forEach(localService.saveSupplier); // Cache locally too
      return suppliers;
    } catch (e, stackTrace) {
      HttpErrorHandler.handleJsonDecodingError('decode suppliers', e);
      AppLogger.logError('❌ Error fetching suppliers: $e', e, stackTrace);
    }

    return localService.getAllSuppliers();
  }

  /// Update supplier
  Future<void> updateSupplier(WidgetRef ref, String id, Supplier supplier) async {
    localService.saveSupplier(supplier); // Always save locally

    if (await _hasActiveSubscription(ref)) {
      try {
        await apiPut(ref, '/suppliers/supplier/$id', supplier.toJson());
      } catch (e, stackTrace) {
        AppLogger.logError('❌ Failed to update supplier remotely: $e', e, stackTrace);
      }
    } else {
      AppLogger.logInfo('⚠️ No active subscription. Update saved locally only.');
    }
  }

  /// Delete supplier
  Future<void> deleteSupplier(WidgetRef ref, String id) async {
    localService.deleteSupplier(id); // Always delete locally

    if (await _hasActiveSubscription(ref)) {
      try {
        await apiDelete(ref, '/suppliers/supplier/$id');
      } catch (e, stackTrace) {
        AppLogger.logError('❌ Failed to delete supplier remotely: $e', e, stackTrace);
      }
    } else {
      AppLogger.logInfo('⚠️ No active subscription. Delete performed locally only.');
    }
  }
}
