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
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  final String email;
  final String password;
  final String confirmPassword;
}
