import 'dart:typed_data';

import '../model/profile_models.dart';

/// Data gateway for the owner profile screen. Reads hydrate the screen; the
/// narrow set of mutations (edit dialog + the two security switches) write back
/// through here. Avatar upload is wired for parity with the design but not yet
/// reachable from the UI (camera overlay is out of scope in the prototype).
abstract class ProfileRepository {
  Future<OwnerProfile> getProfile();
  Future<ProfileStats> getStats();

  /// Persists the editable subset (name/phone/email/address) and returns the
  /// merged record.
  Future<OwnerProfile> updateProfile(OwnerProfile draft);

  Future<void> setTwoFactor(bool enabled);
  Future<void> setEmailNotif(bool enabled);

  /// Uploads [bytes] (JPEG/PNG) and returns the stored public avatar URL.
  Future<String> uploadAvatar(Uint8List bytes, {String filename});
}
