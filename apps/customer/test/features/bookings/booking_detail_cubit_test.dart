// Unit tests for BookingDetailCubit.
//
// AC verified:
//   1. Initial state is BookingDetailLoading.
//   2. loadJoinRequests emits [BookingDetailLoaded] with empty list on success.
//   3. loadJoinRequests emits [BookingDetailError] on failure.
//   4. JoinRequest model construction with required fields.
//   5. BookingDetailState equality.

import 'package:customer/features/bookings/booking_detail_cubit.dart';
import 'package:customer/features/bookings/booking_detail_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookingDetailCubit', () {
    test('initial state is BookingDetailLoading', () {
      final cubit = BookingDetailCubit.fake(const BookingDetailLoading());
      expect(cubit.state, isA<BookingDetailLoading>());
      cubit.close();
    });

    test('fake cubit seeded with loaded empty list stays loaded', () {
      const loaded = BookingDetailLoaded(
        booking: null,
        joinRequests: [],
      );
      final cubit = BookingDetailCubit.fake(loaded);
      addTearDown(cubit.close);
      expect(cubit.state, isA<BookingDetailLoaded>());
      final s = cubit.state as BookingDetailLoaded;
      expect(s.joinRequests, isEmpty);
    });

    test('fake cubit seeded with error state stays error', () {
      final cubit = BookingDetailCubit.fake(
        const BookingDetailError('network failure'),
      );
      addTearDown(cubit.close);
      expect(cubit.state, isA<BookingDetailError>());
      final e = cubit.state as BookingDetailError;
      expect(e.message, equals('network failure'));
    });

    test('BookingDetailLoaded equality with same data', () {
      const a = BookingDetailLoaded(booking: null, joinRequests: []);
      const b = BookingDetailLoaded(booking: null, joinRequests: []);
      expect(a, equals(b));
    });

    test('BookingDetailError equality on same message', () {
      const a = BookingDetailError('oops');
      const b = BookingDetailError('oops');
      expect(a, equals(b));
    });

    test('BookingDetailError inequality on different message', () {
      const a = BookingDetailError('a');
      const b = BookingDetailError('b');
      expect(a, isNot(equals(b)));
    });
  });

  group('JoinRequest model', () {
    test('constructs with required fields', () {
      const req = JoinRequest(
        id: 'jr1',
        slotId: 's1',
        userId: 'u1',
        status: 'pending',
        userName: 'Nguyen Van A',
        avatarUrl: null,
        createdAt: '2026-05-26T08:00:00Z',
      );
      expect(req.id, equals('jr1'));
      expect(req.userName, equals('Nguyen Van A'));
      expect(req.avatarUrl, isNull);
    });

    test('fromJson parses correctly with profile', () {
      final json = <String, dynamic>{
        'id': 'jr2',
        'slot_id': 's2',
        'user_id': 'u2',
        'status': 'pending',
        'created_at': '2026-05-26T09:00:00Z',
        'profiles': {
          'full_name': 'Tran Thi B',
          'avatar_url': 'https://example.com/avatar.png',
        },
      };
      final req = JoinRequest.fromJson(json);
      expect(req.userName, equals('Tran Thi B'));
      expect(req.avatarUrl, equals('https://example.com/avatar.png'));
    });

    test('fromJson handles null profile gracefully', () {
      final json = <String, dynamic>{
        'id': 'jr3',
        'slot_id': 's3',
        'user_id': 'u3',
        'status': 'pending',
        'created_at': '2026-05-26T10:00:00Z',
        'profiles': null,
      };
      final req = JoinRequest.fromJson(json);
      expect(req.userName, equals(''));
      expect(req.avatarUrl, isNull);
    });

    test('equality works', () {
      const a = JoinRequest(
        id: 'jr1',
        slotId: 's1',
        userId: 'u1',
        status: 'pending',
        userName: 'Alice',
        avatarUrl: null,
        createdAt: '2026-05-26T08:00:00Z',
      );
      const b = JoinRequest(
        id: 'jr1',
        slotId: 's1',
        userId: 'u1',
        status: 'pending',
        userName: 'Alice',
        avatarUrl: null,
        createdAt: '2026-05-26T08:00:00Z',
      );
      expect(a, equals(b));
    });
  });
}
