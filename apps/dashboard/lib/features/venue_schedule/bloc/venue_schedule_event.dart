import 'package:freezed_annotation/freezed_annotation.dart';

import '../model/models.dart';

part 'venue_schedule_event.freezed.dart';

@freezed
sealed class VenueScheduleEvent with _$VenueScheduleEvent {
  /// Initial load: venues + day slots + week slots + month occupancy for the
  /// court the bloc is scoped to.
  const factory VenueScheduleEvent.started() = VenueScheduleStarted;

  /// Segmented control: Ngày / Tuần / Tháng.
  const factory VenueScheduleEvent.viewChanged(ScheduleView view) =
      VenueScheduleViewChanged;

  /// ‹ / › date navigator — steps by [delta] × (1 day / 1 week / 1 month)
  /// according to the active view.
  const factory VenueScheduleEvent.dateMoved(int delta) =
      VenueScheduleDateMoved;

  /// "Hôm nay" — reset [VenueScheduleState.focusedDate] to today.
  const factory VenueScheduleEvent.todayPressed() = VenueScheduleTodayPressed;

  /// Week-view "SÂN" chip tapped.
  const factory VenueScheduleEvent.venueSelected(String venueId) =
      VenueScheduleVenueSelected;

  /// "MÔN" chip toggled — multi-select; empty set ⇒ all.
  const factory VenueScheduleEvent.sportFilterToggled(SportType sport) =
      VenueScheduleSportFilterToggled;

  /// "TRẠNG THÁI" chip toggled — multi-select; empty set ⇒ all.
  const factory VenueScheduleEvent.stateFilterToggled(SlotState state) =
      VenueScheduleStateFilterToggled;

  /// Slot block tapped → open the detail sheet.
  const factory VenueScheduleEvent.slotTapped(Slot slot) =
      VenueScheduleSlotTapped;

  /// Empty grid area tapped → open the Create sheet prefilled with the venue
  /// + snapped [startHour] (+ [weekday] in Week view, 0=Mon..6=Sun).
  /// Grid taps keep the prototype's 1h default; the header "Tạo slot mới"
  /// button passes the `CreateDrawer` default of 1.5h.
  const factory VenueScheduleEvent.emptyCellTapped(
    String venueId,
    double startHour, {
    int? weekday,
    @Default(1.0) double durationHours,
  }) = VenueScheduleEmptyCellTapped;

  /// Drag-to-block released (range ≥ 0.5h) → open the Block sheet prefilled
  /// with the dragged `[startHour, endHour)` range.
  const factory VenueScheduleEvent.dragBlockRequested(
    String venueId,
    double startHour,
    double endHour, {
    int? weekday,
  }) = VenueScheduleDragBlockRequested;

  /// Month-view cell tapped → jump to Day view focused on [date].
  const factory VenueScheduleEvent.monthDayTapped(DateTime date) =
      VenueScheduleMonthDayTapped;

  /// Create-sheet submit. With [repeat] on, [request] is expanded across
  /// [weekdays] (0=Mon..6=Sun) × [weeks] — `weekdays.length × weeks` slots.
  const factory VenueScheduleEvent.createSlotSubmitted(
    CreateSlotRequest request, {
    @Default(false) bool repeat,
    @Default(<int>[]) List<int> weekdays,
    @Default(4) int weeks,
  }) = VenueScheduleCreateSlotSubmitted;

  /// Block-sheet submit (Khoá giờ / Bảo trì / Sân của tôi). With [repeat]
  /// on, [request] is expanded across [weekdays] (0=Mon..6=Sun) × [weeks] —
  /// recurrence applies to block mode too, like the prototype's CreateDrawer.
  const factory VenueScheduleEvent.blockSubmitted(
    BlockTimeRequest request, {
    @Default(false) bool repeat,
    @Default(<int>[]) List<int> weekdays,
    @Default(4) int weeks,
  }) = VenueScheduleBlockSubmitted;

  /// Detail-sheet "Duyệt" on a pending booking.
  const factory VenueScheduleEvent.approveRequested(String slotId) =
      VenueScheduleApproveRequested;

  /// Detail-sheet "Từ chối" on a pending booking.
  const factory VenueScheduleEvent.rejectRequested(String slotId) =
      VenueScheduleRejectRequested;

  /// Detail-sheet "Huỷ" / "Mở khoá giờ này".
  const factory VenueScheduleEvent.cancelRequested(String slotId) =
      VenueScheduleCancelRequested;

  /// Toast auto-dismiss (3500ms timer in the UI) or manual dismiss.
  const factory VenueScheduleEvent.toastCleared() = VenueScheduleToastCleared;

  /// Any sheet dismissed (scrim tap / ✕ / Huỷ).
  const factory VenueScheduleEvent.sheetClosed() = VenueScheduleSheetClosed;
}
