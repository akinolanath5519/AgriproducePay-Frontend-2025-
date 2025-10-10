import 'package:agriproduce/data_models/userinfo_model.dart';
import 'package:agriproduce/state_management/userinfo_provider.dart';
import 'package:agriproduce/theme/app_theme.dart';
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

  Widget _buildUserStatusIndicator(User user) {
    if (user.isCurrentUser) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.successGreen.withOpacity(0.1),
          borderRadius: AppBorderRadius.medium,
          border: Border.all(color: AppColors.successGreen),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: AppColors.successGreen, size: 8),
            const SizedBox(width: 4),
            Text(
              'You',
              style: TextStyle(
                color: AppColors.successGreen,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (user.isBlocked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: AppBorderRadius.medium,
          border: Border.all(color: AppColors.error),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.block, color: AppColors.error, size: 12),
            const SizedBox(width: 4),
            Text(
              'Blocked',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.successGreen.withOpacity(0.1),
          borderRadius: AppBorderRadius.medium,
          border: Border.all(color: AppColors.successGreen),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: AppColors.successGreen, size: 12),
            const SizedBox(width: 4),
            Text(
              'Active',
              style: TextStyle(
                color: AppColors.successGreen,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildRoleBadge(String role) {
    final isAdmin = role == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin ? AppColors.primary.withOpacity(0.1) : AppColors.accent.withOpacity(0.1),
        borderRadius: AppBorderRadius.medium,
        border: Border.all(color: isAdmin ? AppColors.primary : AppColors.accent),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          color: isAdmin ? AppColors.primary : AppColors.accent,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUserAvatar(User user) {
    return Stack(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: user.isBlocked
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.grey, Colors.grey],
                  )
                : user.role == 'admin'
                    ? AppColors.primaryGradient
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.accent, AppColors.primary],
                      ),
            boxShadow: [AppShadows.subtle],
          ),
          child: Center(
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (user.isCurrentUser)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.successGreen,
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(color: Colors.white, width: 2),
                ),
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 10,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(User user, User? currentUser) {
    if (currentUser?.role != 'admin' || user.id == currentUser?.id) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.medium),
      onSelected: (value) async {
        if (value == 'block' || value == 'unblock') {
          final action = user.isBlocked ? 'unblock' : 'block';
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('${action.capitalize()} User'),
              content: Text(
                'Are you sure you want to $action ${user.name}?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    action.capitalize(),
                    style: TextStyle(
                      color: action == 'block' ? Colors.orange : AppColors.successGreen,
                    ),
                  ),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            if (user.isBlocked) {
              await ref.read(userListProvider.notifier).unblockUser(ref, user.id);
            } else {
              await ref.read(userListProvider.notifier).blockUser(ref, user.id);
            }
          }
        } else if (value == 'delete' && user.role == 'standard') {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete User'),
              content: Text('Are you sure you want to delete ${user.name}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await ref.read(userListProvider.notifier).deleteStandardUser(ref, user.id);
          }
        }
      },
      itemBuilder: (context) => [
        if (user.role == 'standard')
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: AppColors.error),
                const SizedBox(width: 8),
                const Text('Delete User'),
              ],
            ),
          ),
        PopupMenuItem(
          value: user.isBlocked ? 'unblock' : 'block',
          child: Row(
            children: [
              Icon(
                user.isBlocked ? Icons.lock_open : Icons.lock,
                color: user.isBlocked ? AppColors.successGreen : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(user.isBlocked ? 'Unblock User' : 'Block User'),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userListState = ref.watch(userListProvider);

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

    if (currentUser != null && currentUser.id.isEmpty) {
      currentUser = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Management',
          style: AppText.sectionTitle.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: _refreshUsers,
          color: AppColors.primary,
          child: userListState.isLoading && userListState.users.isEmpty
              ? _buildLoadingState()
              : userListState.users.isEmpty
                  ? _buildEmptyState()
                  : _buildUserList(userListState, currentUser),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.medium),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 180,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Users Found',
            style: AppText.sectionTitle.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Users will appear here once they register',
            style: AppText.subtitle.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(UserListState userListState, User? currentUser) {
    return Column(
      children: [
        // Header Stats
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppBorderRadius.medium,
            boxShadow: [AppShadows.medium],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Total Users',
                userListState.users.length.toString(),
                Icons.people,
                AppColors.primary,
              ),
              _buildStatItem(
                'Admins',
                userListState.users.where((u) => u.role == 'admin').length.toString(),
                Icons.admin_panel_settings,
                AppColors.deepCharcoal,
              ),
              _buildStatItem(
                'Blocked',
                userListState.users.where((u) => u.isBlocked).length.toString(),
                Icons.block,
                AppColors.error,
              ),
            ],
          ),
        ),
        // User List
        Expanded(
          child: ListView.builder(
            itemCount: userListState.users.length,
            itemBuilder: (context, index) {
              final user = userListState.users[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.medium),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: AppBorderRadius.medium,
                      border: user.isCurrentUser
                          ? Border.all(color: AppColors.successGreen, width: 2)
                          : null,
                    ),
                    child: Row(
                      children: [
                        _buildUserAvatar(user),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      user.name,
                                      style: AppText.cardTitle.copyWith(
                                        color: user.isBlocked
                                            ? AppColors.textSecondary
                                            : AppColors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  _buildUserStatusIndicator(user),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: AppText.subtitle.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildRoleBadge(user.role),
                                  if (user.isBlocked) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withOpacity(0.1),
                                        borderRadius: AppBorderRadius.medium,
                                        border: Border.all(color: AppColors.error),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.block, color: AppColors.error, size: 12),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Blocked',
                                            style: TextStyle(
                                              color: AppColors.error,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        _buildActionButton(user, currentUser),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppText.cardValue.copyWith(color: color),
        ),
        Text(
          title,
          style: AppText.subtitle.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}