// Tests for UserRepository.upsertFromSession (grava-144f.2.2).
//
// Coverage:
// - upsertFromSession calls the upsert fn with correct data (id, email, full_name)
// - upsertFromSession completes without error on success
// - upsertFromSession propagates exceptions
// - full_name falls back to null when absent from userMetadata
//
// Design note: UserRepository accepts an optional [upsertFn] callback so tests
// can stub the Supabase call without importing mocks for deep query-builder
// internals. In production the default fn delegates to
// supabase.from('users').upsert(...).

import 'package:customer/features/auth/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Build a minimal [Session] with just the fields consumed by
/// [UserRepository.upsertFromSession].
Session _makeSession({
  required String userId,
  required String email,
  String? fullName,
}) {
  final user = User(
    id: userId,
    appMetadata: {},
    userMetadata: {
      if (fullName != null) 'full_name': fullName,
    },
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
    email: email,
  );
  return Session(
    accessToken: 'access',
    tokenType: 'bearer',
    user: user,
  );
}

void main() {
  group('UserRepository.upsertFromSession', () {
    test(
        'calls upsertFn with id, email, and full_name when full_name is present',
        () async {
      Map<String, dynamic>? capturedData;
      final repo = UserRepository(
        upsertFn: (data) async {
          capturedData = data;
        },
      );

      final session = _makeSession(
        userId: 'user-123',
        email: 'alice@example.com',
        fullName: 'Alice Smith',
      );

      await repo.upsertFromSession(session);

      expect(capturedData, {
        'id': 'user-123',
        'email': 'alice@example.com',
        'full_name': 'Alice Smith',
      });
    });

    test('passes null for full_name when userMetadata has no full_name key',
        () async {
      Map<String, dynamic>? capturedData;
      final repo = UserRepository(
        upsertFn: (data) async {
          capturedData = data;
        },
      );

      final session = _makeSession(
        userId: 'user-456',
        email: 'bob@example.com',
      );

      await repo.upsertFromSession(session);

      expect(capturedData, {
        'id': 'user-456',
        'email': 'bob@example.com',
        'full_name': null,
      });
    });

    test('completes without error on success', () async {
      final repo = UserRepository(
        upsertFn: (_) async {},
      );
      final session = _makeSession(userId: 'u', email: 'u@x.com');
      await expectLater(repo.upsertFromSession(session), completes);
    });

    test('propagates exception thrown by upsertFn', () async {
      final repo = UserRepository(
        upsertFn: (_) async => throw Exception('db error'),
      );
      final session = _makeSession(userId: 'u2', email: 'u2@x.com');
      await expectLater(
        repo.upsertFromSession(session),
        throwsA(isA<Exception>()),
      );
    });
  });
}
