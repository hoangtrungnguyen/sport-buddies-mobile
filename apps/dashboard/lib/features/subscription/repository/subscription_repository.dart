import '../model/subscription.dart';

/// Data gateway for the owner subscription, read by the profile "Gói dịch vụ"
/// card and the nav-drawer trial banner.
abstract class SubscriptionRepository {
  Future<Subscription> getSubscription();
}
