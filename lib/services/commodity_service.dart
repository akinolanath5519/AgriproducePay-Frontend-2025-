import 'dart:convert';
import 'package:agriproduce/constant/appLogger.dart';
import 'package:agriproduce/constant/httpError.dart';
import 'package:agriproduce/data_models/commodity_model.dart';
import 'package:agriproduce/utilis/api_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ---------------- LOCAL COMMODITY CACHE ----------------
class LocalCommodityService {
  void saveCommodity(Commodity commodity) =>
      AppLogger.logInfo('💾 Saved locally: ${commodity.toJson()}');

  List<Commodity> getAllCommodities() {
    AppLogger.logInfo('📦 Returning cached commodities (currently empty)');
    return [];
  }

  bool isDataCached() => false;

  void deleteCommodity(String id) =>
      AppLogger.logInfo('🗑 Deleted locally: $id');
}

/// ---------------- REMOTE COMMODITY SERVICE ----------------
class CommodityService {
  final LocalCommodityService localService = LocalCommodityService();

  /// Create commodity
  Future<void> createCommodity(WidgetRef ref, Commodity commodity) async {
    localService.saveCommodity(commodity);
    try {
      await apiPost(ref, '/commodities/commodity', commodity.toJson());
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to create commodity: $e', e, stackTrace);
    }
  }

  /// Get all commodities
  Future<List<Commodity>> getCommodities(WidgetRef ref) async {
    if (localService.isDataCached()) {
      AppLogger.logInfo('📦 Loaded commodities from cache');
      return localService.getAllCommodities();
    }

    try {
      final response = await apiGet(ref, '/commodities/commodity', json: false);
      if (response.body.isEmpty) return [];

      final List<dynamic> commodityList = jsonDecode(response.body);
      final commodities =
          commodityList.map((json) => Commodity.fromJson(json)).toList();

      commodities.forEach(localService.saveCommodity);
      return commodities;
    } catch (e, stackTrace) {
      HttpErrorHandler.handleJsonDecodingError('decode commodities', e);
      AppLogger.logError('❌ Error fetching commodities: $e', e, stackTrace);
    }

    return localService.getAllCommodities();
  }

  /// Update commodity
  Future<void> updateCommodity(
      WidgetRef ref, String id, Commodity commodity) async {
    localService.saveCommodity(commodity);
    try {
      await apiPut(ref, '/commodities/commodity/$id', commodity.toJson());
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to update commodity: $e', e, stackTrace);
    }
  }

  /// Delete commodity
  Future<void> deleteCommodity(WidgetRef ref, String id) async {
    localService.deleteCommodity(id);
    try {
      await apiDelete(ref, '/commodities/commodity/$id');
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to delete commodity: $e', e, stackTrace);
    }
  }
}
