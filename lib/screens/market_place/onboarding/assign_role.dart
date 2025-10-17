import 'package:agriproduce/screens/dashboard.dart';
import 'package:agriproduce/state_management/auth_provider.dart';
import 'package:agriproduce/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/constant/appLogger.dart';
import 'package:agriproduce/services/auth_service.dart';

class AssignRoleScreen extends ConsumerStatefulWidget {
  const AssignRoleScreen({super.key});

  @override
  ConsumerState<AssignRoleScreen> createState() => _AssignRoleScreenState();
}

class _AssignRoleScreenState extends ConsumerState<AssignRoleScreen> {
  final AuthService _authService = AuthService();
final List<String> _availableRoles = ['admin', 'SELLER', 'BUYER'];

  final Set<String> _selectedRoles = {};

  bool _isLoading = false;

  Future<void> _submitRoles() async {
  if (_selectedRoles.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select at least one role')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final user = ref.read(userProvider);
    if (user == null) throw Exception('User not found in provider');

    AppLogger.logInfo('Assigning roles ${_selectedRoles.toList()} to user ${user.email}');

    // Call the service to assign roles
    final updatedUser = await _authService.assignRole(
      user.id,
      _selectedRoles.toList(),
      ref,
    );

    if (updatedUser != null) {
      // ✅ Log the returned user info
      AppLogger.logInfo('AssignRoleScreen: updated user role: ${updatedUser.role}');

      // ✅ Update the provider so the app sees the new role
      ref.read(userProvider.notifier).state = updatedUser;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Roles assigned and logged in!')),
      );

      // Navigate directly to Home/Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Dashboard()),
      );
    } else {
      AppLogger.logError('AssignRoleScreen: assignRole returned null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to assign roles')),
      );
    }
  } catch (e, st) {
    AppLogger.logError('Error assigning roles: $e\n$st');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to assign roles: $e')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Role')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Select your role(s)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _availableRoles.length,
                itemBuilder: (context, index) {
                  final role = _availableRoles[index];
                  final isSelected = _selectedRoles.contains(role);

                  return Card(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.white,
                    child: CheckboxListTile(
                      title: Text(role),
                      value: isSelected,
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedRoles.add(role);
                          } else {
                            _selectedRoles.remove(role);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitRoles,
              style: ElevatedButton.styleFrom(
                backgroundColor:AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Continue', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
