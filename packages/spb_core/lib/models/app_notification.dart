import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

/// An in-app notification shown to the customer or the owner.
///
/// `type` is a free string so each app can map its own set of values
/// (e.g. `booking_confirmed`, `join_request`, `new_booking`, `cancellation`)
/// without breaking the shared model. [text] is the primary line and [meta]
/// the secondary/detail line.
@freezed
abstract class AppNotification with _$AppNotification {
  const AppNotification._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AppNotification({
    required String id,
    required String type,
    required DateTime createdAt,
    @Default('') String text,
    @Default('') String meta,
    @Default(false) bool isRead,

    /// Optional related entity ids for deep-linking.
    String? bookingId,
    String? slotId,
  }) = _AppNotification;

  bool get isUnread => !isRead;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
