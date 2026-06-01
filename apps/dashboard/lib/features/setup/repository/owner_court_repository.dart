import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/owner_court.dart';

class OwnerCourtRepository {
  const OwnerCourtRepository(this._client);
  final SupabaseClient _client;

  static const _cols =
      'id, name, operating_hours, address, description, amenities, lat, lng, status, auto_approve_single';

  Future<List<OwnerCourt>> getCourts() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];
    final rows = await _client
        .from('courts')
        .select(_cols)
        .eq('owner_id', uid)
        .neq('status', 'inactive')
        .order('name');
    return (rows as List)
        .map((r) => OwnerCourt.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<OwnerCourt> createCourt({
    required String name,
    required int openHour,
    required int closeHour,
    String? address,
    String? description,
    List<String> amenities = const [],
    double? lat,
    double? lng,
  }) async {
    final uid = _client.auth.currentUser!.id;
    final slug = _slugify('$name-${DateTime.now().millisecondsSinceEpoch}');
    final row = await _client.from('courts').insert({
      'name': name,
      'slug': slug,
      'operating_hours': {'open': openHour, 'close': closeHour},
      'address': address,
      'description': description,
      'amenities': amenities,
      'lat': lat,
      'lng': lng,
      'owner_id': uid,
      'status': 'approved',
    }).select(_cols).single();
    return OwnerCourt.fromJson(row);
  }

  Future<OwnerCourt> updateCourt(
    String id, {
    required String name,
    required int openHour,
    required int closeHour,
    String? address,
    String? description,
    List<String> amenities = const [],
    double? lat,
    double? lng,
  }) async {
    final row = await _client.from('courts').update({
      'name': name,
      'operating_hours': {'open': openHour, 'close': closeHour},
      'address': address,
      'description': description,
      'amenities': amenities,
      'lat': lat,
      'lng': lng,
    }).eq('id', id).select(_cols).single();
    return OwnerCourt.fromJson(row);
  }

  /// Persists `courts.auto_approve_single` for [courtId] (OWNER-44/45).
  /// Column-level RLS (migration 0003) allows the court owner to UPDATE this
  /// field; no extra filter needed because the row-level policy already scopes
  /// to `owner_id = auth.uid()`.
  Future<void> updateAutoApprove(String courtId, {required bool value}) async {
    await _client
        .from('courts')
        .update({'auto_approve_single': value})
        .eq('id', courtId);
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

  static String _slugify(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
        .replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e')
        .replaceAll(RegExp(r'[ìíịỉĩ]'), 'i')
        .replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
        .replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u')
        .replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y')
        .replaceAll(RegExp(r'[đ]'), 'd')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}
