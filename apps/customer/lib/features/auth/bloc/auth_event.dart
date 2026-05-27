import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
sealed class AuthEvent with _$AuthEvent {
  /// Submitted from the login screen.
  const factory AuthEvent.loginSubmitted({
    required String email,
    required String password,
  }) = LoginSubmitted;

  /// Submitted from the sign-up screen.
  const factory AuthEvent.signUpSubmitted({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) = SignUpSubmitted;

  /// Initiates Google OAuth sign-in via Supabase.
  const factory AuthEvent.googleSignInRequested() = GoogleSignInRequested;

  /// Submitted from the forgot-password screen.
  const factory AuthEvent.forgotPasswordRequested({
    required String email,
  }) = ForgotPasswordRequested;

  /// Resend the verification email after sign-up.
  const factory AuthEvent.resendVerificationRequested({
    required String email,
  }) = ResendVerificationRequested;

  /// Fired once on app start to check the persisted session.
  const factory AuthEvent.appStarted() = AppStarted;

  /// Internal — emitted by AuthBloc's auth-stream subscription.
  /// Carries the Supabase session (null = signed out).
  /// Not for external / UI use.
  const factory AuthEvent.authStateChanged(Object? session) =
      AuthStateChanged;
}
