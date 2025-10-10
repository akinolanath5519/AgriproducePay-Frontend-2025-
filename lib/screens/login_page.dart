import 'package:agriproduce/state_management/auth_provider.dart';
import 'package:agriproduce/theme/app_theme.dart';
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


class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
          ref.read(userProvider.notifier).setUser(user);

          final role = user.role.trim().toLowerCase();
          final isFirstLogin = user.isFirstLogin;

          if (role == 'admin') {
            if (isFirstLogin) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const CompanyInfoForm(),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Dashboard(isAdmin: true),
                ),
              );
            }
          } else if (role == 'superadmin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const RenewSubscriptionScreen(),
              ),
            );
          } else if (role == 'standard') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Dashboard(isAdmin: false),
              ),
            );
          } else {
            CustomSnackBar.show(
              context,
              'Oops, something went wrong with your user role. Please contact support.',
              backgroundColor: AppColors.error,
            );
          }
        } else {
          CustomSnackBar.show(
            context,
            'Invalid email or password. Please check your credentials and try again.',
            backgroundColor: AppColors.error,
          );
        }
      } catch (e) {
        CustomSnackBar.show(
          context,
          'An unexpected error occurred: $e. Please try again later.',
          backgroundColor: AppColors.error,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      CustomSnackBar.show(
        context,
        'Please fill in all fields correctly before submitting.',
        backgroundColor: AppColors.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hero Section with App Identity
                        Container(
                          margin: const EdgeInsets.only(bottom: 40),
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [AppShadows.glow],
                                ),
                                child: const Icon(
                                  Icons.eco,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'AgriProduce',
                               
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Cultivating Success Together',
                                
                              ),
                            ],
                          ),
                        ),
                        
                        // Login Card
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: AppBorderRadius.large,
                            boxShadow: [AppShadows.medium],
                          ),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppBorderRadius.large,
                            ),
                            color: Colors.white.withOpacity(0.95),
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header with decorative line
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Welcome Back',
                                         
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: 60,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            gradient: AppColors.primaryGradient,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 32),
                                    
                                    // Email Field
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Email Address',
                                          style: AppText.body.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.deepCharcoal,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        CustomTextField(
                                          controller: _emailController,
                                          label: '',
                                          hintText: 'Enter your email',
                                          keyboardType: TextInputType.emailAddress,
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 24),
                                    
                                    // Password Field
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Password',
                                          style: AppText.body.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.deepCharcoal,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _passwordController,
                                          obscureText: !_isPasswordVisible,
                                          decoration: InputDecoration(
                                            hintText: 'Enter your password',
                                            prefixIcon: const Icon(Icons.lock_outline,
                                                color: AppColors.accent),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _isPasswordVisible
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                                color: AppColors.textSecondary,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _isPasswordVisible = !_isPasswordVisible;
                                                });
                                              },
                                            ),
                                            filled: true,
                                            fillColor: AppColors.lightCream.withOpacity(0.5),
                                            border: OutlineInputBorder(
                                              borderRadius: AppBorderRadius.medium,
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: AppBorderRadius.medium,
                                              borderSide: BorderSide(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: AppBorderRadius.medium,
                                              borderSide: const BorderSide(
                                                color: AppColors.primary,
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter your password';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 16),
                                    
                                    // Remember me & Forgot password row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: false,
                                              onChanged: (value) {},
                                              activeColor: AppColors.primary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                            ),
                                            
                                          ],
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const ForgetPasswordScreen(),
                                              ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: Text(
                                            'Forgot Password?',
                                            
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 32),
                                    
                                    // Login Button
                                    _isLoading
                                        ? Container(
                                            width: double.infinity,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              gradient: AppColors.primaryGradient,
                                              borderRadius: AppBorderRadius.medium,
                                              boxShadow: [AppShadows.subtle],
                                            ),
                                            child: const Center(
                                              child: SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              gradient: AppColors.primaryGradient,
                                              borderRadius: AppBorderRadius.medium,
                                              boxShadow: [AppShadows.subtle],
                                            ),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                minimumSize: const Size(double.infinity, 56),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: AppBorderRadius.medium,
                                                ),
                                              ),
                                              onPressed: _login,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Log In',
                                                    style: AppText.button.copyWith(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Icon(Icons.arrow_forward, size: 20),
                                                ],
                                              ),
                                            ),
                                          ),
                                    
                                    const SizedBox(height: 24),
                                    
                                    // Divider with text
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                            color: Colors.grey.shade300,
                                            thickness: 1,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                         
                                        ),
                                        Expanded(
                                          child: Divider(
                                            color: Colors.grey.shade300,
                                            thickness: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 24),
                                    
                                    // Register Section
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const RegisterPage(),
                                              ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: Text(
                                            'Create Account',
                                            style: AppText.body.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),                        
                        const SizedBox(height: 40),                    // Footer with additional info
                        Text(
                          'Secure agricultural management platform',
                          
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}