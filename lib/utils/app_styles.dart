import 'package:flutter/material.dart';
import 'package:kajjafisioapp/utils/app_colors.dart';

class AppStyles {
  static const TextStyle headlineStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static const TextStyle subheadlineStyle = TextStyle(
    fontSize: 16,
    color: AppColors.textColor,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    fontSize: 14,
    color: AppColors.textColor,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle linkTextStyle = TextStyle(
    fontSize: 14,
    color: AppColors.linkColor,
    fontWeight: FontWeight.w500,
  );

  static InputDecoration textFieldDecoration({String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: AppColors.accentColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      suffixIcon: suffixIcon,
    );
  }
}