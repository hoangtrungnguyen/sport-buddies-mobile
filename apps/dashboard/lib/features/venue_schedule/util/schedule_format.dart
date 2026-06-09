/// Formatting + small date helpers for the "Lịch sân" screen — replicates
/// `scfmt` from `schedule-data.jsx` (vi-VN currency grouping, decimal-hour
/// time labels).
library;

/// Vietnamese weekday labels, index 0 = Monday (`SC_DAYS` in the prototype).
const List<String> weekdayShortLabels = [
  'T2',
  'T3',
  'T4',
  'T5',
  'T6',
  'T7',
  'CN'
];

/// Local Monday midnight of the week containing [d] (weekday index 0 = Mon).
DateTime mondayOf(DateTime d) =>
    DateTime(d.year, d.month, d.day - (d.weekday - 1));

/// Decimal hour → `HH:MM` label: `18 → "18:00"`, `19.5 → "19:30"`.
///
/// Mirrors `scfmt.hr`: any fractional part means a half hour (`:30`) — the
/// grid only ever snaps to 30-minute increments.
String hourLabel(double hour) {
  final hh = hour.floor().toString().padLeft(2, '0');
  final mm = hour % 1 == 0 ? '00' : '30';
  return '$hh:$mm';
}

/// VND amount, thousands-grouped vi-VN style + `đ`: `525000 → "525.000đ"`.
String vnd(int amount) {
  final digits = amount.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
    buf.write(digits[i]);
  }
  buf.write('đ');
  return '${amount < 0 ? '-' : ''}$buf';
}

/// Compact VND: `4200000 → "4,2tr"`, `4000000 → "4tr"`, `70000 → "70k"`,
/// `500 → "500"`.
///
/// Mirrors `scfmt.vndShort` (`toFixed(1).replace('.0','') + 'tr'`) with the
/// vi-VN decimal comma the handoff renders ("4,2tr").
String vndShort(int amount) {
  if (amount >= 1000000) {
    final m = (amount / 1000000).toStringAsFixed(1);
    return '${m.endsWith('.0') ? m.substring(0, m.length - 2) : m.replaceAll('.', ',')}tr';
  }
  if (amount >= 1000) return '${(amount / 1000).round()}k';
  return amount.toString();
}
