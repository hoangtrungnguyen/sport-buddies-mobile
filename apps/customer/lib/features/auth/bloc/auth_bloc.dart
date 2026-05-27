// AuthBloc — handles sign-up, login, and session persistence for CAPP-010.
//
// State machine:
//   AuthInitial → (AppStarted, no session)  → AuthUnauthenticated
//   AuthInitial → (AppStarted, has session)  → AuthAuthenticated
//   AuthInitial → (onAuthStateChange signedIn)  → AuthAuthenticated
//   AuthInitial → (onAuthStateChange signedOut) → AuthUnauthenticated
//   AuthInitial → (LoginSubmitted / SignUpSubmitted) → AuthLoading → AuthSuccess | AuthFailureState
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

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// ---------------------------------------------------------------------------
// Pure validation helpers (no Supabase dependency — easy to unit-test)
// ---------------------------------------------------------------------------

/// Returns an error message when [name] is empty/blank, otherwise `null`.
String? validateFullName(String? name, {String? emptyMessage}) {
  if (name == null || name.trim().isEmpty) {
    return emptyMessage ?? 'Vui lòng nhập họ và tên.';
  }
  return null;
}

/// Returns an error message when [email] is empty/blank, otherwise `null`.
String? validateEmail(String? email, {String? emptyMessage}) {
  if (email == null || email.trim().isEmpty) {
    return emptyMessage ?? 'Vui lòng nhập email.';
  }
  return null;
}

/// Returns an error message when [password] fails requirements, else `null`.
/// Requirements: ≥8 chars, ≥1 letter, ≥1 digit.
String? validatePassword(String? password, {String? weakMessage}) {
  if (password == null || password.length < 8) {
    return weakMessage ?? 'Tối thiểu 8 ký tự, có chữ và số.';
  }
  final hasLetter = password.contains(RegExp(r'[a-zA-Z]'));
  final hasDigit = password.contains(RegExp(r'[0-9]'));
  if (!hasLetter || !hasDigit) return weakMessage ?? 'Tối thiểu 8 ký tự, có chữ và số.';
  return null;
}

/// Returns an error message when [confirm] does not equal [password], else `null`.
String? validateConfirmPassword(String password, String confirm,
    {String? mismatchMessage}) {
  if (confirm != password) return mismatchMessage ?? 'Mật khẩu không khớp.';
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
    on<_AuthStateChanged>(_onAuthStateChanged);
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
        (supaAuthState) => add(_AuthStateChanged(supaAuthState.session)),
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

  void _onAuthStateChanged(_AuthStateChanged event, Emitter<AuthState> emit) {
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
    } on AuthException catch (e) {
      final msg = e.message;
      if (msg.contains('Invalid login credentials') ||
          e.statusCode == '400' ||
          e.statusCode == '401') {
        emit(const AuthFailureState('invalid_credentials'));
      } else if (msg.contains('Email not confirmed')) {
        emit(const AuthFailureState('email_not_confirmed'));
      } else {
        emit(AuthFailureState(msg));
      }
    } catch (e) {
      emit(AuthFailureState(e.toString()));
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
    } on AuthException catch (e) {
      emit(AuthFailureState(e.message));
    } catch (e) {
      emit(AuthFailureState(e.toString()));
    }
  }

  /// Native-only deep-link scheme. Must match iOS Info.plist + Android
  /// AndroidManifest intent filter AND be allowed in Supabase Dashboard
  /// (Authentication → URL Configuration → Redirect URLs).
  static const String _nativeOauthRedirect =
      'io.supabase.spbcustomer://login-callback/';

  /// Returns the redirect target for the current platform.
  ///
  /// On web we send Supabase back to the current page (`Uri.base`) — that
  /// way OAuth lands on whatever port `flutter run -d chrome` chose,
  /// regardless of Supabase's configured Site URL. On native we use the
  /// deep-link scheme so the OS routes the callback back into the app.
  static String _resolveOauthRedirect() =>
      kIsWeb ? Uri.base.toString() : _nativeOauthRedirect;

  /// Initiates Google OAuth via Supabase [OAuthProvider.google].
  ///
  /// On native platforms `signInWithOAuth` returns immediately after opening
  /// the system browser; the session arrives later on the [onAuthStateChange]
  /// stream and drives the [AuthAuthenticated] state.
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
    } on AuthException catch (e) {
      emit(AuthFailureState(e.message));
    } catch (e) {
      emit(AuthFailureState(e.toString()));
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
    } on AuthException catch (e) {
      emit(AuthFailureState(e.message));
    } catch (e) {
      emit(AuthFailureState(e.toString()));
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
    } on AuthException catch (e) {
      emit(AuthFailureState(e.message));
    } catch (e) {
      emit(AuthFailureState(e.toString()));
    }
  }
}
