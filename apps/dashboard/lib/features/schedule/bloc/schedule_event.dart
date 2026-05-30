import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_event.freezed.dart';

@freezed
sealed class ScheduleEvent with _$ScheduleEvent {
  /// Initial load: fetch courts, then this week's slots for the first court.
  const factory ScheduleEvent.started() = ScheduleStarted;

  /// Owner picked a different court tab.
  const factory ScheduleEvent.courtSelected(String courtId) =
      ScheduleCourtSelected;

  /// Step the visible week by [weekStart] (Monday midnight).
  const factory ScheduleEvent.weekChanged(DateTime weekStart) =
      ScheduleWeekChanged;

  /// Jump back to the week containing today.
  const factory ScheduleEvent.todayPressed() = ScheduleTodayPressed;

  /// Persist a new owner reservation for the active court (OWNER-19).
  const factory ScheduleEvent.ownerSlotCreated({
    required DateTime startAt,
    required DateTime endAt,
  }) = ScheduleOwnerSlotCreated;

  /// Record a manual walk-in booking for the active court (OWNER-20).
  /// [startAt]/[endAt] are local instants; [customerPhone] is already
  /// E.164-normalized (or null).
  const factory ScheduleEvent.manualBookingCreated({
    required DateTime startAt,
    required DateTime endAt,
    String? customerName,
    String? customerPhone,
    String? notes,
    int? pricePerHourOverride,
  }) = ScheduleManualBookingCreated;

  /// Acknowledge + clear the transient [ScheduleLoaded.bookingResult] after the
  /// compose dialog has reacted to it (OWNER-23), so a re-opened dialog or a
  /// later reload never re-triggers the same success/error signal.
  const factory ScheduleEvent.bookingResultCleared() =
      ScheduleBookingResultCleared;

  /// Block an open slot (OWNER-25): `status → blocked` with an optional
  /// [reason], then reload the week.
  const factory ScheduleEvent.slotBlocked(
    String slotId, {
    String? reason,
  }) = ScheduleSlotBlocked;

  /// Unblock a blocked slot (OWNER-25): `status → open`, then reload the week.
  const factory ScheduleEvent.slotUnblocked(String slotId) =
      ScheduleSlotUnblocked;
}
