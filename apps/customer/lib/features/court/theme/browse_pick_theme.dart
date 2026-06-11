import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_tokens.dart';

/// EPIC-5 "Browse & Pick" Material 3 theme (handoff doc 01).
///
/// Self-contained so the existing app theme is untouched; the three EPIC-5
/// pages wrap their subtree in `Theme(data: buildBrowsePickTheme(), …)`.
/// Every [ColorScheme] field is the exact hex from doc 01 §1 — the prototype
/// values are the contract, not `fromSeed`'s output.
ThemeData buildBrowsePickTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF15803D),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFC9F2D2),
    onPrimaryContainer: Color(0xFF00210B),
    secondary: Color(0xFF0369A1),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFC9E5F5),
    onSecondaryContainer: Color(0xFF001E2E),
    tertiary: Color(0xFF7C5800),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFE08B),
    onTertiaryContainer: Color(0xFF251A00),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFF7FBF2),
    onSurface: Color(0xFF181D17),
    onSurfaceVariant: Color(0xFF42493F),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF1F6EC),
    surfaceContainer: Color(0xFFEBF0E6),
    surfaceContainerHigh: Color(0xFFE5EAE1),
    surfaceContainerHighest: Color(0xFFDFE4DA),
    outline: Color(0xFF72796C),
    outlineVariant: Color(0xFFC2C8BB),
    inverseSurface: Color(0xFF2D322C),
    onInverseSurface: Color(0xFFEEF2E9),
    inversePrimary: Color(0xFFADF0BB),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  final textTheme = _buildTextTheme(scheme);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: textTheme,
    splashFactory: InkRipple.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.titleLarge,
      foregroundColor: scheme.onSurface,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surface,
      side: BorderSide(color: scheme.outlineVariant),
      shape: const RoundedRectangleBorder(borderRadius: AppTokens.radiusSm),
      labelStyle: textTheme.labelLarge,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: AppTokens.radiusMd),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, AppTokens.buttonInlineHeight),
        shape: const StadiumBorder(),
        textStyle: textTheme.labelLarge,
      ),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1),
  );
}

/// Sora for the display/title voice, Plus Jakarta Sans for UI — doc 01 §2.
TextTheme _buildTextTheme(ColorScheme scheme) {
  final onSurface = scheme.onSurface;
  TextStyle sora(double size, double height, FontWeight w) => GoogleFonts.sora(
        fontSize: size,
        height: height / size,
        fontWeight: w,
        color: onSurface,
      );
  TextStyle jakarta(double size, double height, FontWeight w, double spacing) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        height: height / size,
        fontWeight: w,
        letterSpacing: spacing,
        color: onSurface,
      );

  return TextTheme(
    headlineSmall: sora(24, 32, FontWeight.w600),
    titleLarge: sora(22, 28, FontWeight.w600),
    titleMedium: jakarta(16, 24, FontWeight.w600, 0.15),
    titleSmall: jakarta(14, 20, FontWeight.w600, 0.1),
    bodyMedium: jakarta(14, 20, FontWeight.w400, 0.25),
    bodySmall: jakarta(12, 16, FontWeight.w400, 0.4),
    labelLarge: jakarta(14, 20, FontWeight.w600, 0.1),
    labelMedium: jakarta(12, 16, FontWeight.w600, 0.5),
  );
}

/// Built once (google_fonts lookups aren't free); reused by every page.
final ThemeData _browsePickTheme = buildBrowsePickTheme();

/// Wraps an EPIC-5 page subtree in the Browse & Pick M3 theme so the rest of
/// the app's theme is untouched.
class BrowsePickTheme extends StatelessWidget {
  const BrowsePickTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Theme(data: _browsePickTheme, child: child);
}

/// Bespoke number/price display styles (Sora, tabular) — not M3 roles.
extension BrowsePickTextStyles on TextTheme {
  TextStyle priceMedium(ColorScheme s) => GoogleFonts.sora(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w800,
        color: s.onSurface,
        fontFeatures: AppTokens.tnum,
      );

  TextStyle priceLarge(ColorScheme s) => GoogleFonts.sora(
        fontSize: 28,
        height: 34 / 28,
        fontWeight: FontWeight.w700,
        color: s.onSurface,
        fontFeatures: AppTokens.tnum,
      );
}
