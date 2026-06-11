import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom Material 3 color roles that the standard [ColorScheme] does not
/// cover. Used by the "Sân của tôi" redesign for the *pending* ("Chờ duyệt")
/// status chip. Access via `Theme.of(context).extension<SnbColors>()!`.
@immutable
class SnbColors extends ThemeExtension<SnbColors> {
  const SnbColors({
    required this.warnContainer,
    required this.onWarnContainer,
  });

  final Color warnContainer;
  final Color onWarnContainer;

  static const light = SnbColors(
    warnContainer: Color(0xFFFEF3C0),
    onWarnContainer: Color(0xFF574500),
  );

  @override
  SnbColors copyWith({Color? warnContainer, Color? onWarnContainer}) =>
      SnbColors(
        warnContainer: warnContainer ?? this.warnContainer,
        onWarnContainer: onWarnContainer ?? this.onWarnContainer,
      );

  @override
  SnbColors lerp(ThemeExtension<SnbColors>? other, double t) {
    if (other is! SnbColors) return this;
    return SnbColors(
      warnContainer: Color.lerp(warnContainer, other.warnContainer, t)!,
      onWarnContainer:
          Color.lerp(onWarnContainer, other.onWarnContainer, t)!,
    );
  }
}

/// Material 3 color scheme for the SnB owner dashboard.
///
/// Built from the brand seed `#16A34A` but with the exact role values from the
/// "Sân của tôi" Material 3 handoff forced on top (a plain `fromSeed` would
/// shift the brand green). Semantic conventions baked into the design:
/// - **primary** = actions · **secondaryContainer** = selection
/// - **tertiary** = AI provenance (everything the AI wrote)
const _seed = Color(0xFF16A34A);

ColorScheme _buildScheme() =>
    ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light)
        .copyWith(
      primary: const Color(0xFF16A34A),
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: const Color(0xFFDCFCE7),
      onPrimaryContainer: const Color(0xFF14532D),
      secondary: const Color(0xFF52634F),
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: const Color(0xFFD5E8CE),
      onSecondaryContainer: const Color(0xFF101F0F),
      tertiary: const Color(0xFF0E6F9E),
      onTertiary: const Color(0xFFFFFFFF),
      tertiaryContainer: const Color(0xFFCBE6FF),
      onTertiaryContainer: const Color(0xFF001E30),
      error: const Color(0xFFBA1A1A),
      onError: const Color(0xFFFFFFFF),
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
      surface: const Color(0xFFF8FAF2),
      onSurface: const Color(0xFF191D17),
      onSurfaceVariant: const Color(0xFF43483F),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF2F5EC),
      surfaceContainer: const Color(0xFFECEFE6),
      surfaceContainerHigh: const Color(0xFFE6E9E1),
      surfaceContainerHighest: const Color(0xFFE1E4DB),
      outline: const Color(0xFF73796E),
      outlineVariant: const Color(0xFFC3C8BC),
      inverseSurface: const Color(0xFF2E322B),
      onInverseSurface: const Color(0xFFEFF2E9),
      inversePrimary: const Color(0xFF4ADE80),
    );

ThemeData buildDashboardTheme() {
  final scheme = _buildScheme();
  final textTheme = GoogleFonts.robotoTextTheme(
    ThemeData(brightness: Brightness.light).textTheme,
  ).apply(
    bodyColor: scheme.onSurface,
    displayColor: scheme.onSurface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: textTheme,
    fontFamily: GoogleFonts.roboto().fontFamily,
    extensions: const [SnbColors.light],
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
    ),
    // Cards: M3 elevated, level 1, radius 12 (medium).
    cardTheme: CardThemeData(
      elevation: 1,
      color: scheme.surfaceContainerLowest,
      surfaceTintColor: scheme.surfaceTint,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
    ),
    // Text fields: outlined by default, extra-small radius 4, 56px min height.
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(color: scheme.outlineVariant),
      backgroundColor: scheme.surfaceContainerLowest,
      selectedColor: scheme.secondaryContainer,
      labelStyle: textTheme.labelLarge,
      showCheckmark: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        side: BorderSide(color: scheme.outline),
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(textStyle: textTheme.labelLarge),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
      actionTextColor: scheme.inversePrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
  );
}
