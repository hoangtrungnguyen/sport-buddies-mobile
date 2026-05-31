import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'access_control_state.freezed.dart';

@freezed
sealed class AccessControlState with _$AccessControlState {
  const factory AccessControlState.idle() = AccessControlIdle;
  const factory AccessControlState.saving() = AccessControlSaving;
  const factory AccessControlState.saved({required String bookingId}) =
      AccessControlSaved;
  const factory AccessControlState.slotTaken() = AccessControlSlotTaken;

  @With<AppExceptionMixin>()
  const factory AccessControlState.failure(
    String message, {
    StackTrace? stackTrace,
  }) = AccessControlFailure;
}
