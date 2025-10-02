// lib/theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF9DC183); // Sage Green (#9DC183)
  static const accent = Color(0xFF6A994E);  // A darker green for contrast
  static const background = Color(0xFFF5F5F5);
  static const textPrimary = Colors.black87;
  static const textSecondary = Colors.grey;
  static const error = Colors.redAccent;
  
  // Premium enhancements - NEW
  static const goldAccent = Color(0xFFD4AF37); // Luxury gold
  static const deepCharcoal = Color(0xFF2C3E50); // Sophisticated dark
  static const lightCream = Color(0xFFFDF6E3); // Warm cream
  static const successGreen = Color(0xFF27AE60); // Positive actions
  
  // Gradient combinations - NEW
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF9DC183), Color(0xFF6A994E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const backgroundGradient = LinearGradient(
    colors: [Color(0xFFF8FDF8), Color(0xFFE8F4E8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// App Text Styles
class AppText {
  static const heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const bodySecondary = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  // Premium typography enhancements - NEW
  static const displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.deepCharcoal,
    letterSpacing: -0.5,
  );
  
  static const elegantBody = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.deepCharcoal,
    height: 1.6,
  );
  
  static const captionLuxury = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );
}

// Premium shadows system - NEW
class AppShadows {
  static const subtle = BoxShadow(
    color: Colors.black12,
    blurRadius: 8,
    offset: Offset(0, 2),
  );
  
  static const medium = BoxShadow(
    color: Colors.black26,
    blurRadius: 16,
    offset: Offset(0, 4),
  );
  
  static const premium = BoxShadow(
    color: Colors.black38,
    blurRadius: 24,
    offset: Offset(0, 8),
  );
  
  static const glow = BoxShadow(
    color: Color(0x339DC183),
    blurRadius: 20,
    offset: Offset(0, 0),
  );
}

// Premium border radii - NEW
class AppBorderRadius {
  static const small = BorderRadius.all(Radius.circular(8));
  static const medium = BorderRadius.all(Radius.circular(16));
  static const large = BorderRadius.all(Radius.circular(24));
  static const extraLarge = BorderRadius.all(Radius.circular(32));
}

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.accent,
    error: AppColors.error,
    background: AppColors.background,
    surface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(16),
      ),
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 16),
    bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 14),
    titleLarge: TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    // Premium text additions - NEW
    displayLarge: TextStyle(
      color: AppColors.deepCharcoal,
      fontWeight: FontWeight.w700,
      fontSize: 32,
      letterSpacing: -0.5,
    ),
    labelLarge: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 16,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      textStyle: AppText.button,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.3),
      // Premium button enhancements - NEW
      minimumSize: const Size(88, 48),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    margin: const EdgeInsets.all(8),
  ),
  // NEW: Floating action button theme
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  // NEW: Dialog theme for premium feel
  dialogTheme: DialogTheme(
    backgroundColor: Colors.white,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.deepCharcoal,
    ),
  ),
  // NEW: Bottom sheet theme
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
  ),
);

// Premium extensions for easy access - NEW
extension ThemeExtensions on ThemeData {
  // Custom getters for premium elements
  Gradient get primaryGradient => AppColors.primaryGradient;
  Gradient get backgroundGradient => AppColors.backgroundGradient;
  BoxShadow get subtleShadow => AppShadows.subtle;
  BoxShadow get mediumShadow => AppShadows.medium;
  BorderRadius get mediumBorderRadius => AppBorderRadius.medium;
  BorderRadius get largeBorderRadius => AppBorderRadius.large;
}