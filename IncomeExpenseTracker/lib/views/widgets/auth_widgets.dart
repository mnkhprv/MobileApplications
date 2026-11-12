import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme.dart';

/// Curved teal header with the two light-blue circles (Register & Login).
List<Widget> authHeader(double s, {required String title, String? subtitle, required double titleTop}) {
  return [
    Positioned(
      left: 0,
      right: 0,
      top: -18 * s,
      height: 287 * s,
      child: SvgPicture.asset('assets/svg/header_curve.svg', fit: BoxFit.fill),
    ),
    Positioned(
      left: -78 * s,
      top: -73 * s,
      width: 234 * s,
      height: 226 * s,
      child: SvgPicture.asset('assets/svg/auth_eclipse.svg', fit: BoxFit.fill),
    ),
    Positioned(
      left: 100 * s,
      right: 20 * s,
      top: titleTop * s,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: poppins(size: 17 * s, weight: FontWeight.w700, color: Colors.white),
      ),
    ),
    if (subtitle != null)
      Positioned(
        left: 100 * s,
        right: 20 * s,
        top: (titleTop + 52) * s,
        child: Text(
          subtitle,
          textAlign: TextAlign.center,
          style: poppins(size: 14 * s, color: Colors.white),
        ),
      ),
  ];
}

/// White rounded input (328 x 54, radius 16) with a grey hint.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.s,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.textInputAction = TextInputAction.next,
  });

  final double s;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16 * s),
      borderSide: BorderSide.none,
    );
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: textInputAction,
      style: poppins(size: 14 * s, color: AppColors.bodyText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: poppins(size: 14 * s, color: AppColors.hint),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.fromLTRB(39 * s, 17 * s, 20 * s, 17 * s),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.green, width: 1.5),
        ),
        errorBorder: border.copyWith(
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: poppins(size: 11 * s, color: Colors.redAccent),
      ),
    );
  }
}

/// Dark-green pill button used on Register and Login.
class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.s,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final double s;
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.darkGreen,
      borderRadius: BorderRadius.circular(40 * s),
      child: InkWell(
        borderRadius: BorderRadius.circular(40 * s),
        onTap: isLoading ? null : onPressed,
        child: Center(
          child: isLoading
              ? SizedBox.square(
                  dimension: 28 * s,
                  child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
              : Text(
                  label,
                  style: poppins(size: 24 * s, weight: FontWeight.w700, color: Colors.white),
                ),
        ),
      ),
    );
  }
}
