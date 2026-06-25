import 'package:freezed_annotation/freezed_annotation.dart';

import '../model/invoice.dart';
import '../model/payment_method.dart';

part 'checkout_state.freezed.dart';

/// Local state of the checkout dialog: the invoice + methods (constant for the
/// session), the [selected] method, an in-flight [submitting] flag, and the
/// [outcome] (non-null once confirmed → swaps the form for the success view).
@freezed
abstract class CheckoutState with _$CheckoutState {
  const CheckoutState._();

  const factory CheckoutState({
    required Invoice invoice,
    required List<PaymentMethod> methods,
    required PaymentMethodId selected,
    @Default(false) bool submitting,
    PaymentOutcome? outcome,
  }) = _CheckoutState;

  bool get done => outcome != null;

  PaymentMethod get selectedMethod =>
      methods.firstWhere((m) => m.id == selected);
}
