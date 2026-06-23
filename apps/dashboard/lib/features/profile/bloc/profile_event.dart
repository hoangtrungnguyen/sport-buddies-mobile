import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../model/profile_models.dart';

part 'profile_event.freezed.dart';

@freezed
sealed class ProfileEvent with _$ProfileEvent {
  /// Load profile + stats from the repository.
  const factory ProfileEvent.started() = ProfileStarted;

  /// Save the edited draft (name/phone/email/address only).
  const factory ProfileEvent.editSubmitted(OwnerProfile draft) =
      ProfileEditSubmitted;

  /// Optimistic 2FA flip — reverts on repo failure.
  const factory ProfileEvent.twoFactorToggled(bool enabled) =
      ProfileTwoFactorToggled;

  /// Optimistic email-notification flip — reverts on repo failure.
  const factory ProfileEvent.emailNotifToggled(bool enabled) =
      ProfileEmailNotifToggled;

  /// Upload a freshly-picked avatar image ([bytes]) to the backend.
  const factory ProfileEvent.avatarChangeRequested(
    Uint8List bytes, {
    @Default('avatar.jpg') String filename,
  }) = ProfileAvatarChangeRequested;
}
