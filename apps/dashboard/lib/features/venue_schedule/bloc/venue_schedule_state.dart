import 'package:freezed_annotation/freezed_annotation.dart';

import '../model/models.dart';
import '../util/schedule_format.dart';

part 'venue_schedule_state.freezed.dart';

/// Load status of the screen's data.
enum VenueScheduleStatus { loading, ready, failure }

/// Which right-side sheet is open (payloads live on the state fields).
enum VenueScheduleSheet { none, detail, create, block }

/// Single state class for the whole "Lịch sân" screen.
///
/// Filtering is live and client-side (no refetch): [visibleVenues] applies
/// the "MÔN" sport filter, [visibleDaySlots]/[visibleWeekSlots] apply the
/// "TRẠNG THÁI" state filter — empty filter sets mean "show all".
@freezed
abstract class VenueScheduleState with _$VenueScheduleState {
  const VenueScheduleState._();

  const factory VenueScheduleState({
    @Default(ScheduleView.day) ScheduleView view,
    @Default(<Venue>[]) List<Venue> venues,

    /// Week-view venue. Set to the first venue on load.
    String? selectedVenueId,

    /// The day the views centre on (date-only, local). Day view shows this
    /// day; Week view its Monday-based week; Month view its month.
    required DateTime focusedDate,

    /// "MÔN" multi-select; empty ⇒ all sports.
    @Default(<SportType>{}) Set<SportType> sportFilter,

    /// "TRẠNG THÁI" multi-select; empty ⇒ all states.
    @Default(<SlotState>{}) Set<SlotState> stateFilter,

    /// All venues' slots for [focusedDate] (Day view).
    @Default(<Slot>[]) List<Slot> daySlots,

    /// Selected venue's slots for the week of [focusedDate] (Week view).
    @Default(<Slot>[]) List<Slot> weekSlots,

    /// Heatmap cells for the month of [focusedDate], full weeks.
    @Default(<OccupancyDay>[]) List<OccupancyDay> monthCells,
    @Default(VenueScheduleStatus.loading) VenueScheduleStatus status,

    /// Transient success message — cleared via `toastCleared` after 3500ms.
    String? toast,
    @Default(VenueScheduleSheet.none) VenueScheduleSheet activeSheet,

    /// Payload when [activeSheet] is [VenueScheduleSheet.detail].
    Slot? detailSlot,

    /// Prefill when [activeSheet] is [VenueScheduleSheet.create].
    CreateSlotRequest? createPrefill,

    /// Prefill when [activeSheet] is [VenueScheduleSheet.block].
    BlockTimeRequest? blockPrefill,
  }) = _VenueScheduleState;

  /// Monday midnight of the focused week (Week-view window).
  DateTime get weekStart => mondayOf(focusedDate);

  /// Venues passing the sport filter — Day-view columns. Empty filter ⇒ all.
  List<Venue> get visibleVenues => sportFilter.isEmpty
      ? venues
      : venues.where((v) => sportFilter.contains(v.sport)).toList();

  /// Day slots passing the state filter. Empty filter ⇒ all.
  List<Slot> get visibleDaySlots => stateFilter.isEmpty
      ? daySlots
      : daySlots.where((s) => stateFilter.contains(s.state)).toList();

  /// Week slots passing the state filter. Empty filter ⇒ all.
  List<Slot> get visibleWeekSlots => stateFilter.isEmpty
      ? weekSlots
      : weekSlots.where((s) => stateFilter.contains(s.state)).toList();

  /// The Week-view venue, or null before venues load.
  Venue? get selectedVenue {
    for (final v in venues) {
      if (v.id == selectedVenueId) return v;
    }
    return null;
  }
}
