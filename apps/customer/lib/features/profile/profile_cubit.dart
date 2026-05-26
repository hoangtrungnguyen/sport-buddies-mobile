// Profile feature — Cubit.
//
// Loads the current user profile from the Supabase auth session.
// User metadata (full_name, phone, avatar_url) live in:
//   supabaseClient.auth.currentSession?.user.userMetadata
//
// Falls back gracefully when keys are absent (e.g. during development with a
// stub Supabase instance).

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._client) : super(const ProfileLoading());

  /// Convenience constructor for tests: allows starting from an arbitrary
  /// initial state without requiring a real [SupabaseClient].
  ProfileCubit.fake(super.initial)
      : _client = null;

  // Nullable so the fake constructor can leave it unset.
  final SupabaseClient? _client;

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
}
