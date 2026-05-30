// SupabaseCourtRepository — grava-c9ca.1.3
//
// Concrete implementation of CourtRepository that hits Supabase.
// Selects only the columns needed for map display to keep the query lean.
//
// The raw fetch is delegated to [fetchRows] — a protected method that can be
// overridden in tests to inject fixture data without mocking the full
// Supabase builder chain.

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:spb_core/spb_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed [CourtRepository] implementation.
///
/// Query: `SELECT id, name, lat, lng FROM courts WHERE status = 'approved'`
class SupabaseCourtRepository implements CourtRepository {
  SupabaseCourtRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  /// Executes the Supabase query and returns raw row data.
  ///
  /// Override in tests via a subclass to avoid wiring the full Supabase
  /// builder chain through mocktail.
  @visibleForTesting
  Future<List<Map<String, dynamic>>> fetchRows() async {
    final rows = await _client
        .from('courts')
        .select('id, name, lat, lng')
        .eq('status', 'approved');
    return (rows as List<dynamic>).cast<Map<String, dynamic>>();
  }

  @override
  Future<Result<List<Court>>> getApprovedCourts() async {
    try {
      final rows = await fetchRows();
      final courts = rows.map(Court.fromJson).toList();
      return Success(courts);
    } on PostgrestException catch (e) {
      final code = int.tryParse(e.code ?? '') ?? 500;
      return Failure(ServerFailure(code));
    } catch (_) {
      return const Failure(NetworkFailure());
    }
  }

  @override
  Future<Result<List<Court>>> fetchCourtsByOwner(String ownerId) async {
    try {
      final rows = await _client
          .from('courts')
          .select(
            'id, name, owner_id, lat, lng, sport_types, address, price_per_hour, description, amenities, photos',
          )
          .eq('owner_id', ownerId)
          .eq('status', 'approved');
      final courts = (rows as List<dynamic>)
          .map<Court>((r) => Court.fromJson(r as Map<String, dynamic>))
          .toList();
      return Success(courts);
    } on PostgrestException catch (e) {
      final code = int.tryParse(e.code ?? '') ?? 500;
      return Failure(ServerFailure(code));
    } catch (_) {
      return const Failure(NetworkFailure());
    }
  }

  @override
  Future<Result<Court>> fetchCourtById(String courtId) async {
    try {
      final row = await _client
          .from('courts')
          .select(
            'id, name, owner_id, lat, lng, sport_types, address, price_per_hour, description, amenities, photos',
          )
          .eq('id', courtId)
          .single();
      return Success(Court.fromJson(row));
    } on PostgrestException catch (e) {
      final code = int.tryParse(e.code ?? '') ?? 500;
      return Failure(ServerFailure(code));
    } catch (_) {
      return const Failure(NetworkFailure());
    }
  }
}
