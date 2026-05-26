part of 'auth_bloc.dart';

/// Base class for all authentication states.
sealed class AuthState {
  const AuthState();
}

/// Waiting for user input — no operation in flight.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// An async auth operation (signIn / signUp) is in progress.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Auth operation completed successfully.
final class AuthSuccess extends AuthState {
  const AuthSuccess();
}

/// Form input failed validation before any network call.
final class AuthValidationError extends AuthState {
  const AuthValidationError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthValidationError && other.message == message);

  @override
  int get hashCode => message.hashCode;
}

/// Auth operation failed (network or Supabase error).
final class AuthFailureState extends AuthState {
  const AuthFailureState(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthFailureState && other.message == message);

  @override
  int get hashCode => message.hashCode;
}

/// Password-reset email was sent successfully.
final class PasswordResetSent extends AuthState {
  const PasswordResetSent();
}

/// Verification email was (re)sent successfully.
final class VerificationEmailSent extends AuthState {
  const VerificationEmailSent();
}
