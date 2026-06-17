import 'package:dashboard/features/venue_schedule/repository/schedule_time_utils.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _row(DateTime startLocal, DateTime endLocal) => {
      'start_at': startLocal.toUtc().toIso8601String(),
      'end_at': endLocal.toUtc().toIso8601String(),
    };

void main() {
  group('atHour', () {
    test('decimal hour → DateTime on the same day', () {
      final d = DateTime(2026, 6, 15);
      expect(atHour(d, 19.5), DateTime(2026, 6, 15, 19, 30));
      expect(atHour(d, 6), DateTime(2026, 6, 15, 6, 0));
    });
  });

  group('formatting helpers', () {
    test('hhmm / ymd / dayKey', () {
      final d = DateTime(2026, 6, 5, 7, 9);
      expect(hhmm(d), '07:09');
      expect(ymd(d), '2026-06-05');
      expect(dayKey(d), '2026-6-5');
    });
  });

  group('resolveDate', () {
    test('explicit date is normalized to midnight', () {
      expect(resolveDate(DateTime(2026, 6, 15, 13, 45), null),
          DateTime(2026, 6, 15));
    });

    test('weekday selects that day of the current week (Mon=0)', () {
      final monday = resolveDate(null, 0);
      expect(monday.weekday, DateTime.monday);
      final sunday = resolveDate(null, 6);
      expect(sunday.weekday, DateTime.sunday);
      expect(sunday.difference(monday).inDays, 6);
    });

    test('no date and no weekday → today (midnight)', () {
      final now = DateTime.now();
      expect(resolveDate(null, null), DateTime(now.year, now.month, now.day));
    });
  });

  group('uncoveredRanges', () {
    final start = DateTime(2026, 6, 15, 6);
    final end = DateTime(2026, 6, 15, 12);

    test('no rows → the whole window is a gap', () {
      expect(uncoveredRanges(start, end, const []), [
        (start: start, end: end),
      ]);
    });

    test('full coverage → no gaps', () {
      final rows = [_row(start, end)];
      expect(uncoveredRanges(start, end, rows), isEmpty);
    });

    test('a middle booking leaves head and tail gaps', () {
      final rows = [
        _row(DateTime(2026, 6, 15, 8), DateTime(2026, 6, 15, 10)),
      ];
      expect(uncoveredRanges(start, end, rows), [
        (start: start, end: DateTime(2026, 6, 15, 8)),
        (start: DateTime(2026, 6, 15, 10), end: end),
      ]);
    });

    test('overlapping rows are merged before gap computation', () {
      final rows = [
        _row(DateTime(2026, 6, 15, 7), DateTime(2026, 6, 15, 9)),
        _row(DateTime(2026, 6, 15, 8), DateTime(2026, 6, 15, 10)),
      ];
      expect(uncoveredRanges(start, end, rows), [
        (start: start, end: DateTime(2026, 6, 15, 7)),
        (start: DateTime(2026, 6, 15, 10), end: end),
      ]);
    });
  });
}
