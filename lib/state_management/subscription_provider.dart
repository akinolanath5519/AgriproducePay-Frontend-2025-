import 'package:agriproduce/data_models/subscription_model.dart';
import 'package:agriproduce/services/subscription_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionNotifier extends StateNotifier<AsyncValue<List<Subscription>>> {
  final SubscriptionService _subscriptionService;

  SubscriptionNotifier(this._subscriptionService) : super(const AsyncValue.loading());

  // Fetch subscriptions
  Future<void> fetchSubscriptions(WidgetRef ref) async {
    try {
      final fetchedSubscriptions = await _subscriptionService.checkSubscriptionStatus(ref);
      state = AsyncValue.data([Subscription.fromJson(fetchedSubscriptions)]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      print('Error fetching subscriptions: $error');
    }
  }

  // Renew a subscription
  Future<void> renewSubscription(WidgetRef ref, String adminEmail, int duration) async {
    await _subscriptionService.renewSubscription(adminEmail, duration, ref);
    await fetchSubscriptions(ref); // Refresh the list after renewing
  }

  // Delete a subscription
  Future<void> deleteSubscription(WidgetRef ref) async {
    _subscriptionService.localSubscriptionService.deleteSubscription();
    state = const AsyncValue.data([]); // Clear the list after deletion
  }
}

// Create a provider for the SubscriptionService
final subscriptionProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

// Create a provider for the SubscriptionNotifier
final subscriptionNotifierProvider = StateNotifierProvider<SubscriptionNotifier, AsyncValue<List<Subscription>>>((ref) {
  final subscriptionService = ref.watch(subscriptionProvider);
  return SubscriptionNotifier(subscriptionService);
});
