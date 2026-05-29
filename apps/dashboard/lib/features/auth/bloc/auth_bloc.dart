// AuthBloc for the Owner Dashboard.
//
// Login is routed through the backend `POST /auth/owner/login` (which enforces
// the owner role server-side — the role is NOT in the Supabase JWT). The
// returned Supabase tokens hydrate the Supabase session so the rest of the app
// (router session checks, RLS-backed repositories) keeps working unchanged.
//
// State machine:
//   initial → (AppStarted, has session) → authenticated
//   initial → (AppStarted, no session)  → unauthenticated
//   unauthenticated → LoginSubmitted → loading
//        → (backend 200, then hydrate Supabase session) → authenticated
//        → (backend 4xx/5xx | hydration error)          → rejected
//   authenticated   → LogoutRequested → unauthenticated

import 'dart:async';

import 'package:dashboard/features/auth/auth_validators.dart';
import 'package:dashboard/features/auth/bloc/auth_event.dart';
import 'package:dashboard/features/auth/bloc/auth_state.dart';
import 'package:dashboard/features/auth/repository/owner_auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

export 'package:dashboard/features/auth/auth_validators.dart';

export 'auth_event.dart';
export 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required OwnerAuthRepository ownerAuthRepository,
    SupabaseClient? supabaseClient,
  })  : _ownerAuthRepository = ownerAuthRepository,
        _client = supabaseClient,
        super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AuthStateChanged>(_onAuthStateChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<LogoutRequested>(_onLogoutRequested);

    final authStream = _client?.auth.onAuthStateChange;
    if (authStream != null) {
      _sub = authStream.listen(
        (s) => add(AuthEvent.authStateChanged(s.session)),
      );
    }
  }

  final OwnerAuthRepository _ownerAuthRepository;
  final SupabaseClient? _client;
  // ignore: cancel_subscriptions
  StreamSubscription<dynamic>? _sub;

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) {
    final session = _client?.auth.currentSession;
    // A persisted session can only have been established via the
    // owner-validated login below, so trust it. Note: the owner role is not
    // re-checked here — if it is revoked server-side, RLS blocks data access
    // and the next token refresh fails, bounding the trust window to the
    // access token's lifetime (~1h).
    emit(session == null
        ? const AuthUnauthenticated()
        : const AuthAuthenticated());
  }

  void _onAuthStateChanged(AuthStateChanged event, Emitter<AuthState> emit) {
    final session = event.session;
    if (session == null) {
      emit(const AuthUnauthenticated());
    } else {
      // Already validated role on login; just trust the session here.
      emit(const AuthAuthenticated());
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final emailErr = validateEmail(event.email);
    if (emailErr != null) {
      emit(AuthRejected(emailErr));
      return;
    }
    final passErr = validateLoginPassword(event.password);
    if (passErr != null) {
      emit(AuthRejected(passErr));
      return;
    }

    emit(const AuthLoading());
    try {
      // Backend validates the owner role and returns Supabase tokens.
      final result = await _ownerAuthRepository.login(
        email: event.email.trim(),
        password: event.password,
      );
      // Hydrate the Supabase session from the backend-issued tokens so the
      // router's session checks and RLS-backed repositories keep working.
      await hydrateSession(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      // Hydration also fires onAuthStateChange(signedIn) → _onAuthStateChanged,
      // which emits AuthAuthenticated. Emitting here too is harmless (bloc drops
      // a repeat of the current state) and is the sole signal when there is no
      // Supabase auth stream (e.g. tests / null client).
      emit(const AuthAuthenticated());
    } on OwnerLoginException catch (e, st) {
      emit(AuthRejected(e.code, stackTrace: st));
    } on AuthException catch (e, st) {
      // Login succeeded at the backend but hydrating the Supabase session
      // failed (e.g. Supabase unreachable / token rejected). Recoverable —
      // let the owner retry.
      emit(AuthRejected('login_failed', stackTrace: st));
    }
  }

  /// Hydrates the Supabase session from the backend-issued tokens. Passing the
  /// access token lets gotrue skip a refresh round-trip. Exposed (not private)
  /// so tests can drive the hydration-failure path without a real
  /// [SupabaseClient].
  Future<void> hydrateSession({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _client?.auth.setSession(refreshToken, accessToken: accessToken);
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    final emailErr = validateEmail(event.email);
    if (emailErr != null) {
      emit(AuthRejected(emailErr));
      return;
    }
    emit(const AuthLoading());
    try {
      await _client?.auth.resetPasswordForEmail(event.email.trim());
      emit(const PasswordResetSent());
    } on AuthException catch (e, st) {
      emit(AuthRejected(e.message, stackTrace: st));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _client?.auth.signOut();
    emit(const AuthUnauthenticated());
  }
}
