import 'package:flutter/material.dart';

/// Uygulamanın renk paleti: yaprak yeşili, terracotta ve krem.
class AppColors {
  static const Color primary = Color(0xFF2F5D50);
  static const Color primaryLight = Color(0xFFDCE8E0);
  static const Color accent = Color(0xFFC8693F);
  static const Color background = Color(0xFFF7F4EE);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF1F2A24);
  static const Color muted = Color(0xFF6B756F);
}

class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.background,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
    );
  }
}
