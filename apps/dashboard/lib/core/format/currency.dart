/// Whole-VND amount with vi-VN `.` thousands grouping + trailing `đ`:
/// `1200000 → "1.200.000đ"`, `-50000 → "-50.000đ"`.
///
/// Hand-rolled (no `intl`/locale data, trivially testable) — the single source
/// for the dashboard's full-currency strings. The compact "4,2tr"/"70k" form
/// is separate (`schedule_format.vndShort`).
String vndAmount(int amount) {
  final digits = amount.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
    buf.write(digits[i]);
  }
  buf.write('đ');
  return amount < 0 ? '-$buf' : '$buf';
}
