import 'dart:convert';
import 'package:agriproduce/constant/appLogger.dart';
import 'package:agriproduce/constant/httpError.dart';
import 'package:agriproduce/data_models/companyInfo.dart';
import 'package:agriproduce/state_management/token_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:agriproduce/constant/config.dart';
import 'package:get_storage/get_storage.dart';

class LocalCompanyInfoService {
  final box = GetStorage();

  // Save company info
  void saveCompanyInfo(CompanyInfo companyInfo) {
    box.write(companyInfo.id, companyInfo.toJson());
    AppLogger.logInfo('CompanyInfo saved locally: ${companyInfo.toJson()}');
  }

  // Retrieve all company infos
  List<CompanyInfo> getAllCompanyInfos() {
    final storedData = box.getValues().toList();
    if (storedData.isEmpty) {
      AppLogger.logInfo('No company info found in local storage.');
    }
    return storedData.map((data) {
      return CompanyInfo.fromJson(Map<String, dynamic>.from(data));
    }).toList();
  }

  // Delete company info
  void deleteCompanyInfo(String id) {
    box.remove(id);
    AppLogger.logInfo('CompanyInfo deleted locally with id: $id');
  }
}

class CompanyInfoService {
  final LocalCompanyInfoService localService = LocalCompanyInfoService();

  // Create company info
  Future<void> createCompanyInfo(WidgetRef ref, CompanyInfo companyInfo) async {
    localService.saveCompanyInfo(companyInfo);
    AppLogger.logInfo(
        'Attempting to save company info remotely: ${companyInfo.toJson()}');

    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, user not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/company'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(companyInfo.toJson()),
      );

      HttpErrorHandler.handleResponse(response, 'create company info');
    } catch (e, stackTrace) {
      AppLogger.logError(
          'Error saving company info remotely: $e', e, stackTrace);
    }
  }

  // Get all company infos
  Future<List<CompanyInfo>> getCompanyInfos(WidgetRef ref) async {
    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, cannot fetch company infos');
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/company'),
        headers: {'Authorization': 'Bearer $token'},
      );

      HttpErrorHandler.handleResponse(response, 'fetch company infos');

      if (response.body.isEmpty) {
        return [];
      }

      try {
        final List<dynamic> companyInfoList = jsonDecode(response.body);
        List<CompanyInfo> companyInfos = companyInfoList
            .map<CompanyInfo>((json) => CompanyInfo.fromJson(json))
            .toList();

        for (var companyInfo in companyInfos) {
          localService.saveCompanyInfo(companyInfo);
        }

        return companyInfos;
      } catch (e, stackTrace) {
        HttpErrorHandler.handleJsonDecodingError(
            'decode company infos', e);
        AppLogger.logError(
            'Error decoding JSON for company infos', e, stackTrace);
      }
    } catch (e, stackTrace) {
      AppLogger.logError(
          'Error fetching company infos from server: $e', e, stackTrace);
    }

    return localService.getAllCompanyInfos();
  }

  // Update company info
  Future<void> updateCompanyInfo(
      WidgetRef ref, String companyId, CompanyInfo companyInfo) async {
    localService.saveCompanyInfo(companyInfo);
    AppLogger.logInfo(
        'Attempting to update company info remotely with id: $companyId');

    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, user not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.put(
        Uri.parse('${Config.baseUrl}/company/$companyId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(companyInfo.toJson()),
      );

      HttpErrorHandler.handleResponse(response, 'update company info');
    } catch (e, stackTrace) {
      AppLogger.logError(
          'Error updating company info remotely: $e', e, stackTrace);
    }
  }

  // Delete company info
  Future<void> deleteCompanyInfo(WidgetRef ref, String companyId) async {
    localService.deleteCompanyInfo(companyId);
    AppLogger.logInfo(
        'Attempting to delete company info remotely with id: $companyId');

    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, user not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/company/$companyId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      HttpErrorHandler.handleResponse(response, 'delete company info');
    } catch (e, stackTrace) {
      AppLogger.logError(
          'Error deleting company info remotely: $e', e, stackTrace);
    }
  }
}
