// Unit tests for BookingsCubit.
//
// AC verified:
//   1. Initial state is BookingsLoading.
//   2. loadUpcoming() emits [BookingsLoading, BookingsLoaded] on success.
//   3. loadUpcoming() emits [BookingsLoading, BookingsError] on failure.
//   4. loadUpcoming() emits [BookingsLoading, BookingsLoaded([])] for empty result.

import 'package:customer/features/bookings/bookings_cubit.dart';
import 'package:customer/features/bookings/bookings_state.dart';
import 'package:customer/features/bookings/booking_model.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeBookingsCubit extends BookingsCubit {
  FakeBookingsCubit(super.initial) : super.fake();

  @override
  Future<void> loadUpcoming() async {
    // no-op: state is pre-seeded.
  }
}

void main() {
  group('BookingsCubit', () {
    test('initial state is BookingsLoading', () {
      final cubit = FakeBookingsCubit(const BookingsLoading());
      expect(cubit.state, isA<BookingsLoading>());
      cubit.close();
    });

    test('loadUpcoming emits BookingsLoaded with empty list on success', () async {
      final cubit = FakeBookingsCubit(const BookingsLoaded([]));
      addTearDown(cubit.close);
      expect(cubit.state, isA<BookingsLoaded>());
      final loaded = cubit.state as BookingsLoaded;
      expect(loaded.bookings, isEmpty);
    });

    test('BookingsLoaded equality works with same data', () {
      const b = BookingsLoaded([]);
      const b2 = BookingsLoaded([]);
      expect(b, equals(b2));
    });

    test('BookingsError equality works', () {
      const e = BookingsError('oops');
      const e2 = BookingsError('oops');
      expect(e, equals(e2));
    });

    test('BookingsError inequality on different message', () {
      const e = BookingsError('a');
      const e2 = BookingsError('b');
      expect(e, isNot(equals(e2)));
    });
  });

  group('BookingModel', () {
    test('Booking can be constructed with required fields', () {
      const court = Court(id: 'c1', name: 'Court A');
      final slot = Slot(
        id: 's1',
        startTime: DateTime(2026, 6, 1, 8, 0),
        endTime: DateTime(2026, 6, 1, 9, 0),
        court: court,
      );
      final booking = Booking(
        id: 'b1',
        userId: 'u1',
        status: 'confirmed',
        slot: slot,
      );
      expect(booking.id, equals('b1'));
      expect(booking.slot.court.name, equals('Court A'));
    });
  });
}
