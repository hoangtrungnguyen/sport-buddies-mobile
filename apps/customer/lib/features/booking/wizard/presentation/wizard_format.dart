// Display formatters for the booking wizard. All numbers/times/prices use
// tabular figures via the text styles; these just build the strings.
// Word-bearing formatters take AppLocalizations so copy follows the locale.

import 'package:customer/features/court/domain/court.dart';
import 'package:customer/l10n/app_localizations.dart';

/// "610000" → "610.000 đ".
String vnd(int amount) {
  final s = amount.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '$buf đ';
}

/// "09:00".
String hm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// "09:00 – 10:30".
String timeRange(DateTime start, DateTime end) => '${hm(start)} – ${hm(end)}';

/// "Thứ tư, 14/05".
String dateLabel(AppLocalizations l10n, DateTime d) {
  final weekdays = {
    DateTime.monday: l10n.weekdayMonday,
    DateTime.tuesday: l10n.weekdayTuesday,
    DateTime.wednesday: l10n.weekdayWednesday,
    DateTime.thursday: l10n.weekdayThursday,
    DateTime.friday: l10n.weekdayFriday,
    DateTime.saturday: l10n.weekdaySaturday,
    DateTime.sunday: l10n.weekdaySunday,
  };
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  return '${weekdays[d.weekday]}, $dd/$mm';
}

/// "4 giờ" / "1.5 giờ".
String durationLabel(AppLocalizations l10n, Duration d) {
  final hours = d.inMinutes / 60;
  final str = hours == hours.roundToDouble()
      ? hours.toStringAsFixed(0)
      : hours.toStringAsFixed(1);
  return l10n.wizardHours(str);
}

/// "n khung · 4 giờ".
String countLabel(AppLocalizations l10n, int slotCount, Duration total) =>
    l10n.wizardSlotCountDuration(slotCount, durationLabel(l10n, total));

/// Backend ids are uuids; show a short stable token — "#A1B2C3D4".
String bookingIdLabel(String id) {
  final head = id.split('-').first;
  return '#${head.toUpperCase()}';
}

/// Material sport pictogram for the summary tile.
String sportEmoji(Sport sport) => switch (sport) {
      Sport.football => '⚽',
      Sport.badminton => '🏸',
      Sport.pickleball => '🥒',
      Sport.tennis => '🎾',
      Sport.multi => '🏟️',
    };
