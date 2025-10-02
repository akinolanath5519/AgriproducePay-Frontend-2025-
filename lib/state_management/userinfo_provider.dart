import 'package:agriproduce/data_models/userinfo_model.dart';
import 'package:agriproduce/services/userinfo_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserListState {
  final List<User> users;
  final bool isLoading;

  UserListState({
    required this.users,
    required this.isLoading,
  });

  factory UserListState.initial() {
    return UserListState(users: [], isLoading: true);
  }
}

class UserListNotifier extends StateNotifier<UserListState> {
  final UserListService _userListService;

  UserListNotifier(this._userListService) : super(UserListState.initial());

  /// Fetch all users
  Future<void> fetchUsers(WidgetRef ref) async {
    try {
      print('Starting to fetch users...');
      state = UserListState(users: state.users, isLoading: true);

      final result = await _userListService.getUsers(ref);

      final associatedUsers = result?['associatedUsers'] as List<User>? ?? [];

      state = UserListState(users: associatedUsers, isLoading: false);

      print('Users: ${associatedUsers.map((e) => e.name).toList()}');
    } catch (error) {
      print('Error in UserListNotifier: $error');
      state = UserListState(users: [], isLoading: false);
    }
  }

  /// Delete standard user
  Future<void> deleteStandardUser(WidgetRef ref, String userId) async {
    try {
      await _userListService.deleteStandardUser(ref, userId);

      final updatedUsers =
          state.users.where((user) => user.id != userId).toList();

      state = UserListState(users: updatedUsers, isLoading: false);

      print('Deleted user with ID: $userId');
    } catch (error) {
      print('Error deleting user: $error');
    }
  }

  /// Block user
  Future<void> blockUser(WidgetRef ref, String userId) async {
    try {
      await _userListService.blockUser(ref, userId);

      final updatedUsers = state.users.map((user) {
        if (user.id == userId) {
          return user.copyWith(isBlocked: true); 
        }
        return user;
      }).toList();

      state = UserListState(users: updatedUsers, isLoading: false);

      print('Blocked user with ID: $userId');
    } catch (error) {
      print('Error blocking user: $error');
    }
  }

  /// Unblock user
  Future<void> unblockUser(WidgetRef ref, String userId) async {
    try {
      await _userListService.unblockUser(ref, userId);

      final updatedUsers = state.users.map((user) {
        if (user.id == userId) {
          return user.copyWith(isBlocked: false);
        }
        return user;
      }).toList();

      state = UserListState(users: updatedUsers, isLoading: false);

      print('Unblocked user with ID: $userId');
    } catch (error) {
      print('Error unblocking user: $error');
    }
  }
}

final userListServiceProvider = Provider<UserListService>((ref) {
  return UserListService();
});

final userListProvider =
    StateNotifierProvider<UserListNotifier, UserListState>((ref) {
  final userListService = ref.watch(userListServiceProvider);
  return UserListNotifier(userListService);
});
