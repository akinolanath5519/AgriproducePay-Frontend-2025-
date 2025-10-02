import 'dart:convert';
import 'package:agriproduce/constant/appLogger.dart';
import 'package:agriproduce/constant/httpError.dart';
import 'package:agriproduce/data_models/companyInfo.dart';
import 'package:agriproduce/utilis/api_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ---------------- LOCAL COMPANY INFO CACHE ----------------
class LocalCompanyInfoService {
  void saveCompanyInfo(CompanyInfo companyInfo) =>
      AppLogger.logInfo('💾 Saved locally: ${companyInfo.toJson()}');

  List<CompanyInfo> getAllCompanyInfos() {
    AppLogger.logInfo('📦 Returning cached company infos (currently empty)');
    return [];
  }

  bool isDataCached() => false;

  void deleteCompanyInfo(String id) =>
      AppLogger.logInfo('🗑 Deleted locally: $id');
}

/// ---------------- REMOTE COMPANY INFO SERVICE ----------------
class CompanyInfoService {
  final LocalCompanyInfoService localService = LocalCompanyInfoService();

  /// Create company info
  Future<void> createCompanyInfo(WidgetRef ref, CompanyInfo companyInfo) async {
    localService.saveCompanyInfo(companyInfo);
    try {
      await apiPost(ref, '/companyinfo/company', companyInfo.toJson());
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to create company info: $e', e, stackTrace);
    }
  }

  /// Get all company infos
  Future<List<CompanyInfo>> getCompanyInfos(WidgetRef ref) async {
    if (localService.isDataCached()) {
      AppLogger.logInfo('📦 Loaded company infos from cache');
      return localService.getAllCompanyInfos();
    }

    try {
      final response =
          await apiGet(ref, '/companyinfo/company', json: false);
      if (response.body.isEmpty) return [];

      final List<dynamic> companyInfoList = jsonDecode(response.body);
      final companyInfos =
          companyInfoList.map((json) => CompanyInfo.fromJson(json)).toList();

      companyInfos.forEach(localService.saveCompanyInfo);
      return companyInfos;
    } catch (e, stackTrace) {
      HttpErrorHandler.handleJsonDecodingError('decode company infos', e);
      AppLogger.logError('❌ Error fetching company infos: $e', e, stackTrace);
    }

    return localService.getAllCompanyInfos();
  }

  /// Update company info
  Future<void> updateCompanyInfo(
      WidgetRef ref, String id, CompanyInfo companyInfo) async {
    localService.saveCompanyInfo(companyInfo);
    try {
      await apiPut(ref, '/companyinfo/company/$id', companyInfo.toJson());
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to update company info: $e', e, stackTrace);
    }
  }

  /// Delete company info
  Future<void> deleteCompanyInfo(WidgetRef ref, String id) async {
    localService.deleteCompanyInfo(id);
    try {
      await apiDelete(ref, '/companyinfo/company/$id');
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to delete company info: $e', e, stackTrace);
    }
  }
}
