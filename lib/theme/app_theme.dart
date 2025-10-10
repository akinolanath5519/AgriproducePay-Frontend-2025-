// lib/theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary colors → Deep Purple
  static const primary = Color(0xFF673AB7); // Deep Purple 500
  static const accent = Color(0xFF4527A0);  // Deep Purple 700
  static const background = Color(0xFFF5F5F5);
  static const textPrimary = Colors.black87;
  static const textSecondary = Colors.grey;
  static const error = Colors.redAccent;

  // Premium
  static const goldAccent = Color(0xFFD4AF37);
  static const deepCharcoal = Color(0xFF2C3E50);
  static const lightCream = Color(0xFFFDF6E3);
  static const successGreen = Color(0xFF27AE60);

  // Extra accent
  static const orangeAccent = Colors.orange;

  // Updated Gradients
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF673AB7), Color(0xFF4527A0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const backgroundGradient = LinearGradient(
    colors: [Color(0xFFF3E5F5), Color(0xFFEDE7F6)], // light purples
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// App Text Styles based on screenshot
class AppText {
  /// App Title (AgriproducePay)
  static const appTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// Greeting (Good morning, John!)
  static const greeting = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Subtitle (overview text)
  static const subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Card Title (Total Purchases, Pending Sacks…)
  static const cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// Card Value (₦2,450,000, 145…)
  static const cardValue = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// Card Status (+12.5%, -8 from yesterday…)
  static const statusPositive = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.successGreen,
  );

  static const statusNegative = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Colors.redAccent,
  );

  /// Section Title (Quick Actions)
  static const sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Quick Action Labels
  static const quickAction = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// Bottom Navigation Labels
  static const navLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Buttons
  static const button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static var body = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
}

// Shadows
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

// Border radius
class AppBorderRadius {
  static const small = BorderRadius.all(Radius.circular(8));
  static const medium = BorderRadius.all(Radius.circular(16));
  static const large = BorderRadius.all(Radius.circular(24));
  static const extraLarge = BorderRadius.all(Radius.circular(32));
}

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Poppins', // 👈 use Poppins for consistency
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.accent,
    error: AppColors.error,
    background: AppColors.background,
    surface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,   // ✅ White background
    foregroundColor: Colors.black,   // ✅ Icons & text in black for contrast
    elevation: 0,                     // ✅ Flat, no shadow (optional)
     
   
  ),
  textTheme: TextTheme(
    headlineSmall: AppText.greeting,
    bodyLarge: AppText.body,
    bodyMedium: AppText.subtitle,
    titleLarge: AppText.sectionTitle,
    labelLarge: AppText.button,
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
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  dialogTheme: const DialogTheme(
    backgroundColor: Colors.white,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.deepCharcoal,
    ),
  ),
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

extension ThemeExtensions on ThemeData {
  Gradient get primaryGradient => AppColors.primaryGradient;
  Gradient get backgroundGradient => AppColors.backgroundGradient;
  BoxShadow get subtleShadow => AppShadows.subtle;
  BoxShadow get mediumShadow => AppShadows.medium;
  BorderRadius get mediumBorderRadius => AppBorderRadius.medium;
  BorderRadius get largeBorderRadius => AppBorderRadius.large;
}


class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Stack(
        children: [
          // Circle top-left
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
          // Circle bottom-right
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
          // Page content
          child,
        ],
      ),
    );
  }
}
