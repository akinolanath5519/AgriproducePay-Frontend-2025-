import 'package:agriproduce/data_models/companyInfo.dart';
import 'package:agriproduce/services/companyInfo_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Create a provider for the CompanyInfoService
final companyInfoProvider = Provider<CompanyInfoService>((ref) {
  return CompanyInfoService();
});

// Create a StateNotifier to manage the state of company information
class CompanyInfoNotifier extends StateNotifier<List<CompanyInfo>> {
  final CompanyInfoService _companyInfoService;

  CompanyInfoNotifier(this._companyInfoService) : super([]);

  // Fetch company information
  Future<void> fetchCompanyInfos(WidgetRef ref) async {
    try {
      final fetchedCompanyInfos =
          await _companyInfoService.getCompanyInfos(ref);
      state =
          fetchedCompanyInfos; // Update state with fetched company information
    } catch (error) {
      print('Error fetching company information: $error');
      rethrow; // Handle the error appropriately
    }
  }

  // Create new company information
  Future<void> createCompanyInfo(WidgetRef ref, CompanyInfo companyInfo) async {
    await _companyInfoService.createCompanyInfo(ref, companyInfo);
    await fetchCompanyInfos(ref); // Refresh the list after creating
  }

  // Update existing company information
  Future<void> updateCompanyInfo(
      WidgetRef ref, String companyId, CompanyInfo companyInfo) async {
    await _companyInfoService.updateCompanyInfo(ref, companyId, companyInfo);
    await fetchCompanyInfos(ref); // Refresh the list after updating
  }

  // Delete company information
  Future<void> deleteCompanyInfo(WidgetRef ref, String companyId) async {
    await _companyInfoService.deleteCompanyInfo(ref, companyId);
    await fetchCompanyInfos(ref); // Refresh the list after deletion
  }
}

// Create a provider for the CompanyInfoNotifier
final companyInfoNotifierProvider =
    StateNotifierProvider<CompanyInfoNotifier, List<CompanyInfo>>((ref) {
  final companyInfoService = ref.watch(companyInfoProvider);
  return CompanyInfoNotifier(companyInfoService);
});
