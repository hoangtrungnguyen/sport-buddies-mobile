import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:spb_core/spb_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed [SlotRepository] implementation.
class SupabaseSlotRepository implements SlotRepository {
  SupabaseSlotRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  @visibleForTesting
  Future<List<Map<String, dynamic>>> fetchRows(String courtId) async {
    final now = DateTime.now().toUtc().toIso8601String();

    final rows = await _client
        .from('slots')
        .select('''
          id,
          start_time,
          end_time,
          court_id,
          courts!inner(name, sport_type),
          access_policy,
          max_players,
          current_players
        ''')
        .eq('court_id', courtId)
        .eq('status', 'open')
        .gt('start_time', now)
        .order('start_time', ascending: true);

    return (rows as List<dynamic>).map<Map<String, dynamic>>((row) {
      final court = row['courts'] as Map<String, dynamic>?;
      return {
        'id': row['id'] as String,
        'start_time': row['start_time'] as String,
        'end_time': row['end_time'] as String,
        'court_id': row['court_id'] as String,
        'court_name': court?['name'] as String? ?? '',
        'sport_type': court?['sport_type'] as String? ?? 'badminton',
        'access_policy': row['access_policy'] as String? ?? 'open',
        'max_players': row['max_players'] as int? ?? 4,
        'current_players': row['current_players'] as int? ?? 0,
      };
    }).toList();
  }

  @override
  Future<Result<List<Slot>>> fetchSlots(String courtId) async {
    try {
      final rows = await fetchRows(courtId);
      final slots = rows.map(Slot.fromJson).toList();
      return Success(slots);
    } on PostgrestException catch (e) {
      final code = int.tryParse(e.code ?? '') ?? 500;
      return Failure(ServerFailure(code));
    } catch (_) {
      return const Failure(NetworkFailure());
    }
  }

  @override
  Future<Result<List<Slot>>> fetchAllGroupSlots() async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final rows = await _client
          .from('slots')
          .select('''
            id,
            start_time,
            end_time,
            court_id,
            courts!inner(name, sport_type),
            access_policy,
            max_players,
            current_players
          ''')
          .eq('status', 'open')
          .eq('access_policy', 'open')
          .gt('start_time', now)
          .order('start_time', ascending: true);

      final slots = (rows as List<dynamic>).map<Slot>((row) {
        final court = row['courts'] as Map<String, dynamic>?;
        return Slot.fromJson({
          'id': row['id'] as String,
          'start_time': row['start_time'] as String,
          'end_time': row['end_time'] as String,
          'court_id': row['court_id'] as String,
          'court_name': court?['name'] as String? ?? '',
          'sport_type': court?['sport_type'] as String? ?? 'badminton',
          'access_policy': row['access_policy'] as String? ?? 'open',
          'max_players': row['max_players'] as int? ?? 4,
          'current_players': row['current_players'] as int? ?? 0,
        });
      }).toList();

      return Success(slots);
    } on PostgrestException catch (e) {
      final code = int.tryParse(e.code ?? '') ?? 500;
      return Failure(ServerFailure(code));
    } catch (_) {
      return const Failure(NetworkFailure());
    }
  }
}
