// Notifications view layer for the Notifications (Thông báo) screen.
//
// The data model itself is the shared `AppNotification` from spb_core
// (`type` raw string, `text`/`meta` lines, `isRead`). This file keeps the
// customer-only *presentation* concerns: the [NotifType] icon vocabulary and
// the [NotifDay] section bucket, both derived from the core model on demand.

import 'package:spb_core/spb_core.dart';

// Re-export so the screen/tile keep importing AppNotification through this one
// file (they already do) without each needing a spb_core import.
export 'package:spb_core/spb_core.dart' show AppNotification;

/// Presentation category driving the tile icon + filter chips. Derived from the
/// backend `type` string via [notifTypeFromRaw]; unknown types fall back to
/// [NotifType.reminder] so the row still renders.
enum NotifType {
  bookingConfirmed,
  joinRequest,
  reminder,
  playerJoined,
  joinApproved,
  joinRejected,
  cancelled,
  series,
}

/// Date bucket a notification falls into. Drives the section grouping so the
/// display never depends on parsing a human-readable time string.
enum NotifDay { today, yesterday, older }

/// Maps the backend `type` text to a [NotifType].
NotifType notifTypeFromRaw(String raw) => switch (raw.trim()) {
  'booking_request' || 'join_request' => NotifType.joinRequest,
  'booking_confirmed' || 'booking_created' => NotifType.bookingConfirmed,
  'reminder' => NotifType.reminder,
  'player_joined' => NotifType.playerJoined,
  'join_approved' => NotifType.joinApproved,
  'join_rejected' => NotifType.joinRejected,
  'cancelled' || 'booking_cancelled' => NotifType.cancelled,
  'series' || 'series_reminder' => NotifType.series,
  _ => NotifType.reminder,
};

/// Buckets [created] relative to [now] (defaults to wall-clock now).
NotifDay notifDayOf(DateTime created, [DateTime? now]) {
  final ref = now ?? DateTime.now();
  final d = DateTime(created.year, created.month, created.day);
  final today = DateTime(ref.year, ref.month, ref.day);
  final diff = today.difference(d).inDays;
  if (diff <= 0) return NotifDay.today;
  if (diff == 1) return NotifDay.yesterday;
  return NotifDay.older;
}

/// View-layer conveniences derived from the core [AppNotification].
extension NotificationView on AppNotification {
  /// The presentation category for icon/filter purposes.
  NotifType get notifType => notifTypeFromRaw(type);

  /// The section bucket this notification renders under.
  NotifDay get day => notifDayOf(createdAt);
}
