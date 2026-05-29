import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/owner_slot.dart';

/// Read/write contract for owner-side slots. An interface so the bloc can be
/// driven by an in-memory fake in tests (the concrete impl talks to Supabase).
abstract interface class OwnerSlotRepository {
  /// All slots for [courtId] whose start falls inside the 7-day window
  /// beginning [weekStart] (local midnight Monday), ordered chronologically.
  /// Unlike the customer query this is **not** filtered by status — the owner
  /// sees booked / pending / owner / blocked / maintenance slots alike.
  Future<List<OwnerSlot>> fetchWeekSlots({
    required String courtId,
    required DateTime weekStart,
  });

  /// Creates an owner reservation (OWNER-19) for `[startAt, endAt)` on
  /// [courtId]. Persisted with `status = 'owner'` so it is hidden from the
  /// customer slot picker (OWNER-81) and carries no payment (OWNER-82).
  Future<OwnerSlot> createOwnerSlot({
    required String courtId,
    required DateTime startAt,
    required DateTime endAt,
  });
}

/// Supabase-backed [OwnerSlotRepository].
///
/// Column contract matches the verified customer read path
/// (`apps/customer/.../supabase_slot_repository.dart`): the `slots` table has
/// `id, court_id, start_at, end_at, status`.
///
/// NOTE — owner status: writing `status = 'owner'` assumes `slots.status` is
/// free text (or its CHECK / enum already allows `owner`). If the column is a
/// constrained Postgres enum, the backend needs:
///
/// ```sql
/// ALTER TYPE slot_status ADD VALUE IF NOT EXISTS 'owner';
/// -- or, for a CHECK constraint, add 'owner' to the allowed set.
/// ```
class SupabaseOwnerSlotRepository implements OwnerSlotRepository {
  const SupabaseOwnerSlotRepository(this._client);

  final SupabaseClient _client;

  static const _cols = 'id, court_id, start_at, end_at, status';

  @override
  Future<List<OwnerSlot>> fetchWeekSlots({
    required String courtId,
    required DateTime weekStart,
  }) async {
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = start.add(const Duration(days: 7));
    final rows = await _client
        .from('slots')
        .select(_cols)
        .eq('court_id', courtId)
        .gte('start_at', start.toUtc().toIso8601String())
        .lt('start_at', end.toUtc().toIso8601String())
        .order('start_at');
    return (rows as List)
        .map((r) => OwnerSlot.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<OwnerSlot> createOwnerSlot({
    required String courtId,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    final row = await _client
        .from('slots')
        .insert({
          'court_id': courtId,
          'start_at': startAt.toUtc().toIso8601String(),
          'end_at': endAt.toUtc().toIso8601String(),
          'status': SlotStatus.owner,
        })
        .select(_cols)
        .single();
    return OwnerSlot.fromRow(row);
  }
}
