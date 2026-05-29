import 'package:dashboard/core/mixins/app_exception_mixin.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../setup/model/owner_court.dart';
import '../model/manual_booking_result.dart';
import '../model/owner_slot.dart';

part 'schedule_state.freezed.dart';

@freezed
sealed class ScheduleState with _$ScheduleState {
  const factory ScheduleState.initial() = ScheduleInitial;
  const factory ScheduleState.loading() = ScheduleLoading;

  /// Loaded view. [courts] may be empty (owner has no courts yet) — the screen
  /// then shows an empty state directing them to Setup. [activeCourtId] is
  /// empty only when [courts] is empty.
  const factory ScheduleState.loaded({
    required List<OwnerCourt> courts,
    required String activeCourtId,
    required DateTime weekStart,
    required List<OwnerSlot> slots,
    @Default(false) bool busy,

    /// Transient outcome of the most recent manual-booking attempt (OWNER-23).
    /// Set by the bloc when the booking resolves, consumed once by the compose
    /// dialog, then cleared via [ScheduleEvent.bookingResultCleared]. Null in
    /// the steady state.
    ManualBookingResult? bookingResult,
  }) = ScheduleLoaded;

  @With<AppExceptionMixin>()
  const factory ScheduleState.failure(String message,
      {StackTrace? stackTrace}) = ScheduleFailure;
}
