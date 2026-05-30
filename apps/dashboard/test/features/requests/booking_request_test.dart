import 'package:dashboard/features/requests/model/booking_request.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _row({
  String id = '11112222-3333-4444-5555-666677778888',
  String status = 'pending',
  String? customerName,
  Map<String, dynamic>? profiles,
  num? totalPrice,
  num? pricePerHour = 200000,
  String courtName = 'Sân 1',
  String start = '2026-05-29T11:00:00Z',
  String end = '2026-05-29T12:30:00Z',
  String? code,
}) =>
    {
      'id': id,
      'status': status,
      if (customerName != null) 'customer_name': customerName,
      if (profiles != null) 'profiles': profiles,
      if (totalPrice != null) 'total_price': totalPrice,
      if (code != null) 'code': code,
      'slots': {
        'start_at': start,
        'end_at': end,
        'courts': {
          'name': courtName,
          if (pricePerHour != null) 'price_per_hour': pricePerHour,
        },
      },
    };

void main() {
  group('bookingStatusFromRaw', () {
    test('folds synonyms into the three buckets', () {
      expect(bookingStatusFromRaw('confirmed'), BookingStatus.confirmed);
      expect(bookingStatusFromRaw('booked'), BookingStatus.confirmed);
      expect(bookingStatusFromRaw('approved'), BookingStatus.confirmed);
      expect(bookingStatusFromRaw('completed'), BookingStatus.confirmed);
      expect(bookingStatusFromRaw('cancelled'), BookingStatus.cancelled);
      expect(bookingStatusFromRaw('canceled'), BookingStatus.cancelled);
      expect(bookingStatusFromRaw('rejected'), BookingStatus.cancelled);
      expect(bookingStatusFromRaw('pending'), BookingStatus.pending);
      // Unknown / null default to pending (never silently dropped).
      expect(bookingStatusFromRaw('weird'), BookingStatus.pending);
      expect(bookingStatusFromRaw(null), BookingStatus.pending);
      expect(bookingStatusFromRaw('CONFIRMED'), BookingStatus.confirmed);
    });
  });

  group('BookingRequest.fromRow', () {
    test('parses the canonical join shape', () {
      final b = BookingRequest.fromRow(_row(
        customerName: 'Nguyễn Văn A',
        status: 'confirmed',
        courtName: 'Sân Trung Tâm',
      ));
      expect(b.customerName, 'Nguyễn Văn A');
      expect(b.courtName, 'Sân Trung Tâm');
      expect(b.status, BookingStatus.confirmed);
      expect(b.startAt.toUtc(), DateTime.utc(2026, 5, 29, 11));
      expect(b.endAt.toUtc(), DateTime.utc(2026, 5, 29, 12, 30));
      expect(b.durationHours, 1.5);
    });

    test('prefers customer_name, then profiles, then Khách lẻ', () {
      expect(BookingRequest.fromRow(_row(customerName: 'Walk In')).customerName,
          'Walk In');
      expect(
        BookingRequest.fromRow(
                _row(profiles: const {'full_name': 'App User'}))
            .customerName,
        'App User',
      );
      expect(BookingRequest.fromRow(_row()).customerName, 'Khách lẻ');
    });

    test('uses explicit total_price when present', () {
      final b = BookingRequest.fromRow(_row(totalPrice: 555000));
      expect(b.revenue, 555000);
    });

    test('computes revenue from price_per_hour × duration when no total', () {
      // 1.5h × 200_000 = 300_000.
      final b = BookingRequest.fromRow(_row());
      expect(b.revenue, 300000);
    });

    test('revenue is 0 when neither total nor court price is known', () {
      final b = BookingRequest.fromRow(_row(pricePerHour: null));
      expect(b.revenue, 0);
    });

    test('rounds fractional price × duration', () {
      // 1.5h × 133_333 = 199_999.5 → 200_000.
      final b = BookingRequest.fromRow(_row(pricePerHour: 133333));
      expect(b.revenue, 200000);
    });

    test('total_price of 0 is treated as unset and falls back to court price',
        () {
      // 1.5h × 200_000 = 300_000 (a literal 0 total is far more likely a
      // missing column than a genuinely free booking).
      final b = BookingRequest.fromRow(_row(totalPrice: 0));
      expect(b.revenue, 300000);
    });

    test('derives a short # code from the id when none is given', () {
      final b = BookingRequest.fromRow(_row(id: 'abcdef12-0000-0000'));
      expect(b.code, '#ABCDEF');
    });

    test('keeps an explicit code, adding a leading # if missing', () {
      expect(BookingRequest.fromRow(_row(code: 'ORD123')).code, '#ORD123');
      expect(BookingRequest.fromRow(_row(code: '#ORD123')).code, '#ORD123');
    });

    test('tolerates a missing court name', () {
      final row = _row()..['slots']['courts'] = <String, dynamic>{};
      expect(BookingRequest.fromRow(row).courtName, 'Sân');
    });
  });
}
