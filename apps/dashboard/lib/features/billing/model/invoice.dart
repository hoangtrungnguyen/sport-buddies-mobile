/// The invoice the owner is paying at checkout — a subscription charge.
/// Source: design handoff `billing-data.jsx` (`PLAN` + `CURRENT_BILL`).
class Invoice {
  const Invoice({
    required this.id,
    required this.planName,
    required this.period,
    required this.amount,
  });

  final String id; // "SNB-2608"
  final String planName; // "Gói Chuyên nghiệp"
  final String period; // "04/08/2026 – 03/09/2026"
  final int amount; // whole VND, VAT included
}

/// Result of confirming a payment. The mock branches on method (MoMo = instant
/// success, bank/cash = pending reconciliation); production should reflect the
/// real transaction status (polling / webhook).
enum PaymentOutcome { success, pending }
