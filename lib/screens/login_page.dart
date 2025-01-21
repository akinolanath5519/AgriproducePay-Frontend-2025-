import 'package:agriproduce/state_management/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/services/auth_service.dart';
import 'package:agriproduce/widgets/custom_snackbar.dart';
import 'package:agriproduce/widgets/custom_text_field.dart';
import 'package:agriproduce/screens/dashboard.dart';
import 'package:agriproduce/screens/register_page.dart';
import 'package:agriproduce/screens/forget_password.dart';
import 'package:agriproduce/widgets/companyinfo_form.dart';
import 'package:agriproduce/subscription/super_admin_renew_sub.dart';
import 'package:agriproduce/widgets/custom_decorations.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = await _authService.login(
          _emailController.text,
          _passwordController.text,
          ref,
        );

        if (user != null) {
          // After successful login, set the user data in the provider
          ref.read(userProvider.notifier).setUser(user);

          final role = user.role.trim().toLowerCase();
          final isFirstLogin = user.isFirstLogin;

          if (role == 'admin') {
            if (isFirstLogin) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const CompanyInfoForm()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const Dashboard(isAdmin: true)),
              );
            }
          } else if (role == 'superadmin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const RenewSubscriptionScreen()),
            );
          } else if (role == 'standard') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const Dashboard(isAdmin: false)),
            );
          } else {
            CustomSnackBar.show(
              context,
              'Unexpected user role: $role',
              backgroundColor: Colors.red,
            );
          }
        } else {
          CustomSnackBar.show(
            context,
            'Invalid email or password.',
            backgroundColor: Colors.red,
          );
        }
      } catch (e) {
        CustomSnackBar.show(
          context,
          'An error occurred: $e',
          backgroundColor: Colors.red,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: CustomDecorations.backgroundDecoration(
          imagePath: 'assets/newmarket.jpg',
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white.withOpacity(0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email',
                            hintText: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.deepPurple,
                                  ),
                                )
                              : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                    ),
                                    onPressed: _login,
                                    child: const Text(
                                      'Log In',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ForgetPasswordScreen()),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterPage()),
                    );
                  },
                  child: const Text(
                    'Don\'t have an account? Register',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
