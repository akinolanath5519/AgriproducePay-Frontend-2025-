import 'package:flutter/material.dart';
import 'package:agriproduce/screens/home_screen.dart';
import 'package:agriproduce/screens/login_page.dart';
import 'package:agriproduce/screens/company_info_screen.dart';
import 'package:agriproduce/screens/calculator_screen.dart';
import 'package:agriproduce/screens/purchases_screen.dart';
import 'package:agriproduce/screens/profile_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String companyInfo = '/company-info';
  static const String home = '/home';
  static const String calculator = '/calculator';
  static const String purchases = '/purchases';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // DEBUG: Print the route name and arguments
    debugPrint('=== AppRoutes.generateRoute called ===');
    debugPrint('Route name: ${settings.name}');
    debugPrint('Route arguments: ${settings.arguments}');

    switch (settings.name) {
      case login:
        debugPrint('Navigating to LoginPage');
        return MaterialPageRoute(builder: (_) => LoginPage());
      case companyInfo:
        debugPrint('Navigating to CompanyInfoScreen');
        return MaterialPageRoute(builder: (_) => CompanyInfoScreen());
      case home:
        debugPrint('Navigating to HomeScreen');
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case calculator:
        debugPrint('Navigating to CalculatorScreen');
        return MaterialPageRoute(builder: (_) => const CalculatorScreen());
      case purchases:
        debugPrint('Navigating to PurchasesScreen');
        return MaterialPageRoute(builder: (_) => const PurchasesScreen());
      case profile:
        debugPrint('Navigating to ProfileScreen');
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        debugPrint('Unknown route! Navigating to LoginPage by default');
        return MaterialPageRoute(
          builder: (_) => LoginPage(), // Default route
        );
    }
  }

  // Method to navigate back to the home screen
  static void navigateToHome(BuildContext context) {
    debugPrint('Navigating to HomeScreen using navigateToHome');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
