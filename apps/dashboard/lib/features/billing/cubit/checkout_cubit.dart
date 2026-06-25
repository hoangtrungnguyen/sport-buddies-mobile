import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/payment_method.dart';
import '../repository/billing_repository.dart';
import 'checkout_state.dart';

/// Drives the checkout dialog: method selection and confirm → outcome. State is
/// dialog-scoped (created per presentation), so this is a [Cubit], not a
/// shell-level singleton.
class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({required BillingRepository repository})
      : _repository = repository,
        super(CheckoutState(
          invoice: repository.currentInvoice,
          methods: repository.methods,
          selected: PaymentMethodId.bank,
        ));

  final BillingRepository _repository;

  /// Selects a payment method. Ignored once submitting or done.
  void select(PaymentMethodId id) {
    if (state.submitting || state.done) return;
    emit(state.copyWith(selected: id));
  }

  /// Confirms payment for the selected method and records the outcome.
  Future<void> pay() async {
    if (state.submitting || state.done) return;
    emit(state.copyWith(submitting: true));
    try {
      final outcome = await _repository.confirmPayment(state.selected);
      emit(state.copyWith(submitting: false, outcome: outcome));
    } catch (_) {
      // Surface nothing structured yet (stub never throws); just clear the
      // spinner so the user can retry. A real gateway would map errors here.
      emit(state.copyWith(submitting: false));
    }
  }
}
