import 'package:supabase_flutter/supabase_flutter.dart';

/// Owner identity helpers shared by the drawer footer, the top-bar avatar and
/// the profile repository. Supabase exposes no profile table for owners, so the
/// display name is derived from `user_metadata` (if the backend ever sets one),
/// falling back to the email's local part.

/// Best display name for [user]: a `user_metadata` name, else the email's local
/// part, else null. Callers supply their own fallback label.
String? ownerDisplayName(User? user) {
  final meta = user?.userMetadata;
  final metaName =
      (meta?['full_name'] ?? meta?['name'] ?? meta?['display_name']) as String?;
  if (metaName != null && metaName.trim().isNotEmpty) return metaName.trim();
  final email = user?.email ?? '';
  if (email.contains('@')) return email.split('@').first;
  return null;
}

/// 1–2 letter uppercase initials from [name]. Splits on whitespace and dots so
/// an email local part like `minh.nguyen` yields `MN`. Returns [fallback] when
/// [name] has no usable letters.
String ownerInitials(String name, {String fallback = '?'}) {
  final parts =
      name.trim().split(RegExp(r'[\s.]+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return fallback;
  if (parts.length == 1) {
    final p = parts.first;
    return (p.length >= 2 ? p.substring(0, 2) : p).toUpperCase();
  }
  return (parts.first[0] + parts.last[0]).toUpperCase();
}
