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

// -----------------------------------------------------------------------------
// Recurrence planning
// -----------------------------------------------------------------------------

/// Thrown by [planRecurrence] when the requested recurrence cannot be expressed
/// against the server's UTC-day / single-window constraints. The repository
/// catches it and rethrows as a user-facing `ScheduleRepositoryException`.
class RecurrencePlanException implements Exception {
  const RecurrencePlanException(this.message);
  final String message;
}

/// One ≤90-day window of a recurrence batch — the date bounds of a single
/// `POST /api/courts/{id}/recurrence` call (already UTC `YYYY-MM-DD`).
typedef RecurrenceWindow = ({String fromDate, String untilDate});

/// The fully-resolved recurrence batch: the shared UTC weekday keys + `HH:MM`
/// times and the ordered list of ≤90-day windows to POST in sequence.
typedef RecurrencePlan = ({
  List<String> daysOfWeek,
  String startTime,
  String endTime,
  List<RecurrenceWindow> windows,
});

/// Server-side recurrence cap: one `POST .../recurrence` spans at most 90 days
/// (`until_date - from_date`, server `_MAX_RECURRENCE_DAYS = 90` → 400 beyond).
const _maxRecurrenceChunkDays = 90;

/// Translates a local wall-clock recurrence ([anchorWeek] Monday, decimal
/// [startHour]/[endHour], [weekdays] 0=Mon..6=Sun, [weeks]) into the UTC keys,
/// times and ≤90-day date windows the recurrence endpoint expects.
///
/// Pure — [now] is injected so the timezone / day-shift / chunking edge cases
/// are unit-testable. Throws [RecurrencePlanException] for the two user-facing
/// reject cases (window already elapsed, or a session crossing/ending on the
/// UTC-day boundary, which the endpoint cannot express).
///
/// The local anchor window matches the legacy client-side loop: [Monday of the
/// anchor week, Monday + weeks*7 - 1] — clamped forward to today so a mid-week
/// anchor never back-fills past days, and past today when today's session start
/// has already elapsed.
RecurrencePlan planRecurrence({
  required DateTime anchorWeek,
  required double startHour,
  required double endHour,
  required List<int> weekdays,
  required int weeks,
  required DateTime now,
}) {
  final today = DateTime(now.year, now.month, now.day);
  var fromLocal = anchorWeek.isBefore(today) ? today : anchorWeek;
  if (fromLocal == today && atHour(today, startHour).isBefore(now)) {
    fromLocal = DateTime(today.year, today.month, today.day + 1);
  }
  final untilLocal = DateTime(
      anchorWeek.year, anchorWeek.month, anchorWeek.day + weeks * 7 - 1);
  if (untilLocal.isBefore(fromLocal)) {
    throw const RecurrencePlanException(
        'Khoảng lặp lại đã trôi qua — hãy chọn tuần hiện tại hoặc sau.');
  }

  final startLocal = atHour(fromLocal, startHour);
  final startUtc = startLocal.toUtc();
  final endUtc = atHour(fromLocal, endHour).toUtc();
  // The endpoint expresses a session as HH:MM times within ONE UTC day, so a
  // session that crosses UTC midnight — or ends exactly on it, making end_time
  // ("00:00") <= start_time — is inexpressible and the server rejects it with
  // 400. Locally (UTC+7) that is any session spanning, or ending exactly at,
  // 07:00. Throw a specific reason; single-slot create handles these windows
  // fine (full datetimes).
  if (endUtc.hour * 60 + endUtc.minute <= startUtc.hour * 60 + startUtc.minute) {
    final boundary = (startLocal.timeZoneOffset.inMinutes / 60.0 + 24) % 24;
    throw RecurrencePlanException(
        'Lịch lặp lại không hỗ trợ khung giờ kéo dài qua hoặc kết thúc '
        'đúng ${hourLabel(boundary)} (giới hạn máy chủ) — hãy tạo từng '
        'slot riêng lẻ.');
  }

  // Whole days between the local date and the UTC date of the same instant
  // (-1, 0 or +1) — applied to the weekday keys and date bounds.
  final dayShift = DateTime.utc(startUtc.year, startUtc.month, startUtc.day)
      .difference(
          DateTime.utc(startLocal.year, startLocal.month, startLocal.day))
      .inDays;
  const dayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  final daysOfWeek = [
    for (final w in {...weekdays}) dayKeys[(w + dayShift + 7) % 7],
  ];

  // Long recurrences (weeks >= 14) are sent as consecutive ≤ 90-day windows.
  // Non-atomic across windows — same as the legacy per-session loop: a
  // mid-batch failure keeps what earlier windows created (handled by the
  // caller's partial-summary rejection).
  final windows = <RecurrenceWindow>[];
  var chunkStart = fromLocal;
  while (!chunkStart.isAfter(untilLocal)) {
    final cap = DateTime(chunkStart.year, chunkStart.month,
        chunkStart.day + _maxRecurrenceChunkDays);
    final chunkEnd = cap.isAfter(untilLocal) ? untilLocal : cap;
    windows.add((
      fromDate: ymd(DateTime(
          chunkStart.year, chunkStart.month, chunkStart.day + dayShift)),
      untilDate:
          ymd(DateTime(chunkEnd.year, chunkEnd.month, chunkEnd.day + dayShift)),
    ));
    chunkStart = DateTime(chunkEnd.year, chunkEnd.month, chunkEnd.day + 1);
  }

  return (
    daysOfWeek: daysOfWeek,
    startTime: hhmm(startUtc),
    endTime: hhmm(endUtc),
    windows: windows,
  );
}

/// One future block session: the concrete [date] plus the [weekday] key
/// (0=Mon..6=Sun) it was generated from, for `BlockTimeRequest.copyWith`.
typedef BlockSession = ({DateTime date, int weekday});

/// Expands a recurring block into its future sessions — each selected weekday ×
/// week, anchored on [anchorWeek] (a Monday) — skipping any whose start at
/// [startHour] has already passed ([now]). The bloc blocks one request per
/// returned session; this is the per-session loop the recurring-block path runs
/// client-side (the recurrence endpoint covers create, not block).
///
/// Pure — [now] injected for testability, like [planRecurrence].
List<BlockSession> recurringBlockSessions({
  required DateTime anchorWeek,
  required List<int> weekdays,
  required int weeks,
  required double startHour,
  required DateTime now,
}) {
  final sessions = <BlockSession>[];
  for (var w = 0; w < weeks; w++) {
    for (final weekday in weekdays) {
      final date = DateTime(
          anchorWeek.year, anchorWeek.month, anchorWeek.day + w * 7 + weekday);
      if (atHour(date, startHour).isBefore(now)) continue;
      sessions.add((date: date, weekday: weekday));
    }
  }
  return sessions;
}
