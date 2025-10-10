import 'dart:convert';
import 'package:agriproduce/constant/appLogger.dart';
import 'package:agriproduce/constant/httpError.dart';
import 'package:agriproduce/data_models/subscription_plan_model.dart';
import 'package:agriproduce/utilis/api_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// ---------------- LOCAL SUBSCRIPTION PLAN CACHE ----------------
class LocalSubscriptionPlanService {
  final Map<String, SubscriptionPlan> _cache = {};

  void savePlan(SubscriptionPlan plan) {
    _cache[plan.id] = plan;
    AppLogger.logInfo('💾 Saved locally: ${plan.toJson()}');
  }

  List<SubscriptionPlan> getAllPlans() {
    AppLogger.logInfo('📦 Returning cached subscription plans');
    return _cache.values.toList();
  }

  bool isDataCached() => _cache.isNotEmpty;

  void deletePlan(String id) {
    _cache.remove(id);
    AppLogger.logInfo('🗑 Deleted locally: $id');
  }
}

/// ---------------- REMOTE SUBSCRIPTION PLAN SERVICE ----------------
class SubscriptionPlanService {
  final LocalSubscriptionPlanService localService = LocalSubscriptionPlanService();

  /// Get all subscription plans
  Future<List<SubscriptionPlan>> getPlans(WidgetRef ref) async {
    if (localService.isDataCached()) {
      AppLogger.logInfo('📦 Loaded subscription plans from cache');
      return localService.getAllPlans();
    }

    try {
      final response = await apiGet(ref, '/subscriptions/plans', json: false);
      if (response.body.isEmpty) return [];

      final List<dynamic> planList = jsonDecode(response.body)['plans'];
      final plans = planList.map((json) => SubscriptionPlan.fromJson(json)).toList();
      plans.forEach(localService.savePlan);
      return plans;
    } catch (e, stackTrace) {
      HttpErrorHandler.handleJsonDecodingError('decode subscription plans', e);
      AppLogger.logError('❌ Error fetching subscription plans: $e', e, stackTrace);
    }

    return localService.getAllPlans();
  }

  /// Create a new plan
  Future<void> createPlan(WidgetRef ref, SubscriptionPlan plan) async {
    localService.savePlan(plan);
    try {
      await apiPost(ref, '/subscriptions/plans', plan.toJson());
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to create subscription plan: $e', e, stackTrace);
    }
  }

  /// Update a subscription plan
  Future<void> updatePlan(WidgetRef ref, String id, SubscriptionPlan plan) async {
    localService.savePlan(plan);
    try {
      await apiPut(ref, '/subscriptions/plans/$id', plan.toJson());
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to update subscription plan: $e', e, stackTrace);
    }
  }

  /// Delete a subscription plan
  Future<void> deletePlan(WidgetRef ref, String id) async {
    localService.deletePlan(id);
    try {
      await apiDelete(ref, '/subscriptions/plans/$id');
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to delete subscription plan: $e', e, stackTrace);
    }
  }

  /// Initialize payment for a plan
  Future<void> initializePayment(WidgetRef ref, SubscriptionPlan plan) async {
    try {
      final response = await apiPost(ref, '/payments/initialize', {'planId': plan.id});
      final data = jsonDecode(response.body);
      final authorizationUrl = data['authorization_url'] as String;

      final Uri url = Uri.parse(authorizationUrl);
      if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
        AppLogger.logError('❌ Could not launch Paystack URL: $authorizationUrl');
      } else {
        AppLogger.logInfo('🚀 Launched Paystack checkout');
      }
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to initialize payment: $e', e, stackTrace);
    }
  }

  /// ------------------ Check active subscription ------------------
  Future<Map<String, dynamic>> checkActiveSubscription(WidgetRef ref) async {
    try {
      final response = await apiGet(ref, '/subscriptions/active-subscription', json: true);
      final Map<String, dynamic> data = jsonDecode(response.body);
      AppLogger.logInfo('💳 Active subscription: $data');
      return data;
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to check active subscription: $e', e, stackTrace);
      return {"hasActive": false, "subscription": null};
    }
  }
}
