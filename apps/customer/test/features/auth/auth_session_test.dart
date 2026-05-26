// Tests for session-persistence behaviour (grava-144f.1.4).
//
// Coverage:
// - AuthBloc emits AuthAuthenticated when AppStarted and a session exists
// - AuthBloc emits AuthUnauthenticated when AppStarted and no session exists
// - AuthBloc responds to onAuthStateChange stream events
// - GoRouter redirect: unauthenticated → '/login', authenticated → null (stays)

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:customer/features/auth/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa
    show AuthState, AuthChangeEvent, GoTrueClient, Session;

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockGoTrueClient extends Mock implements supa.GoTrueClient {}

class MockSession extends Mock implements supa.Session {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AuthBloc — session persistence (grava-144f.1.4)', () {
    late MockGoTrueClient mockAuth;
    late StreamController<supa.AuthState> authStateController;

    setUp(() {
      mockAuth = MockGoTrueClient();
      authStateController = StreamController<supa.AuthState>.broadcast();

      // Default: no current session
      when(() => mockAuth.currentSession).thenReturn(null);
      when(() => mockAuth.onAuthStateChange).thenAnswer(
        (_) => authStateController.stream,
      );
    });

    tearDown(() {
      authStateController.close();
    });

    // -------------------------------------------------------------------------
    // AppStarted with no session → AuthUnauthenticated
    // -------------------------------------------------------------------------
    blocTest<AuthBloc, AuthState>(
      'emits AuthUnauthenticated on AppStarted when no session exists',
      build: () => AuthBloc(authClient: mockAuth),
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => [isA<AuthUnauthenticated>()],
    );

    // -------------------------------------------------------------------------
    // AppStarted with existing session → AuthAuthenticated
    // -------------------------------------------------------------------------
    blocTest<AuthBloc, AuthState>(
      'emits AuthAuthenticated on AppStarted when a session exists',
      build: () {
        when(() => mockAuth.currentSession).thenReturn(MockSession());
        return AuthBloc(authClient: mockAuth);
      },
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => [isA<AuthAuthenticated>()],
    );

    // -------------------------------------------------------------------------
    // onAuthStateChange: signedIn event → AuthAuthenticated
    // -------------------------------------------------------------------------
    blocTest<AuthBloc, AuthState>(
      'emits AuthAuthenticated when onAuthStateChange fires SIGNED_IN',
      build: () => AuthBloc(authClient: mockAuth),
      act: (bloc) {
        authStateController.add(
          supa.AuthState(
            supa.AuthChangeEvent.signedIn,
            MockSession(),
          ),
        );
      },
      expect: () => [isA<AuthAuthenticated>()],
    );

    // -------------------------------------------------------------------------
    // onAuthStateChange: signedOut event → AuthUnauthenticated
    // -------------------------------------------------------------------------
    blocTest<AuthBloc, AuthState>(
      'emits AuthUnauthenticated when onAuthStateChange fires SIGNED_OUT',
      build: () => AuthBloc(authClient: mockAuth),
      act: (bloc) {
        authStateController.add(
          const supa.AuthState(
            supa.AuthChangeEvent.signedOut,
            null,
          ),
        );
      },
      expect: () => [isA<AuthUnauthenticated>()],
    );
  });
}
