import 'package:flutter/material.dart';
import 'package:agriproduce/widgets/custom_snackbar.dart';
import 'package:agriproduce/widgets/custom_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/services/auth_service.dart';
import 'package:agriproduce/theme/app_theme.dart';
import 'login_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _adminEmailController = TextEditingController();
  bool _isAdmin = false;
  bool _isLoading = false;

  final AuthService _authService = AuthService();
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
            backgroundColor: AppColors.successGreen,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else {
          CustomSnackBar.show(
            context,
            'Registration failed. Please try again.',
            backgroundColor: AppColors.error,
          );
        }
      } catch (e) {
        CustomSnackBar.show(
          context,
          'An error occurred: $e',
          backgroundColor: AppColors.error,
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
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              top: -80,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
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
                        // Hero Section
                        Container(
                          margin: const EdgeInsets.only(bottom: 32),
                          child: Column(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [AppShadows.glow],
                                ),
                                child: const Icon(
                                  Icons.person_add_alt_1,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Join AgriProduce',
                               
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start your agricultural journey',
                               
                              ),
                            ],
                          ),
                        ),
                        
                        // Registration Card
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
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                child: Column(
                                  children: [
                                    // Header with decorative line
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Create Account',
                                          
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
                                    
                                    // Role Selection
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Select Role',
                                          style: AppText.body.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.deepCharcoal,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            // Admin Option
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _isAdmin = true;
                                                  });
                                                },
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 300),
                                                  margin: const EdgeInsets.only(right: 8),
                                                  padding: const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    gradient: _isAdmin 
                                                      ? AppColors.primaryGradient 
                                                      : LinearGradient(
                                                          colors: [Colors.grey.shade100, Colors.grey.shade100],
                                                        ),
                                                    borderRadius: AppBorderRadius.medium,
                                                    border: Border.all(
                                                      color: _isAdmin 
                                                        ? AppColors.primary 
                                                        : Colors.grey.shade300,
                                                      width: 2,
                                                    ),
                                                    boxShadow: _isAdmin ? [AppShadows.subtle] : [],
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.admin_panel_settings,
                                                        size: 40,
                                                        color: _isAdmin ? Colors.white : AppColors.textSecondary,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        'Admin',
                                                        style: AppText.body.copyWith(
                                                          color: _isAdmin ? Colors.white : AppColors.textSecondary,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            
                                            // Standard User Option
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _isAdmin = false;
                                                  });
                                                },
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 300),
                                                  margin: const EdgeInsets.only(left: 8),
                                                  padding: const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    gradient: !_isAdmin 
                                                      ? AppColors.primaryGradient 
                                                      : LinearGradient(
                                                          colors: [Colors.grey.shade100, Colors.grey.shade100],
                                                        ),
                                                    borderRadius: AppBorderRadius.medium,
                                                    border: Border.all(
                                                      color: !_isAdmin 
                                                        ? AppColors.primary 
                                                        : Colors.grey.shade300,
                                                      width: 2,
                                                    ),
                                                    boxShadow: !_isAdmin ? [AppShadows.subtle] : [],
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.person,
                                                        size: 40,
                                                        color: !_isAdmin ? Colors.white : AppColors.textSecondary,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        'Standard User',
                                                        style: AppText.body.copyWith(
                                                          color: !_isAdmin ? Colors.white : AppColors.textSecondary,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 32),
                                    
                                    // Form Fields
                                    Column(
                                      children: [
                                        // Name Field
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Full Name',
                                              style: AppText.body.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.deepCharcoal,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            CustomTextField(
                                              controller: _nameController,
                                              label: '',
                                              hintText: 'Enter your full name',
                                              prefixIcon: Icons.person_outline,
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 20),
                                        
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
                                              prefixIcon: Icons.email_outlined,
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 20),
                                        
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
                                            CustomTextField(
                                              controller: _passwordController,
                                              label: '',
                                              hintText: 'Create a strong password',
                                              keyboardType: TextInputType.visiblePassword,
                                              prefixIcon: Icons.lock_outline,
                                              isPassword: true,
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 20),
                                        
                                        // Admin Email Field (Conditional)
                                        if (!_isAdmin)
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Admin Email Reference',
                                                style: AppText.body.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.deepCharcoal,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              CustomTextField(
                                                controller: _adminEmailController,
                                                label: '',
                                                hintText: 'Enter your admin\'s email',
                                                keyboardType: TextInputType.emailAddress,
                                                prefixIcon: Icons.admin_panel_settings_outlined,
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 32),
                                    
                                    // Register Button
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
                                              onPressed: _register,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Create Account',
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
                                    
                                    // Login Redirect
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Already have an account? ',
                                          
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => const LoginPage()),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: Text(
                                            'Sign In',
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
                        
                        const SizedBox(height: 40),
                        
                        // Footer
                        Text(
                          'Secure • Reliable • Agricultural-Focused',
                          
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