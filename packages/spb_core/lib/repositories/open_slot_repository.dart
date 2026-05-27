// OpenSlotRepository — grava-c9ca.5.2.
//
// Abstract contract for fetching open slots for a specific court.
// Concrete implementations (e.g. SupabaseOpenSlotRepository)
// live in `apps/customer` so this package stays pure-Dart with no Supabase dep.

import '../core/result.dart';
import '../models/open_slot.dart';

export '../models/open_slot.dart';

/// Repository contract for fetching open slots.
///
/// The canonical query this contract represents:
/// ```sql
/// SELECT
///   s.id,
///   s.start_time,
///   s.end_time,
///   s.court_id,
///   c.name AS court_name,
///   c.sport_type,
///   s.access_policy,
///   s.max_players,
///   s.current_players
/// FROM slots s
/// JOIN courts c ON c.id = s.court_id
/// WHERE s.court_id = $1
///   AND s.status = 'open'
///   AND s.start_time > NOW()
/// ORDER BY s.start_time ASC
/// ```
abstract interface class OpenSlotRepository {
  /// Returns all open slots for a specific court.
  ///
  /// [courtId] is the UUID of the court to fetch slots for.
  ///
  /// On network / server failure returns a [Failure]; on success returns
  /// a [Success] containing the (possibly empty) list.
  Future<Result<List<OpenSlot>>> fetchOpenSlots(String courtId);

  /// Returns all slots opened for group play across every court.
  ///
  /// The canonical query:
  /// ```sql
  /// SELECT s.*, c.name, c.sport_type
  /// FROM slots s JOIN courts c ON c.id = s.court_id
  /// WHERE s.status = 'booked'
  ///   AND s.access_policy = 'open'
  ///   AND s.start_time > NOW()
  /// ORDER BY s.start_time ASC
  /// ```
  Future<Result<List<OpenSlot>>> fetchAllOpenGroupSlots();
}
