part of 'auth_bloc.dart';

/// Base class for all authentication events.
sealed class AuthEvent {
  const AuthEvent();
}

/// Submitted from the login screen.
final class LoginSubmitted extends AuthEvent {
  const LoginSubmitted({required this.email, required this.password});

  final String email;
  final String password;
}

/// Submitted from the sign-up screen.
final class SignUpSubmitted extends AuthEvent {
  const SignUpSubmitted({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
}

/// Initiates Google OAuth sign-in via Supabase.
final class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

/// Submitted from the forgot-password screen.
final class ForgotPasswordRequested extends AuthEvent {
  const ForgotPasswordRequested({required this.email});

  final String email;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ForgotPasswordRequested && other.email == email);

  @override
  int get hashCode => email.hashCode;
}

/// Resend the verification email after sign-up.
final class ResendVerificationRequested extends AuthEvent {
  const ResendVerificationRequested({required this.email});

  final String email;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResendVerificationRequested && other.email == email);

  @override
  int get hashCode => email.hashCode;
}

/// Fired once on app start to check the persisted session.
final class AppStarted extends AuthEvent {
  const AppStarted();
}

/// Internal event emitted by the bloc's [onAuthStateChange] subscription.
///
/// Carries the Supabase session (null = signed out).
final class _AuthStateChanged extends AuthEvent {
  const _AuthStateChanged(this.session);

  final Object? session; // supabase_flutter.Session | null
}
