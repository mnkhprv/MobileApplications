import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../widgets/design_canvas.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// Screen 2 — "Onboarding" (Figma node 1:270).
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const route = '/onboarding';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: DesignCanvas(
          builder: (context, s) => [
            // Mint background (circles + slanted edge) with the 3D character,
            // coin and donut. In Figma those 3D layers use a "multiply" blend,
            // so they are pre-blended onto the background in one image.
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 613.33 * s,
              child: Image.asset('assets/images/onboarding_hero.png', fit: BoxFit.fill),
            ),
            // Headline.
            Positioned(
              left: 54 * s,
              width: 301 * s,
              top: 625 * s,
              child: Text(
                'Ухаалаг Зарцуулж\nИлүү Хэмнэе',
                textAlign: TextAlign.center,
                style: inter(
                  size: 32 * s,
                  weight: FontWeight.w700,
                  color: AppColors.green,
                  letterSpacing: -0.64 * s,
                  height: 1.0,
                ),
              ),
            ),
            // "Эхлэх" button with its soft blurred shadow underneath.
            Positioned(
              left: 31 * s,
              width: 352 * s,
              bottom: (896 - 845) * s,
              height: 36 * s,
              // Figma: #3E7C78 rectangle with a 24px gaussian blur.
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 24 * s, sigmaY: 24 * s),
                child: const ColoredBox(color: AppColors.darkGreen),
              ),
            ),
            Positioned(
              left: 28 * s,
              width: 358 * s,
              bottom: (896 - 745 - 64) * s,
              height: 64 * s,
              child: _GradientButton(
                s: s,
                label: 'Эхлэх',
                onPressed: () => Navigator.of(context).pushNamed(RegisterScreen.route),
              ),
            ),
            // "Хэрэглэгчийн эрх бий юу?   Нэвтрэх"
            Positioned(
              left: 0,
              right: 0,
              bottom: (896 - 850) * s,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'Хэрэглэгчийн Эрх Бий Юу?',
                      overflow: TextOverflow.ellipsis,
                      style: poppins(size: 14 * s, color: AppColors.bodyText),
                    ),
                  ),
                  SizedBox(width: 48 * s),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(LoginScreen.route),
                    child: Text(
                      'Нэвтрэх',
                      style: poppins(size: 14 * s, color: AppColors.link),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.s, required this.label, required this.onPressed});

  final double s;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(40 * s);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.172, 1.234],
          colors: [AppColors.buttonGradientStart, AppColors.buttonGradientEnd],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: inter(
                size: 24 * s,
                weight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.48 * s,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
