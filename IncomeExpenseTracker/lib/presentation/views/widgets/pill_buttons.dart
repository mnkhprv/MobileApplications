import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Outlined green pill: ИЛГЭЭХ, ДАРААХ, Share Receipt.
class OutlinePillButton extends StatelessWidget {
  const OutlinePillButton({
    super.key,
    required this.s,
    required this.label,
    required this.onPressed,
    this.height = 60,
    this.isLoading = false,
  });

  final double s;
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(40 * s),
      side: const BorderSide(color: AppColors.ring),
    );
    return SizedBox(
      height: height * s,
      child: Material(
        color: Colors.white,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? SizedBox.square(
                    dimension: 22 * s,
                    child: const CircularProgressIndicator(
                      color: AppColors.green,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    label,
                    style: inter(
                      size: 18 * s,
                      weight: FontWeight.w600,
                      color: AppColors.green,
                      letterSpacing: -0.36 * s,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Filled gradient pill with a soft blurred shadow: Төлөх, Баталгаажуулах
/// (Figma group 1:3201 — same colours as the onboarding button).
class GradientPillButton extends StatelessWidget {
  const GradientPillButton({
    super.key,
    required this.s,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final double s;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(40 * s);
    return SizedBox(
      height: 60 * s,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 14 * s,
            right: 14 * s,
            top: 34 * s,
            height: 26 * s,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 24 * s, sigmaY: 24 * s),
              child: const ColoredBox(color: AppColors.darkGreen),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.buttonGradientStart,
                    AppColors.buttonGradientEnd,
                  ],
                  stops: [0.17, 1.23],
                ),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: radius,
                  onTap: isLoading ? null : onPressed,
                  child: Center(
                    child: isLoading
                        ? SizedBox.square(
                            dimension: 24 * s,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            label,
                            style: inter(
                              size: 18 * s,
                              weight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: -0.36 * s,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
