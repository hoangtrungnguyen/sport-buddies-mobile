import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup_event.freezed.dart';

@freezed
sealed class SignupEvent with _$SignupEvent {
  /// Owner tapped "Đăng ký". [confirmPassword] is validated client-side only
  /// and never sent to the server.
  const factory SignupEvent.submitted({
    required String email,
    required String password,
    required String confirmPassword,
  }) = SignupSubmitted;
}
