// Tests for AuthBloc form validation logic (CAPP-010 / grava-144f.1.1).
//
// Coverage:
// - validateEmail: non-empty check
// - validatePassword: minimum 8 chars check
// - validateConfirmPassword: must match password
// - AuthBloc state transitions for login and sign-up
import 'package:bloc_test/bloc_test.dart';
import 'package:customer/features/auth/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Pure validation helpers (no Supabase) — these are the main RED→GREEN target
  // ---------------------------------------------------------------------------

  group('validateEmail', () {
    test('returns error message for empty string', () {
      expect(validateEmail(''), isNotNull);
    });

    test('returns error message for whitespace-only string', () {
      expect(validateEmail('   '), isNotNull);
    });

    test('returns null for a non-empty email', () {
      expect(validateEmail('user@example.com'), isNull);
    });

    test('returns null for any non-empty string (minimal spec)', () {
      // The spec only requires non-empty; no RFC-5322 check at this stage.
      expect(validateEmail('x'), isNull);
    });
  });

  group('validatePassword', () {
    test('returns error message for empty string', () {
      expect(validatePassword(''), isNotNull);
    });

    test('returns error message for password shorter than 8 chars', () {
      expect(validatePassword('abc123'), isNotNull);
      expect(validatePassword('1234567'), isNotNull);
    });

    test('returns null for password of exactly 8 chars', () {
      expect(validatePassword('12345678'), isNull);
    });

    test('returns null for password longer than 8 chars', () {
      expect(validatePassword('myStr0ngP@ss'), isNull);
    });
  });

  group('validateConfirmPassword', () {
    test('returns error message when confirm does not match password', () {
      expect(validateConfirmPassword('password1', 'password2'), isNotNull);
    });

    test('returns null when confirm matches password', () {
      expect(validateConfirmPassword('myPass123', 'myPass123'), isNull);
    });

    test('returns error message when confirm is empty and password is not', () {
      expect(validateConfirmPassword('myPass123', ''), isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // AuthBloc state machine
  // ---------------------------------------------------------------------------

  group('AuthBloc', () {
    late AuthBloc bloc;

    setUp(() {
      bloc = AuthBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is AuthInitial', () {
      expect(bloc.state, isA<AuthInitial>());
    });

    blocTest<AuthBloc, AuthState>(
      'emits AuthValidationError when LoginSubmitted with empty email',
      build: AuthBloc.new,
      act: (b) => b.add(
        const LoginSubmitted(email: '', password: 'validPass1'),
      ),
      expect: () => [isA<AuthValidationError>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthValidationError when LoginSubmitted with short password',
      build: AuthBloc.new,
      act: (b) => b.add(
        const LoginSubmitted(email: 'user@example.com', password: 'short'),
      ),
      expect: () => [isA<AuthValidationError>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] for valid login credentials',
      build: AuthBloc.new,
      act: (b) => b.add(
        const LoginSubmitted(
          email: 'user@example.com',
          password: 'validPass1',
        ),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthSuccess>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthValidationError when SignUpSubmitted with mismatched passwords',
      build: AuthBloc.new,
      act: (b) => b.add(
        const SignUpSubmitted(
          email: 'user@example.com',
          password: 'validPass1',
          confirmPassword: 'different',
        ),
      ),
      expect: () => [isA<AuthValidationError>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] for valid sign-up data',
      build: AuthBloc.new,
      act: (b) => b.add(
        const SignUpSubmitted(
          email: 'user@example.com',
          password: 'validPass1',
          confirmPassword: 'validPass1',
        ),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthSuccess>()],
    );
  });
}
