import 'package:flutter/material.dart';

// Week/day grid metrics — `schedule-styles.css` :root + SC_HOURS.

/// `--hour-px` — row height per hour.
const double kHourPx = 60;

/// `--time-gutter`.
const double kGutterWidth = 64;

/// Operating hours 06:00–22:00 inclusive (`SC_HOURS` = 17 labels).
const int kFirstHour = 6;
const int kHourCount = 17;

/// Body height = `SC_HOURS.length × HPX` = 1020px.
const double kBodyHeight = kHourCount * kHourPx;

/// `.week-head, .week-body { min-width: 760px; }` under the 1024px breakpoint.
const double kMinGridWidth = 760;

/// `.week-col.today` faint wash — `rgba(34,197,94,.03)`.
const Color kTodayColumnWash = Color(0x0822C55E);

/// `--shadow-md: 0 4px 12px rgba(17,24,39,.06)` — slot hover elevation.
const BoxShadow kSlotHoverShadow = BoxShadow(
  color: Color(0x0F111827),
  offset: Offset(0, 4),
  blurRadius: 12,
);

/// Pointer y (local to a column) → decimal hour snapped DOWN to 30 minutes.
/// Replicates `hourFromY`: `6 + Math.floor(clamp(y/HPX, 0, 17) * 2) / 2`.
double hourFromDy(double dy) {
  final rel = (dy / kHourPx).clamp(0.0, kHourCount.toDouble());
  return kFirstHour + (rel * 2).floorToDouble() / 2;
}
