import 'dart:convert';
import 'package:agriproduce/constant/appLogger.dart';
import 'package:agriproduce/constant/httpError.dart';
import 'package:agriproduce/data_models/userinfo_model.dart';
import 'package:agriproduce/utilis/api_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ---------------- LOCAL USER CACHE ----------------
class LocalUserService {
  void saveUser(User user) =>
      AppLogger.logInfo('💾 Saved user locally: ${user.toJson()}');

  List<User> getAllUsers() {
    AppLogger.logInfo('📦 Returning cached users (currently empty)');
    return [];
  }

  bool isDataCached() => false;

  void deleteUser(String id) =>
      AppLogger.logInfo('🗑 Deleted user locally: $id');
}

/// ---------------- REMOTE USER SERVICE ----------------
class UserListService {
  final LocalUserService localService = LocalUserService();

  /// Fetch admin + associated users
  Future<Map<String, dynamic>?> getUsers(WidgetRef ref) async {
    if (localService.isDataCached()) {
      AppLogger.logInfo('📦 Loaded users from cache');
      return {
        "admin": null,
        "associatedUsers": localService.getAllUsers(),
      };
    }

    try {
      final response = await apiGet(ref, '/auth/get/adminanduser', json: false);
      if (response.body.isEmpty) return null;

      final responseData = jsonDecode(response.body);

      // Parse admin
      final adminData = responseData['admin'];
      final admin = adminData != null ? User.fromJson(adminData) : null;

      // Parse users
      final usersJson = responseData['associatedUsers'] as List<dynamic>;
      final users = usersJson.map((u) => User.fromJson(u)).toList();

      users.forEach(localService.saveUser);

      AppLogger.logInfo('✅ Admin + users fetched successfully');
      return {"admin": admin, "associatedUsers": users};
    } catch (e, stackTrace) {
      HttpErrorHandler.handleJsonDecodingError('decode users', e);
      AppLogger.logError('❌ Error fetching users: $e', e, stackTrace);
      return null;
    }
  }

  /// Update user
  Future<void> updateUser(WidgetRef ref, String userId, User user) async {
    localService.saveUser(user);
    try {
      await apiPut(ref, '/users/$userId', user.toJson());
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to update user: $e', e, stackTrace);
    }
  }

  /// Delete standard user
  Future<void> deleteStandardUser(WidgetRef ref, String userId) async {
    localService.deleteUser(userId);
    try {
      await apiDelete(ref, '/auth/delete/standarduser/$userId');
      AppLogger.logInfo('✅ Standard user deleted from server');
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to delete user: $e', e, stackTrace);
      rethrow;
    }
  }

  /// Block user
  Future<void> blockUser(WidgetRef ref, String userId) async {
    try {
      await apiPatch(ref, '/auth/users/block/$userId', {});
      AppLogger.logInfo('✅ User blocked successfully');
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to block user: $e', e, stackTrace);
      rethrow;
    }
  }

  /// Unblock user
  Future<void> unblockUser(WidgetRef ref, String userId) async {
    try {
      await apiPatch(ref, '/auth/users/unblock/$userId', {});
      AppLogger.logInfo('✅ User unblocked successfully');
    } catch (e, stackTrace) {
      AppLogger.logError('❌ Failed to unblock user: $e', e, stackTrace);
      rethrow;
    }
  }
}
