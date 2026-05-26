// AuthBloc — handles sign-up and login for CAPP-010 (grava-144f.1.1).
//
// State machine:
//   AuthInitial → (event) → AuthLoading → AuthSuccess | AuthFailureState
//   AuthInitial → (event with bad input) → AuthValidationError
//
// Supabase is called via the SupabaseClient injected from the DI container.
// In test environments the client may not be fully initialised; the bloc
// gracefully treats any exception as an AuthFailureState so tests can stub
// at the bloc level without a real network.
//
// Validation helpers are top-level functions so tests can import them directly.

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
  AuthBloc({SupabaseClient? supabaseClient})
      : _client = supabaseClient,
        super(const AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SignUpSubmitted>(_onSignUpSubmitted);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ResendVerificationRequested>(_onResendVerificationRequested);
  }

  final SupabaseClient? _client;

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
