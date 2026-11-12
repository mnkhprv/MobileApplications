import 'package:flutter/material.dart';

/// Colors taken from the Figma design.
class AppColors {
  static const green = Color(0xFF438883); // "GREEN" style in Figma
  static const darkGreen = Color(0xFF3E7C78); // auth buttons
  static const link = Color(0xFF32819A);
  static const authBackground = Color(0xFFF0F0F0);
  static const hint = Color(0xFF858585);
  static const bodyText = Color(0xFF444444);

  static const splashGradientStart = Color(0xFF63B5AF);
  static const splashGradientEnd = Color(0xFF438883);
  static const buttonGradientStart = Color(0xFF69AEA9);
  static const buttonGradientEnd = Color(0xFF3F8782);

  // Home screen
  static const card = Color(0xFF2F7E79);
  static const cardShadow = Color(0xFF1B5C58);
  static const cardLabel = Color(0xFFD0E5E4);
  static const title = Color(0xFF222222);
  static const secondary = Color(0xFF666666); // "Secondary" style in Figma
  static const income = Color(0xFF25A969);
  static const expense = Color(0xFFF95B51); // "Red" style in Figma
  static const iconTile = Color(0xFFF0F6F5);
}

/// Inter is bundled as a variable font, so the weight axis is set explicitly.
TextStyle inter({
  required double size,
  FontWeight weight = FontWeight.w400,
  Color color = Colors.black,
  double? letterSpacing,
  double? height,
}) {
  return TextStyle(
    fontFamily: 'Inter',
    fontSize: size,
    fontWeight: weight,
    fontVariations: [FontVariation('wght', weight.value.toDouble())],
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );
}

/// Poppins has no Cyrillic glyphs, so Mongolian text falls back to Inter.
TextStyle poppins({
  required double size,
  FontWeight weight = FontWeight.w400,
  Color color = Colors.black,
}) {
  return TextStyle(
    fontFamily: 'Poppins',
    fontFamilyFallback: const ['Inter'],
    fontSize: size,
    fontWeight: weight,
    fontVariations: [FontVariation('wght', weight.value.toDouble())],
    color: color,
  );
}

ThemeData buildTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
    fontFamily: 'Inter',
    scaffoldBackgroundColor: Colors.white,
  );
}
