import 'package:agriproduce/data_models/bulkweight_model.dart';
import 'package:agriproduce/services/bulkweight_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BulkWeightNotifier extends StateNotifier<List<BulkWeight>> {
  final BulkWeightService _bulkWeightService;

  BulkWeightNotifier(this._bulkWeightService) : super([]);

  // Fetch all bulk weights
  Future<void> fetchBulkWeights(WidgetRef ref) async {
    try {
      final fetchedBulkWeights = await _bulkWeightService.getBulkWeights(ref);
      state = fetchedBulkWeights; // Update state with fetched bulk weights
    } catch (error) {
      print('Error fetching bulk weights: $error');
      rethrow; // Handle the error appropriately
    }
  }

  // Create bulk weight entries
  Future<void> createBulkWeight(WidgetRef ref, List<BulkWeight> bulkWeights) async {
    await _bulkWeightService.createBulkWeight(ref, bulkWeights);
    await fetchBulkWeights(ref); // Refresh the list after creation
  }

  // Update an existing bulk weight entry
  Future<void> updateBulkWeight(WidgetRef ref, String entryId, BulkWeight bulkWeight) async {
    await _bulkWeightService.updateBulkWeight(ref, entryId, bulkWeight);
    await fetchBulkWeights(ref); // Refresh the list after updating
  }

  // Delete a bulk weight entry
  Future<void> deleteBulkWeight(WidgetRef ref, String entryId) async {
    await _bulkWeightService.deleteBulkWeight(ref, entryId);
    await fetchBulkWeights(ref); // Refresh the list after deletion
  }

  // Delete a complete transaction
  Future<void> deleteTransaction(WidgetRef ref, String transactionId) async {
    await _bulkWeightService.deleteTransaction(ref, transactionId);
    await fetchBulkWeights(ref); // Refresh the list after deletion
  }
}

// Create a provider for the BulkWeightService
final bulkWeightServiceProvider = Provider<BulkWeightService>((ref) {
  return BulkWeightService();
});

// Create a provider for the BulkWeightNotifier
final bulkWeightNotifierProvider =
    StateNotifierProvider<BulkWeightNotifier, List<BulkWeight>>((ref) {
  final bulkWeightService = ref.watch(bulkWeightServiceProvider);
  return BulkWeightNotifier(bulkWeightService);
});