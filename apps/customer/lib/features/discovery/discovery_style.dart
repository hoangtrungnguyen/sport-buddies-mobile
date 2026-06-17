// Shared design tokens + small display helpers for the Discovery feature.
// (Material Design 3 surface scale fed the SportBuddies brand colours.)
// Extracted so the screen and its widget units share one source of truth.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:spb_core/spb_core.dart';

// ── Design tokens — MD3 surface/color scale ────────────────────────────────
const mdSurface = Color(0xFFF7FBF2); // header bg (greenish tinted)
const mdOnSurface = Color(0xFF181D17); // primary text
const mdOnSurfaceVariant = Color(0xFF42493F); // secondary text
const mdSurfaceContainerLowest = Color(0xFFFFFFFF); // card bg
const mdSurfaceContainerLow = Color(0xFFF1F6EC); // filter sheet bg
const mdSurfaceContainerHigh = Color(0xFFE5EAE1); // full badge bg
const mdSurfaceContainerHighest = Color(0xFFDFE4DA); // search bar bg
const mdPrimary = Color(0xFF15803D);
const mdOnPrimary = Color(0xFFFFFFFF);
const mdPrimaryContainer = Color(0xFFC9F2D2); // active chip bg
const mdOnPrimaryContainer = Color(0xFF00210B); // active chip text
const mdOutline = Color(0xFF72796C);
const mdOutlineVariant = Color(0xFFC2C8BB); // chip border, divider
const mdN50 = Color(0xFFF3F6F0); // list body bg

// MD3 shape scale
const mdCornerSm = 8.0; // chips, badges
const mdCornerMd = 12.0; // thumbnails
const mdCornerLg = 16.0; // cards
const mdCornerXl = 28.0; // bottom sheets
const double mdCornerFull = 9999.0; // buttons, pills

// Warning palette — all-full banner
const warningBg = Color(0xFFFEF9C3);
const warningBorder = Color(0xFFFDE68A);
const warningText = Color(0xFF92670B);

// ── Per-sport accent (doc 01 §5) ────────────────────────────────────────────
Color sportColorFor(List<String> sportTypes) {
  final t = (sportTypes.firstOrNull ?? '').toLowerCase();
  return switch (t) {
    'football' || 'bóng đá' || 'bóng đá 5v5' => const Color(0xFF16A34A),
    'pickleball' => const Color(0xFF0EA5E9),
    'badminton' || 'cầu lông' => const Color(0xFFEF4444),
    'tennis' => const Color(0xFFEAB308),
    _ => mdOnSurfaceVariant,
  };
}

IconData sportIconFor(List<String> sportTypes) {
  final t = (sportTypes.firstOrNull ?? '').toLowerCase();
  return switch (t) {
    'football' || 'bóng đá' || 'bóng đá 5v5' => Icons.sports_soccer,
    'badminton' || 'cầu lông' => Icons.sports_tennis,
    'pickleball' => Icons.sports_tennis,
    'tennis' => Icons.sports_tennis,
    _ => Icons.sports,
  };
}

/// Distance in km from [userPos] to the court, or null when location is
/// unavailable.
double? courtDistanceKm(CourtAvailability c, LatLng? userPos) {
  if (userPos == null) return null;
  return userPos.distanceTo(LatLng(c.lat, c.lng));
}

String formatKm(double km) =>
    km < 10 ? km.toStringAsFixed(1) : km.toStringAsFixed(0);

/// Localized label for a sport filter slug ('' = all). Falls back to the raw
/// slug for unknown values.
String sportLabelFor(AppLocalizations l10n, String slug) => switch (slug) {
      '' => l10n.sportAll,
      'football' => l10n.sportFootball,
      'pickleball' => l10n.sportPickleball,
      'badminton' => l10n.sportBadminton,
      'tennis' => l10n.sportTennis,
      'multi' => l10n.sportMulti,
      _ => slug,
    };
