import '../model/models.dart';

/// Predictable repository rejection (e.g. a slot id that no longer exists).
///
/// An [Exception] subtype — NOT an `Error` — so the bloc's `on Exception`
/// handlers catch it and emit a failure state instead of letting it escape
/// to `AppBlocObserver.onError` (see the exception-vs-failure convention in
/// CLAUDE.md). Implementations must throw this (or another `Exception`) for
/// anticipated rejections.
class ScheduleRepositoryException implements Exception {
  ScheduleRepositoryException(this.message);

  final String message;

  @override
  String toString() => 'ScheduleRepositoryException: $message';
}

/// Data contract for the "Lịch sân" screen. Abstract so the data source can
/// be swapped (Supabase today, REST later) without touching the service or
/// bloc — the production implementation is `SupabaseScheduleRepository`.
///
/// `courtId` is the facility the screen is scoped to; `venueId` is one
/// playing surface inside it (see the terminology note in `model/models.dart`).
/// `venueId` is either a real `venues.id` uuid or the synthetic
/// `general:<courtId>` sentinel for the venue-less "Chung (cả sân)" lane
/// (`slots.venue_id IS NULL`) — implementations decode the sentinel; it never
/// reaches the backend.
abstract interface class ScheduleRepository {
  /// The authenticated owner's active courts — the schedule's court picker.
  Future<List<ScheduleCourt>> getCourts();

  /// All venues (playing surfaces) of [courtId] — Day-view columns and
  /// Week-view chips — plus the synthetic "Chung (cả sân)" venue appended
  /// last (always present, even for a court with zero venues).
  Future<List<Venue>> getVenues(String courtId);

  /// All of [courtId]'s slots for one [day] (Day view) — every venue lane
  /// plus the venue-less Chung lane.
  Future<List<Slot>> getDaySlots(String courtId, DateTime day);

  /// One venue lane's slots for the 7-day window starting [weekStart] (local
  /// Monday midnight) — Week view. Returned slots carry `weekday` 0..6.
  /// [venueId] may be the `general:<courtId>` sentinel (venue-less slots).
  Future<List<Slot>> getWeekSlots(String venueId, DateTime weekStart);

  /// Occupancy heatmap cells for the full-week grid spanning [month]
  /// (any instant inside the month). Includes leading/trailing other-month
  /// cells with `isCurrentMonth: false`.
  Future<List<OccupancyDay>> getMonthOccupancy(String courtId, DateTime month);

  /// Creates a single bookable slot (empty / open / private).
  Future<Slot> createSlot(CreateSlotRequest req);

  /// Creates [req] on each of [weekdays] (0=Mon..6=Sun) for [weeks]
  /// consecutive weeks — `selectedWeekdays × weeks` slots.
  ///
  /// Returns the number of slots actually created (occurrences that overlap
  /// an existing slot or fall outside operating hours are skipped) — the
  /// count shown in the success toast. The grids re-fetch after a mutation,
  /// so the created rows themselves are not returned.
  Future<int> createRecurringSlots(
    CreateSlotRequest req,
    List<int> weekdays,
    int weeks,
  );

  /// Blocks a time range (locked / maintenance / owner).
  Future<void> blockTime(BlockTimeRequest req);

  /// Approves a pending booking — `pending → confirmed`.
  Future<Slot> approveSlot(String slotId);

  /// Rejects a pending booking; the slot is released.
  Future<void> rejectSlot(String slotId);

  /// Cancels a booking / removes a block.
  Future<void> cancelSlot(String slotId);
}
