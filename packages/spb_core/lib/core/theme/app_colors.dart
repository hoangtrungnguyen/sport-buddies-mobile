import 'dart:ui';

/// Shared color palette for SportBuddies.
///
/// Tokens match the design system in `sportbuddies-color-system.md`.
abstract final class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Brand greens
  // ---------------------------------------------------------------------------

  /// Primary CTA / nav active state — dark saturated green.
  static const Color primary = Color(0xFF16A34A);

  /// Hover / pressed state on primary actions.
  static const Color primaryDark = Color(0xFF15803D);

  /// Tinted background for selected chips, active nav bg.
  static const Color primaryLight = Color(0xFFDCFCE7);

  /// Decorative accents.
  static const Color primaryMid = Color(0xFF4ADE80);

  /// Lightest green surface.
  static const Color primary50 = Color(0xFFF0FDF4);

  // ---------------------------------------------------------------------------
  // Secondary / info
  // ---------------------------------------------------------------------------

  static const Color secondary = Color(0xFF0EA5E9);
  static const Color secondaryDark = Color(0xFF0284C7);
  static const Color secondaryLight = Color(0xFFE0F2FE);

  // ---------------------------------------------------------------------------
  // Semantic
  // ---------------------------------------------------------------------------

  /// Available slot pins, confirmed badge.
  static const Color success = Color(0xFF22C55E);
  static const Color successBg = Color(0xFFDCFCE7);

  /// Cancel / reject / fully-booked.
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerBg = Color(0xFFFEE2E2);
  static const Color dangerDark = Color(0xFFDC2626);

  /// Pending status.
  static const Color warning = Color(0xFFEAB308);
  static const Color warningBg = Color(0xFFFEF9C3);

  // ---------------------------------------------------------------------------
  // Neutrals
  // ---------------------------------------------------------------------------

  static const Color neutral900 = Color(0xFF111827);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral50  = Color(0xFFF9FAFB);

  /// Card / sheet / modal background.
  static const Color surface = Color(0xFFFFFFFF);

  /// Page canvas.
  static const Color background = Color(0xFFF9FAFB);

  /// Modal backdrop.
  static const Color overlay = Color(0x7A000000);

  // ---------------------------------------------------------------------------
  // Legacy aliases (keep until customer app is migrated)
  // ---------------------------------------------------------------------------

  /// @deprecated Use [primaryDark] instead.
  static const Color secondary_legacy = Color(0xFF66BB6A);

  /// @deprecated Use [background] instead.
  static const Color surface_legacy = Color(0xFFF5F5F5);

  static const Color error = Color(0xFFB00020);
}
