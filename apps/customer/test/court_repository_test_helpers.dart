// Shared test helpers for CourtRepository — reused across map feature tests.

import 'package:customer/features/map/court_repository_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeSupabaseClient extends Fake implements SupabaseClient {}

/// A controllable [SupabaseCourtRepository] subclass that bypasses the real
/// Supabase client. Provide a [rowsProvider] to control what rows are returned.
class FakeCourtRepository extends SupabaseCourtRepository {
  FakeCourtRepository({required this.rowsProvider})
      : super(client: _FakeSupabaseClient());

  final Future<List<Map<String, dynamic>>> Function() rowsProvider;

  @override
  Future<List<Map<String, dynamic>>> fetchRows() => rowsProvider();
}
