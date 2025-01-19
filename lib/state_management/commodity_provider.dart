import 'package:agriproduce/data_models/commodity_model.dart';
import 'package:agriproduce/services/commodity_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommodityNotifier extends StateNotifier<List<Commodity>> {
  final CommodityService _commodityService;
  
  CommodityNotifier(this._commodityService) : super([]);

  // Fetch commodities
  Future<void> fetchCommodities(WidgetRef ref) async {
    try {
      final fetchedCommodities = await _commodityService.getCommodities(ref);
      state = fetchedCommodities; // Update state with fetched commodities
    } catch (error) {
      print('Error fetching commodities: $error');
      rethrow; // Handle the error appropriately
    }
  }

  // Create a new commodity
  Future<void> createCommodity(WidgetRef ref, Commodity commodity) async {
    await _commodityService.createCommodity(ref, commodity);
    await fetchCommodities(ref); // Refresh the list after creating
  }

  // Update an existing commodity
  Future<void> updateCommodity(WidgetRef ref, String commodityId, Commodity commodity) async {
    await _commodityService.updateCommodity(ref, commodityId, commodity);
    await fetchCommodities(ref); // Refresh the list after updating
  }

  // Delete a commodity
  Future<void> deleteCommodity(WidgetRef ref, String commodityId) async {
    await _commodityService.deleteCommodity(ref, commodityId);
    await fetchCommodities(ref); // Refresh the list after deletion
  }
}


// Create a provider for the CommodityService
final commodityProvider = Provider<CommodityService>((ref) {
  return CommodityService();
});

// Create a provider for the CommodityNotifier
final commodityNotifierProvider = StateNotifierProvider<CommodityNotifier, List<Commodity>>((ref) {
  final commodityService = ref.watch(commodityProvider);
  return CommodityNotifier(commodityService);
});
