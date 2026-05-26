// Profile feature — BLoC states.
//
// States:
//   ProfileLoading      — initial/fetching state; screen shows a spinner.
//   ProfileLoaded       — user data ready; screen renders fields.
//   ProfileError        — fetch failed; screen shows an error message.
//   ProfileSaving       — full_name update in progress.
//   ProfileUpdateError  — full_name update failed; message carries the reason.

import 'package:flutter/foundation.dart';

/// Base class for all profile states.
@immutable
sealed class ProfileState {
  const ProfileState();
}

/// Emitted while the user profile is being fetched.
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Emitted when user profile data has been successfully loaded.
class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.fullName,
    required this.phone,
    required this.email,
    this.avatarUrl,
  });

  final String fullName;
  final String phone;
  final String email;

  /// Remote URL for the avatar image, or null when no avatar is set.
  final String? avatarUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileLoaded &&
          runtimeType == other.runtimeType &&
          fullName == other.fullName &&
          phone == other.phone &&
          email == other.email &&
          avatarUrl == other.avatarUrl;

  @override
  int get hashCode =>
      Object.hash(fullName, phone, email, avatarUrl);
}

/// Emitted when fetching user profile data fails.
class ProfileError extends ProfileState {
  const ProfileError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// Emitted while a full_name update is being saved to the database.
class ProfileSaving extends ProfileState {
  const ProfileSaving();
}

/// Emitted when a full_name update fails.
class ProfileUpdateError extends ProfileState {
  const ProfileUpdateError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileUpdateError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
