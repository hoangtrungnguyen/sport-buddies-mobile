import 'package:dashboard/core/mixins/app_exception_mixin.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup_state.freezed.dart';

@freezed
sealed class SignupState with _$SignupState {
  const factory SignupState.initial() = SignupInitial;
  const factory SignupState.submitting() = SignupSubmitting;

  /// Account created (`201`). [requiresVerification] reflects the backend mode:
  /// when true the account needs email verification before login (the UI shows
  /// a "verify your email" prompt; login otherwise returns
  /// `403 email_not_verified`); when false the account is auto-confirmed and can
  /// log in immediately. Derived from the signup response so the UI adapts to
  /// either backend configuration.
  const factory SignupState.success({
    required String email,
    required bool requiresVerification,
  }) = SignupSuccess;

  /// Predictable rejection — UI switches on [message] key (validation message
  /// or an [OwnerSignupException] code).
  @With<AppExceptionMixin>()
  const factory SignupState.rejected(String message, {StackTrace? stackTrace}) =
      SignupRejected;
}
