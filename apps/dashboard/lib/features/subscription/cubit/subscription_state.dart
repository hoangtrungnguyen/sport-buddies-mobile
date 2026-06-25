import 'package:freezed_annotation/freezed_annotation.dart';

import '../model/subscription.dart';

part 'subscription_state.freezed.dart';

@freezed
sealed class SubscriptionState with _$SubscriptionState {
  const factory SubscriptionState.initial() = SubscriptionInitial;
  const factory SubscriptionState.loading() = SubscriptionLoading;
  const factory SubscriptionState.loaded(Subscription subscription) =
      SubscriptionLoaded;
  const factory SubscriptionState.failure(String message) = SubscriptionFailure;
}
