import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:agriproduce/constant/config.dart';
import 'package:agriproduce/state_management/token_provider.dart';
import 'package:agriproduce/constant/appLogger.dart';
import 'package:agriproduce/constant/httpError.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Local Subscription Service to handle local data storage using shared_preferences
class LocalSubscriptionService {
  static const String _subscriptionKey = 'subscription_data';

  // Save subscription data locally
  Future<void> saveSubscription(Map<String, dynamic> subscriptionData) async {
    final prefs = await SharedPreferences.getInstance();
    final subscriptionJsonString = jsonEncode(subscriptionData);
    await prefs.setString(_subscriptionKey, subscriptionJsonString);
    AppLogger.logInfo('Subscription data saved locally: $subscriptionData');
  }

  // Retrieve subscription data from local storage
  Future<Map<String, dynamic>?> getSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final subscriptionJsonString = prefs.getString(_subscriptionKey);
    if (subscriptionJsonString != null) {
      try {
        final subscriptionData =
            jsonDecode(subscriptionJsonString) as Map<String, dynamic>;
        AppLogger.logInfo(
            'Subscription data loaded from local storage: $subscriptionData');
        return subscriptionData;
      } catch (e) {
        AppLogger.logError('Error decoding cached subscription data: $e');
      }
    }
    AppLogger.logInfo('No subscription data found in local storage.');
    return null;
  }

  // Delete subscription data
  Future<void> deleteSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_subscriptionKey);
    AppLogger.logInfo('Subscription data deleted locally');
  }
}

// Subscription Service to manage API calls and local storage interaction
class SubscriptionService {
  final String renewSubscriptionEndpoint =
      '${Config.baseUrl}/renew-subscription';
  final String subscriptionStatusEndpoint =
      '${Config.baseUrl}/subscription-status';

  final LocalSubscriptionService localSubscriptionService =
      LocalSubscriptionService();

  // Helper function to parse dates from strings
  DateTime _parseDate(String date) {
    try {
      return DateTime.parse(date).toUtc(); // Convert to UTC for consistency
    } catch (e) {
      AppLogger.logError('Error parsing date: $e');
      return DateTime.utc(1970, 1, 1); // Return a default date if parsing fails
    }
  }

  // Renew subscription
  Future<Map<String, dynamic>> renewSubscription(
      String adminEmail, int duration, WidgetRef ref) async {
    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError("No token found");
      throw Exception("No token found");
    }

    try {
      final response = await http.post(
        Uri.parse(renewSubscriptionEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'adminEmail': adminEmail, 'duration': duration}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Ensure subscription expiry date is parsed correctly
        DateTime expiryDate = _parseDate(responseData['subscriptionExpiry']);

        // Handle the subscription start and expiry dates properly
        responseData['subscriptionExpiry'] = expiryDate.toIso8601String();

        await localSubscriptionService
            .saveSubscription(responseData); // Cache the subscription data
        AppLogger.logInfo('Subscription renewed successfully: $responseData');
        return responseData;
      } else {
        HttpErrorHandler.handleResponse(
            response, 'Failed to renew subscription');
        throw Exception("Failed to renew subscription");
      }
    } catch (e) {
      // Fetch from local storage in case of an error
      final cachedData = await localSubscriptionService.getSubscription();
      if (cachedData != null) {
        AppLogger.logInfo("Error renewing subscription, using cached data.");
        return cachedData;
      }
      AppLogger.logError("Error renewing subscription: $e");
      throw Exception("Error renewing subscription: $e");
    }
  }

  // Check subscription status
  Future<Map<String, dynamic>> checkSubscriptionStatus(WidgetRef ref) async {
    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError("No token found");
      throw Exception("No token found");
    }

    try {
      final response = await http.get(
        Uri.parse(subscriptionStatusEndpoint),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Ensure subscription expiry date is parsed correctly
        DateTime expiryDate = _parseDate(responseData['subscriptionExpiry']);

        // Handle the subscription start and expiry dates properly
        responseData['subscriptionExpiry'] = expiryDate.toIso8601String();

        await localSubscriptionService
            .saveSubscription(responseData); // Cache the subscription data
        AppLogger.logInfo(
            'Fetched subscription status successfully: $responseData');
        return responseData;
      } else {
        HttpErrorHandler.handleResponse(
            response, 'Failed to fetch subscription status');
        throw Exception("Failed to fetch subscription status");
      }
    } catch (e) {
      // Fetch from local storage in case of an error
      final cachedData = await localSubscriptionService.getSubscription();
      if (cachedData != null) {
        AppLogger.logInfo(
            "Error checking subscription status, using cached data.");
        return cachedData;
      }
      AppLogger.logError("Error checking subscription status: $e");
      throw Exception("Error checking subscription status: $e");
    }
  }
}
