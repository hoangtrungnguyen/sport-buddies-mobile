import 'package:dashboard/core/debug/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/slot_player.dart';
import '../slot_roster_logic.dart';

/// Read contract for the players registered in a slot (OWNER-33). An interface
/// so the bloc can be driven by an in-memory fake in tests.
abstract interface class SlotPlayersRepository {
  /// The roster for [slotId], scoped to the owner's courts by RLS.
  Future<List<SlotPlayer>> fetchPlayers({required String slotId});
}

/// Supabase-backed [SlotPlayersRepository].
///
/// Reads only what the court owner can see under RLS, in two simple queries (no
/// embedded joins, so no PostgREST 400 risk):
/// - `slot_participants` (owner-readable via `slot_participants_select`) → the
///   real `payment_status` per player;
/// - `bookings` (owner-readable via `bookings_select_owner`) → booking status +
///   walk-in `customer_name`.
///
/// It deliberately does NOT embed `customers`/`profiles`: under the owner's JWT
/// that table is not readable for other players (only `customers_select_self`),
/// so the join would return null anyway — names come from `customer_name` or a
/// fallback. Once the backend adds an owner-scoped policy (BCORE bug), add a
/// `customers(full_name, avatar_url)` embed and [mergeSlotRoster] will pick it
/// up automatically.
class SupabaseSlotPlayersRepository implements SlotPlayersRepository {
  const SupabaseSlotPlayersRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<SlotPlayer>> fetchPlayers({required String slotId}) async {
    try {
      final participants = await _client
          .from('slot_participants')
          .select('id, user_id, payment_status, payment_method, joined_at')
          .eq('slot_id', slotId)
          .order('joined_at');
      final bookings = await _client
          .from('bookings')
          .select('id, user_id, status, customer_name, is_walk_in, total_price')
          .eq('slot_id', slotId)
          .neq('status', 'cancelled');
      return mergeSlotRoster(
        participants: (participants as List).cast<Map<String, dynamic>>(),
        bookings: (bookings as List).cast<Map<String, dynamic>>(),
      );
    } catch (e, st) {
      appLogger.e('SlotPlayersRepository.fetchPlayers',
          error: e, stackTrace: st);
      rethrow;
    }
  }
}
