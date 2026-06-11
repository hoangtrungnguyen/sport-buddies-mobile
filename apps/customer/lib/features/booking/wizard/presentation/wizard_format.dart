// Display formatters for the booking wizard. All numbers/times/prices use
// tabular figures via the text styles; these just build the strings.
// Vietnamese copy is final (handoff CLAUDE.md §3).

import 'package:customer/features/court/domain/court.dart';

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
String dateLabel(DateTime d) {
  const weekdays = {
    DateTime.monday: 'Thứ hai',
    DateTime.tuesday: 'Thứ ba',
    DateTime.wednesday: 'Thứ tư',
    DateTime.thursday: 'Thứ năm',
    DateTime.friday: 'Thứ sáu',
    DateTime.saturday: 'Thứ bảy',
    DateTime.sunday: 'Chủ nhật',
  };
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  return '${weekdays[d.weekday]}, $dd/$mm';
}

/// "4 giờ" / "1.5 giờ".
String durationLabel(Duration d) {
  final hours = d.inMinutes / 60;
  final str = hours == hours.roundToDouble()
      ? hours.toStringAsFixed(0)
      : hours.toStringAsFixed(1);
  return '$str giờ';
}

/// "n khung · 4 giờ".
String countLabel(int slotCount, Duration total) =>
    '$slotCount khung · ${durationLabel(total)}';

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
