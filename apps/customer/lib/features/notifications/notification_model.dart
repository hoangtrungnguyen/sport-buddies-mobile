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
/// display never depends on parsing the human-readable [AppNotification.time]
/// string.
enum NotifDay { today, yesterday, older }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.day,
    this.unread = false,
  });

  final String id;
  final NotifType type;
  final String title;
  final String body;
  final String time;
  final NotifDay day;
  final bool unread;

  /// Same notification, marked read — for optimistic UI updates.
  AppNotification copyAsRead() => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        time: time,
        day: day,
        unread: false,
      );
}
