import 'dart:convert';
import 'package:agriproduce/constant/appLogger.dart';
import 'package:agriproduce/constant/httpError.dart';
import 'package:agriproduce/data_models/commodity_model.dart';
import 'package:agriproduce/services/subscription_plan_service.dart';
import 'package:agriproduce/utilis/api_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ---------------- LOCAL COMMODITY CACHE ----------------
class LocalCommodityService {
  final Map<String, Commodity> _cache = {};

  void saveCommodity(Commodity commodity) {
    _cache[commodity.id] = commodity;
    AppLogger.logInfo('💾 Saved locally: ${commodity.toJson()}');
  }

  List<Commodity> getAllCommodities() {
    AppLogger.logInfo('📦 Returning cached commodities');
    return _cache.values.toList();
  }

  bool isDataCached() => _cache.isNotEmpty;

  void deleteCommodity(String id) {
    _cache.remove(id);
    AppLogger.logInfo('🗑 Deleted locally: $id');
  }
}

/// ---------------- COMMODITY SERVICE WITH SUBSCRIPTION CHECK ----------------
class CommodityService {
  final LocalCommodityService localService = LocalCommodityService();
  final SubscriptionPlanService subscriptionService = SubscriptionPlanService();

  /// Check if user has active subscription
  Future<bool> _hasActiveSubscription(WidgetRef ref) async {
    final data = await subscriptionService.checkActiveSubscription(ref);
    return data['hasActive'] == true;
  }

  /// Create commodity
  Future<void> createCommodity(WidgetRef ref, Commodity commodity) async {
    localService.saveCommodity(commodity); // Always save locally

    if (await _hasActiveSubscription(ref)) {
      try {
        await apiPost(ref, '/commodities/commodity', commodity.toJson());
      } catch (e, stackTrace) {
        AppLogger.logError('❌ Failed to create commodity remotely: $e', e, stackTrace);
      }
    } else {
      AppLogger.logInfo('⚠️ User has no active subscription. Commodity saved locally only.');
    }
  }

  /// Get all commodities
  Future<List<Commodity>> getCommodities(WidgetRef ref) async {
    if (!await _hasActiveSubscription(ref)) {
      AppLogger.logInfo('⚠️ No active subscription. Returning local commodities only.');
      return localService.getAllCommodities();
    }

    try {
      final response = await apiGet(ref, '/commodities/commodity', json: false);
      if (response.body.isEmpty) return localService.getAllCommodities();

      final List<dynamic> commodityList = jsonDecode(response.body);
      final commodities = commodityList.map((json) => Commodity.fromJson(json)).toList();

      commodities.forEach(localService.saveCommodity); // Cache locally too
      return commodities;
    } catch (e, stackTrace) {
      HttpErrorHandler.handleJsonDecodingError('decode commodities', e);
      AppLogger.logError('❌ Error fetching commodities: $e', e, stackTrace);
    }

    return localService.getAllCommodities();
  }

  /// Update commodity
  Future<void> updateCommodity(WidgetRef ref, String id, Commodity commodity) async {
    localService.saveCommodity(commodity); // Always save locally

    if (await _hasActiveSubscription(ref)) {
      try {
        await apiPut(ref, '/commodities/commodity/$id', commodity.toJson());
      } catch (e, stackTrace) {
        AppLogger.logError('❌ Failed to update commodity remotely: $e', e, stackTrace);
      }
    } else {
      AppLogger.logInfo('⚠️ No active subscription. Update saved locally only.');
    }
  }

  /// Delete commodity
  Future<void> deleteCommodity(WidgetRef ref, String id) async {
    localService.deleteCommodity(id); // Always delete locally

    if (await _hasActiveSubscription(ref)) {
      try {
        await apiDelete(ref, '/commodities/commodity/$id');
      } catch (e, stackTrace) {
        AppLogger.logError('❌ Failed to delete commodity remotely: $e', e, stackTrace);
      }
    } else {
      AppLogger.logInfo('⚠️ No active subscription. Delete performed locally only.');
    }
  }
}
