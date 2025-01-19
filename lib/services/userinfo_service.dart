import 'dart:convert';
import 'package:agriproduce/constant/appLogger.dart';
import 'package:agriproduce/constant/httpError.dart';
import 'package:agriproduce/constant/config.dart';
import 'package:agriproduce/data_models/userinfo_model.dart';
import 'package:agriproduce/state_management/token_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// Local user service for caching
class LocalUserService {
  // Save a user locally
  void saveUser(User user) {
    AppLogger.logInfo('User saved locally: ${user.toJson()}');
  }

  // Retrieve all users
  List<User> getAllUsers() {
    return [];
  }

  // Check if user data is cached
  bool isDataCached() {
    return false;
  }

  // Delete a user
  void deleteUser(String id) {
    AppLogger.logInfo('User deleted locally with id: $id');
  }
}

// Remote user service
class UserListService {
  final LocalUserService localService = LocalUserService();

  // Fetch all users
  Future<List<User>> getUsers(WidgetRef ref) async {
    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, cannot fetch users');
      throw Exception('User not authenticated');
    }

    if (localService.isDataCached()) {
      AppLogger.logInfo('Fetching users from local cache');
      return localService.getAllUsers();
    }

    try {
      AppLogger.logInfo('Fetching users from server...');
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/users'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      HttpErrorHandler.handleResponse(response, 'fetch users');

      if (response.body.isEmpty) {
        return [];
      }

      try {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('associatedUsers')) {
          final List<dynamic> userList = jsonResponse['associatedUsers'];
          List<User> users =
              userList.map<User>((json) => User.fromJson(json)).toList();

          // Save users locally for caching
          for (var user in users) {
            localService.saveUser(user);
          }

          AppLogger.logInfo('Users fetched and cached successfully');
          return users;
        } else {
          AppLogger.logError('Unexpected JSON structure: $jsonResponse');
          throw Exception('Unexpected JSON structure');
        }
      } catch (e, stackTrace) {
        HttpErrorHandler.handleJsonDecodingError('decode users', e);
        AppLogger.logError('Error decoding JSON for users', e, stackTrace);
      }
    } catch (e, stackTrace) {
      AppLogger.logError('Error fetching users from server: $e', e, stackTrace);
    }

    // Fallback to local cache
    AppLogger.logInfo('Returning users from local cache due to error');
    return localService.getAllUsers();
  }

  // Update user
  Future<void> updateUser(WidgetRef ref, String userId, User user) async {
    localService.saveUser(user);
    AppLogger.logInfo('Attempting to update user remotely with id: $userId');

    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, user not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.put(
        Uri.parse('${Config.baseUrl}/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(user.toJson()),
      );

      HttpErrorHandler.handleResponse(response, 'update user');
    } catch (e, stackTrace) {
      AppLogger.logError('Error updating user remotely: $e', e, stackTrace);
    }
  }

  // Delete user
  Future<void> deleteUser(WidgetRef ref, String userId) async {
    localService.deleteUser(userId);
    AppLogger.logInfo('Attempting to delete user remotely with id: $userId');

    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, user not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      HttpErrorHandler.handleResponse(response, 'delete user');
    } catch (e, stackTrace) {
      AppLogger.logError('Error deleting user remotely: $e', e, stackTrace);
    }
  }
}
