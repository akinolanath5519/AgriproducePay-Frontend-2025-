import 'package:agriproduce/screens/market_place/onboarding/assign_role.dart';
import 'package:agriproduce/screens/market_place/onboarding/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:agriproduce/theme/app_theme.dart';
import 'package:agriproduce/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriProducePay',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/assignRole': (context) {
         
          return AssignRoleScreen();
        },
      },
      home: const SplashScreen(),
    );
  }
}
