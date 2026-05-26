import 'dart:ui';

/// Shared color palette for SportBuddies.
///
/// Uses [dart:ui] [Color] so this file has no dependency on the Flutter SDK —
/// it can be consumed by any Dart target (Flutter, Dart CLI, etc.).
///
/// Color constants follow the Material 3 role naming convention so they map
/// directly to [ColorScheme] roles in `app_theme.dart`.
abstract final class AppColors {
  AppColors._();

  /// Primary brand color — SportBuddies green.
  static const Color primary = Color(0xFF2E7D32);

  /// Secondary accent — lighter green complement.
  static const Color secondary = Color(0xFF66BB6A);

  /// Surface — near-white for cards and sheets.
  static const Color surface = Color(0xFFF5F5F5);

  /// Background — white canvas.
  static const Color background = Color(0xFFFFFFFF);

  /// Error — Material-standard red.
  static const Color error = Color(0xFFB00020);
}
