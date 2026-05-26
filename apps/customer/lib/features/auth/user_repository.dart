// UserRepository — manages upsert of authenticated user records into the
// `users` table in Supabase (grava-144f.2.2).
//
// Design:
//   Production usage injects a real [SupabaseClient] and the default [upsertFn]
//   performs:
//       supabase.from('users').upsert({id, email, full_name})
//
//   Test usage passes a custom [upsertFn] to avoid mocking deep Supabase
//   query-builder internals.

import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles persistence of user profile data derived from an auth [Session].
class UserRepository {
  /// Creates a [UserRepository].
  ///
  /// In production, provide [supabaseClient] — the default [upsertFn] will
  /// delegate to it.
  ///
  /// In tests, pass a custom [upsertFn] to stub the Supabase call.
  UserRepository({
    SupabaseClient? supabaseClient,
    Future<void> Function(Map<String, dynamic> data)? upsertFn,
  })  : _client = supabaseClient,
        _upsertFn = upsertFn;

  final SupabaseClient? _client;
  final Future<void> Function(Map<String, dynamic> data)? _upsertFn;

  /// Upserts a row in the `users` table from the authenticated [session].
  ///
  /// Fields written:
  /// - `id`         — `session.user.id`
  /// - `email`      — `session.user.email`
  /// - `full_name`  — `session.user.userMetadata['full_name']` (nullable)
  ///
  /// Throws any exception from the underlying Supabase call unchanged.
  Future<void> upsertFromSession(Session session) async {
    final data = <String, dynamic>{
      'id': session.user.id,
      'email': session.user.email,
      'full_name': session.user.userMetadata?['full_name'],
    };

    if (_upsertFn != null) {
      await _upsertFn!(data);
      return;
    }

    // Production path — client must be provided.
    await _client!.from('users').upsert(data);
  }
}
