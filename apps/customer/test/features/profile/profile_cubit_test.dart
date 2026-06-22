// Unit tests for ProfileCubit.updateFullName.
//
// Covers:
//   - updateFullName emits [ProfileSaving, ProfileLoaded] on success.
//   - updateFullName emits [ProfileSaving, ProfileUpdateError] on DB failure.
//   - updateFullName is a no-op when state is not ProfileLoaded.
//
// Uses ProfileCubit.fake with an injected update callback so no real
// Supabase network calls are made.

import 'package:bloc_test/bloc_test.dart';
import 'package:customer/features/profile/profile_cubit.dart';
import 'package:customer/features/profile/profile_state.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Loaded state used as a base for update tests.
const _kLoaded = ProfileLoaded(
  fullName: 'Old Name',
  phone: '0901234567',
  email: 'old@example.com',
);

/// Builds a cubit starting from [_kLoaded] whose update function either
/// succeeds (default) or throws [error] when non-null.
ProfileCubit _buildCubit({Exception? error}) {
  return ProfileCubit.fake(
    _kLoaded,
    update: (_, name) async {
      if (error != null) throw error;
      // success — no-op; cubit will emit ProfileLoaded with new name.
    },
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ProfileCubit.updateFullName', () {
    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileSaving, ProfileLoaded(newName)] on success',
      build: () => _buildCubit(),
      act: (cubit) => cubit.updateFullName('New Name'),
      expect: () => [
        const ProfileSaving(),
        const ProfileLoaded(
          fullName: 'New Name',
          phone: '0901234567',
          email: 'old@example.com',
        ),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileSaving, ProfileUpdateError] on DB failure',
      build: () => _buildCubit(error: Exception('DB write failed')),
      act: (cubit) => cubit.updateFullName('Any Name'),
      expect: () => [
        const ProfileSaving(),
        isA<ProfileUpdateError>(),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'is a no-op when current state is not ProfileLoaded',
      build: () => ProfileCubit.fake(const ProfileLoading()),
      act: (cubit) => cubit.updateFullName('Ignored'),
      expect: () => <ProfileState>[],
    );

    blocTest<ProfileCubit, ProfileState>(
      'ProfileUpdateError carries the generic error code',
      build: () => _buildCubit(error: Exception('network timeout')),
      act: (cubit) => cubit.updateFullName('Any Name'),
      expect: () => [
        const ProfileSaving(),
        isA<ProfileUpdateError>().having(
          (e) => e.message,
          'message',
          'generic',
        ),
      ],
    );
  });
}
