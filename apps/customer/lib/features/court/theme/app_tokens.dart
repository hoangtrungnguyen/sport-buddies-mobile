import 'package:flutter/material.dart';

/// EPIC-5 "Browse & Pick" design tokens (handoff doc 01 §3–§5).
///
/// Colour comes from [Theme.of(context).colorScheme]; this class carries the
/// non-colour tokens — shape scale, component sizes, motion — plus the few
/// bespoke text styles (price / number displays) that aren't M3 roles.
abstract final class AppTokens {
  AppTokens._();

  // ── Shape scale (doc 01 §3) ────────────────────────────────────────────
  static const double cornerXs = 4;
  static const double cornerSm = 8;
  static const double cornerMd = 12;
  static const double cornerLg = 16;
  static const double cornerXl = 28;
  static const double cornerFull = 9999;

  static const BorderRadius radiusSm = BorderRadius.all(
    Radius.circular(cornerSm),
  );
  static const BorderRadius radiusMd = BorderRadius.all(
    Radius.circular(cornerMd),
  );
  static const BorderRadius radiusLg = BorderRadius.all(
    Radius.circular(cornerLg),
  );
  static const BorderRadius radiusFull = BorderRadius.all(
    Radius.circular(cornerFull),
  );

  // ── Component sizes (doc 01 §5) ────────────────────────────────────────
  static const double buttonInlineHeight = 40;
  static const double buttonSummaryHeight = 48;
  static const double buttonStickyHeight = 56;
  static const double chipHeight = 32;
  static const double iconButtonInline = 40;
  static const double iconButtonAppBar = 48;
  static const double badgeHeight = 24;
  static const double appBarHeight = 64;
  static const double gridCellHeight = 44; // also the min tap target
  static const double minTapTarget = 44;

  // ── Motion (doc 01 §4) ─────────────────────────────────────────────────
  static const Curve easing = Cubic(0.2, 0, 0, 1);
  static const Duration motionFast = Duration(milliseconds: 100);
  static const Duration motionMed = Duration(milliseconds: 200);
  static const Duration motionSlow = Duration(milliseconds: 300);

  // ── Elevation (doc 01 §4) ──────────────────────────────────────────────
  static const List<BoxShadow> elev1 = [
    BoxShadow(color: Color(0x14000000), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 3,
      spreadRadius: 1,
      offset: Offset(0, 1),
    ),
  ];

  /// Tabular figures — every number/time/price uses these (doc 01 §2).
  static const List<FontFeature> tnum = [FontFeature.tabularFigures()];
}
