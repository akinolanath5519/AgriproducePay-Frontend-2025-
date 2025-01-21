import 'package:flutter/material.dart';
import 'package:agriproduce/screens/home_screen.dart'; // Import your Home Screen
import 'package:agriproduce/screens/login_page.dart';
import 'package:agriproduce/screens/company_info_screen.dart';
import 'package:agriproduce/screens/calculator_screen.dart'; // Import your Calculator Screen
import 'package:agriproduce/screens/purchases_screen.dart'; // Import your Purchases Screen
import 'package:agriproduce/screens/profile_screen.dart'; // Import your Profile Screen

class AppRoutes {
  static const String login = '/';
  static const String companyInfo = '/company-info';
  static const String home = '/home';
  static const String calculator = '/calculator';
  static const String purchases = '/purchases';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case companyInfo:
        return MaterialPageRoute(builder: (_) => CompanyInfoScreen());
      case home:
        final bool isAdmin = settings.arguments as bool? ?? false;
        return MaterialPageRoute(builder: (_) => HomeScreen(isAdmin: isAdmin));
      case calculator:
        return MaterialPageRoute(builder: (_) => CalculatorScreen(isAdmin: false)); // Pass isAdmin: false for non-admin
      case purchases:
        return MaterialPageRoute(builder: (_) => PurchasesScreen(isAdmin: false));
      case profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => LoginPage(), // Default route
        );
    }
  }

  // Method to navigate back to the home screen
  static void navigateToHome(BuildContext context, {required bool isAdmin}) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(isAdmin: isAdmin)),
      (Route<dynamic> route) => false,
    );
  }
}