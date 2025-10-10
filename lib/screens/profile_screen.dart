// ignore_for_file: deprecated_member_use

import 'package:agriproduce/state_management/subscription_provider.dart';
import 'package:agriproduce/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:agriproduce/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'login_page.dart';
import 'company_info_screen.dart';
import 'userinfo_screen.dart';
import 'package:agriproduce/theme/app_theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );
    
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionNotifierProvider);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return true;
      },
      child: Scaffold(
        body: AppBackground(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
             
              // Profile Content
              SliverList(
                delegate: SliverChildListDelegate([
                  // Profile Header Card
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: _buildProfileHeader(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Subscription Section
                  subscription.when(
                    data: (subscriptionData) {
                      final expiryDate = subscriptionData.first.subscriptionExpiry;
                      final isExpired = expiryDate.isBefore(DateTime.now());
                      final isActive = !isExpired;
                      final daysRemaining = expiryDate.difference(DateTime.now()).inDays;

                      return AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideAnimation.value * 0.8),
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: _buildSubscriptionCard(isActive, expiryDate, daysRemaining),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CustomLoadingIndicator(),
                    ),
                    error: (error, stackTrace) => AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value * 0.8),
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: _buildErrorCard(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons Section
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value * 0.6),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: _buildActionButtons(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.large,
        boxShadow: [AppShadows.medium],
      ),
      child: Column(
        children: [
          // Profile Avatar with Badge
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [AppShadows.glow],
                ),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.successGreen,
                    shape: BoxShape.circle,
                    boxShadow: [AppShadows.subtle],
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // User Info
          Text(
            'Admin User',
            style: AppText.greeting.copyWith(
              fontSize: 22,
              color: AppColors.deepCharcoal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Administrator Account',
            style: AppText.subtitle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Stats Row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppBorderRadius.medium,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Active', '12', Icons.group),
                _buildStatItem('Teams', '3', Icons.workspaces),
                _buildStatItem('Projects', '8', Icons.assignment),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppText.cardValue.copyWith(
            fontSize: 18,
            color: AppColors.deepCharcoal,
          ),
        ),
        Text(
          label,
          style: AppText.subtitle.copyWith(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard(bool isActive, DateTime expiryDate, int daysRemaining) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [AppColors.successGreen.withOpacity(0.1), AppColors.primary.withOpacity(0.05)]
              : [Colors.orange.withOpacity(0.1), Colors.red.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppBorderRadius.large,
        border: Border.all(
          color: isActive ? AppColors.successGreen.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [AppShadows.subtle],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.successGreen : Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isActive ? Icons.verified : Icons.warning,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Subscription Status',
                  style: AppText.cardTitle.copyWith(
                    fontSize: 18,
                    color: AppColors.deepCharcoal,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.successGreen.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                  borderRadius: AppBorderRadius.medium,
                  border: Border.all(
                    color: isActive ? AppColors.successGreen : Colors.orange,
                  ),
                ),
                child: Text(
                  isActive ? 'ACTIVE' : 'EXPIRED',
                  style: TextStyle(
                    color: isActive ? AppColors.successGreen : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSubscriptionInfoRow(
            'Expiry Date',
            DateFormat('dd MMMM yyyy').format(expiryDate),
            Icons.calendar_today,
          ),
          const SizedBox(height: 12),
          _buildSubscriptionInfoRow(
            'Days Remaining',
            isActive ? '$daysRemaining days' : 'Expired',
            Icons.timer,
          ),
          if (isActive && daysRemaining <= 7) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: AppBorderRadius.medium,
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Subscription expires soon. Consider renewing.',
                      style: AppText.subtitle.copyWith(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubscriptionInfoRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppText.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: AppText.cardTitle.copyWith(
              color: AppColors.deepCharcoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.large,
        boxShadow: [AppShadows.medium],
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text(
            'Unable to Load Subscription',
            style: AppText.cardTitle.copyWith(
              color: AppColors.deepCharcoal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: AppText.subtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(subscriptionNotifierProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: AppBorderRadius.medium,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Try Again',
              style: AppText.button,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildActionButton(
            icon: FontAwesomeIcons.building,
            label: 'Company Information',
            description: 'Manage company details and settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CompanyInfoScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: FontAwesomeIcons.users,
            label: 'User Management',
            description: 'View and manage system users',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserListScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: FontAwesomeIcons.rightFromBracket,
            label: 'Logout',
            description: 'Sign out of your account',
            isDestructive: true,
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppBorderRadius.medium,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppBorderRadius.medium,
            boxShadow: [AppShadows.subtle],
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDestructive 
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(
                  icon,
                  color: isDestructive ? AppColors.error : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppText.cardTitle.copyWith(
                        color: isDestructive ? AppColors.error : AppColors.deepCharcoal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppText.subtitle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.large),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout,
                    color: AppColors.error,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Confirm Logout',
                  style: AppText.sectionTitle.copyWith(
                    color: AppColors.deepCharcoal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to log out of your account?',
                  style: AppText.subtitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.medium),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('Cancel', style: AppText.button.copyWith(color: AppColors.textSecondary)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop(true);
                          await AuthService().logout(ref);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.medium),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('Logout', style: AppText.button),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}