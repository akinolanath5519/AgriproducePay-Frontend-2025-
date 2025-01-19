import 'package:agriproduce/data_models/userinfo_model.dart';
import 'package:agriproduce/services/userinfo_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserListState {
  final List<User> users;
  final bool isLoading;

  UserListState({required this.users, required this.isLoading});

  factory UserListState.initial() {
    return UserListState(users: [], isLoading: true);
  }
}

class UserListNotifier extends StateNotifier<UserListState> {
  final UserListService _userListService;

  UserListNotifier(this._userListService) : super(UserListState.initial());

  Future<void> fetchUsers(WidgetRef ref) async {
    try {
      print('Starting to fetch users...');
      state = UserListState(users: state.users, isLoading: true);
      final users = await _userListService.getUsers(ref);
      state = UserListState(users: users, isLoading: false);
      print('Users updated in state: ${users.map((e) => e.name).toList()}');
    } catch (error) {
      print('Error in UserListNotifier: $error');
      state = UserListState(users: [], isLoading: false);
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
