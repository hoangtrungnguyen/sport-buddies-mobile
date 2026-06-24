import 'package:dashboard/core/mixins/app_exception_mixin.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:spb_core/spb_core.dart';

part 'notification_state.freezed.dart';

@freezed
sealed class NotificationState with _$NotificationState {
  const factory NotificationState.initial() = NotificationInitial;
  const factory NotificationState.loading() = NotificationLoading;
  const factory NotificationState.loaded(
    List<AppNotification> notifications, {
    @Default(0) int unreadCount,
  }) = NotificationLoaded;

  @With<AppExceptionMixin>()
  const factory NotificationState.failure(
    String message, {
    StackTrace? stackTrace,
  }) = NotificationFailure;
}
