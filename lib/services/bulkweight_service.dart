import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agriproduce/data_models/bulkweight_model.dart';
import 'package:agriproduce/constant/config.dart';
import 'package:agriproduce/constant/appLogger.dart';
import 'package:agriproduce/constant/httpError.dart';
import 'package:agriproduce/state_management/token_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocalBulkWeightService {
  // Save a bulk weight entry locally
  void saveBulkWeight(BulkWeight bulkWeight) {
    AppLogger.logInfo('BulkWeight saved locally: ${bulkWeight.toJson()}');
  }

  // Retrieve all bulk weight entries
  List<BulkWeight> getAllBulkWeights() {
    return [];
  }

  // Check if data is cached
  bool isDataCached() {
    return false;
  }

  // Delete a bulk weight entry
  void deleteBulkWeight(String id) {
    AppLogger.logInfo('BulkWeight deleted locally with id: $id');
  }
}

class BulkWeightService {
  final LocalBulkWeightService localService = LocalBulkWeightService();

  // Create bulk weight entry
  Future<void> createBulkWeight(WidgetRef ref, List<BulkWeight> bulkWeights) async {
    for (var bulkWeight in bulkWeights) {
      localService.saveBulkWeight(bulkWeight);
    }

    AppLogger.logInfo('Attempting to save bulk weight entries remotely.');

    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, user not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/bulkweight'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'entries': bulkWeights.map((entry) => entry.toJson()).toList(),
        }),
      );

      HttpErrorHandler.handleResponse(response, 'create bulk weight entries');
    } catch (e, stackTrace) {
      AppLogger.logError('Error saving bulk weight entries remotely: $e', e, stackTrace);
    }
  }

  // Get all bulk weight entries
  Future<List<BulkWeight>> getBulkWeights(WidgetRef ref) async {
    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, cannot fetch bulk weight entries');
      throw Exception('User not authenticated');
    }

    // Return cached data if available
    if (localService.isDataCached()) {
      return localService.getAllBulkWeights();
    }

    try {
      // Send the HTTP request
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/bulkweight'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      // Handle the HTTP response
      HttpErrorHandler.handleResponse(response, 'fetch bulk weight entries');

      // If the response body is empty, return an empty list
      if (response.body.isEmpty) {
        AppLogger.logInfo('Response body is empty, returning empty list.');
        return [];
      }

      // Log the raw response body for debugging
      AppLogger.logInfo('Raw response body: ${response.body}');

      try {
        // Decode the response body into a dynamic object
        final dynamic decodedResponse = jsonDecode(response.body);

        // Check if the response is a Map<String, dynamic> (expected structure)
        if (decodedResponse is Map<String, dynamic>) {
          final Map<String, dynamic> transactions = decodedResponse['transactions'];
          List<BulkWeight> bulkWeights = [];

          // Process each entry in the response
          transactions.forEach((transactionId, entries) {
            // Log the type of entries and the transactionId
            AppLogger.logInfo('Processing transactionId: $transactionId');

            // Ensure entries is a List, and log if it's not
            if (entries is List) {
              for (var entry in entries) {
                try {
                  final bulkWeight = BulkWeight.fromJson(entry);
                  bulkWeights.add(bulkWeight);
                  localService.saveBulkWeight(bulkWeight);
                } catch (e, stackTrace) {
                  AppLogger.logError('Error decoding entry for transaction $transactionId', e, stackTrace);
                }
              }
            } else {
              // Handle cases where entries are not a list
              AppLogger.logError('Entries for transaction $transactionId are not in the expected list format. Received: $entries');

              // Optionally, handle the case where entries might be a Map
              if (entries is Map) {
                AppLogger.logError('Received Map for transaction $transactionId. Data: $entries');
                // You can decide how to handle it here, e.g., converting Map to List, or skipping it
              } else {
                AppLogger.logError('Unexpected data type for entries: ${entries.runtimeType}');
              }
            }
          });

          return bulkWeights;
        } else {
          // If the decoded response is not a Map<String, dynamic>, log the error
          AppLogger.logError('Decoded response is not a Map<String, dynamic>. Response: $decodedResponse');
          throw Exception('Invalid data format from server');
        }
      } catch (e, stackTrace) {
        // Handle JSON decoding error
        HttpErrorHandler.handleJsonDecodingError('decode bulk weight entries', e);
        AppLogger.logError('Error decoding JSON for bulk weight entries', e, stackTrace);
        throw Exception('Failed to decode data for bulk weight entries');
      }
    } catch (e, stackTrace) {
      // Handle network or server errors
      AppLogger.logError('Error fetching bulk weight entries from server: $e', e, stackTrace);
      throw Exception('Failed to fetch bulk weight entries from server');
    }
  }

  // Update bulk weight entry
    
  Future<void> updateBulkWeight(WidgetRef ref, String entryId, BulkWeight bulkWeight) async {
    localService.saveBulkWeight(bulkWeight);
    AppLogger.logInfo('Attempting to update bulk weight remotely with id: $entryId');
  
    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, user not authenticated');
      throw Exception('User not authenticated');
    }
  
    try {
      final response = await http.put(
        Uri.parse('${Config.baseUrl}/bulkweight/$entryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bulkWeight.toJson()),
      );
  
      HttpErrorHandler.handleResponse(response, 'update bulk weight');
    } catch (e, stackTrace) {
      AppLogger.logError('Error updating bulk weight remotely: $e', e, stackTrace);
    }
  }

  // Delete bulk weight entry
  Future<void> deleteBulkWeight(WidgetRef ref, String entryId) async {
    localService.deleteBulkWeight(entryId);
    AppLogger.logInfo('Attempting to delete bulk weight remotely with id: $entryId');

    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, user not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/bulkweight/entry/$entryId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      HttpErrorHandler.handleResponse(response, 'delete bulk weight entry');
    } catch (e, stackTrace) {
      AppLogger.logError('Error deleting bulk weight remotely: $e', e, stackTrace);
    }
  }

  // Delete a complete transaction
    // Delete a complete transaction
  Future<void> deleteTransaction(WidgetRef ref, String transactionId) async {
    AppLogger.logInfo('Attempting to delete transaction remotely with id: $transactionId');
  
    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, user not authenticated');
      throw Exception('User not authenticated');
    }
  
    try {
      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/bulkweight/$transactionId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
  
      HttpErrorHandler.handleResponse(response, 'delete transaction');
    } catch (e, stackTrace) {
      AppLogger.logError('Error deleting transaction remotely: $e', e, stackTrace);
    }
  }

  // Get all transactions
  Future<Map<String, List<BulkWeight>>> getAllTransactions(WidgetRef ref) async {
    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, cannot fetch transactions');
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/bulkweight'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      HttpErrorHandler.handleResponse(response, 'fetch transactions');

      if (response.body.isEmpty) {
        return {};
      }

      try {
        final Map<String, dynamic> transactionMap = jsonDecode(response.body);
        Map<String, List<BulkWeight>> transactions = {};

        transactionMap.forEach((transactionId, entries) {
          transactions[transactionId] = entries
              .map<BulkWeight>((entry) => BulkWeight.fromJson(entry))
              .toList();
        });

        return transactions;
      } catch (e, stackTrace) {
        HttpErrorHandler.handleJsonDecodingError('decode transactions', e);
        AppLogger.logError('Error decoding JSON for transactions', e, stackTrace);
      }
    } catch (e, stackTrace) {
      AppLogger.logError('Error fetching transactions from server: $e', e, stackTrace);
    }

    return {};
  }
}