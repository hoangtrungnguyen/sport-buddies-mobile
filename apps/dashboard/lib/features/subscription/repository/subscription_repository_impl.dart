import '../../../core/debug/app_logger.dart';
import '../model/subscription.dart';
import 'subscription_api_client.dart';
import 'subscription_repository.dart';

/// Live [SubscriptionRepository] backed by `GET /api/owners/me/subscription`.
///
/// Offline-safe (mirrors `FeatureFlagService`): until the backend endpoint
/// lands — or on any transient failure — it falls back to the prototype trial
/// seed so the profile card and drawer banner still render. Remove the fallback
/// once the endpoint is guaranteed in every environment.
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl(this._api);

  final SubscriptionApiClient _api;

  @override
  Future<Subscription> getSubscription() async {
    try {
      return await _api.getSubscription();
    } catch (e, st) {
      appLogger.w('Subscription: API unavailable, using seed',
          error: e, stackTrace: st);
      return _seed();
    }
  }

  /// Prototype default — the free 3-month trial (design source: profile-data.jsx
  /// / nav-drawer trial banner).
  Subscription _seed() => Subscription(
        tier: SubscriptionTier.free,
        status: SubscriptionStatus.trialing,
        name: 'Gói miễn phí 3 tháng',
        startedAt: DateTime(2026, 5, 4),
        expiresAt: DateTime(2026, 8, 4),
      );
}
