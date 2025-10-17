import 'dart:convert';
import 'package:agriproduce/state_management/auth_provider.dart';
import 'package:agriproduce/state_management/token_provider.dart';
import 'package:agriproduce/data_models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:agriproduce/constant/config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/constant/appLogger.dart';
import 'package:agriproduce/constant/httpError.dart';

class AuthService {
// Add this inside your AuthService class
  Future<User?> assignRole(
  int userId,
  List<String> roles,
  WidgetRef ref,
) async {
  try {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/auth/assign-role'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'roles': roles,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);

      // ✅ Extract the token sent by backend
      final token = responseData['token'];
      if (token == null || token.isEmpty) {
        throw Exception("No token received after assigning roles");
      }

      // ✅ Parse user object (with roles)
      final assignedUser = User.fromJson(responseData['user']);

      // ✅ Save token in provider or secure storage
      await saveToken(token, ref);

      // ✅ Update user in provider
      ref.read(userProvider.notifier).setUser(assignedUser);

      AppLogger.logInfo(
          'Roles assigned successfully and user logged in: ${assignedUser.email}');

      return assignedUser;
    } else {
      HttpErrorHandler.handleResponse(response, 'Failed to assign roles');
      return null;
    }
  } catch (e) {
    AppLogger.logError('Error assigning roles to userId $userId: $e');
    rethrow;
  }
}

  Future<bool> toggleRole(
    int userId,
    String role,
    bool enabled,
    WidgetRef ref,
  ) async {
    final token = ref.read(tokenProvider);
    if (token == null) {
      AppLogger.logError('Token is null, cannot toggle roles');
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/auth/toggle-role'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'role': role,
          'enabled': enabled,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        AppLogger.logInfo(responseData['message']);
        return true;
      } else {
        HttpErrorHandler.handleResponse(response, 'Failed to toggle role');
        return false;
      }
    } catch (e) {
      AppLogger.logError('Error toggling role for userId $userId: $e');
      rethrow;
    }
  }


// Add this inside your AuthService class
  Future<Map<String, dynamic>?> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/auth/sign-up'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        AppLogger.logInfo('Signup successful for $email');

        return {
          'userId': responseData['userId'],
          'message': responseData['message'],
        };
      } else {
        HttpErrorHandler.handleResponse(response, 'Failed to sign up');
        return null;
      }
    } catch (e) {
      AppLogger.logError('Signup error for $email: $e');
      rethrow;
    }
  }



  // Login Method
  Future<User?> login(String email, String password, WidgetRef ref) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // ✅ Extract token separately
        final token = responseData['token'];
        if (token == null || token.isEmpty) {
          throw Exception("No token received from server");
        }

        // ✅ Parse user object
        final user = User.fromJson(responseData['user']);

        // Save token
        await saveToken(token, ref);

        // Set user data
        ref.read(userProvider.notifier).setUser(user);

        AppLogger.logInfo('Login successful for $email');

        return user;
      } else {
        HttpErrorHandler.handleResponse(response, 'Failed to log in');
        return null;
      }
    } catch (e) {
      AppLogger.logError('Login error for $email: $e');
      rethrow;
    }
  }

  // Register Method (Admin)
  Future<http.Response> registerAdmin(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/auth/register-admin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        AppLogger.logInfo('Admin registration successful for $name ($email)');
      } else {
        HttpErrorHandler.handleResponse(response, 'Failed to register admin');
      }
      return response;
    } catch (e) {
      AppLogger.logError('Error registering admin $name ($email): $e');
      rethrow;
    }
  }

  // Register Method (Standard User)
  Future<http.Response> registerStandardUser(
      String name, String email, String password, String adminEmail) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/auth/register-standard'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'adminEmail': adminEmail,
        }),
      );

      if (response.statusCode == 200) {
        AppLogger.logInfo(
            'Standard user registration successful for $name ($email)');
      } else {
        HttpErrorHandler.handleResponse(
            response, 'Failed to register standard user');
      }
      return response;
    } catch (e) {
      AppLogger.logError('Error registering standard user $name ($email): $e');
      rethrow;
    }
  }

  // Register Method (Super Admin)
  Future<http.Response> registerSuperAdmin(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/register-super-admin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        AppLogger.logInfo(
            'Super admin registration successful for $name ($email)');
      } else {
        HttpErrorHandler.handleResponse(
            response, 'Failed to register super admin');
      }
      return response;
    } catch (e) {
      AppLogger.logError('Error registering super admin $name ($email): $e');
      rethrow;
    }
  }

  // Logout Method
  Future<void> logout(WidgetRef ref) async {
    try {
      await clearToken(ref);
      ref.read(userProvider.notifier).logout(); // Clear user data on logout
      AppLogger.logInfo('User logged out successfully');
    } catch (e) {
      AppLogger.logError('Error during logout: $e');
      rethrow;
    }
  }
}

Future<Map<String, dynamic>?> getUsers(WidgetRef ref) async {
  final token = ref.read(tokenProvider);
  if (token == null) {
    AppLogger.logError('Token is null, cannot fetch users');
    throw Exception('User not authenticated');
  }

  try {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/auth/get/adminanduser'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    HttpErrorHandler.handleResponse(response, 'fetch users');

    if (response.body.isEmpty) {
      return null;
    }

    final responseData = jsonDecode(response.body);

    // Admin info
    final adminData = responseData['admin'];
    final admin = adminData != null ? User.fromJson(adminData) : null;

    // Associated users
    final associatedUsersJson =
        responseData['associatedUsers'] as List<dynamic>;
    final associatedUsers =
        associatedUsersJson.map((u) => User.fromJson(u)).toList();

    return {
      "admin": admin,
      "associatedUsers": associatedUsers,
    };
  } catch (e, stackTrace) {
    AppLogger.logError('Error fetching users: $e', e, stackTrace);
    rethrow;
  }
}
