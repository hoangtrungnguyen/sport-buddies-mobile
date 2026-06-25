/// VND formatter for the checkout/billing screens — matches the design handoff
/// verbatim: `990000 → "990.000 ₫"`, `0 → "Miễn phí"`.
///
/// Distinct from `core/format/currency.dart` (`vndAmount`, which emits the
/// trailing `đ` with no space) because the payment-gateway design specifies the
/// `₫` symbol with a leading space. Hand-rolled, no `intl` (same convention as
/// the rest of the app).
String fmtVnd(int n) {
  if (n == 0) return 'Miễn phí';
  final digits = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
    buf.write(digits[i]);
  }
  final s = '$buf ₫';
  return n < 0 ? '-$s' : s;
}
