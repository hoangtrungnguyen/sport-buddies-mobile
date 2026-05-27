import '../core/result.dart';
import '../models/slot.dart';

export '../models/slot.dart';

/// Repository contract for fetching available slots for a court.
///
/// ```sql
/// SELECT s.id, s.start_time, s.end_time, s.court_id,
///        c.name AS court_name, c.sport_type,
///        s.access_policy, s.max_players, s.current_players
/// FROM slots s
/// JOIN courts c ON c.id = s.court_id
/// WHERE s.court_id = $1
///   AND s.status = 'open'
///   AND s.start_time > NOW()
/// ORDER BY s.start_time ASC
/// ```
abstract interface class SlotRepository {
  /// Returns all open slots for [courtId].
  Future<Result<List<Slot>>> fetchSlots(String courtId);

  /// Returns all open group slots across every court (map panel).
  Future<Result<List<Slot>>> fetchAllGroupSlots();
}
