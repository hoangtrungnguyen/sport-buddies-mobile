import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription.freezed.dart';

/// Owner subscription tier — the backend's own vocabulary, returned verbatim by
/// `GET /api/owners/me/subscription`. NB: this differs from `OwnerPlan`
/// (free/pro/enterprise) used by the feature-flag API; map before feeding
/// `GET /api/plans/{plan}/feature-flags` if/when tier drives flags.
enum SubscriptionTier { free, trial, premium }

/// Lifecycle of the subscription, derived server-side: `trialing` for a trial,
/// `active` for free/premium, `expired` past the window. The backend has no
/// cancellation concept yet, so `cancelled` is never emitted.
enum SubscriptionStatus { trialing, active, expired }

/// The owner's current subscription. The single source for both the profile
/// "Gói dịch vụ" card and the nav-drawer trial banner.
///
/// [startedAt]/[expiresAt] are null for a non-expiring plan (e.g. the live free
/// tier sends both null). [daysLeft]/[progress] are derived live from them — and
/// likewise null when there's no window — so the countdown never goes stale and
/// the backend sends only the canonical dates, never the computed values.
@freezed
abstract class Subscription with _$Subscription {
  const Subscription._();

  const factory Subscription({
    required SubscriptionTier tier,
    required SubscriptionStatus status,
    required String name, // "Gói miễn phí 3 tháng"
    DateTime? startedAt,
    DateTime? expiresAt,
  }) = _Subscription;

  /// Whether this plan has a time window (trial/expiring plan) vs an open-ended
  /// one (free). Drives whether the expiry line + progress bar render.
  bool get hasWindow => expiresAt != null;

  /// Whole days remaining until [expiresAt], floored at 0. Null with no window.
  int? get daysLeft {
    final exp = expiresAt;
    if (exp == null) return null;
    final diff = exp.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Elapsed fraction (0..1) of the [startedAt]→[expiresAt] window — drives the
  /// progress bar. Null with no window; clamped; a zero/negative window is full.
  double? get progress {
    final start = startedAt, exp = expiresAt;
    if (start == null || exp == null) return null;
    final total = exp.difference(start).inSeconds;
    if (total <= 0) return 1;
    final elapsed = DateTime.now().difference(start).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  /// Parses the `GET /api/owners/me/subscription` payload. Unknown tier/status
  /// strings degrade to [SubscriptionTier.free]/[SubscriptionStatus.trialing]
  /// so a backend that adds a value never crashes the client; `started_at`/
  /// `expires_at` are nullable (free plan sends both null). (Named `parse`, not
  /// `fromJson`, so json_serializable doesn't try to generate a `.g.dart`.)
  factory Subscription.parse(Map<String, dynamic> json) => Subscription(
        tier: _tierFrom(json['tier'] as String?),
        status: _statusFrom(json['status'] as String?),
        name: (json['name'] as String?)?.trim().isNotEmpty == true
            ? (json['name'] as String).trim()
            : 'Gói dịch vụ',
        startedAt: _dateOrNull(json['started_at']),
        expiresAt: _dateOrNull(json['expires_at']),
      );

  /// Lenient ISO-8601 parse → local time, or null for null/empty/malformed.
  static DateTime? _dateOrNull(Object? v) {
    if (v is! String || v.isEmpty) return null;
    return DateTime.tryParse(v)?.toLocal();
  }

  static SubscriptionTier _tierFrom(String? s) => SubscriptionTier.values
      .firstWhere((t) => t.name == s, orElse: () => SubscriptionTier.free);

  static SubscriptionStatus _statusFrom(String? s) =>
      SubscriptionStatus.values.firstWhere((t) => t.name == s,
          orElse: () => SubscriptionStatus.trialing);
}
