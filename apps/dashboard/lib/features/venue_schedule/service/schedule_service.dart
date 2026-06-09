import '../model/models.dart';
import '../repository/schedule_repository.dart';
import '../util/schedule_format.dart';

/// One concrete session of a recurrence preview — "T3 · tuần 2".
class RecurrenceSession {
  const RecurrenceSession({
    required this.weekday,
    required this.weekIndex,
    required this.date,
  });

  /// 0 = Mon … 6 = Sun.
  final int weekday;

  /// 0-based week offset from the anchor week.
  final int weekIndex;
  final DateTime date;

  /// Preview-chip label, e.g. "T3 · tuần 2".
  String get label => '${weekdayShortLabels[weekday]} · tuần ${weekIndex + 1}';
}

/// Business logic for the "Lịch sân" screen. Wraps the abstract
/// [ScheduleRepository] (constructor-injected, swappable) and adds the pure
/// helpers the bloc/sheets need: recurrence expansion preview and slot
/// overlap validation.
class ScheduleService {
  ScheduleService(this._repo);

  final ScheduleRepository _repo;

  // ---------------------------------------------------------------------------
  // Repository pass-throughs — the bloc depends only on the service
  // ---------------------------------------------------------------------------

  Future<List<Venue>> getVenues(String courtId) => _repo.getVenues(courtId);

  Future<List<Slot>> getDaySlots(String courtId, DateTime day) =>
      _repo.getDaySlots(courtId, day);

  Future<List<Slot>> getWeekSlots(String venueId, DateTime weekStart) =>
      _repo.getWeekSlots(venueId, weekStart);

  Future<List<OccupancyDay>> getMonthOccupancy(
          String courtId, DateTime month) =>
      _repo.getMonthOccupancy(courtId, month);

  Future<Slot> createSlot(CreateSlotRequest req) => _repo.createSlot(req);

  Future<int> createRecurringSlots(
    CreateSlotRequest req,
    List<int> weekdays,
    int weeks,
  ) =>
      _repo.createRecurringSlots(req, weekdays, weeks);

  Future<void> blockTime(BlockTimeRequest req) => _repo.blockTime(req);

  Future<Slot> approveSlot(String slotId) => _repo.approveSlot(slotId);

  Future<void> rejectSlot(String slotId) => _repo.rejectSlot(slotId);

  Future<void> cancelSlot(String slotId) => _repo.cancelSlot(slotId);

  // ---------------------------------------------------------------------------
  // Pure helpers
  // ---------------------------------------------------------------------------

  /// Expands a "Lặp lại nhiều buổi" selection into the concrete sessions it
  /// would create: `selectedWeekdays × weeks`, chronological. Drives the
  /// Create-sheet preview card ("Sẽ tạo N slot · T3, T5 · 4 tuần · …") and its
  /// chips; the anchor week is the week containing [anchorDate].
  List<RecurrenceSession> expandRecurrence({
    required DateTime anchorDate,
    required List<int> weekdays,
    required int weeks,
  }) {
    final anchorWeek = mondayOf(anchorDate);
    final sorted = [...weekdays]..sort();
    return [
      for (var w = 0; w < weeks; w++)
        for (final weekday in sorted)
          RecurrenceSession(
            weekday: weekday,
            weekIndex: w,
            date: DateTime(
              anchorWeek.year,
              anchorWeek.month,
              anchorWeek.day + w * 7 + weekday,
            ),
          ),
    ];
  }

  /// True when `[startHour, startHour + durationHours)` collides with an
  /// existing slot of [venueId] in [slots].
  ///
  /// [date]/[weekday] narrow the check to one day — pass whichever the view
  /// uses (Day view: [date]; Week view: [weekday]). Slots in [ignoreStates]
  /// (default: none) don't count; pass `{SlotState.empty}` to allow booking
  /// over an empty placeholder.
  bool hasOverlap(
    List<Slot> slots, {
    required String venueId,
    required double startHour,
    required double durationHours,
    DateTime? date,
    int? weekday,
    Set<SlotState> ignoreStates = const {},
  }) {
    final endHour = startHour + durationHours;
    return slots.any((s) {
      if (s.venueId != venueId) return false;
      if (ignoreStates.contains(s.state)) return false;
      if (weekday != null && s.weekday != weekday) return false;
      if (date != null && s.date != null && !_sameDay(s.date!, date)) {
        return false;
      }
      return s.startHour < endHour && s.endHour > startHour;
    });
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
