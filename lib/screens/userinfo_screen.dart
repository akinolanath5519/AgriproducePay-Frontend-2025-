import 'package:agriproduce/state_management/userinfo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch users only if the user list is empty
    Future.microtask(() {
      final userListState = ref.read(userListProvider);
      if (userListState.users.isEmpty) {
        ref.read(userListProvider.notifier).fetchUsers(ref);
      }
    });
  }

  Future<void> _refreshUsers() async {
    try {
      await ref.read(userListProvider.notifier).fetchUsers(ref);
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    final userListState = ref.watch(userListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        backgroundColor: Colors.deepPurple, // Custom color for AppBar
        elevation: 4.0, // Slight shadow for a more modern look
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUsers, // Pull-to-refresh function
        child: userListState.isLoading && userListState.users.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              ) // Show loading indicator if fetching for the first time
            : userListState.users.isEmpty
                ? const Center(child: Text('No users found'))
                : ListView.builder(
                    itemCount: userListState.users.length,
                    itemBuilder: (context, index) {
                      final user = userListState.users[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Card(
                          elevation:
                              0.2, // Card elevation for a floating effect
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.deepPurple,
                              child: Icon(
                                Icons.person, // Human icon instead of letter
                                color: Colors.white,
                                size: 24.0,
                              ),
                            ),
                            title: Text(
                              user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email: ${user.email}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                Text(
                                  'Role: ${user.role}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            tileColor: user.isCurrentUser
                                ? Colors.green.withOpacity(0.4)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
