import 'package:flutter/material.dart';
import 'package:agriproduce/widgets/custom_button.dart';
import 'package:agriproduce/widgets/custom_snackbar.dart';
import 'package:agriproduce/widgets/custom_decorations.dart';
import 'package:agriproduce/widgets/custom_text.dart';
import 'package:agriproduce/widgets/custom_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/services/auth_service.dart';
import 'login_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _adminEmailController = TextEditingController();
  bool _isAdmin = false;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _adminEmailController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = _isAdmin
            ? await _authService.registerAdmin(
                _nameController.text,
                _emailController.text,
                _passwordController.text,
              )
            : await _authService.registerStandardUser(
                _nameController.text,
                _emailController.text,
                _passwordController.text,
                _adminEmailController.text,
              );

        if (response.statusCode == 201) {
          CustomSnackBar.show(
            context,
            'Registration successful! Please login.',
            backgroundColor: Colors.green,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else {
          CustomSnackBar.show(
            context,
            'Registration failed. Try again.',
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
          imagePath: 'assets/farmer.jpg',
          color: Colors.black54,
          blendMode: BlendMode.darken,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const CustomText(
                    text: 'Create an Account',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isAdmin = true;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isAdmin
                                ? Colors.deepPurple
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isAdmin
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.admin_panel_settings,
                                size: 50,
                                color: _isAdmin ? Colors.white : Colors.grey,
                              ),
                              const CustomText(
                                  text: 'Admin', color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isAdmin = false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: !_isAdmin
                                ? Colors.deepPurple
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: !_isAdmin
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.person,
                                size: 50,
                                color: !_isAdmin ? Colors.white : Colors.grey,
                              ),
                              const CustomText(
                                  text: 'Standard User', color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Name',
                    hintText: 'Enter your name',
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hintText: 'Enter your password',
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  const SizedBox(height: 20),
                  if (!_isAdmin)
                    CustomTextField(
                      controller: _adminEmailController,
                      label: 'Admin Email',
                      hintText: 'Enter admin email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.deepPurple,
                        )
                      : CustomButton(
                          onPressed: _register,
                          text: 'Register',
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(30),
                          elevation: 15,
                          shadowColor: Colors.black.withOpacity(0.5),
                        ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: const CustomText(
                      text: 'Already have an account? Login',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
