import 'package:flutter/material.dart';
import 'package:spb_core/core/theme/app_colors.dart';

/// Builds the Material 3 light [ThemeData] for SportBuddies customer app.
///
/// Consumes [AppColors] from `spb_core` so color definitions stay in one place.
ThemeData buildLightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surface,
    error: AppColors.error,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
  );
}
