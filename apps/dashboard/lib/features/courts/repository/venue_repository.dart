import 'package:dashboard/core/debug/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/venue.dart';

/// Lightweight per-court rollup used by the My-courts grid.
class CourtVenueSummary {
  int count = 0;
  final Set<String> sports = {};
}

class VenueRepository {
  const VenueRepository(this._client);
  final SupabaseClient _client;

  static const _cols =
      'id, court_id, name, sport_type, capacity, price_per_hour, status, indoor';

  /// One-query summary (count + distinct sports) per court, for the My-courts
  /// grid cards. Read-only; RLS scopes `venues` to the owner's courts.
  Future<Map<String, CourtVenueSummary>> fetchSummaries(
    List<String> courtIds,
  ) async {
    if (courtIds.isEmpty) return {};
    try {
      final rows = await _client
          .from('venues')
          .select('court_id, sport_type')
          .inFilter('court_id', courtIds)
          .neq('status', 'inactive');
      final out = <String, CourtVenueSummary>{};
      for (final r in rows as List) {
        final m = r as Map<String, dynamic>;
        final cid = m['court_id'] as String;
        final sport = (m['sport_type'] as String?)?.trim() ?? '';
        final s = out.putIfAbsent(cid, () => CourtVenueSummary());
        s.count++;
        if (sport.isNotEmpty) s.sports.add(sport);
      }
      return out;
    } catch (e, st) {
      appLogger.e('VenueRepository.fetchSummaries', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<List<Venue>> fetchForCourt(String courtId) async {
    try {
      final rows = await _client
          .from('venues')
          .select(_cols)
          .eq('court_id', courtId)
          .order('name');
      return (rows as List)
          .map((r) => Venue.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      appLogger.e('VenueRepository.fetchForCourt', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Venue> create({
    required String courtId,
    required String name,
    required String sportType,
    required int capacity,
    required int pricePerHour,
    bool indoor = false,
  }) async {
    try {
      final row = await _client
          .from('venues')
          .insert({
            'court_id': courtId,
            'name': name,
            'sport_type': sportType,
            'capacity': capacity,
            'price_per_hour': pricePerHour,
            'status': 'active',
            'indoor': indoor,
          })
          .select(_cols)
          .single();
      return Venue.fromJson(row);
    } catch (e, st) {
      appLogger.e('VenueRepository.create', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Venue> update(
    String id, {
    required String name,
    required String sportType,
    required int capacity,
    required int pricePerHour,
    bool? indoor,
  }) async {
    try {
      final data = {
        'name': name,
        'sport_type': sportType,
        'capacity': capacity,
        'price_per_hour': pricePerHour,
      };
      if (indoor != null) data['indoor'] = indoor;
      final row = await _client
          .from('venues')
          .update(data)
          .eq('id', id)
          .select(_cols)
          .single();
      return Venue.fromJson(row);
    } catch (e, st) {
      appLogger.e('VenueRepository.update', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> deactivate(String id) async {
    try {
      await _client
          .from('venues')
          .update({'status': 'inactive'})
          .eq('id', id);
    } catch (e, st) {
      appLogger.e('VenueRepository.deactivate', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> reactivate(String id) async {
    try {
      await _client
          .from('venues')
          .update({'status': 'active'})
          .eq('id', id);
    } catch (e, st) {
      appLogger.e('VenueRepository.reactivate', error: e, stackTrace: st);
      rethrow;
    }
  }
}
