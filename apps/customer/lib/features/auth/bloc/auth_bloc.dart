// AuthBloc — handles sign-up, login, and session persistence for CAPP-010.
//
// State machine:
//   AuthInitial → (AppStarted, no session)  → AuthUnauthenticated
//   AuthInitial → (AppStarted, has session)  → AuthAuthenticated
//   AuthInitial → (onAuthStateChange signedIn)  → AuthAuthenticated
//   AuthInitial → (onAuthStateChange signedOut) → AuthUnauthenticated
//   AuthInitial → (LoginSubmitted / SignUpSubmitted) → AuthLoading → AuthSuccess | AuthRejected
//   AuthInitial → (bad input) → AuthValidationError
//
// Supabase is called via the injected SupabaseClient / GoTrueClient.
// In test environments both may be `null`; the bloc gracefully stubs so tests
// can exercise the state machine without a real network.
//
// Validation helpers are top-level functions so tests can import them directly.
//
// Google sign-in uses Supabase OAuth (signInWithOAuth + OAuthProvider.google).
// Redirect target is platform-aware:
//   - Web    → Uri.base.toString() — the current page URL, so OAuth returns
//              to the running Flutter dev server (whatever port it picked).
//   - Native → `io.supabase.spbcustomer://login-callback/` deep link
//              (registered in iOS Info.plist + Android intent filter).
//
// The bloc does NOT mirror the auth user into a `users` table — that row is
// created by a server-side trigger (or another service) when Supabase Auth
// emits a sign-up. Client-side upserts have been deliberately removed.

import 'dart:async';

import 'package:customer/features/auth/bloc/auth_event.dart';
import 'package:customer/features/auth/bloc/auth_state.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

export 'auth_event.dart';
export 'auth_state.dart';

// ---------------------------------------------------------------------------
// Pure validation helpers (no Supabase dependency — easy to unit-test)
// ---------------------------------------------------------------------------

// Validators return [null] when valid, or an error to show. Form callers pass
// a localized [*Message]; when omitted (e.g. the bloc handler) a stable error
// *code* is returned instead, which the display layer resolves via
// [appErrorMessage]. So no user-facing copy is hard-coded here.

/// Returns an error when [name] is empty/blank, otherwise `null`.
String? validateFullName(String? name, {String? emptyMessage}) {
  if (name == null || name.trim().isEmpty) {
    return emptyMessage ?? 'name_required';
  }
  return null;
}

/// Returns an error when [email] is empty/blank, otherwise `null`.
String? validateEmail(String? email, {String? emptyMessage}) {
  if (email == null || email.trim().isEmpty) {
    return emptyMessage ?? 'email_required';
  }
  return null;
}

/// Returns an error when [password] fails requirements, else `null`.
/// Requirements: ≥8 chars, ≥1 letter, ≥1 digit.
String? validatePassword(String? password, {String? weakMessage}) {
  if (password == null || password.length < 8) {
    return weakMessage ?? 'password_weak';
  }
  final hasLetter = password.contains(RegExp(r'[a-zA-Z]'));
  final hasDigit = password.contains(RegExp(r'[0-9]'));
  if (!hasLetter || !hasDigit) {
    return weakMessage ?? 'password_weak';
  }
  return null;
}

/// Returns an error when [confirm] does not equal [password], else `null`.
String? validateConfirmPassword(String password, String confirm,
    {String? mismatchMessage}) {
  if (confirm != password) return mismatchMessage ?? 'password_mismatch';
  return null;
}

// ---------------------------------------------------------------------------
// AuthBloc
// ---------------------------------------------------------------------------

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    SupabaseClient? supabaseClient,
    GoTrueClient? authClient,
  })  : _client = supabaseClient,
        _authClient = authClient,
        super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AuthStateChanged>(_onAuthStateChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SignUpSubmitted>(_onSignUpSubmitted);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ResendVerificationRequested>(_onResendVerificationRequested);

    // Subscribe to Supabase auth stream events so AuthBloc stays in sync
    // with the session state even when the app resumes from background.
    final authStream = _authClient?.onAuthStateChange;
    if (authStream != null) {
      _authSubscription = authStream.listen(
        (supaAuthState) =>
            add(AuthEvent.authStateChanged(supaAuthState.session)),
      );
    }
  }

  final SupabaseClient? _client;

  /// Optional GoTrueClient for session checks and stream subscriptions.
  /// Separated so tests can mock it without a full SupabaseClient.
  final GoTrueClient? _authClient;

  // ignore: cancel_subscriptions
  StreamSubscription<dynamic>? _authSubscription;

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  // ---------------------------------------------------------------------------
  // Session-persistence handlers
  // ---------------------------------------------------------------------------

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) {
    final session = _authClient?.currentSession;
    if (session != null) {
      emit(const AuthAuthenticated());
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  void _onAuthStateChanged(AuthStateChanged event, Emitter<AuthState> emit) {
    if (event.session != null) {
      emit(const AuthAuthenticated());
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final emailError = validateEmail(event.email);
    if (emailError != null) {
      emit(AuthValidationError(emailError));
      return;
    }
    final passwordError = validatePassword(event.password);
    if (passwordError != null) {
      emit(AuthValidationError(passwordError));
      return;
    }

    emit(const AuthLoading());
    try {
      final client = _client;
      if (client != null) {
        await client.auth.signInWithPassword(
          email: event.email,
          password: event.password,
        );
      }
      emit(const AuthSuccess());
    } on AuthException catch (e, stackTrace) {
      final msg = e.message;
      if (msg.contains('Invalid login credentials') ||
          e.statusCode == '400' ||
          e.statusCode == '401') {
        emit(AuthRejected('invalid_credentials', stackTrace: stackTrace));
      } else if (msg.contains('Email not confirmed')) {
        emit(AuthRejected('email_not_confirmed', stackTrace: stackTrace));
      } else {
        emit(AuthRejected(msg, stackTrace: stackTrace));
      }
    }
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final nameError = validateFullName(event.fullName);
    if (nameError != null) {
      emit(AuthValidationError(nameError));
      return;
    }
    final emailError = validateEmail(event.email);
    if (emailError != null) {
      emit(AuthValidationError(emailError));
      return;
    }
    final passwordError = validatePassword(event.password);
    if (passwordError != null) {
      emit(AuthValidationError(passwordError));
      return;
    }
    final confirmError =
        validateConfirmPassword(event.password, event.confirmPassword);
    if (confirmError != null) {
      emit(AuthValidationError(confirmError));
      return;
    }

    emit(const AuthLoading());
    try {
      final client = _client;
      if (client != null) {
        await client.auth.signUp(
          email: event.email,
          password: event.password,
          data: {'full_name': event.fullName.trim()},
        );
      }
      emit(const AuthSuccess());
    } on AuthException catch (e, stackTrace) {
      emit(AuthRejected(e.message, stackTrace: stackTrace));
    }
  }

  /// Native-only deep-link scheme. Must match iOS Info.plist + Android
  /// AndroidManifest intent filter AND be allowed in Supabase Dashboard
  /// (Authentication → URL Configuration → Redirect URLs).
  static const String _nativeOauthRedirect =
      'io.supabase.spbcustomer://login-callback/';

  static String _resolveOauthRedirect() =>
      kIsWeb ? Uri.base.toString() : _nativeOauthRedirect;

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final client = _client;
      if (client != null) {
        await client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: _resolveOauthRedirect(),
        );
      }
      emit(const AuthSuccess());
    } on AuthException catch (e, stackTrace) {
      final msg = e.message.toLowerCase();
      if (msg.contains('access_denied') || msg.contains('cancelled')) {
        emit(AuthRejected('oauth_cancelled', stackTrace: stackTrace));
      } else if (msg.contains('provider') &&
          (msg.contains('disabled') || msg.contains('not enabled'))) {
        emit(AuthRejected('oauth_provider_disabled', stackTrace: stackTrace));
      } else {
        emit(AuthRejected(e.message, stackTrace: stackTrace));
      }
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    final emailError = validateEmail(event.email);
    if (emailError != null) {
      emit(AuthValidationError(emailError));
      return;
    }

    emit(const AuthLoading());
    try {
      final client = _client;
      if (client != null) {
        await client.auth.resetPasswordForEmail(event.email);
      }
      emit(const PasswordResetSent());
    } on AuthException catch (e, stackTrace) {
      emit(AuthRejected(e.message, stackTrace: stackTrace));
    }
  }

  Future<void> _onResendVerificationRequested(
    ResendVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    final emailError = validateEmail(event.email);
    if (emailError != null) {
      emit(AuthValidationError(emailError));
      return;
    }

    emit(const AuthLoading());
    try {
      final client = _client;
      if (client != null) {
        await client.auth.resend(
          type: OtpType.signup,
          email: event.email,
        );
      }
      emit(const VerificationEmailSent());
    } on AuthException catch (e, stackTrace) {
      emit(AuthRejected(e.message, stackTrace: stackTrace));
    }
  }
}
