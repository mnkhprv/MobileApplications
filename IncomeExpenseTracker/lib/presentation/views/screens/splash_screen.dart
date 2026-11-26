import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

/// Screen 1 — "Splash Screen" (Figma node 1:517).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const route = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), _next);
  }

  void _next() {
    _timer?.cancel();
    if (!mounted) return;
    // A user still signed in from last time (Firebase keeps the session)
    // goes straight to Home.
    final signedIn = context.read<AuthViewModel>().isLoggedIn;
    Navigator.of(context).pushReplacementNamed(
      signedIn ? HomeScreen.route : OnboardingScreen.route,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.sizeOf(context).width / 414;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: GestureDetector(
          onTap: _next,
          child: Container(
            decoration: const BoxDecoration(
              // linear-gradient(153deg, #63B5AF 4.5%, #438883 103%)
              gradient: LinearGradient(
                begin: Alignment(-0.45, -1),
                end: Alignment(0.45, 1),
                stops: [0.045, 1.0],
                colors: [
                  AppColors.splashGradientStart,
                  AppColors.splashGradientEnd,
                ],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Grain texture at 10% opacity.
                Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    'assets/images/splash_noise.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Center(
                  child: Text(
                    'Сайн уу?',
                    style: inter(
                      size: 50 * s,
                      weight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -2 * s,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
