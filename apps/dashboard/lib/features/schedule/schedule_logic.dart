// Pure, framework-free scheduling helpers for the weekly calendar.
//
// Kept separate from the bloc/repository so the date math and conflict
// detection can be unit-tested without Supabase or Flutter.

import 'model/owner_slot.dart';

/// Operating-hour window shown on the calendar (06:00 → 22:00), matching the
/// design grid (17 rows, hours 6..22 inclusive on the axis).
const int kOpenHour = 6;
const int kCloseHour = 22;

/// The hour rows rendered down the left gutter: 6,7,…,22.
List<int> get scheduleHours =>
    List<int>.generate(kCloseHour - kOpenHour + 1, (i) => kOpenHour + i);

/// Vietnamese weekday short labels, Monday-first (T2..CN), matching the design.
const List<String> kDayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

/// Midnight of the Monday on or before [day] (in [day]'s own time zone).
///
/// Dart's [DateTime.weekday] is 1 (Mon) … 7 (Sun), so the week is Monday-first
/// to line up with [kDayLabels].
DateTime mondayOf(DateTime day) {
  final d = DateTime(day.year, day.month, day.day);
  return d.subtract(Duration(days: d.weekday - DateTime.monday));
}

/// Zero-based day column (0 == Monday … 6 == Sunday) for [day] within the week
/// beginning [weekStart]. Returns `null` if [day] falls outside that week.
int? dayIndexInWeek(DateTime weekStart, DateTime day) {
  final start = mondayOf(weekStart);
  final diff = DateTime(day.year, day.month, day.day).difference(start).inDays;
  return (diff >= 0 && diff < 7) ? diff : null;
}

/// True when the half-open intervals `[aStart, aEnd)` and `[bStart, bEnd)`
/// overlap. Touching edges (one ends exactly when the other starts) do not
/// count as a conflict.
bool intervalsOverlap(
  DateTime aStart,
  DateTime aEnd,
  DateTime bStart,
  DateTime bEnd,
) =>
    aStart.isBefore(bEnd) && bStart.isBefore(aEnd);

/// True when a new slot spanning `[startAt, endAt)` would collide with any
/// existing slot in [existing] (cancelled/empty lists never conflict).
///
/// Used by the create-slot form to block overlapping owner slots
/// (mirrors the design's conflict guard).
bool hasConflict(
  List<OwnerSlot> existing,
  DateTime startAt,
  DateTime endAt,
) =>
    existing.any((s) => intervalsOverlap(startAt, endAt, s.startAt, s.endAt));
