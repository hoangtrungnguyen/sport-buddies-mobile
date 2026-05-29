import 'package:dashboard/features/schedule/model/owner_slot.dart';
import 'package:dashboard/features/schedule/schedule_logic.dart';
import 'package:flutter_test/flutter_test.dart';

OwnerSlot _slot(DateTime start, DateTime end) =>
    OwnerSlot(id: 'x', courtId: 'c1', startAt: start, endAt: end);

void main() {
  group('week math', () {
    test('mondayOf returns the Monday on/before a midweek day', () {
      // 2026-05-14 is a Thursday (design TODAY_INDEX == 3).
      expect(mondayOf(DateTime(2026, 5, 14)), DateTime(2026, 5, 11));
      // A Monday maps to itself.
      expect(mondayOf(DateTime(2026, 5, 11)), DateTime(2026, 5, 11));
      // A Sunday maps back to the same week's Monday.
      expect(mondayOf(DateTime(2026, 5, 17)), DateTime(2026, 5, 11));
    });

    test('dayIndexInWeek is Monday-first and bounded to the week', () {
      final ws = DateTime(2026, 5, 11);
      expect(dayIndexInWeek(ws, DateTime(2026, 5, 11)), 0); // Mon
      expect(dayIndexInWeek(ws, DateTime(2026, 5, 14)), 3); // Thu
      expect(dayIndexInWeek(ws, DateTime(2026, 5, 17)), 6); // Sun
      expect(dayIndexInWeek(ws, DateTime(2026, 5, 18)), isNull); // next week
      expect(dayIndexInWeek(ws, DateTime(2026, 5, 10)), isNull); // prev week
    });

    test('scheduleHours covers the operating window inclusively', () {
      expect(scheduleHours.first, kOpenHour);
      expect(scheduleHours.last, kCloseHour);
      expect(scheduleHours.length, kCloseHour - kOpenHour + 1);
    });

    test('kDayLabels is Monday-first', () {
      expect(kDayLabels.first, 'T2');
      expect(kDayLabels.last, 'CN');
      expect(kDayLabels.length, 7);
    });
  });

  group('overlap / conflict', () {
    final h10 = DateTime(2026, 5, 14, 10);
    final h11 = DateTime(2026, 5, 14, 11);
    final h12 = DateTime(2026, 5, 14, 12);

    test('touching edges do not overlap', () {
      expect(intervalsOverlap(h10, h11, h11, h12), isFalse);
    });

    test('genuine overlap is detected', () {
      expect(
        intervalsOverlap(h10, DateTime(2026, 5, 14, 11, 30), h11, h12),
        isTrue,
      );
    });

    test('hasConflict flags an overlapping new slot', () {
      final existing = [_slot(h10, h11)];
      expect(hasConflict(existing, DateTime(2026, 5, 14, 10, 30), h12), isTrue);
    });

    test('hasConflict allows a back-to-back slot', () {
      final existing = [_slot(h10, h11)];
      expect(hasConflict(existing, h11, h12), isFalse);
    });

    test('empty schedule never conflicts', () {
      expect(hasConflict(const [], h10, h11), isFalse);
    });
  });
}
