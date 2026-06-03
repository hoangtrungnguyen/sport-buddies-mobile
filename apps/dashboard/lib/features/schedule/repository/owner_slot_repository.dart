import 'package:dashboard/core/debug/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/owner_slot.dart';

/// Predictable failure of a slot action. [code] is a stable key; the bloc maps
/// any throw to a recoverable failure rather than crashing the view.
class OwnerSlotException implements Exception {
  const OwnerSlotException(this.code);

  /// e.g. `not_open` (block guard failed — the slot was no longer open, e.g.
  /// booked) or `not_blocked` (unblock guard failed).
  final String code;

  @override
  String toString() => 'OwnerSlotException($code)';
}

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

  /// Blocks an **open** slot (OWNER-25): `status → blocked`, persisting an
  /// optional [reason] to `blocked_reason`. Guarded so a booked (or otherwise
  /// non-open) slot is never blocked — throws [OwnerSlotException]`('not_open')`
  /// when no open row matched. A blocked slot drops out of the customer picker
  /// automatically (it filters `status = 'open'`).
  Future<void> blockSlot({required String slotId, String? reason});

  /// Unblocks a blocked slot (OWNER-25): `status → open`, clearing
  /// `blocked_reason`. Throws [OwnerSlotException]`('not_blocked')` when the
  /// slot was not blocked.
  Future<void> unblockSlot({required String slotId});
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

  static const _cols =
      'id, court_id, start_at, end_at, status, blocked_reason, max_players';

  @override
  Future<List<OwnerSlot>> fetchWeekSlots({
    required String courtId,
    required DateTime weekStart,
  }) async {
    try {
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
    } catch (e, st) {
      appLogger.e('OwnerSlotRepository.fetchWeekSlots',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<OwnerSlot> createOwnerSlot({
    required String courtId,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    try {
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
    } catch (e, st) {
      appLogger.e('OwnerSlotRepository.createOwnerSlot',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> blockSlot({required String slotId, String? reason}) async {
    try {
      final trimmed = reason?.trim();
      final rows = await _client
          .from('slots')
          .update({
            'status': SlotStatus.blocked,
            'blocked_reason':
                (trimmed != null && trimmed.isNotEmpty) ? trimmed : null,
          })
          .eq('id', slotId)
          .eq('status', SlotStatus.open) // never block a booked/owner/etc. slot
          .select('id');
      if ((rows as List).isEmpty) {
        throw const OwnerSlotException('not_open');
      }
    } catch (e, st) {
      appLogger.e('OwnerSlotRepository.blockSlot', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> unblockSlot({required String slotId}) async {
    try {
      final rows = await _client
          .from('slots')
          .update({'status': SlotStatus.open, 'blocked_reason': null})
          .eq('id', slotId)
          .eq('status', SlotStatus.blocked)
          .select('id');
      if ((rows as List).isEmpty) {
        throw const OwnerSlotException('not_blocked');
      }
    } catch (e, st) {
      appLogger.e('OwnerSlotRepository.unblockSlot', error: e, stackTrace: st);
      rethrow;
    }
  }
}
