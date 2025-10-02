// ignore_for_file: deprecated_member_use

import 'package:agriproduce/state_management/subscription_provider.dart';
import 'package:agriproduce/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:agriproduce/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'login_page.dart';
import 'company_info_screen.dart';
import 'userinfo_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Profile Header with Gradient and Animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildProfileHeader(),
              ),
              const SizedBox(height: 20),

              // Subscription Information
              subscription.when(
                data: (subscriptionData) {
                  final expiryDate = subscriptionData.first.subscriptionExpiry;
                  final isExpired = expiryDate.isBefore(DateTime.now());
                  final isActive = !isExpired;

                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Enhanced Subscription Card
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepPurple.withOpacity(0.1),
                                Colors.purple.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Colors.deepPurple.withOpacity(0.3),
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                'Subscription Status:',
                                isActive ? 'Active' : 'Expired',
                                isActive,
                              ),
                              const SizedBox(height: 10),
                              _buildInfoRow(
                                'Subscription Expiry:',
                                DateFormat('dd MMM yyyy').format(expiryDate),
                                isActive,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const CustomLoadingIndicator(),
                error: (error, stackTrace) => Column(
                  children: [
                    const Text('Error loading subscription info'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () =>
                          ref.refresh(subscriptionNotifierProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Action Buttons with Animations
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildPrimaryButton(
                  context,
                  icon: FontAwesomeIcons.building,
                  label: 'Company Information',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CompanyInfoScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildPrimaryButton(
                  context,
                  icon: FontAwesomeIcons.users,
                  label: 'Users',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UserListScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildPrimaryButton(
                  context,
                  icon: FontAwesomeIcons.rightFromBracket,
                  label: 'Logout',
                  onPressed: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Confirm Logout'),
                          content:
                              const Text('Are you sure you want to log out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Logout'),
                            ),
                          ],
                        );
                      },
                    );

                    if (shouldLogout == true) {
                      await AuthService().logout(ref);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.withOpacity(0.8),
                  Colors.purple.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.transparent,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isActive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Row(
          children: [
            Icon(
              isActive ? Icons.check_circle : Icons.cancel,
              color: isActive ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.black87 : Colors.black45,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.withOpacity(0.8),
              Colors.purple.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FaIcon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
