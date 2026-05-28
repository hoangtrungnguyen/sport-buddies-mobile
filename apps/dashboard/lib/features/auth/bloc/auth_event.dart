import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
sealed class AuthEvent with _$AuthEvent {
  const factory AuthEvent.appStarted() = AppStarted;

  /// Internal — from Supabase auth stream.
  const factory AuthEvent.authStateChanged(Object? session) = AuthStateChanged;

  const factory AuthEvent.loginSubmitted({
    required String email,
    required String password,
  }) = LoginSubmitted;

  const factory AuthEvent.forgotPasswordRequested({
    required String email,
  }) = ForgotPasswordRequested;

  const factory AuthEvent.logoutRequested() = LogoutRequested;
}
