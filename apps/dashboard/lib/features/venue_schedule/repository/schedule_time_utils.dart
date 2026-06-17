import '../util/schedule_format.dart';

/// Pure date / range helpers for the schedule repository — recurrence date
/// formatting, decimal-hour → DateTime, and the block-gap math. No I/O, so the
/// timezone/boundary edge cases are unit-testable in isolation.

/// A `[start, end)` datetime range (local) — used by the block-gap math.
typedef ScheduleRange = ({DateTime start, DateTime end});

/// Sub-ranges of `[start, end)` not covered by any of [rows] (slot rows with
/// `start_at`/`end_at`) — the holes `blockTime` fills with inserts.
List<ScheduleRange> uncoveredRanges(
  DateTime start,
  DateTime end,
  List<Map<String, dynamic>> rows,
) {
  final covered = <ScheduleRange>[];
  for (final r in rows) {
    final s = DateTime.parse(r['start_at'] as String).toLocal();
    final e = DateTime.parse(r['end_at'] as String).toLocal();
    final cs = s.isAfter(start) ? s : start;
    final ce = e.isBefore(end) ? e : end;
    if (ce.isAfter(cs)) covered.add((start: cs, end: ce));
  }
  covered.sort((a, b) => a.start.compareTo(b.start));
  final gaps = <ScheduleRange>[];
  var cursor = start;
  for (final c in covered) {
    if (c.start.isAfter(cursor)) gaps.add((start: cursor, end: c.start));
    if (c.end.isAfter(cursor)) cursor = c.end;
  }
  if (cursor.isBefore(end)) gaps.add((start: cursor, end: end));
  return gaps;
}

/// Defaults a missing date like the create/block sheets expect: weekday → that
/// day of the current week, otherwise today.
DateTime resolveDate(DateTime? date, int? weekday) {
  if (date != null) return DateTime(date.year, date.month, date.day);
  final now = DateTime.now();
  if (weekday != null) {
    final monday = mondayOf(now);
    return DateTime(monday.year, monday.month, monday.day + weekday);
  }
  return DateTime(now.year, now.month, now.day);
}

/// Local [date] at decimal [hour] (`19.5` → 19:30).
DateTime atHour(DateTime date, double hour) => DateTime(
    date.year, date.month, date.day, hour.floor(), ((hour % 1) * 60).round());

/// `HH:MM` of [d] — the recurrence endpoint's time format.
String hhmm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// `YYYY-MM-DD` of [d] — the recurrence endpoint's date format.
String ymd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Day-bucket key for occupancy aggregation.
String dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
