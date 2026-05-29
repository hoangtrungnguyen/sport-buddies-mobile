import 'package:dashboard/features/auth/bloc/auth_bloc.dart';
import 'package:dashboard/features/auth/repository/owner_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

/// Stubs [OwnerAuthRepository.login]. The parent ctor builds an (unused) Dio.
class _StubRepo extends OwnerAuthRepository {
  _StubRepo({this.result, this.error});

  final OwnerLoginResult? result;
  final OwnerLoginException? error;
  int calls = 0;

  @override
  Future<OwnerLoginResult> login({
    required String email,
    required String password,
  }) async {
    calls++;
    if (error != null) throw error!;
    return result!;
  }
}

/// AuthBloc whose Supabase session hydration always fails — exercises the
/// `setSession` → `AuthException` → `login_failed` path without a real client.
class _HydrationFailsBloc extends AuthBloc {
  _HydrationFailsBloc(OwnerAuthRepository repo)
      : super(ownerAuthRepository: repo);

  @override
  Future<void> hydrateSession({
    required String accessToken,
    required String refreshToken,
  }) async {
    throw const AuthException('hydration failed');
  }
}

const _okResult = OwnerLoginResult(
  accessToken: 'at',
  refreshToken: 'rt',
  userId: 'u_1',
  email: 'owner@example.com',
);

void main() {
  group('AuthBloc login (via backend)', () {
    test('rejects an invalid email without calling the backend', () async {
      final repo = _StubRepo(result: _okResult);
      final bloc = AuthBloc(ownerAuthRepository: repo);

      final expectation =
          expectLater(bloc.stream, emitsInOrder([isA<AuthRejected>()]));
      bloc.add(const AuthEvent.loginSubmitted(
          email: 'nope', password: 'whatever'));

      await expectation;
      expect(repo.calls, 0);
      await bloc.close();
    });

    test('rejects an empty password without calling the backend', () async {
      final repo = _StubRepo(result: _okResult);
      final bloc = AuthBloc(ownerAuthRepository: repo);

      final expectation =
          expectLater(bloc.stream, emitsInOrder([isA<AuthRejected>()]));
      bloc.add(const AuthEvent.loginSubmitted(
          email: 'owner@example.com', password: ''));

      await expectation;
      expect(repo.calls, 0);
      await bloc.close();
    });

    test('loading → authenticated on a 200 (no Supabase client in test)',
        () async {
      final repo = _StubRepo(result: _okResult);
      // supabaseClient is null here, so setSession is skipped.
      final bloc = AuthBloc(ownerAuthRepository: repo);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([const AuthLoading(), const AuthAuthenticated()]),
      );
      bloc.add(const AuthEvent.loginSubmitted(
          email: '  owner@example.com ', password: 'Abcd1234'));

      await expectation;
      expect(repo.calls, 1);
      await bloc.close();
    });

    test('loading → rejected(invalid_credentials) on 401', () async {
      final repo = _StubRepo(
          error: const OwnerLoginException('invalid_credentials',
              statusCode: 401));
      final bloc = AuthBloc(ownerAuthRepository: repo);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const AuthLoading(),
          isA<AuthRejected>()
              .having((s) => s.message, 'message', 'invalid_credentials'),
        ]),
      );
      bloc.add(const AuthEvent.loginSubmitted(
          email: 'owner@example.com', password: 'wrong123'));

      await expectation;
      await bloc.close();
    });

    test('loading → rejected(access_denied) on 403', () async {
      final repo = _StubRepo(
          error: const OwnerLoginException('access_denied', statusCode: 403));
      final bloc = AuthBloc(ownerAuthRepository: repo);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const AuthLoading(),
          isA<AuthRejected>()
              .having((s) => s.message, 'message', 'access_denied'),
        ]),
      );
      bloc.add(const AuthEvent.loginSubmitted(
          email: 'owner@example.com', password: 'Abcd1234'));

      await expectation;
      await bloc.close();
    });

    test('loading → rejected(email_not_verified) on 403 email_not_verified',
        () async {
      final repo = _StubRepo(
          error: const OwnerLoginException('email_not_verified',
              statusCode: 403));
      final bloc = AuthBloc(ownerAuthRepository: repo);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const AuthLoading(),
          isA<AuthRejected>()
              .having((s) => s.message, 'message', 'email_not_verified'),
        ]),
      );
      bloc.add(const AuthEvent.loginSubmitted(
          email: 'owner@example.com', password: 'Abcd1234'));

      await expectation;
      await bloc.close();
    });

    test('loading → rejected(login_failed) when session hydration fails',
        () async {
      final repo = _StubRepo(result: _okResult);
      final bloc = _HydrationFailsBloc(repo);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const AuthLoading(),
          isA<AuthRejected>()
              .having((s) => s.message, 'message', 'login_failed'),
        ]),
      );
      bloc.add(const AuthEvent.loginSubmitted(
          email: 'owner@example.com', password: 'Abcd1234'));

      await expectation;
      expect(repo.calls, 1);
      await bloc.close();
    });

    test('AppStarted with no session → unauthenticated', () async {
      final repo = _StubRepo(result: _okResult);
      final bloc = AuthBloc(ownerAuthRepository: repo);

      final expectation =
          expectLater(bloc.stream, emitsInOrder([const AuthUnauthenticated()]));
      bloc.add(const AuthEvent.appStarted());

      await expectation;
      await bloc.close();
    });
  });
}
