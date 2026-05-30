import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'awaiting_confirmation_state.freezed.dart';

@freezed
sealed class AwaitingState with _$AwaitingState {
  const factory AwaitingState.initial() = AwaitingInitial;
  const factory AwaitingState.loading() = AwaitingLoading;

  const factory AwaitingState.loaded({
    required String bookingId,
    required String slotId,
    required String courtName,
    required DateTime slotStart,
    required DateTime slotEnd,
    @Default('pending') String status,
  }) = AwaitingLoaded;

  const factory AwaitingState.confirmed({
    required String bookingId,
    required String slotId,
  }) = AwaitingConfirmed;

  @With<AppExceptionMixin>()
  const factory AwaitingState.error(String message, {StackTrace? stackTrace}) =
      AwaitingError;
}
