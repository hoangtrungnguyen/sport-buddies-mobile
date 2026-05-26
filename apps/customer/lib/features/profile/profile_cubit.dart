// Profile feature — Cubit.
//
// Loads the current user profile from the Supabase auth session.
// User metadata (full_name, phone, avatar_url) live in:
//   supabaseClient.auth.currentSession?.user.userMetadata
//
// Falls back gracefully when keys are absent (e.g. during development with a
// stub Supabase instance).
//
// updateFullName writes to the `users` table:
//   supabase.from('users').update({'full_name': name}).eq('id', userId)
//
// For testability the actual DB call is delegated to [_updateFn], which
// defaults to the real Supabase implementation but can be overridden via the
// [ProfileCubit.fake] constructor without requiring Supabase mock chains.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'profile_state.dart';

/// Signature of the function that persists a full_name change.
/// Receives the authenticated [userId] and the new [name].
/// Should throw on failure.
typedef UpdateFullNameFn = Future<void> Function(
  String userId,
  String name,
);

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._client)
      : _updateFn = null,
        super(const ProfileLoading());

  /// Convenience constructor for tests: allows starting from an arbitrary
  /// initial state without requiring a real [SupabaseClient].
  ///
  /// [update] — optional override for the DB write; when null the real
  /// Supabase call is used (but [client] would need to be non-null then).
  ProfileCubit.fake(
    super.initial, {
    UpdateFullNameFn? update,
  })  : _client = null,
        _updateFn = update;

  // Nullable so the fake constructor can leave it unset.
  final SupabaseClient? _client;

  /// Optional override for the update DB call (used in tests).
  final UpdateFullNameFn? _updateFn;

  // ---------------------------------------------------------------------------
  // loadProfile
  // ---------------------------------------------------------------------------

  /// Fetches the user profile from the Supabase auth session and emits the
  /// appropriate state.
  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    try {
      final client = _client;
      if (client == null) {
        // Stub path: used in tests when no real client is provided.
        emit(const ProfileLoaded(
          fullName: '',
          phone: '',
          email: '',
          avatarUrl: null,
        ));
        return;
      }

      final user = client.auth.currentSession?.user;
      if (user == null) {
        emit(const ProfileError('No authenticated user found.'));
        return;
      }

      final meta = user.userMetadata ?? {};
      emit(ProfileLoaded(
        fullName: (meta['full_name'] as String?) ?? '',
        phone: (meta['phone'] as String?) ?? '',
        email: user.email ?? '',
        avatarUrl: meta['avatar_url'] as String?,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // updateFullName
  // ---------------------------------------------------------------------------

  /// Persists [name] as the authenticated user's full_name.
  ///
  /// Emits [ProfileSaving] while the request is in-flight.
  /// On success emits [ProfileLoaded] with the updated name.
  /// On failure emits [ProfileUpdateError] with the error message.
  ///
  /// No-op when the current state is not [ProfileLoaded] (guard against
  /// calling before the profile has been loaded).
  Future<void> updateFullName(String name) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    emit(const ProfileSaving());
    try {
      final overrideFn = _updateFn;
      if (overrideFn != null) {
        // Test path: delegate to the injected stub.
        await overrideFn('', name);
      } else {
        final client = _client;
        if (client == null) {
          // Defensive: no client in non-test path should not happen.
          emit(const ProfileUpdateError('Supabase client not available.'));
          return;
        }
        final userId = client.auth.currentSession?.user.id ?? '';
        await client
            .from('users')
            .update({'full_name': name}).eq('id', userId);
      }
      emit(ProfileLoaded(
        fullName: name,
        phone: current.phone,
        email: current.email,
        avatarUrl: current.avatarUrl,
      ));
    } catch (e) {
      emit(ProfileUpdateError(e.toString()));
    }
  }
}
