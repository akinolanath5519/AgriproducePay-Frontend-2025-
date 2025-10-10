import 'dart:convert';
import 'package:agriproduce/constant/appLogger.dart';
import 'package:agriproduce/constant/httpError.dart';
import 'package:agriproduce/data_models/bulkweight_model.dart';
import 'package:agriproduce/utilis/api_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ---------------- LOCAL BULKWEIGHT CACHE ----------------
class LocalBulkWeightService {
  final List<BulkWeight> _bulkWeights = [];
  final List<BulkWeightEntry> _entries = [];

  // BulkWeight
  void saveBulkWeight(BulkWeight bulkWeight) {
    _bulkWeights.add(bulkWeight);
    AppLogger.logInfo('💾 Saved BulkWeight locally: ${bulkWeight.toString()}');
  }

  List<BulkWeight> getAllBulkWeights() => _bulkWeights;
  bool isBulkWeightCached() => _bulkWeights.isNotEmpty;

  void deleteBulkWeight(String id) {
    _bulkWeights.removeWhere((bw) => bw.id == id);
    AppLogger.logInfo('🗑 Deleted local BulkWeight: $id');
  }

  // BulkWeightEntry
  void saveEntry(BulkWeightEntry entry) {
    _entries.add(entry);
    AppLogger.logInfo('💾 Saved BulkWeightEntry locally: ${entry.toJson()}');
  }

  List<BulkWeightEntry> getAllEntries() => _entries;
  bool isEntryCached() => _entries.isNotEmpty;

  void deleteEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    AppLogger.logInfo('🗑 Deleted local BulkWeightEntry: $id');
  }
}

/// ---------------- REMOTE BULKWEIGHT SERVICE ----------------
class BulkWeightService {
  final LocalBulkWeightService localService = LocalBulkWeightService();

  /// Create BulkWeight
  Future<void> createBulkWeight(WidgetRef ref, BulkWeight bulkWeight) async {
    localService.saveBulkWeight(bulkWeight);
    try {
      await apiPost(ref, '/bulkweights/bulkweight', bulkWeight.toJson());
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to create BulkWeight: $e', e, stackTrace);
    }
  }

  /// Create BulkWeightEntry
  Future<void> createEntry(WidgetRef ref, BulkWeightEntry entry) async {
    localService.saveEntry(entry);
    try {
      await apiPost(ref, '/bulkweights/entries', entry.toJson());
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to create BulkWeightEntry: $e', e, stackTrace);
    }
  }

  /// Get all BulkWeights
  Future<List<BulkWeight>> getBulkWeights(WidgetRef ref) async {
    if (localService.isBulkWeightCached()) {
      AppLogger.logInfo('📦 Loaded BulkWeights from cache');
      return localService.getAllBulkWeights();
    }

    try {
      final response = await apiGet(ref, '/bulkweights/bulkweight', json: false);
      if (response.body.isEmpty) return [];

      final List<dynamic> data = jsonDecode(response.body);
      final bulkWeights = data.map((json) => BulkWeight.fromJson(json)).toList();

      bulkWeights.forEach(localService.saveBulkWeight);
      return bulkWeights;
    } catch (e, stackTrace) {
      HttpErrorHandler.handleJsonDecodingError('decode bulkweights', e);
      AppLogger.logError('❌ Error fetching bulkweights: $e', e, stackTrace);
    }

    return localService.getAllBulkWeights();
  }

  /// Get all Entries for a transaction
  Future<List<BulkWeightEntry>> getEntries(WidgetRef ref, String transactionRef) async {
    if (localService.isEntryCached()) {
      AppLogger.logInfo('📦 Loaded BulkWeightEntries from cache');
      return localService.getAllEntries();
    }

    try {
      final response =
          await apiGet(ref, 'bulkweights/bulkweight/entries/$transactionRef', json: false);
      if (response.body.isEmpty) return [];

      final List<dynamic> data = jsonDecode(response.body);
      final entries = data.map((json) => BulkWeightEntry.fromJson(json)).toList();

      entries.forEach(localService.saveEntry);
      return entries;
    } catch (e, stackTrace) {
      HttpErrorHandler.handleJsonDecodingError('decode bulkweight entries', e);
      AppLogger.logError('❌ Error fetching bulkweight entries: $e', e, stackTrace);
    }

    return localService.getAllEntries();
  }

  /// Delete BulkWeightEntry
  Future<void> deleteEntry(WidgetRef ref, String id) async {
    localService.deleteEntry(id);
    try {
      await apiDelete(ref, '/bulkweights/entries/$id');
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to delete BulkWeightEntry: $e', e, stackTrace);
    }
  }

  /// Delete BulkWeight
  Future<void> deleteBulkWeight(WidgetRef ref, String id) async {
    localService.deleteBulkWeight(id);
    try {
      await apiDelete(ref, '/bulkweights/bulkweight/$id');
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to delete BulkWeight: $e', e, stackTrace);
    }
  }

  /// Update BulkWeightEntry
  Future<void> updateEntry(WidgetRef ref, BulkWeightEntry entry) async {
    try {
      await apiPut(ref, '/bulkweights/entries/${entry.id}', entry.toJson());
      localService.saveEntry(entry);
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to update BulkWeightEntry: $e', e, stackTrace);
    }
  }
}
