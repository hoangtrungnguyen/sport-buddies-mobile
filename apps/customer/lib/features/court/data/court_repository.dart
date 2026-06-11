// EPIC-5 repository interfaces (handoff doc 04 §2). UI codes against these;
// real Supabase wiring is swapped in later.

import '../domain/court.dart';
import '../domain/schedule.dart';
import '../domain/time_slot.dart';

abstract interface class CourtRepository {
  Future<Court> getCourt(String courtId);
  Future<SportsCenter> getCenter(String centerId);
}

abstract interface class SlotRepository {
  /// Grid for one day (screen 08).
  Future<ScheduleDay> getCenterSchedule(String centerId, DateTime date);

  /// Picker list for one court+day (screen 09) — all statuses; the UI greys
  /// booked/blocked.
  Future<List<TimeSlot>> getSlots(String courtId, DateTime date);

  /// "Slot mở chơi ghép" for a court (joinable, not-full first).
  Future<List<OpenGroupSlot>> getOpenGroupSlots(String courtId);
}
