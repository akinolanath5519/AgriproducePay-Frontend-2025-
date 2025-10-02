import 'package:agriproduce/data_models/userinfo_model.dart';
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
    Future.microtask(() {
      final userListState = ref.read(userListProvider);
      if (userListState.users.isEmpty) {
        ref.read(userListProvider.notifier).fetchUsers(ref);
      }
    });
  }

  Future<void> _refreshUsers() async {
    await ref.read(userListProvider.notifier).fetchUsers(ref);
  }

  @override
  Widget build(BuildContext context) {
    final userListState = ref.watch(userListProvider);

    // ✅ safely find current user (nullable)
    User? currentUser = userListState.users.isNotEmpty
        ? userListState.users.firstWhere(
            (u) => u.isCurrentUser,
            orElse: () => User(
              id: '',
              name: '',
              email: '',
              role: '',
              isCurrentUser: false,
              isBlocked: false,
            ),
          )
        : null;

    // If fallback user is invalid, set it to null
    if (currentUser != null && currentUser.id.isEmpty) {
      currentUser = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        backgroundColor: Colors.deepPurple,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUsers,
        child: userListState.isLoading && userListState.users.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : userListState.users.isEmpty
                ? const Center(child: Text('No users found'))
                : ListView.builder(
                    itemCount: userListState.users.length,
                    itemBuilder: (context, index) {
                      final user = userListState.users[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            leading: CircleAvatar(
                              backgroundColor: user.isBlocked
                                  ? Colors.grey
                                  : Colors.deepPurple,
                              child:
                                  const Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              user.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color:
                                    user.isBlocked ? Colors.grey : Colors.black,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email: ${user.email}'),
                                Text('Role: ${user.role}'),
                                if (user.isBlocked)
                                  const Text(
                                    'Blocked',
                                    style: TextStyle(color: Colors.red),
                                  ),
                              ],
                            ),
                            tileColor: user.isCurrentUser
                                ? Colors.green.withOpacity(0.4)
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ✅ Block/Unblock button (only for admin)
                                if (currentUser?.role == 'admin' &&
                                    user.id != currentUser?.id)
                                  IconButton(
                                    icon: Icon(
                                      user.isBlocked
                                          ? Icons.lock_open
                                          : Icons.lock,
                                      color: user.isBlocked
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                    onPressed: () async {
                                      if (user.isBlocked) {
                                        await ref
                                            .read(userListProvider.notifier)
                                            .unblockUser(ref, user.id);
                                      } else {
                                        await ref
                                            .read(userListProvider.notifier)
                                            .blockUser(ref, user.id);
                                      }
                                    },
                                  ),

                                // ✅ Delete button (only for admin on standard users)
                                if (user.role == 'standard' &&
                                    currentUser?.role == 'admin')
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      final confirmed =
                                          await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete User'),
                                          content: Text(
                                              'Are you sure you want to delete ${user.name}?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirmed == true) {
                                        await ref
                                            .read(userListProvider.notifier)
                                            .deleteStandardUser(ref, user.id);
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
