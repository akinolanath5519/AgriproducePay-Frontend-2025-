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
  // Login Method

  Future<User?> login(String email, String password, WidgetRef ref) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final user = User.fromJson(responseData); // Parse directly into User model

        // Save token
        await saveToken(user.token, ref);

        // Set user data to the userProvider
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
        Uri.parse('${Config.baseUrl}/register-admin'),
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
        Uri.parse('${Config.baseUrl}/register-standard'),
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
