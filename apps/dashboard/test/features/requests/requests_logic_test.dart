import 'package:dashboard/features/requests/model/booking_request.dart';
import 'package:dashboard/features/requests/requests_logic.dart';
import 'package:flutter_test/flutter_test.dart';

BookingRequest _req({
  String id = 'id',
  String name = 'Khách',
  String court = 'Sân 1',
  required int hour,
  int durMin = 60,
  BookingStatus status = BookingStatus.confirmed,
  int revenue = 100000,
}) {
  final start = DateTime(2026, 5, 29, hour);
  return BookingRequest(
    id: id,
    code: '#$id',
    customerName: name,
    courtName: court,
    startAt: start,
    endAt: start.add(Duration(minutes: durMin)),
    status: status,
    revenue: revenue,
  );
}

void main() {
  group('sortByStartAsc', () {
    test('orders by start, tie-broken by court then code', () {
      final out = sortByStartAsc([
        _req(id: 'c', hour: 9, court: 'Sân 2'),
        _req(id: 'a', hour: 8),
        _req(id: 'b', hour: 9, court: 'Sân 1'),
      ]);
      expect(out.map((b) => b.id).toList(), ['a', 'b', 'c']);
    });

    test('does not mutate the input', () {
      final input = [_req(id: 'b', hour: 9), _req(id: 'a', hour: 8)];
      sortByStartAsc(input);
      expect(input.first.id, 'b');
    });
  });

  group('computeSummary', () {
    test('counts total, pending, and sums revenue of non-cancelled', () {
      final s = computeSummary([
        _req(status: BookingStatus.confirmed, revenue: 100000, hour: 8),
        _req(status: BookingStatus.pending, revenue: 50000, hour: 9),
        _req(status: BookingStatus.cancelled, revenue: 999000, hour: 10),
      ]);
      expect(s.total, 3);
      expect(s.pending, 1);
      // Cancelled revenue excluded: 100k + 50k.
      expect(s.expectedRevenue, 150000);
    });

    test('empty list yields zeroes', () {
      final s = computeSummary([]);
      expect(s.total, 0);
      expect(s.pending, 0);
      expect(s.expectedRevenue, 0);
    });
  });

  group('pagination', () {
    final items =
        List.generate(10, (i) => _req(id: '$i', hour: 6 + i)); // 10 items

    test('pageCount rounds up; empty still has one page', () {
      expect(pageCount(10), 3); // 4 + 4 + 2
      expect(pageCount(8), 2);
      expect(pageCount(0), 1);
    });

    test('pageSlice returns up to perPage items', () {
      expect(pageSlice(items, 0).map((b) => b.id).toList(),
          ['0', '1', '2', '3']);
      expect(pageSlice(items, 2).map((b) => b.id).toList(), ['8', '9']);
      expect(pageSlice(items, 9), isEmpty); // out of range
    });

    test('clampPage keeps page in range', () {
      expect(clampPage(-1, 10), 0);
      expect(clampPage(5, 10), 2);
      expect(clampPage(0, 0), 0);
    });

    test('recordCountLabel is a cumulative progress label', () {
      expect(recordCountLabel(0, 10), 'Hiển thị 4 trong 10 đơn');
      expect(recordCountLabel(2, 10), 'Hiển thị 10 trong 10 đơn');
      expect(recordCountLabel(0, 0), 'Hiển thị 0 trong 0 đơn');
      // A negative/out-of-range page floors at 0 shown, never goes negative.
      expect(recordCountLabel(-1, 10), 'Hiển thị 0 trong 10 đơn');
    });

    test('a slot-time group straddling a page boundary recurs per page', () {
      // 5 bookings share one start instant; with 4/page the group is split.
      final same = List.generate(5, (i) => _req(id: '$i', hour: 8));
      final sorted = sortByStartAsc(same);

      final p0 = groupBySlotTime(pageSlice(sorted, 0));
      expect(p0, hasLength(1));
      expect(p0.single.label, '08:00');
      expect(p0.single.items, hasLength(4));

      final p1 = groupBySlotTime(pageSlice(sorted, 1));
      expect(p1, hasLength(1));
      expect(p1.single.label, '08:00');
      expect(p1.single.items, hasLength(1));
    });
  });

  group('groupBySlotTime', () {
    test('groups adjacent equal start times, preserving order', () {
      final groups = groupBySlotTime([
        _req(id: 'a', hour: 8),
        _req(id: 'b', hour: 8),
        _req(id: 'c', hour: 9),
      ]);
      expect(groups, hasLength(2));
      expect(groups[0].items.map((b) => b.id), ['a', 'b']);
      expect(groups[0].label, '08:00');
      expect(groups[1].items.map((b) => b.id), ['c']);
      expect(groups[1].label, '09:00');
    });

    test('groups by instant regardless of timezone representation', () {
      final inst = DateTime.utc(2026, 5, 29, 4);
      BookingRequest at(DateTime s, String id) => BookingRequest(
            id: id,
            code: '#$id',
            customerName: 'x',
            courtName: 'Sân 1',
            startAt: s,
            endAt: s.add(const Duration(hours: 1)),
            status: BookingStatus.confirmed,
            revenue: 0,
          );
      // Same moment, two representations → one group.
      final groups = groupBySlotTime([at(inst, 'a'), at(inst.toLocal(), 'b')]);
      expect(groups, hasLength(1));
      expect(groups.single.items.map((b) => b.id), ['a', 'b']);
    });
  });

  group('labels & formatting', () {
    test('statusLabel maps each status', () {
      expect(statusLabel(BookingStatus.pending), 'Chờ xác nhận');
      expect(statusLabel(BookingStatus.confirmed), 'Đã xác nhận');
      expect(statusLabel(BookingStatus.cancelled), 'Đã huỷ');
    });

    test('timeRange formats HH:mm – HH:mm', () {
      expect(
        timeRange(DateTime(2026, 5, 29, 8), DateTime(2026, 5, 29, 9, 30)),
        '08:00 – 09:30',
      );
    });

    test('dayHeading prefixes the Vietnamese weekday', () {
      // 2026-05-29 is a Friday → T6.
      expect(dayHeading(DateTime(2026, 5, 29)), 'T6, 29/05/2026');
    });

    test('formatVnd groups thousands with dots + đ', () {
      expect(formatVnd(0), '0đ');
      expect(formatVnd(150000), '150.000đ');
      expect(formatVnd(1200000), '1.200.000đ');
      expect(formatVnd(999), '999đ');
      expect(formatVnd(-1200000), '-1.200.000đ');
    });
  });

  group('date helpers', () {
    test('dayStartLocal strips the time', () {
      expect(dayStartLocal(DateTime(2026, 5, 29, 13, 45)),
          DateTime(2026, 5, 29));
    });

    test('addDays shifts whole days from midnight', () {
      expect(addDays(DateTime(2026, 5, 29, 23), 1), DateTime(2026, 5, 30));
      expect(addDays(DateTime(2026, 5, 1), -1), DateTime(2026, 4, 30));
    });

    test('isSameDay ignores time', () {
      expect(isSameDay(DateTime(2026, 5, 29, 1), DateTime(2026, 5, 29, 23)),
          isTrue);
      expect(isSameDay(DateTime(2026, 5, 29), DateTime(2026, 5, 30)), isFalse);
    });
  });
}
