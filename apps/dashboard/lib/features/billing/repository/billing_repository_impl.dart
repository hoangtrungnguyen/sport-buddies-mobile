import '../../../config/feature_flags/feature_flag_service.dart';
import '../../../core/di/injection.dart';
import '../model/invoice.dart';
import '../model/payment_method.dart';
import 'billing_repository.dart';

/// Seed-backed [BillingRepository] for the checkout prototype.
///
/// There is no payment backend yet, so the invoice + methods come from the
/// design seed (`billing-data.jsx`) and [confirmPayment] simulates the
/// gateway: MoMo resolves to instant `success`, bank/cash to `pending`
/// reconciliation. Swap for an API-backed impl once the gateway lands — the
/// abstract contract and the screen stay unchanged.
class BillingRepositoryImpl implements BillingRepository {
  @override
  Invoice get currentInvoice => const Invoice(
        id: 'SNB-2608',
        planName: 'Gói Chuyên nghiệp',
        period: '04/08/2026 – 03/09/2026',
        amount: 990000,
      );

  @override
  List<PaymentMethod> get methods {
    // Cash is gated behind the `checkout_payment_cash` flag (off → hidden).
    final cashEnabled =
        sl<FeatureFlagService>().isEnabled('checkout_payment_cash');
    return PaymentMethod.all
        .where((m) => m.id != PaymentMethodId.cash || cashEnabled)
        .toList();
  }

  @override
  Future<PaymentOutcome> confirmPayment(PaymentMethodId method) async {
    // Simulate the network round-trip to the gateway.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return method == PaymentMethodId.momo
        ? PaymentOutcome.success
        : PaymentOutcome.pending;
  }
}
