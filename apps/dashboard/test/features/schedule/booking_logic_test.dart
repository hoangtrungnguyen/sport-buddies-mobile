import 'package:dashboard/features/schedule/booking_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeVietnamPhone', () {
    test('local 0-prefixed → +84', () {
      expect(normalizeVietnamPhone('0901234567'), '+84901234567');
    });

    test('strips spaces / dashes / dots / parens', () {
      expect(normalizeVietnamPhone('090 123 4567'), '+84901234567');
      expect(normalizeVietnamPhone('090-123-4567'), '+84901234567');
      expect(normalizeVietnamPhone('(090).123.4567'), '+84901234567');
    });

    test('country-coded 84… → +84…', () {
      expect(normalizeVietnamPhone('84901234567'), '+84901234567');
    });

    test('already +84 international is preserved', () {
      expect(normalizeVietnamPhone('+84901234567'), '+84901234567');
    });

    test('bare local digits missing the leading 0 get +84', () {
      expect(normalizeVietnamPhone('901234567'), '+84901234567');
    });

    test('empty / blank → null', () {
      expect(normalizeVietnamPhone(''), isNull);
      expect(normalizeVietnamPhone('   '), isNull);
    });

    test('non-numeric or too short → null', () {
      expect(normalizeVietnamPhone('abc'), isNull);
      expect(normalizeVietnamPhone('012'), isNull); // → +8412, too short
    });

    test('result is valid E.164', () {
      final n = normalizeVietnamPhone('0987654321')!;
      expect(isValidE164(n), isTrue);
    });
  });

  group('isValidE164', () {
    test('accepts well-formed', () {
      expect(isValidE164('+84901234567'), isTrue);
    });
    test('rejects missing + / leading zero / letters', () {
      expect(isValidE164('84901234567'), isFalse);
      expect(isValidE164('+0901234567'), isFalse); // leading 0 after +
      expect(isValidE164('+84abc'), isFalse);
    });
  });

  group('buildManualBookingPayload', () {
    test('sends UTC components preserving the picked instant', () {
      final start = DateTime(2026, 5, 14, 18); // 18:00 local
      final end = DateTime(2026, 5, 14, 19, 30); // 19:30 local

      final body = buildManualBookingPayload(
        courtId: 'court-1',
        startAtLocal: start,
        endAtLocal: end,
      );

      expect(body['court_id'], 'court-1');
      // Reconstruct the instant the server will build (date+time as UTC) and
      // assert it equals the picked instant — independent of the runner's TZ.
      final sentStart =
          DateTime.parse('${body['date']}T${body['start_time']}:00Z');
      final sentEnd = DateTime.parse('${body['date']}T${body['end_time']}:00Z');
      expect(sentStart, start.toUtc());
      expect(sentEnd, end.toUtc());
    });

    test('omits blank optional fields', () {
      final body = buildManualBookingPayload(
        courtId: 'c1',
        startAtLocal: DateTime(2026, 5, 14, 10),
        endAtLocal: DateTime(2026, 5, 14, 11),
        customerName: '   ',
        customerPhone: null,
        notes: '',
      );
      expect(body.containsKey('customer_name'), isFalse);
      expect(body.containsKey('customer_phone'), isFalse);
      expect(body.containsKey('notes'), isFalse);
      expect(body.containsKey('price_per_hour_override'), isFalse);
    });

    test('includes trimmed optional fields when present', () {
      final body = buildManualBookingPayload(
        courtId: 'c1',
        startAtLocal: DateTime(2026, 5, 14, 10),
        endAtLocal: DateTime(2026, 5, 14, 11),
        customerName: '  Minh  ',
        customerPhone: '+84901234567',
        notes: '  walk-in  ',
        pricePerHourOverride: 120000,
      );
      expect(body['customer_name'], 'Minh');
      expect(body['customer_phone'], '+84901234567');
      expect(body['notes'], 'walk-in');
      expect(body['price_per_hour_override'], 120000);
    });
  });

  group('crossesUtcDateBoundary', () {
    test('same UTC date → false', () {
      // Build explicit UTC instants so the check is TZ-independent.
      expect(
        crossesUtcDateBoundary(
          DateTime.utc(2026, 5, 14, 10),
          DateTime.utc(2026, 5, 14, 12),
        ),
        isFalse,
      );
    });

    test('window straddling UTC midnight → true', () {
      expect(
        crossesUtcDateBoundary(
          DateTime.utc(2026, 5, 14, 23, 0),
          DateTime.utc(2026, 5, 15, 0, 30),
        ),
        isTrue,
      );
    });
  });

  group('confirmedBookingMessage', () {
    // 2026-05-29 is a Friday → 'T6' in kDayLabels.
    test('includes the customer, weekday, date and time range', () {
      final msg = confirmedBookingMessage(
        startAtLocal: DateTime(2026, 5, 29, 18, 0),
        endAtLocal: DateTime(2026, 5, 29, 19, 30),
        customerName: 'Minh',
      );
      expect(msg, 'Đã xác nhận đặt sân cho Minh · T6 29/05 18:00–19:30');
    });

    test('omits the "cho <name>" clause when the name is blank', () {
      final msg = confirmedBookingMessage(
        startAtLocal: DateTime(2026, 5, 29, 7, 0),
        endAtLocal: DateTime(2026, 5, 29, 8, 0),
        customerName: '   ',
      );
      expect(msg, 'Đã xác nhận đặt sân · T6 29/05 07:00–08:00');
      expect(msg.contains(' cho '), isFalse);
    });
  });
}
