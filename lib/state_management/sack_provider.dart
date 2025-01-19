import 'package:agriproduce/data_models/sack_model.dart';
import 'package:agriproduce/services/sack_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sackServiceProvider = Provider<SackService>((ref) => SackService());

final sackRecordsProvider = StateNotifierProvider<SackRecordsNotifier, List<SackRecord>>((ref) {
  return SackRecordsNotifier(ref.watch(sackServiceProvider));
});

class SackRecordsNotifier extends StateNotifier<List<SackRecord>> {
  final SackService sackService;

  SackRecordsNotifier(this.sackService) : super([]);

  Future<void> fetchSacks(WidgetRef ref) async {
    try {
      final sacks = await sackService.getSacks(ref);
      state = sacks;
    } catch (e) {
      throw Exception('Failed to fetch sacks: $e');
    }
  }

  void addSack(SackRecord sack) {
    state = [...state, sack];
  }

  void updateSack(SackRecord updatedSack) {
    state = [
      for (final sack in state)
        if (sack.id == updatedSack.id) updatedSack else sack
    ];
  }

  void deleteSack(String id) {
    state = state.where((sack) => sack.id != id).toList();
  }
}
