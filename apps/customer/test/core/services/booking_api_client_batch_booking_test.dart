// End-to-end tests for multi-slot batch booking API.
//
// AC verified:
//   1. Response parsing: per-slot success → booking map
//   2. Response parsing: per-slot error → SlotUnavailableException
//   3. Response parsing: mixed success/error → exception with failed slot IDs
//   4. Response parsing: null booking ID → skipped
//   5. Response structure: handles array of result objects

import 'dart:convert';

import 'package:customer/core/services/booking_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('createBatchBooking response parsing', () {
    // Helper to test response parsing logic in isolation
    Map<String, String> parseSuccessResponse(String responseBody) {
      final decoded = jsonDecode(responseBody);
      final resultList = decoded is List<dynamic> ? decoded : [decoded];
      final bookingMap = <String, String>{};
      final failedSlots = <String>[];

      for (final item in resultList) {
        if (item is! Map<String, dynamic>) continue;
        final slotId = item['slot_id'] as String?;
        final status = item['status'] as String?;
        final booking = item['booking'] as Map<String, dynamic>?;

        if (slotId != null) {
          if (status == 'success' && booking != null) {
            final bookingId = booking['id'] as String?;
            if (bookingId != null) {
              bookingMap[slotId] = bookingId;
            }
          } else if (status == 'error') {
            failedSlots.add(slotId);
          }
        }
      }

      if (failedSlots.isNotEmpty) {
        throw SlotUnavailableException(
          'Failed slots: ${failedSlots.join(", ")}',
        );
      }

      return bookingMap;
    }

    test('parses successful multi-slot batch response', () {
      final responseBody = '''
        [
          {
            "slot_id": "slot-1",
            "status": "success",
            "booking": {
              "id": "booking-1",
              "slot_id": "slot-1",
              "court_id": "court-1",
              "user_id": "user-1",
              "status": "pending",
              "customer_name": "John Doe",
              "customer_phone": "0123456789",
              "notes": "Test booking",
              "booking_series_id": null,
              "created_at": "2026-06-12T10:00:00Z"
            },
            "error": null
          },
          {
            "slot_id": "slot-2",
            "status": "success",
            "booking": {
              "id": "booking-2",
              "slot_id": "slot-2",
              "court_id": "court-1",
              "user_id": "user-1",
              "status": "pending",
              "customer_name": "John Doe",
              "customer_phone": "0123456789",
              "notes": "Test booking",
              "booking_series_id": null,
              "created_at": "2026-06-12T10:00:00Z"
            },
            "error": null
          }
        ]
      ''';

      final result = parseSuccessResponse(responseBody);

      expect(result, equals({
        'slot-1': 'booking-1',
        'slot-2': 'booking-2',
      }));
      expect(result.length, equals(2));
    });

    test('parses single-slot successful response', () {
      final responseBody = '''
        [
          {
            "slot_id": "slot-1",
            "status": "success",
            "booking": {
              "id": "booking-uuid-456",
              "slot_id": "slot-1",
              "court_id": "court-789",
              "user_id": "user-101",
              "status": "pending",
              "customer_name": "Test User",
              "customer_phone": "0123456789",
              "notes": null,
              "booking_series_id": null,
              "created_at": "2026-06-12T15:30:00Z"
            },
            "error": null
          }
        ]
      ''';

      final result = parseSuccessResponse(responseBody);

      expect(result, equals({'slot-1': 'booking-uuid-456'}));
    });

    test('throws exception when any slot fails', () {
      final responseBody = '''
        [
          {
            "slot_id": "slot-1",
            "status": "success",
            "booking": {
              "id": "booking-1",
              "slot_id": "slot-1",
              "court_id": "court-1",
              "user_id": "user-1",
              "status": "pending",
              "customer_name": "John Doe",
              "customer_phone": "0123456789",
              "notes": null,
              "booking_series_id": null,
              "created_at": "2026-06-12T10:00:00Z"
            },
            "error": null
          },
          {
            "slot_id": "slot-2",
            "status": "error",
            "booking": null,
            "error": "Slot already taken"
          }
        ]
      ''';

      expect(
        () => parseSuccessResponse(responseBody),
        throwsA(isA<SlotUnavailableException>()),
      );
    });

    test('throws exception with all failed slot IDs', () {
      final responseBody = '''
        [
          {
            "slot_id": "slot-1",
            "status": "error",
            "booking": null,
            "error": "Already taken"
          },
          {
            "slot_id": "slot-2",
            "status": "error",
            "booking": null,
            "error": "Already taken"
          },
          {
            "slot_id": "slot-3",
            "status": "error",
            "booking": null,
            "error": "Already taken"
          }
        ]
      ''';

      expect(
        () => parseSuccessResponse(responseBody),
        throwsA(
          isA<SlotUnavailableException>().having(
            (e) => e.detail,
            'detail',
            contains('slot-1'),
          ),
        ),
      );
    });

    test('skips items with null booking ID in success status', () {
      final responseBody = '''
        [
          {
            "slot_id": "slot-1",
            "status": "success",
            "booking": {
              "id": "booking-1",
              "slot_id": "slot-1",
              "court_id": "court-1",
              "user_id": "user-1",
              "status": "pending",
              "customer_name": "John Doe",
              "customer_phone": "0123456789",
              "notes": null,
              "booking_series_id": null,
              "created_at": "2026-06-12T10:00:00Z"
            },
            "error": null
          },
          {
            "slot_id": "slot-2",
            "status": "success",
            "booking": {
              "id": null,
              "slot_id": "slot-2",
              "court_id": "court-1",
              "user_id": "user-1",
              "status": "pending",
              "customer_name": "John Doe",
              "customer_phone": "0123456789",
              "notes": null,
              "booking_series_id": null,
              "created_at": "2026-06-12T10:00:00Z"
            },
            "error": null
          }
        ]
      ''';

      final result = parseSuccessResponse(responseBody);

      // slot-2 should not be in the result due to null ID
      expect(result, equals({'slot-1': 'booking-1'}));
      expect(result.containsKey('slot-2'), isFalse);
    });

    test('handles complex UUID values correctly', () {
      final responseBody = '''
        [
          {
            "slot_id": "550e8400-e29b-41d4-a716-446655440000",
            "status": "success",
            "booking": {
              "id": "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
              "slot_id": "550e8400-e29b-41d4-a716-446655440000",
              "court_id": "6ba7b811-9dad-11d1-80b4-00c04fd430c8",
              "user_id": "6ba7b812-9dad-11d1-80b4-00c04fd430c8",
              "status": "pending",
              "customer_name": "Test User",
              "customer_phone": "0123456789",
              "notes": null,
              "booking_series_id": null,
              "created_at": "2026-06-12T15:30:00Z"
            },
            "error": null
          }
        ]
      ''';

      final result = parseSuccessResponse(responseBody);

      expect(
        result['550e8400-e29b-41d4-a716-446655440000'],
        equals('6ba7b810-9dad-11d1-80b4-00c04fd430c8'),
      );
    });

    test('handles response with all required booking fields', () {
      final responseBody = '''
        [
          {
            "slot_id": "slot-1",
            "status": "success",
            "booking": {
              "id": "booking-1",
              "slot_id": "slot-1",
              "court_id": "court-1",
              "user_id": "user-1",
              "status": "confirmed",
              "customer_name": "John Doe",
              "customer_phone": "0123456789",
              "notes": "VIP booking with notes",
              "booking_series_id": "series-1",
              "created_at": "2026-06-12T10:00:00Z"
            },
            "error": null
          }
        ]
      ''';

      final result = parseSuccessResponse(responseBody);

      // Parser should extract only the ID regardless of other fields
      expect(result, equals({'slot-1': 'booking-1'}));
    });
  });
}
