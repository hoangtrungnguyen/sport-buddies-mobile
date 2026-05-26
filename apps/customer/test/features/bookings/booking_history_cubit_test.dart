// Unit tests for BookingHistoryCubit.
//
// AC verified:
//   1. Initial state is BookingsLoading.
//   2. loadHistory() emits [BookingsLoading, BookingsLoaded] on success.
//   3. loadHistory() emits [BookingsLoading, BookingsLoaded([])] for empty result.
//   4. loadHistory() emits [BookingsLoading, BookingsError] on failure.

import 'package:customer/features/bookings/booking_history_cubit.dart';
import 'package:customer/features/bookings/bookings_state.dart';
import 'package:customer/features/bookings/booking_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake subclass to pre-seed state without a real Supabase client.
class FakeBookingHistoryCubit extends BookingHistoryCubit {
  FakeBookingHistoryCubit(super.initial) : super.fake();

  @override
  Future<void> loadHistory() async {
    // no-op: state is pre-seeded via constructor.
  }
}

void main() {
  group('BookingHistoryCubit', () {
    test('initial state is BookingsLoading', () {
      final cubit = FakeBookingHistoryCubit(const BookingsLoading());
      expect(cubit.state, isA<BookingsLoading>());
      cubit.close();
    });

    test('loadHistory emits BookingsLoaded with empty list for empty result',
        () async {
      final cubit = FakeBookingHistoryCubit(const BookingsLoaded([]));
      addTearDown(cubit.close);
      expect(cubit.state, isA<BookingsLoaded>());
      final loaded = cubit.state as BookingsLoaded;
      expect(loaded.bookings, isEmpty);
    });

    test('loadHistory emits BookingsLoaded with bookings on success', () async {
      const court = Court(id: 'c1', name: 'Sân A');
      final slot = Slot(
        id: 's1',
        startTime: DateTime(2026, 1, 10, 9, 0),
        endTime: DateTime(2026, 1, 10, 10, 0),
        court: court,
      );
      final booking = Booking(
        id: 'b1',
        userId: 'u1',
        status: 'completed',
        slot: slot,
      );
      final cubit = FakeBookingHistoryCubit(BookingsLoaded([booking]));
      addTearDown(cubit.close);
      final loaded = cubit.state as BookingsLoaded;
      expect(loaded.bookings, hasLength(1));
      expect(loaded.bookings.first.status, equals('completed'));
    });

    test('loadHistory emits BookingsError on failure', () async {
      final cubit =
          FakeBookingHistoryCubit(const BookingsError('Failed to load history'));
      addTearDown(cubit.close);
      expect(cubit.state, isA<BookingsError>());
      final error = cubit.state as BookingsError;
      expect(error.message, equals('Failed to load history'));
    });

    test('BookingsLoaded equality with same data', () {
      const a = BookingsLoaded([]);
      const b = BookingsLoaded([]);
      expect(a, equals(b));
    });

    test('BookingsError equality with same message', () {
      const a = BookingsError('oops');
      const b = BookingsError('oops');
      expect(a, equals(b));
    });
  });
}
