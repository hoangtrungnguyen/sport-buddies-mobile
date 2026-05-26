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

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// ---------------------------------------------------------------------------
// Pure validation helpers (no Supabase dependency — easy to unit-test)
// ---------------------------------------------------------------------------

/// Returns an error message when [email] is empty/blank, otherwise `null`.
String? validateEmail(String? email) {
  if (email == null || email.trim().isEmpty) return 'Email is required.';
  return null;
}

/// Returns an error message when [password] is shorter than 8 chars, else `null`.
String? validatePassword(String? password) {
  if (password == null || password.length < 8) {
    return 'Password must be at least 8 characters.';
  }
  return null;
}

/// Returns an error message when [confirm] does not equal [password], else `null`.
String? validateConfirmPassword(String password, String confirm) {
  if (confirm != password) return 'Passwords do not match.';
  return null;
}

// ---------------------------------------------------------------------------
// AuthBloc
// ---------------------------------------------------------------------------

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({SupabaseClient? supabaseClient, GoTrueClient? authClient})
      : _client = supabaseClient,
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
      emit(AuthFailureState(e.message));
    } catch (e) {
      emit(AuthFailureState(e.toString()));
    }
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
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
        );
      }
      emit(const AuthSuccess());
    } on AuthException catch (e) {
      emit(AuthFailureState(e.message));
    } catch (e) {
      emit(AuthFailureState(e.toString()));
    }
  }

  /// Initiates Google OAuth via Supabase [OAuthProvider.google].
  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final client = _client;
      if (client != null) {
        await client.auth.signInWithOAuth(OAuthProvider.google);
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
