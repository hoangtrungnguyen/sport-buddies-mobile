/// Client-side formatting for the Home screen — the `/api/home/overview`
/// endpoint returns raw ints / ISO timestamps, all display strings (currency,
/// time ranges, Vietnamese date labels, avatar initials) are built here.
library;

import 'package:dashboard/core/format/currency.dart';

const List<String> _weekdayShort = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

const List<String> _weekdayFull = [
  'Thứ Hai',
  'Thứ Ba',
  'Thứ Tư',
  'Thứ Năm',
  'Thứ Sáu',
  'Thứ Bảy',
  'Chủ Nhật',
];

/// VND amount, thousands-grouped vi-VN style + `đ`: `4250000 → "4.250.000đ"`.
String vndCurrency(int amount) => vndAmount(amount);

/// `HH:MM` of a local [d].
String hhmm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Signed percentage label: `12 → "+12%"`, `-5 → "-5%"`, `0 → "0%"`.
String signedPercent(int pct) => '${pct > 0 ? '+' : ''}$pct%';

/// `T2`…`CN` short weekday label (Mon-indexed).
String weekdayShort(DateTime d) => _weekdayShort[d.weekday - 1];

/// `Thứ Hai`…`Chủ Nhật` full weekday label.
String weekdayFull(DateTime d) => _weekdayFull[d.weekday - 1];

/// `dd/MM/yyyy`.
String dmy(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Session time range for a request row: `"Hôm nay · 18:00–19:30"` when
/// [start] falls on [today], otherwise `"08/06 · 18:00–19:30"`.
String whenLabel(DateTime start, DateTime end, DateTime today) {
  final sameDay =
      start.year == today.year && start.month == today.month && start.day == today.day;
  final prefix = sameDay
      ? 'Hôm nay'
      : '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}';
  return '$prefix · ${hhmm(start)}–${hhmm(end)}';
}

/// 1–2 letter avatar initials from the first two words of [name]
/// (`"Trần Quốc Bảo" → "TQ"`, `"Minh" → "M"`). `"?"` when blank.
String initialsFrom(String name) {
  final words =
      name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return '?';
  if (words.length == 1) return words.first[0].toUpperCase();
  return (words[0][0] + words[1][0]).toUpperCase();
}
