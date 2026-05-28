import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/owner_court.dart';

class OwnerCourtRepository {
  const OwnerCourtRepository(this._client);
  final SupabaseClient _client;

  Future<List<OwnerCourt>> getCourts() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];
    final rows = await _client
        .from('courts')
        .select('id, name, sport_type, capacity, open_hour, close_hour, price_per_hour, status')
        .eq('owner_id', uid)
        .order('name');
    return (rows as List)
        .map((r) => OwnerCourt.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<OwnerCourt> createCourt({
    required String name,
    required String sportType,
    required int capacity,
    required int openHour,
    required int closeHour,
    required int pricePerHour,
  }) async {
    final uid = _client.auth.currentUser!.id;
    final row = await _client
        .from('courts')
        .insert({
          'name': name,
          'sport_type': sportType,
          'capacity': capacity,
          'open_hour': openHour,
          'close_hour': closeHour,
          'price_per_hour': pricePerHour,
          'owner_id': uid,
          'status': 'approved',
        })
        .select()
        .single();
    return OwnerCourt.fromJson(row);
  }

  Future<OwnerCourt> updateCourt(
    String id, {
    required String name,
    required String sportType,
    required int capacity,
    required int openHour,
    required int closeHour,
    required int pricePerHour,
  }) async {
    final row = await _client
        .from('courts')
        .update({
          'name': name,
          'sport_type': sportType,
          'capacity': capacity,
          'open_hour': openHour,
          'close_hour': closeHour,
          'price_per_hour': pricePerHour,
        })
        .eq('id', id)
        .select()
        .single();
    return OwnerCourt.fromJson(row);
  }

  Future<void> deactivateCourt(String id) async {
    await _client
        .from('courts')
        .update({'status': 'inactive'})
        .eq('id', id);
  }

  Future<void> reactivateCourt(String id) async {
    await _client
        .from('courts')
        .update({'status': 'approved'})
        .eq('id', id);
  }
}
