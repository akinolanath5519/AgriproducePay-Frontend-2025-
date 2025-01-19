import 'dart:convert';
import 'package:agriproduce/constant/appLogger.dart';
import 'package:agriproduce/constant/httpError.dart';
import 'package:agriproduce/data_models/supplier_model.dart';
import 'package:agriproduce/state_management/token_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:agriproduce/constant/config.dart';

class LocalSupplierService {
  // Save a supplier
  void saveSupplier(Supplier supplier) {
    AppLogger.logInfo('Supplier saved locally: ${supplier.toJson()}');
  }

  // Retrieve all suppliers
  List<Supplier> getAllSuppliers() {
    AppLogger.logInfo('No suppliers found in local storage.');
    return []; // Placeholder for local data retrieval
  }

  // Check if data is cached
  bool isDataCached() {
    return false; // Placeholder, adjust based on your local data storage
  }

  // Delete a supplier
  void deleteSupplier(String id) {
    AppLogger.logInfo('Supplier deleted locally with id: $id');
  }
}

class SupplierService {
  final LocalSupplierService localService = LocalSupplierService();

  // Method to create a supplier
  Future<void> createSupplier(WidgetRef ref, Supplier supplier) async {
    // Save locally first
    localService.saveSupplier(supplier);
    AppLogger.logInfo(
        'Attempting to save supplier remotely: ${supplier.toJson()}');

    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, user not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/supplier'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(supplier.toJson()),
      );

      HttpErrorHandler.handleResponse(response, 'save supplier remotely');
    } catch (e) {
      AppLogger.logError('Error saving supplier remotely: $e');
    }
  }

  // Method to get all suppliers
  Future<List<Supplier>> getSuppliers(WidgetRef ref) async {
    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, cannot fetch suppliers');
      throw Exception('User not authenticated');
    }

    if (localService.isDataCached()) {
      AppLogger.logInfo('Data loaded from cache');
      return localService.getAllSuppliers();
    } else {
      AppLogger.logInfo('Cache is empty, fetching from server...');
    }

    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/supplier'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      AppLogger.logInfo('Response status code: ${response.statusCode}');
      AppLogger.logInfo('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          AppLogger.logInfo('Received empty response body from server');
          return []; // Return an empty list if the response body is empty
        }

        try {
          final List<dynamic> supplierList = jsonDecode(response.body);
          List<Supplier> suppliers = supplierList
              .map<Supplier>((json) => Supplier.fromJson(json))
              .toList();
          AppLogger.logInfo(
              'Fetched suppliers from server: ${suppliers.length}');

          for (var supplier in suppliers) {
            localService.saveSupplier(supplier);
          }
          AppLogger.logInfo('Suppliers saved to cache');

          return suppliers;
        } catch (e) {
          HttpErrorHandler.handleJsonDecodingError('fetch suppliers', e);
        }
      } else {
        HttpErrorHandler.handleResponse(
            response, 'fetch suppliers from server');
      }
    } catch (e) {
      AppLogger.logError('Error fetching suppliers from server: $e');
      AppLogger.logInfo('Returning cached suppliers due to server error');
    }

    return localService
        .getAllSuppliers(); // Return locally stored data if remote fetch fails
  }

  // Method to update a supplier
  Future<void> updateSupplier(
      WidgetRef ref, String supplierId, Supplier supplier) async {
    localService.saveSupplier(supplier);
    AppLogger.logInfo(
        'Attempting to update supplier remotely with id: $supplierId - ${supplier.toJson()}');

    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, user not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.put(
        Uri.parse('${Config.baseUrl}/supplier/$supplierId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(supplier.toJson()),
      );

      HttpErrorHandler.handleResponse(response, 'update supplier remotely');
    } catch (e) {
      AppLogger.logError('Error updating supplier remotely: $e');
    }
  }

  // Method to delete a supplier
  Future<void> deleteSupplier(WidgetRef ref, String supplierId) async {
    localService.deleteSupplier(supplierId);
    AppLogger.logInfo(
        'Attempting to delete supplier remotely with id: $supplierId');

    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, user not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/supplier/$supplierId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      HttpErrorHandler.handleResponse(response, 'delete supplier remotely');
    } catch (e) {
      AppLogger.logError('Error deleting supplier remotely: $e');
    }
  }
}
