// CourtAvailabilityRepository — grava-c9ca.2.1.
//
// Abstract contract for fetching approved courts enriched with their open-slot
// counts. Concrete implementations (e.g. SupabaseCourtAvailabilityRepository)
// live in `apps/customer` so this package stays pure-Dart with no Supabase dep.

import '../core/result.dart';
import '../models/court_availability.dart';

export '../models/court_availability.dart';

/// Repository contract for courts + availability data.
///
/// The canonical query this contract represents:
/// ```sql
/// SELECT
///   c.id,
///   c.name,
///   c.lat,
///   c.lng,
///   COUNT(s.id) AS open_slot_count
/// FROM courts c
/// LEFT JOIN slots s
///   ON s.court_id = c.id
///   AND s.status = 'open'
///   AND s.start_time > NOW()
/// WHERE c.status = 'approved'
/// GROUP BY c.id, c.name, c.lat, c.lng
/// ```
abstract interface class CourtAvailabilityRepository {
  /// Returns all approved courts enriched with their open-slot count.
  ///
  /// On network / server failure returns a [Failure]; on success returns
  /// a [Success] containing the (possibly empty) list.
  Future<Result<List<CourtAvailability>>> fetchCourtsWithAvailability();
}
