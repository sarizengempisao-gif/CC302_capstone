import 'package:flutter/material.dart';

/// Shared color palette for TaxiGo. Centralising the colors here keeps the
/// look consistent across screens and avoids magic numbers scattered around.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF1769E0);
  static const primaryDark = Color(0xFF1455C0);
  static const primaryLight = Color(0xFF2789F4);
  static const background = Color(0xFFF5F8FD);
  static const surfaceAlt = Color(0xFFF7F9FC);
  static const borderColor = Color(0xFFE1E8F0);

  /// Gradient used for the blue hero headers on the login screen and the
  /// passenger "book a ride" card.
  static const headerGradient = LinearGradient(
    colors: [primaryDark, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// The blue surface used for stat cards on the admin dashboard.
  static const statSurface = Color(0xFFEFF6FF);
}

/// Reusable heading style (condensed for a compact, strong look).
class AppTextStyles {
  AppTextStyles._();

  static const heading = TextStyle(
    fontFamily: 'TaxiGoDisplay',
    fontSize: 25,
    fontWeight: FontWeight.w800,
  );

  static const subheading = TextStyle(
    fontFamily: 'TaxiGo',
    fontSize: 14,
    color: Colors.black54,
  );

  static const statValue = TextStyle(
    fontFamily: 'TaxiGo',
    fontSize: 24,
    fontWeight: FontWeight.w800,
  );

  static const statLabel = TextStyle(
    fontFamily: 'TaxiGo',
    color: Colors.black54,
  );
}

/// The single source of truth for the app's [ThemeData].
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
  fontFamily: 'TaxiGo',
  scaffoldBackgroundColor: AppColors.background,
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceAlt,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.borderColor),
    ),
  ),
);
