import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/identity/owner_identity.dart';
import '../model/profile_models.dart';
import 'profile_api_client.dart';
import 'profile_repository.dart';

/// In-memory [ProfileRepository] seeded from the prototype's owner record and
/// overlaid with the live Supabase identity (name/email) where available.
///
/// There is no backend profile endpoint yet, so writes mutate the in-session
/// copy and resolve successfully — enough to drive the read-first/edit-on-tap
/// screen end to end. Swap for an API/Supabase-backed impl once the endpoint
/// lands; the abstract contract and the screen stay unchanged.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._api, [SupabaseClient? client])
      : _client = client;

  final ProfileApiClient _api;
  final SupabaseClient? _client;

  OwnerProfile? _cache;

  // --- prototype defaults (design source: profile-data.jsx) ----------------

  static final _stats = const ProfileStats(
    clusters: 3,
    venues: 8,
    rating: 4.8,
    ratingCount: 124,
    monthlyBookings: 312,
  );

  OwnerProfile _seed() {
    final user = _currentUser();
    final email = (user?.email?.trim().isNotEmpty ?? false)
        ? user!.email!.trim()
        : 'minh.nguyen@snb.vn';
    final name = ownerDisplayName(user) ?? 'Nguyễn Văn Minh';
    return OwnerProfile(
      id: user?.id ?? 'owner-1',
      name: name,
      initials: ownerInitials(name),
      role: 'Chủ sân',
      area: 'Quận 7, TP.HCM',
      joinedAt: DateTime(2025, 3, 1),
      phone: '0908 124 357',
      email: email,
      address: '128 Nguyễn Lương Bằng, P. Tân Phú, Quận 7',
      verified: true,
      bizName: 'Hộ kinh doanh Minh Sport',
      taxCode: '0312 998 471',
      bizArea: 'Quận 7 · Nhà Bè · Quận 4',
      bankName: 'Vietcombank — CN Phú Mỹ Hưng',
      accountMasked: '•••• •••• 4357',
      accountHolder: 'NGUYEN VAN MINH',
      payoutLinked: true,
      twoFactor: false,
      emailNotif: true,
      passwordChangedAt: DateTime(2026, 5, 14),
      activeDevices: 3,
    );
  }

  @override
  Future<OwnerProfile> getProfile() async => _cache ??= _seed();

  @override
  Future<ProfileStats> getStats() async => _stats;

  @override
  Future<OwnerProfile> updateProfile(OwnerProfile draft) async {
    return _cache = draft;
  }

  @override
  Future<void> setTwoFactor(bool enabled) async {
    final c = _cache;
    if (c != null) _cache = c.copyWith(twoFactor: enabled);
  }

  @override
  Future<void> setEmailNotif(bool enabled) async {
    final c = _cache;
    if (c != null) _cache = c.copyWith(emailNotif: enabled);
  }

  @override
  Future<String> uploadAvatar(Uint8List bytes,
      {String filename = 'avatar.jpg'}) async {
    final url = await _api.uploadAvatar(bytes, filename: filename);
    final c = _cache;
    if (c != null) _cache = c.copyWith(avatarUrl: url);
    return url;
  }

  // --- Supabase identity overlay (same rules as the drawer footer) ---------

  User? _currentUser() {
    try {
      return _client?.auth.currentUser;
    } catch (_) {
      return null;
    }
  }
}
