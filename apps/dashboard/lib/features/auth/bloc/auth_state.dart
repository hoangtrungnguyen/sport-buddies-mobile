import 'package:dashboard/core/mixins/app_exception_mixin.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated() = AuthAuthenticated;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;

  /// Predictable server rejection — UI switches on [message] key.
  @With<AppExceptionMixin>()
  const factory AuthState.rejected(String message, {StackTrace? stackTrace}) =
      AuthRejected;

  /// Password-reset email sent.
  const factory AuthState.passwordResetSent() = PasswordResetSent;
}
