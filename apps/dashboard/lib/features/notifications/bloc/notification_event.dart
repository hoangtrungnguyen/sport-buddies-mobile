import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_event.freezed.dart';

@freezed
sealed class NotificationEvent with _$NotificationEvent {
  const factory NotificationEvent.loadRequested() = NotificationLoadRequested;
  const factory NotificationEvent.markAllReadRequested() =
      NotificationMarkAllReadRequested;
  const factory NotificationEvent.realtimeReceived() =
      NotificationRealtimeReceived;
}
