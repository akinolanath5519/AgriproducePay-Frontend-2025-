import 'package:agriproduce/services/subscription_plan_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/data_models/subscription_plan_model.dart';

/// ----------------- StateNotifier -----------------
class SubscriptionPlanNotifier extends StateNotifier<List<SubscriptionPlan>> {
  final SubscriptionPlanService _service;

  SubscriptionPlanNotifier(this._service) : super([]);

  Future<void> fetchPlans(WidgetRef ref) async {
    state = await _service.getPlans(ref);
  }

Future<void>checkActiveSubscription(WidgetRef ref) async {
   await _service.checkActiveSubscription(ref);
  }

  Future<void> payForPlan(WidgetRef ref, SubscriptionPlan plan) async {
    await _service.initializePayment(ref, plan);
  }


  Future<void> createPlan(WidgetRef ref, SubscriptionPlan plan) async {
    await _service.createPlan(ref, plan);
    await fetchPlans(ref);
  }

  Future<void> updatePlan(WidgetRef ref, String id, SubscriptionPlan plan) async {
    await _service.updatePlan(ref, id, plan);
    await fetchPlans(ref);
  }

  Future<void> deletePlan(WidgetRef ref, String id) async {
    await _service.deletePlan(ref, id);
    await fetchPlans(ref);
  }
}

/// ----------------- Providers -----------------
final subscriptionPlanServiceProvider =
    Provider<SubscriptionPlanService>((ref) => SubscriptionPlanService());

final subscriptionPlanNotifierProvider =
    StateNotifierProvider.autoDispose<SubscriptionPlanNotifier, List<SubscriptionPlan>>(
  (ref) {
    final service = ref.watch(subscriptionPlanServiceProvider);
    return SubscriptionPlanNotifier(service);
  },
);