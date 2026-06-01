import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/venue.dart';

class VenueRepository {
  const VenueRepository(this._client);
  final SupabaseClient _client;

  static const _cols =
      'id, court_id, name, sport_type, capacity, price_per_hour, status';

  Future<List<Venue>> fetchForCourt(String courtId) async {
    final rows = await _client
        .from('venues')
        .select(_cols)
        .eq('court_id', courtId)
        .order('name');
    return (rows as List)
        .map((r) => Venue.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<Venue> create({
    required String courtId,
    required String name,
    required String sportType,
    required int capacity,
    required int pricePerHour,
  }) async {
    final row = await _client
        .from('venues')
        .insert({
          'court_id': courtId,
          'name': name,
          'sport_type': sportType,
          'capacity': capacity,
          'price_per_hour': pricePerHour,
          'status': 'active',
        })
        .select(_cols)
        .single();
    return Venue.fromJson(row);
  }

  Future<Venue> update(
    String id, {
    required String name,
    required String sportType,
    required int capacity,
    required int pricePerHour,
  }) async {
    final row = await _client
        .from('venues')
        .update({
          'name': name,
          'sport_type': sportType,
          'capacity': capacity,
          'price_per_hour': pricePerHour,
        })
        .eq('id', id)
        .select(_cols)
        .single();
    return Venue.fromJson(row);
  }

  Future<void> deactivate(String id) async {
    await _client
        .from('venues')
        .update({'status': 'inactive'})
        .eq('id', id);
  }

  Future<void> reactivate(String id) async {
    await _client
        .from('venues')
        .update({'status': 'active'})
        .eq('id', id);
  }
}
