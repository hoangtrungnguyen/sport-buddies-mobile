// Small date formatters for the profile screen. Kept dependency-free (no
// `intl`) — the app already formats VND/dates by hand elsewhere.

String _pad2(int n) => n.toString().padLeft(2, '0');

/// `DateTime(2025, 3) → "03/2025"` — the "Tham gia từ" join month.
String monthYear(DateTime d) => '${_pad2(d.month)}/${d.year}';

/// `DateTime(2026, 5, 14) → "14/05/2026"` — full day for password / expiry.
String dayMonthYear(DateTime d) =>
    '${_pad2(d.day)}/${_pad2(d.month)}/${d.year}';
