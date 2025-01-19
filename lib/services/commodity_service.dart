import 'dart:convert';
import 'package:agriproduce/constant/appLogger.dart';
import 'package:agriproduce/constant/httpError.dart';
import 'package:agriproduce/data_models/commodity_model.dart';
import 'package:agriproduce/state_management/token_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:agriproduce/constant/config.dart';

class LocalCommodityService {
  // Save a commodity
  void saveCommodity(Commodity commodity) {
    AppLogger.logInfo('Commodity saved locally: ${commodity.toJson()}');
  }

  // Retrieve all commodities
  List<Commodity> getAllCommodities() {
    return [];
  }

  // Check if data is cached
  bool isDataCached() {
    return false;
  }

  // Delete a commodity
  void deleteCommodity(String id) {
    AppLogger.logInfo('Commodity deleted locally with id: $id');
  }
}

class CommodityService {
  final LocalCommodityService localService = LocalCommodityService();

  // Create commodity
  Future<void> createCommodity(WidgetRef ref, Commodity commodity) async {
    localService.saveCommodity(commodity);
    AppLogger.logInfo(
        'Attempting to save commodity remotely: ${commodity.toJson()}');

    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, user not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/commodity'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(commodity.toJson()),
      );

      HttpErrorHandler.handleResponse(response, 'create commodity');
    } catch (e, stackTrace) {
      AppLogger.logError('Error saving commodity remotely: $e', e, stackTrace);
    }
  }

  // Get all commodities
  Future<List<Commodity>> getCommodities(WidgetRef ref) async {
    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, cannot fetch commodities');
      throw Exception('User not authenticated');
    }

    if (localService.isDataCached()) {
      return localService.getAllCommodities();
    }

    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/commodity'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      HttpErrorHandler.handleResponse(response, 'fetch commodities');

      if (response.body.isEmpty) {
        return [];
      }

      try {
        final List<dynamic> commodityList = jsonDecode(response.body);
        List<Commodity> commodities = commodityList
            .map<Commodity>((json) => Commodity.fromJson(json))
            .toList();

        for (var commodity in commodities) {
          localService.saveCommodity(commodity);
        }

        return commodities;
      } catch (e, stackTrace) {
        HttpErrorHandler.handleJsonDecodingError('decode commodities', e);
        AppLogger.logError(
            'Error decoding JSON for commodities', e, stackTrace);
      }
    } catch (e, stackTrace) {
      AppLogger.logError(
          'Error fetching commodities from server: $e', e, stackTrace);
    }

    return localService.getAllCommodities();
  }

  // Update commodity
  Future<void> updateCommodity(
      WidgetRef ref, String commodityId, Commodity commodity) async {
    localService.saveCommodity(commodity);
    AppLogger.logInfo(
        'Attempting to update commodity remotely with id: $commodityId');

    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, user not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.put(
        Uri.parse('${Config.baseUrl}/commodity/$commodityId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(commodity.toJson()),
      );

      HttpErrorHandler.handleResponse(response, 'update commodity');
    } catch (e, stackTrace) {
      AppLogger.logError(
          'Error updating commodity remotely: $e', e, stackTrace);
    }
  }

  // Delete commodity
  Future<void> deleteCommodity(WidgetRef ref, String commodityId) async {
    localService.deleteCommodity(commodityId);
    AppLogger.logInfo(
        'Attempting to delete commodity remotely with id: $commodityId');

    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, user not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/commodity/$commodityId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      HttpErrorHandler.handleResponse(response, 'delete commodity');
    } catch (e, stackTrace) {
      AppLogger.logError(
          'Error deleting commodity remotely: $e', e, stackTrace);
    }
  }
}
