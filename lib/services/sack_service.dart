import 'dart:convert';
import 'package:agriproduce/data_models/sack_model.dart';
import 'package:agriproduce/state_management/token_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:agriproduce/constant/config.dart';
import 'package:agriproduce/constant/appLogger.dart';
import 'package:agriproduce/constant/httpError.dart';
import 'package:get_storage/get_storage.dart';

class LocalSackService {
  final box = GetStorage();

  // Save a sack
  void saveSack(SackRecord sack) {
    box.write(sack.id, sack.toJson());
    AppLogger.logInfo('Sack saved locally: ${sack.toJson()}');
  }

  // Retrieve all sacks
  List<SackRecord> getAllSacks() {
    final storedData = box.getValues().toList();
    if (storedData.isEmpty) {
      AppLogger.logInfo('No sacks found in local storage.');
    }
    return storedData.map((data) {
      return SackRecord.fromJson(Map<String, dynamic>.from(data));
    }).toList();
  }

  // Delete a sack
  void deleteSack(String id) {
    box.remove(id);
    AppLogger.logInfo('Sack deleted locally with id: $id');
  }
}

class SackService {
  final LocalSackService localService = LocalSackService();

  // Method to create a sack
  Future<void> createSack(WidgetRef ref, SackRecord sack) async {
    // Save locally first
    localService.saveSack(sack);
    AppLogger.logInfo('Attempting to save sack remotely: ${sack.toJson()}');

    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, user not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/sack'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(sack.toJson()),
      );

      if (response.statusCode != 201) {
        HttpErrorHandler.handleResponse(response, 'save sack remotely');
        throw Exception('Failed to create sack: ${response.body}');
      }

      AppLogger.logInfo('Sack created successfully remotely: ${response.body}');
    } catch (e) {
      AppLogger.logError('Error saving sack remotely: $e');
    }
  }

  // Method to get all sacks
  Future<List<SackRecord>> getSacks(WidgetRef ref) async {
    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, cannot fetch sacks');
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/sack'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> sackList = jsonDecode(response.body);
        AppLogger.logInfo('Fetched sacks successfully: $sackList');
        return sackList
            .map<SackRecord>((json) => SackRecord.fromJson(json))
            .toList();
      } else {
        HttpErrorHandler.handleResponse(response, 'fetch sacks from server');
        throw Exception('Failed to load sacks: ${response.body}');
      }
    } catch (e) {
      AppLogger.logError('Error fetching sacks from server: $e');
    }

    // Return locally stored data if remote fetch fails
    return localService.getAllSacks();
  }

  // Method to update a sack
  Future<void> updateSack(WidgetRef ref, String sackId, SackRecord sack) async {
    // Save locally first
    localService.saveSack(sack);
    AppLogger.logInfo(
        'Attempting to update sack remotely with id: $sackId - ${sack.toJson()}');

    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, user not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.put(
        Uri.parse('${Config.baseUrl}/sack/$sackId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(sack.toJson()),
      );

      if (response.statusCode != 200) {
        HttpErrorHandler.handleResponse(response, 'update sack remotely');
        throw Exception('Failed to update sack: ${response.body}');
      }

      AppLogger.logInfo('Sack updated successfully remotely: ${response.body}');
    } catch (e) {
      AppLogger.logError('Error updating sack remotely: $e');
    }
  }

  // Method to delete a sack
  Future<void> deleteSack(WidgetRef ref, String sackId) async {
    // Always remove from local storage first
    localService.deleteSack(sackId);
    AppLogger.logInfo('Attempting to delete sack remotely with id: $sackId');

    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, user not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/sack/$sackId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        HttpErrorHandler.handleResponse(response, 'delete sack remotely');
        throw Exception('Failed to delete sack: ${response.body}');
      }

      AppLogger.logInfo('Sack deleted successfully remotely: ${response.body}');
    } catch (e) {
      AppLogger.logError('Error deleting sack remotely: $e');
    }
  }
}
