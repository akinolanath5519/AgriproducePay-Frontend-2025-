import 'package:agriproduce/data_models/commodity_model.dart';
import 'package:agriproduce/services/commodity_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commodityServiceProvider = Provider<CommodityService>((ref) {
  final service = CommodityService();
  return service;
});

class CommodityNotifier extends StateNotifier<List<Commodity>> {
  final CommodityService _commodityService;
  CommodityNotifier(this._commodityService) : super([]);

  // Fetch commodities
  Future<void> fetchCommodities(WidgetRef ref) async {
    try {
      final fetchedCommodities = await _commodityService.getCommodities(ref);
      state = fetchedCommodities;
    } catch (error) {
      print('Error fetching commodities: $error');
      rethrow;
    }
  }

  // Create a new commodity
  Future<void> createCommodity(WidgetRef ref, Commodity commodity) async {
    await _commodityService.createCommodity(ref, commodity);
    addCommodity(commodity); // Add commodity to the state immediately
  }

  // Update an existing commodity
  Future<void> updateCommodity(WidgetRef ref, String id, Commodity commodity) async {
    await _commodityService.updateCommodity(ref, id, commodity);
    updateCommodityInState(id, commodity); // Update commodity in state immediately
  }

  // Delete a commodity
  Future<void> deleteCommodity(WidgetRef ref, String id) async {
    await _commodityService.deleteCommodity(ref, id);
    deleteCommodityInState(id); // Remove commodity from state immediately
  }

  // State modification helpers
  void addCommodity(Commodity commodity) {
    state = [...state, commodity];
  }

  void updateCommodityInState(String id, Commodity updatedCommodity) {
    state = [
      for (final commodity in state)
        if (commodity.id == id) updatedCommodity else commodity
    ];
  }

  void deleteCommodityInState(String id) {
    state = state.where((commodity) => commodity.id != id).toList();
  }
}

final commodityNotifierProvider =
    StateNotifierProvider<CommodityNotifier, List<Commodity>>((ref) {
  final commodityService = ref.watch(commodityServiceProvider);
  return CommodityNotifier(commodityService);
});
