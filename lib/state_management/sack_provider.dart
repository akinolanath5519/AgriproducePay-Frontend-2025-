import 'package:agriproduce/data_models/sack_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/services/sack_service.dart';

/// ---------------- Sack Collection Notifier ----------------
class SackCollectionNotifier extends StateNotifier<List<SackCollection>> {
  final SackService _sackService;

  SackCollectionNotifier(this._sackService) : super([]);

  // Fetch all collections
  Future<void> fetchSackCollections(WidgetRef ref) async {
    try {
      final fetchedCollections = await _sackService.getSackCollections(ref);
      state = fetchedCollections;
    } catch (error) {
      print('❌ Error fetching sack collections: $error');
      rethrow;
    }
  }

  // Create a new collection
  Future<void> createSackCollection(WidgetRef ref, SackCollection collection) async {
    await _sackService.createSackCollection(ref, collection);
    await fetchSackCollections(ref);
  }
}

/// ---------------- Sack Return Notifier ----------------
class SackReturnNotifier extends StateNotifier<List<SackReturn>> {
  final SackService _sackService;

  SackReturnNotifier(this._sackService) : super([]);

  // Fetch all returns
  Future<void> fetchSackReturns(WidgetRef ref) async {
    try {
      final fetchedReturns = await _sackService.getSackReturns(ref);
      state = fetchedReturns;
    } catch (error) {
      print('❌ Error fetching sack returns: $error');
      rethrow;
    }
  }

  // Create a new return
  Future<void> createSackReturn(WidgetRef ref, SackReturn sackReturn) async {
    await _sackService.createSackReturn(ref, sackReturn);
    await fetchSackReturns(ref);
  }
}

/// ---------------- Providers ----------------

// Sack service provider
final sackServiceProvider = Provider<SackService>((ref) {
  return SackService();
});

// SackCollection state notifier provider
final sackCollectionNotifierProvider =
    StateNotifierProvider<SackCollectionNotifier, List<SackCollection>>((ref) {
  final service = ref.watch(sackServiceProvider);
  return SackCollectionNotifier(service);
});

// SackReturn state notifier provider
final sackReturnNotifierProvider =
    StateNotifierProvider<SackReturnNotifier, List<SackReturn>>((ref) {
  final service = ref.watch(sackServiceProvider);
  return SackReturnNotifier(service);
});
