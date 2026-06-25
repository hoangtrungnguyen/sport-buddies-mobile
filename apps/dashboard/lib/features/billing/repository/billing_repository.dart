import '../model/invoice.dart';
import '../model/payment_method.dart';

/// Data gateway for the checkout screen: the invoice to pay, the available
/// payment methods, and confirming a payment.
abstract class BillingRepository {
  /// The invoice currently being paid (the subscription charge).
  Invoice get currentInvoice;

  /// Available payment methods, in display order.
  List<PaymentMethod> get methods;

  /// Confirms payment via [method] and resolves to the transaction outcome.
  Future<PaymentOutcome> confirmPayment(PaymentMethodId method);
}
