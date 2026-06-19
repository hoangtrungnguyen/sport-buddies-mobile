// Notification domain model for the Notifications (Thông báo) screen.

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

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.day,
    this.unread = false,
  });

  final String id;
  final NotifType type;
  final String title;
  final String body;

  /// Local creation time — formatted for display (relative time) in the
  /// widget layer so the label can be localized.
  final DateTime createdAt;
  final NotifDay day;
  final bool unread;

  /// Same notification, marked read — for optimistic UI updates.
  AppNotification copyAsRead() => AppNotification(
    id: id,
    type: type,
    title: title,
    body: body,
    createdAt: createdAt,
    day: day,
    unread: false,
  );
}
