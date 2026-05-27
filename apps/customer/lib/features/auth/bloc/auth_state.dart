import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  /// Waiting for user input — no operation in flight.
  const factory AuthState.initial() = AuthInitial;

  /// An async auth operation (signIn / signUp) is in progress.
  const factory AuthState.loading() = AuthLoading;

  /// Auth operation completed successfully.
  const factory AuthState.success() = AuthSuccess;

  /// Form input failed validation before any network call.
  const factory AuthState.validationError(String message) = AuthValidationError;

  /// Server rejected the request for a known, recoverable reason.
  /// [message] is a stable key the UI switches on (e.g. 'invalid_credentials').
  @With<AppExceptionMixin>()
  const factory AuthState.rejected(String message, {StackTrace? stackTrace}) =
      AuthRejected;

  /// Auth operation failed with an unexpected error (non-recoverable).
  const factory AuthState.failure(String message, {StackTrace? stackTrace}) =
      AuthFailureState;

  /// Password-reset email was sent successfully.
  const factory AuthState.passwordResetSent() = PasswordResetSent;

  /// Verification email was (re)sent successfully.
  const factory AuthState.verificationEmailSent() = VerificationEmailSent;

  /// A valid session is present.
  const factory AuthState.authenticated() = AuthAuthenticated;

  /// No session present.
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
}
