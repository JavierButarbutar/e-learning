import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryDark    = Color(0xFF1B5E20);
  static const Color primary        = Color(0xFF2E7D32);
  static const Color primaryMid     = Color(0xFF388E3C);
  static const Color primaryLight   = Color(0xFF43A047);
  static const Color primarySurface = Color(0xFFEAF4EA);
  static const Color primaryBorder  = Color(0xFFC5E0C5);

  static const Color accent         = Color(0xFFF5A623);
  static const Color accentLight    = Color(0xFFFFF3CD);
  static const Color accentBorder   = Color(0xFFF5C842);

  static const Color bg             = Color(0xFF1E6B1E);
  static const Color surface        = Color(0xFFFFFFFF);

  static const Color textPrimary    = Color(0xFF1A3A1A);
  static const Color textSecondary  = Color(0xFF6B7C6B);
  static const Color textHint       = Color(0xFF6B9B6B);

  static const Color divider        = Color(0xFFE8F0E8);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}