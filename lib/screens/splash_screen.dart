import 'package:agriproduce/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class SplashStrings {
  static const tagline = 'Simplifying Agriculture,\nFacilitating Trade';
  static const loadingText = 'Loading, please wait...';
  static const logoPath = 'assets/splashscreen.png';
}

class SplashDurations {
  static const splashDelay = Duration(seconds: 3);
  static const logoAnimation = Duration(milliseconds: 1000);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late final Future<void> _navigationFuture;

  @override
  void initState() {
    super.initState();
    _navigationFuture = _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(SplashDurations.splashDelay);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _navigationFuture.ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInLogo(
                    duration: SplashDurations.logoAnimation,
                    child: Image.asset(
                      SplashStrings.logoPath,
                      width: 300,
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.business,
                        size: 50,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Semantics(
                    header: true,
                    child: Text(
                      SplashStrings.tagline,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const PulseLoader(),
                  const SizedBox(height: 30),
                  ExcludeSemantics(
                    child: Text(
                      SplashStrings.loadingText,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.8),
                      ),
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

class FadeInLogo extends StatelessWidget {
  final Duration duration;
  final Widget child;

  const FadeInLogo({
    super.key,
    required this.child,
    this.duration = SplashDurations.logoAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeIn,
      builder: (_, value, child) => Opacity(opacity: value, child: child),
      child: child,
    );
  }
}

class PulseLoader extends StatefulWidget {
  const PulseLoader({super.key});

  @override
  PulseLoaderState createState() => PulseLoaderState();
}

class PulseLoaderState extends State<PulseLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        strokeWidth: 3,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
