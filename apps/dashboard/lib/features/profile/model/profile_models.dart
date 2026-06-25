import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_models.freezed.dart';

/// The owner's personal account record (Hồ sơ chủ sân). Read-first; only
/// name/phone/email/address are user-editable from the screen — everything
/// else is server-owned or a security preference toggled in place.
@freezed
abstract class OwnerProfile with _$OwnerProfile {
  const factory OwnerProfile({
    required String id,
    required String name,
    required String initials,
    /// Public URL of the uploaded avatar; null → render [initials].
    String? avatarUrl,
    required String role, // "Chủ sân"
    required String area, // "Quận 7, TP.HCM"
    required DateTime joinedAt,
    required String phone,
    required String email,
    required String address,
    required bool verified,
    // business
    required String bizName,
    required String taxCode,
    required String bizArea,
    // payout
    required String bankName,
    required String accountMasked,
    required String accountHolder,
    required bool payoutLinked,
    // security prefs
    required bool twoFactor,
    required bool emailNotif,
    DateTime? passwordChangedAt,
    @Default(0) int activeDevices,
  }) = _OwnerProfile;
}

/// Server-computed business stats shown in the 4-up tile row — read-only.
@freezed
abstract class ProfileStats with _$ProfileStats {
  const factory ProfileStats({
    required int clusters,
    required int venues,
    required double rating,
    required int ratingCount,
    required int monthlyBookings,
  }) = _ProfileStats;
}
