import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/subscription_repository.dart';
import 'subscription_state.dart';

/// Loads the owner subscription once and exposes it to the profile card and the
/// nav-drawer trial banner (provided at the shell so both share one instance).
class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit(this._repository)
      : super(const SubscriptionState.initial());

  final SubscriptionRepository _repository;

  Future<void> load() async {
    emit(const SubscriptionState.loading());
    try {
      emit(SubscriptionState.loaded(await _repository.getSubscription()));
    } catch (e) {
      emit(SubscriptionState.failure(e.toString()));
    }
  }
}
