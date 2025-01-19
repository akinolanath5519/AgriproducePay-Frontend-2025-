import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/data_models/user_model.dart';

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null);

  // Set the user after login
  void setUser(User user) {
    print('Setting user: ${user.name}, ${user.email}, ${user.role}'); // Debugging print
    state = user;
  }

  // Clear the user data (logout)
  void logout() {
    state = null;
  }

  // Update user data if necessary
  void updateUser(User updatedUser) {
    state = updatedUser;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});
