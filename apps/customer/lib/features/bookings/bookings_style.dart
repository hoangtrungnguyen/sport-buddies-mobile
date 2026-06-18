// Shared MD3 tokens, label helpers and the host-crown glyph for the My
// Bookings feature. Extracted so the screen and its widget units share one
// source of truth.

import 'package:customer/features/bookings/booking_view.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─── MD3 tokens ──────────────────────────────────────────────────────────────
const mdSurface                 = Color(0xFFF7FBF2);
const mdOnSurface               = Color(0xFF181D18);
const mdOnSurfaceVariant        = Color(0xFF414941);
const mdSurfaceContainerLowest  = Color(0xFFFFFFFF);
const mdSurfaceContainer        = Color(0xFFEBEFE6);
const mdSurfaceContainerHighest = Color(0xFFDCE1D7);
const mdPrimary                 = Color(0xFF15803D);
const mdPrimaryContainer        = Color(0xFFBBF7D0);
const mdOnPrimaryContainer      = Color(0xFF002111);
const mdSecondary               = Color(0xFF506352);
const mdSecondaryContainer      = Color(0xFFD3E8D3);
const mdOnSecondaryContainer    = Color(0xFF0E1F10);
const mdTertiary                = Color(0xFF3D6373);
const mdTertiaryContainer       = Color(0xFFC1E8FA);
const mdOnTertiaryContainer     = Color(0xFF001F2A);
const mdError                   = Color(0xFFBA1A1A);
const mdOutlineVariant          = Color(0xFFBFC9BA);
const mdCornerFull = BorderRadius.all(Radius.circular(9999));

// ─── Label helpers ──────────────────────────────────────────────────────────

/// Section header for a booking's date ("TODAY · dd/MM", weekday · dd/MM).
String dateSectionLabel(AppLocalizations l10n, DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(date.year, date.month, date.day);
  final formatted = DateFormat('dd/MM').format(date);
  if (d == today) return '${l10n.bookingsToday} · $formatted';
  if (d == today.add(const Duration(days: 1))) {
    return '${l10n.bookingsTomorrow} · $formatted';
  }
  final weekdays = [
    l10n.bookingsWeekdaySun,
    l10n.bookingsWeekdayMon,
    l10n.bookingsWeekdayTue,
    l10n.bookingsWeekdayWed,
    l10n.bookingsWeekdayThu,
    l10n.bookingsWeekdayFri,
    l10n.bookingsWeekdaySat,
  ];
  return '${weekdays[date.weekday % 7]} · $formatted';
}

/// Localized booking status label from status + role.
String statusLabel(AppLocalizations l10n, BookingStatus status, BookingRole role) =>
    switch (status) {
      BookingStatus.confirmed =>
        role == BookingRole.join ? l10n.bookingStatusApproved : l10n.bookingStatusConfirmed,
      BookingStatus.pending =>
        role == BookingRole.join ? l10n.bookingStatusPendingJoin : l10n.bookingStatusPendingHost,
      BookingStatus.completed => l10n.bookingsFilterCompleted,
      BookingStatus.cancelled => l10n.bookingStatusCancelled,
    };

/// Localized label for a join-request override token.
String overrideLabel(AppLocalizations l10n, String token) => switch (token) {
      'accepted' => l10n.bookingJoinAccepted,
      'rejected' => l10n.bookingJoinRejected,
      _ => l10n.bookingStatusPendingHost,
    };

/// Localized label for an action token.
String actionLabel(AppLocalizations l10n, String token) => switch (token) {
      'rebook' => l10n.bookingActionRebook,
      'detail' => l10n.bookingActionDetail,
      'cancel' => l10n.bookingActionCancel,
      _ => token,
    };

// ─── Host crown icon (SVG path painted) ──────────────────────────────────────

class HostCrown extends StatelessWidget {
  const HostCrown({super.key, this.color = mdPrimary, this.size = 13.0});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CrownPainter(color: color),
    );
  }
}

class _CrownPainter extends CustomPainter {
  const _CrownPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final sx = size.width / 24;
    final sy = size.height / 24;
    final path = Path()
      ..moveTo(3 * sx, 7 * sy)
      ..lineTo(7.5 * sx, 10.5 * sy)
      ..lineTo(12 * sx, 4 * sy)
      ..lineTo(16.5 * sx, 10.5 * sy)
      ..lineTo(21 * sx, 7 * sy)
      ..lineTo(19.4 * sx, 18 * sy)
      ..lineTo(4.6 * sx, 18 * sy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CrownPainter old) => old.color != color;
}
