import 'package:agriproduce/screens/login_page.dart';
import 'package:agriproduce/state_management/token_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  // Ensure proper initialization of Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriProduce',
      theme: lightTheme(), // Light theme using GetWidget
      home: SplashScreen(), // Show SplashScreen initially
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  _navigateToLogin() async {
    await Future.delayed(Duration(seconds: 3), () {}); // Delay for 3 seconds
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.deepPurple, // Set the background color to deep purple
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/splashscreen.png'), // Display the image
              SizedBox(height: 20),
              Text(
                'Simplifying Agriculture, Empowering Trade',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Set text color to white
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Light theme configuration using GetWidget
ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.deepPurple, // Primary color set to deepPurple
    primaryColor: Colors.deepPurple,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: Colors.deepPurpleAccent, // Complementary purple accent
    ),
    scaffoldBackgroundColor: Colors.grey[200], // Light gray background color
    appBarTheme: AppBarTheme(
      color: Colors.deepPurple,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      toolbarTextStyle: TextTheme(
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          fontFamily:
              GoogleFonts.montserrat().fontFamily, // Montserrat for titles
        ),
      ).bodyMedium,
      titleTextStyle: TextTheme(
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          fontFamily:
              GoogleFonts.montserrat().fontFamily, // Montserrat for titles
        ),
      ).titleLarge,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        fontSize: 16.0,
        color: Colors.black,
        fontFamily: GoogleFonts.roboto().fontFamily, // Roboto for body text
      ),
      bodyMedium: TextStyle(
        fontSize: 14.0,
        color: Colors.black87,
        fontFamily: GoogleFonts.roboto().fontFamily, // Roboto for body text
      ),
      labelLarge: TextStyle(
        color: Colors.deepPurple,
        fontFamily: GoogleFonts.lato().fontFamily, // Lato for labels
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple, // Updated button color
        foregroundColor: Colors.white, // Updated text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Increased corner radius
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor:
            Colors.deepPurpleAccent, // Corrected to foregroundColor
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color.fromARGB(
          255, 122, 65, 221), // Floating action button color
      foregroundColor: Colors.white, // Icon color
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[300], // Gray background for input fields
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: Colors.grey.withOpacity(0.3), // Very faint border
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
            color: Colors.deepPurple), // Focused border to deep purple
      ),
      labelStyle: TextStyle(
        color: Colors.deepPurple,
        fontFamily: GoogleFonts.lato().fontFamily, // Lato for labels
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    ),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}