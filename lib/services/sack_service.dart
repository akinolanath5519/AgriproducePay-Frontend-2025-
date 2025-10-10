import 'dart:convert';
import 'package:agriproduce/constant/appLogger.dart';
import 'package:agriproduce/constant/httpError.dart';
import 'package:agriproduce/data_models/sack_model.dart';
import 'package:agriproduce/utilis/api_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ---------------- LOCAL SACK CACHE ----------------
class LocalSackService {
  final List<SackCollection> _collections = [];
  final List<SackReturn> _returns = [];

  void saveCollection(SackCollection collection) {
    _collections.add(collection);
    AppLogger.logInfo('💾 Saved sack collection locally: ${collection.toJson()}');
  }

  void saveReturn(SackReturn sackReturn) {
    _returns.add(sackReturn);
    AppLogger.logInfo('💾 Saved sack return locally: ${sackReturn.toJson()}');
  }

  List<SackCollection> getAllCollections() => _collections;
  List<SackReturn> getAllReturns() => _returns;

  bool isCollectionCached() => _collections.isNotEmpty;
  bool isReturnCached() => _returns.isNotEmpty;

  void deleteCollection(String id) {
    _collections.removeWhere((c) => c.id == id);
    AppLogger.logInfo('🗑 Deleted local sack collection: $id');
  }

  void deleteReturn(String id) {
    _returns.removeWhere((r) => r.id == id);
    AppLogger.logInfo('🗑 Deleted local sack return: $id');
  }
}

/// ---------------- REMOTE SACK SERVICE ----------------
class SackService {
  final LocalSackService localService = LocalSackService();

  /// Create Sack Collection
  Future<void> createSackCollection(WidgetRef ref, SackCollection collection) async {
    localService.saveCollection(collection);
    try {
      await apiPost(ref, '/sacks/sack/collection', collection.toJson());
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to create sack collection: $e', e, stackTrace);
    }
  }

  /// Create Sack Return
  Future<void> createSackReturn(WidgetRef ref, SackReturn sackReturn) async {
    localService.saveReturn(sackReturn);
    try {
      await apiPost(ref, '/sacks/sack/return', sackReturn.toJson());
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to create sack return: $e', e, stackTrace);
    }
  }

  /// Get all Sack Collections
  Future<List<SackCollection>> getSackCollections(WidgetRef ref) async {
    if (localService.isCollectionCached()) {
      AppLogger.logInfo('📦 Loaded sack collections from cache');
      return localService.getAllCollections();
    }

    try {
      final response = await apiGet(ref, '/sacks/sack/collection', json: false);
      if (response.body.isEmpty) return [];

      final List<dynamic> data = jsonDecode(response.body);
      final collections = data.map((json) => SackCollection.fromJson(json)).toList();

      collections.forEach(localService.saveCollection);
      return collections;
    } catch (e, stackTrace) {
      HttpErrorHandler.handleJsonDecodingError('decode sack collections', e);
      AppLogger.logError('❌ Error fetching sack collections: $e', e, stackTrace);
    }

    return localService.getAllCollections();
  }

  /// Get all Sack Returns
  Future<List<SackReturn>> getSackReturns(WidgetRef ref) async {
    if (localService.isReturnCached()) {
      AppLogger.logInfo('📦 Loaded sack returns from cache');
      return localService.getAllReturns();
    }

    try {
      final response = await apiGet(ref, '/sacks/sack/return', json: false);
      if (response.body.isEmpty) return [];

      final List<dynamic> data = jsonDecode(response.body);
      final returns = data.map((json) => SackReturn.fromJson(json)).toList();

      returns.forEach(localService.saveReturn);
      return returns;
    } catch (e, stackTrace) {
      HttpErrorHandler.handleJsonDecodingError('decode sack returns', e);
      AppLogger.logError('❌ Error fetching sack returns: $e', e, stackTrace);
    }

    return localService.getAllReturns();
  }

  /// Get supplier sack balance
  Future<Object> getSupplierSackBalance(WidgetRef ref, String supplierId) async {
    try {
      final response = await apiGet(ref, '/sacks/sack/balance/$supplierId', json: true);
      return response.body;
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to fetch supplier sack balance: $e', e, stackTrace);
      return {};
    }
  }
}
