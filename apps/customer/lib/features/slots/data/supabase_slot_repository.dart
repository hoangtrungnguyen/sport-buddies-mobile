import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:spb_core/spb_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed [SlotRepository] implementation.
class SupabaseSlotRepository implements SlotRepository {
  SupabaseSlotRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  static const _slotSelect = '''
    id,
    start_at,
    end_at,
    court_id,
    courts!inner(name, sport_types),
    access_policy,
    max_players,
    slot_participants(count)
  ''';

  static Map<String, dynamic> _mapRow(Map<String, dynamic> row) {
    final court = row['courts'] as Map<String, dynamic>?;
    final sportTypes = court?['sport_types'] as List<dynamic>? ?? [];
    final sportType =
        sportTypes.isNotEmpty ? sportTypes.first as String? ?? 'badminton' : 'badminton';
    final participantData = row['slot_participants'] as List<dynamic>? ?? [];
    final currentPlayers = participantData.isNotEmpty
        ? int.tryParse(participantData.first['count'].toString()) ?? 0
        : 0;
    return {
      'id': row['id'] as String,
      'start_time': row['start_at'] as String,
      'end_time': row['end_at'] as String,
      'court_id': row['court_id'] as String,
      'court_name': court?['name'] as String? ?? '',
      'sport_type': sportType,
      'access_policy': row['access_policy'] as String? ?? 'open',
      'max_players': row['max_players'] as int? ?? 4,
      'current_players': currentPlayers,
    };
  }

  @visibleForTesting
  Future<List<Map<String, dynamic>>> fetchRows(String courtId) async {
    final now = DateTime.now().toUtc().toIso8601String();

    final rows = await _client
        .from('slots')
        .select(_slotSelect)
        .eq('court_id', courtId)
        .eq('status', 'open')
        .gt('start_at', now)
        .order('start_at', ascending: true);

    return (rows as List<dynamic>)
        .map<Map<String, dynamic>>((row) => _mapRow(row as Map<String, dynamic>))
        .toList();
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
  Future<Result<Slot>> fetchSlotById(String slotId) async {
    try {
      final row = await _client
          .from('slots')
          .select(_slotSelect)
          .eq('id', slotId)
          .single();
      return Success(Slot.fromJson(_mapRow(row)));
    } on PostgrestException catch (e) {
      final code = int.tryParse(e.code ?? '') ?? 500;
      return Failure(ServerFailure(code));
    } catch (_) {
      return const Failure(NetworkFailure());
    }
  }

  @override
  Future<Result<List<Slot>>> fetchScheduleSlots(
      List<String> courtIds, DateTime date) async {
    if (courtIds.isEmpty) return const Success([]);
    try {
      final dayStart = DateTime(date.year, date.month, date.day).toUtc();
      final dayEnd = dayStart.add(const Duration(days: 1));

      final rows = await _client
          .from('slots')
          .select(_slotSelect)
          .inFilter('court_id', courtIds)
          .gte('start_at', dayStart.toIso8601String())
          .lt('start_at', dayEnd.toIso8601String())
          .order('start_at', ascending: true);

      final slots = (rows as List<dynamic>)
          .map<Slot>((row) => Slot.fromJson(_mapRow(row as Map<String, dynamic>)))
          .toList();
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
          .select(_slotSelect)
          .eq('status', 'booked')
          .eq('access_policy', 'open')
          .gt('start_at', now)
          .order('start_at', ascending: true);

      final slots = (rows as List<dynamic>)
          .map<Slot>((row) => Slot.fromJson(_mapRow(row as Map<String, dynamic>)))
          .toList();

      return Success(slots);
    } on PostgrestException catch (e) {
      final code = int.tryParse(e.code ?? '') ?? 500;
      return Failure(ServerFailure(code));
    } catch (_) {
      return const Failure(NetworkFailure());
    }
  }
}
