// Supabase-backed [CourtRepository] — reads only (writes go through the API).
//
// No venue/center grouping exists in the schema yet (`courts` is flat;
// owner_id spans multiple physical venues), so [getCenter] returns the single
// court as a one-court "center" until a real venue model lands.

import 'package:customer/core/debug/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/court.dart';
import 'court_repository.dart';

class SupabaseBrowseCourtRepository implements CourtRepository {
  const SupabaseBrowseCourtRepository(this._client);

  final SupabaseClient _client;

  static const _columns =
      'id, name, address, sport_types, price_per_hour, photos, amenities, '
      'description, lat, lng';

  @override
  Future<Court> getCourt(String courtId) async {
    final row = await _client
        .from('courts')
        .select(_columns)
        .eq('id', courtId)
        .single();
    return _mapCourt(row, openSlotsToday: await _openSlotsToday(courtId));
  }

  @override
  Future<SportsCenter> getCenter(String centerId) async {
    // Schema has no venue grouping → the "center" is just this court.
    final court = await getCourt(centerId);
    return SportsCenter(id: centerId, name: court.name, courts: [court]);
  }

  /// Count of open slots on this court for the rest of today.
  Future<int> _openSlotsToday(String courtId) async {
    try {
      final now = DateTime.now();
      final endOfDay = DateTime(now.year, now.month, now.day + 1);
      final rows = await _client
          .from('slots')
          .select('id')
          .eq('court_id', courtId)
          .eq('status', 'open')
          .gte('start_at', now.toUtc().toIso8601String())
          .lt('start_at', endOfDay.toUtc().toIso8601String());
      return (rows as List).length;
    } catch (e, st) {
      appLogger.e('SupabaseBrowseCourtRepository._openSlotsToday',
          error: e, stackTrace: st);
      return 0;
    }
  }

  Court _mapCourt(Map<String, dynamic> row, {required int openSlotsToday}) {
    return Court(
      id: row['id'] as String,
      // Self-center until a real venue model exists.
      centerId: row['id'] as String,
      name: (row['name'] as String?) ?? '',
      address: (row['address'] as String?) ?? '',
      sports: parseSports(row['sport_types']),
      pricePerHourVnd: _toInt(row['price_per_hour']),
      rating: 0,
      reviewCount: 0,
      distanceKm: 0,
      photoUrls: ((row['photos'] as List?) ?? const []).cast<String>(),
      amenities: ((row['amenities'] as List?) ?? const []).cast<String>(),
      description: (row['description'] as String?) ?? '',
      openSlotsToday: openSlotsToday,
      lat: _toDouble(row['lat']),
      lng: _toDouble(row['lng']),
    );
  }
}

/// Maps a backend sport string to a [Sport]. `sport_types` is mixed — clean
/// enum names (`badminton`) and Vietnamese display labels (`Bóng đá 5v5`).
Sport sportFromString(String s) {
  final t = s.toLowerCase();
  if (t.contains('bóng đá') || t.contains('football')) return Sport.football;
  if (t.contains('cầu lông') || t.contains('badminton')) return Sport.badminton;
  if (t.contains('pickle')) return Sport.pickleball;
  if (t.contains('tennis')) return Sport.tennis;
  return Sport.multi;
}

List<Sport> parseSports(dynamic raw) {
  final list = (raw as List?)?.cast<String>() ?? const <String>[];
  final sports = list.map(sportFromString).toList();
  return sports.isEmpty ? const [Sport.multi] : sports;
}

int _toInt(dynamic v) => v == null ? 0 : (num.tryParse(v.toString())?.round() ?? 0);
double _toDouble(dynamic v) =>
    v == null ? 0 : (num.tryParse(v.toString())?.toDouble() ?? 0);
