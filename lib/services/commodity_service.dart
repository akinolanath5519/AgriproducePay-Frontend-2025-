import 'dart:convert';
import 'package:agriproduce/constant/appLogger.dart';
import 'package:agriproduce/data_models/commodity_model.dart';
import 'package:agriproduce/local%20service/local_commodity_service.dart';
import 'package:agriproduce/utilis/api_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommodityService {
  final LocalCommodityService localService = LocalCommodityService();

  /// Create commodity (offline first)
  Future<void> createCommodity(WidgetRef ref, Commodity commodity) async {
    // 1️⃣ Insert locally with temp ID
    await localService.insertCommodity(commodity, synced: false);

    try {
      // 2️⃣ Sync to server
      final response =
          await apiPost(ref, '/commodities/commodity', commodity.toJson());
      final serverData = jsonDecode(response.body);
      final serverCommodity = Commodity.fromJson(serverData);

      // 3️⃣ Update local DB with server ID and mark as synced
      await localService.deleteCommodity(commodity.id); // remove temp
      await localService.insertCommodity(serverCommodity, synced: true);

      AppLogger.logInfo('✅ Synced commodity to server: ${serverCommodity.id}');
    } catch (e, stackTrace) {
      AppLogger.logError(
          '❌ Failed to sync commodity → will retry later', e, stackTrace);
    }
  }

  /// Get all commodities (offline-first, merged with server)
  Future<List<Commodity>> getCommodities(WidgetRef ref) async {
    // 1. Load local first
    final localCommodities = await localService.getAllCommodities();
    AppLogger.logInfo(
        "📥 Loaded ${localCommodities.length} commodities from local DB");

    // Log each local commodity
    for (final c in localCommodities) {
      AppLogger.logInfo(
          "   LOCAL → id=${c.id}, name=${c.name}, synced=${c.isSynced}");
    }

    try {
      // 2. Try fetching from API
      final response = await apiGet(ref, '/commodities/commodity', json: false);
      if (response.body.isNotEmpty) {
        final List<dynamic> commodityList = jsonDecode(response.body);
        final serverCommodities =
            commodityList.map((json) => Commodity.fromJson(json)).toList();

        AppLogger.logInfo(
            "🌍 Refreshed ${serverCommodities.length} commodities from server");

        // Log each server commodity
        for (final c in serverCommodities) {
          AppLogger.logInfo("   SERVER → id=${c.id}, name=${c.name}");
        }

        // Save/overwrite server commodities in local DB as synced
        for (final c in serverCommodities) {
          AppLogger.logInfo(
              "💾 Inserting/Updating server commodity in local DB → id=${c.id}, name=${c.name}");
          await localService.insertCommodity(c, synced: true);
        }

        // 3. Merge server + local
        final Map<String, Commodity> merged = {
          for (final c in localCommodities) c.id: c,
          for (final c in serverCommodities) c.id: c, // overwrites if same id
        };

        AppLogger.logInfo(
            "🧩 After merge → ${merged.length} unique commodities");

        // Log merged commodities
        for (final c in merged.values) {
          AppLogger.logInfo("   MERGED → id=${c.id}, name=${c.name}");
        }

        return merged.values.toList();
      }
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Error fetching commodities: $e', e, stackTrace);
    }

    // 4. If API fails, fallback to local only
    return localCommodities;
  }

  /// Update commodity (offline first)
  Future<void> updateCommodity(
      WidgetRef ref, String id, Commodity commodity) async {
    await localService.insertCommodity(commodity, synced: false);
    try {
      await apiPut(ref, '/commodities/commodity/$id', commodity.toJson());
      await localService.updateSyncStatus(id, true);
      AppLogger.logInfo('🚀 Synced commodity update to server: $id');
    } catch (e, stackTrace) {
      AppLogger.logError(
          '❌ Failed to sync commodity update: $e', e, stackTrace);
    }
  }

  /// Delete commodity (offline first)
  Future<void> deleteCommodity(WidgetRef ref, String id) async {
    await localService.deleteCommodity(id);
    try {
      await apiDelete(ref, '/commodities/commodity/$id');
      AppLogger.logInfo('🚀 Deleted commodity remotely: $id');
    } catch (e, stackTrace) {
      AppLogger.logError(
          '❌ Failed to delete commodity remotely: $e', e, stackTrace);
    }
  }

  /// Sync all unsynced local commodities to server
  Future<void> syncLocalToServer(WidgetRef ref) async {
    final unsynced = await localService.getUnsyncedCommodities();

    for (final commodity in unsynced) {
      try {
        final response =
            await apiPost(ref, '/commodities/commodity', commodity.toJson());
        final serverData = jsonDecode(response.body);
        final serverCommodity = Commodity.fromJson(serverData);

        // Replace temp ID with server ID
        await localService.deleteCommodity(commodity.id);
        await localService.insertCommodity(serverCommodity, synced: true);

        AppLogger.logInfo('🚀 Synced local commodity: ${serverCommodity.id}');
      } catch (e, stackTrace) {
        AppLogger.logError(
            '❌ Failed to sync local commodity: $e', e, stackTrace);
      }
    }
  }
}
