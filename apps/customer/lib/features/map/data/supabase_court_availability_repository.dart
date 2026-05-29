// SupabaseCourtAvailabilityRepository — grava-c9ca.2.1.
//
// Concrete implementation of [CourtAvailabilityRepository] backed by
// Supabase. The query joins `courts` and `slots` to return each approved
// court with the count of future open slots in a single round-trip.
//
// The RPC function `get_courts_with_availability` must exist in the database:
//
// ```sql
// CREATE OR REPLACE FUNCTION get_courts_with_availability()
// RETURNS TABLE (
//   court_id UUID,
//   name     TEXT,
//   lat      DOUBLE PRECISION,
//   lng      DOUBLE PRECISION,
//   open_slot_count BIGINT
// ) LANGUAGE sql STABLE AS $$
//   SELECT
//     c.id          AS court_id,
//     c.name,
//     c.lat,
//     c.lng,
//     COUNT(s.id)   AS open_slot_count
//   FROM courts c
//   LEFT JOIN slots s
//     ON s.court_id = c.id
//    AND s.status   = 'open'
//    AND s.start_time > NOW()
//   WHERE c.status = 'approved'
//   GROUP BY c.id, c.name, c.lat, c.lng;
// $$;
// ```
//
// If a direct SQL RPC is unavailable the same data can be assembled in Dart
// via two separate queries (courts + slot counts). For now the RPC path is
// used; the fallback is left for a later migration task.

import 'package:spb_core/spb_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed [CourtAvailabilityRepository].
///
/// Receives [SupabaseClient] via constructor injection (§6.1) — never reads
/// `Supabase.instance.client` directly.
class SupabaseCourtAvailabilityRepository
    implements CourtAvailabilityRepository {
  const SupabaseCourtAvailabilityRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<List<CourtAvailability>>> fetchCourtsWithAvailability() async {
    try {
      final rows = await _client
          .from('courts')
          .select(
            'id, name, lat, lng, sport_types, slots!left(id, status, start_at)',
          )
          .eq('status', 'approved');

      final courts = (rows as List<dynamic>).map((row) {
        final slots = (row['slots'] as List<dynamic>?) ?? [];
        final now = DateTime.now().toUtc();
        final openSlotCount = slots.where((s) {
          final status = s['status'] as String? ?? '';
          final startTimeRaw = s['start_at'];
          if (status != 'open' || startTimeRaw == null) return false;
          final startTime = DateTime.tryParse(startTimeRaw as String);
          return startTime != null && startTime.isAfter(now);
        }).length;

        final sportTypes = ((row['sport_types'] as List<dynamic>?) ?? [])
            .cast<String>();

        return CourtAvailability(
          courtId: row['id'] as String,
          name: row['name'] as String,
          lat: (row['lat'] as num).toDouble(),
          lng: (row['lng'] as num).toDouble(),
          openSlotCount: openSlotCount,
          sportTypes: sportTypes,
        );
      }).toList();

      return Success(courts);
    } on PostgrestException catch (e) {
      return Failure(ServerFailure(e.code != null ? int.tryParse(e.code!) ?? 0 : 0));
    } catch (_) {
      return const Failure(NetworkFailure());
    }
  }
}
