class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.text,
    required this.meta,
    required this.createdAt,
    required this.isRead,
    this.bookingId,
  });

  final String id;

  /// 'new_booking' | 'cancellation' | 'info' | 'system'
  final String type;
  final String text;
  final String meta;
  final DateTime createdAt;
  final bool isRead;
  final String? bookingId;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        type: (json['type'] as String?) ?? 'info',
        text: (json['text'] as String?) ?? '',
        meta: (json['meta'] as String?) ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
        isRead: (json['is_read'] as bool?) ?? false,
        bookingId: json['booking_id'] as String?,
      );

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        type: type,
        text: text,
        meta: meta,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        bookingId: bookingId,
      );
}
