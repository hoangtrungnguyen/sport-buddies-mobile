import 'package:dashboard/core/debug/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/booking_request.dart';
import '../requests_logic.dart';

/// Read contract for the owner's incoming booking requests (OWNER-27). An
/// interface so the bloc can be driven by an in-memory fake in tests; the
/// concrete impl talks to Supabase.
abstract interface class BookingRequestRepository {
  /// All booking requests whose slot starts on the calendar day of [day]
  /// (local). Scoped to the authenticated owner's courts by RLS
  /// (`courts.owner_id = auth.uid()`). Order is **not** guaranteed — the bloc
  /// sorts ascending by start time (`sortByStartAsc`).
  Future<List<BookingRequest>> fetchForDay({required DateTime day});
}

/// Supabase-backed [BookingRequestRepository].
///
/// Query shape mirrors the verified customer read path
/// (`bookings.select('*, slots(*, courts(*))')`) with two additions for the
/// owner queue:
///
/// 1. `slots!inner(...)` — an **inner** join so a booking whose slot falls
///    outside the day window is dropped (a plain join would keep the parent row
///    with a null `slots`, which we'd then have to filter client-side).
/// 2. A `start_at` range on the referenced `slots` table bounding the local
///    day `[00:00, next-00:00)`, sent as UTC ISO-8601 (slots store UTC).
///
/// The owner scoping itself is **not** expressed in this query — it relies on
/// RLS policies restricting `bookings`/`slots` to `courts.owner_id =
/// auth.uid()`. If those policies are absent, this would over-return; confirming
/// them is a backend follow-up (filed separately).
class SupabaseBookingRequestRepository implements BookingRequestRepository {
  const SupabaseBookingRequestRepository(this._client);

  final SupabaseClient _client;

  // Schema: slots.court_id → courts ← venues.court_id (reverse FK).
  // venues is reached via courts, not directly from slots.
  static const _select =
      '*, slots!inner(id, start_at, end_at, courts(name, price_per_hour, venues(sport_type, price_per_hour)))';

  @override
  Future<List<BookingRequest>> fetchForDay({required DateTime day}) async {
    try {
      final start = dayStartLocal(day);
      final end = start.add(const Duration(days: 1));
      // No server-side ordering: PostgREST's `order` on an embedded resource only
      // reorders the nested object, not the parent `bookings` rows. The bloc owns
      // the sort (sortByStartAsc), so ordering here would be a no-op.
      final rows = await _client
          .from('bookings')
          .select(_select)
          .gte('slots.start_at', start.toUtc().toIso8601String())
          .lt('slots.start_at', end.toUtc().toIso8601String());
      return (rows as List)
          .cast<Map<String, dynamic>>()
          // Defensive: skip any row whose slot join came back null (e.g. RLS
          // hid the referenced slot) so it never crashes the mapper.
          .where((r) => r['slots'] != null)
          .map(BookingRequest.fromRow)
          .toList();
    } catch (e, st) {
      appLogger.e('BookingRequestRepository.fetchForDay',
          error: e, stackTrace: st);
      rethrow;
    }
  }
}
