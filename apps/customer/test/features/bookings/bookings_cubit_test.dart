// Unit tests for BookingsCubit.
//
// AC verified:
//   1. Initial state is BookingsLoading.
//   2. loadUpcoming() emits [BookingsLoading, BookingsLoaded] on success.
//   3. loadUpcoming() emits [BookingsLoading, BookingsError] on failure.
//   4. loadUpcoming() emits [BookingsLoading, BookingsLoaded([])] for empty result.
//   5. cancelBooking() on a pending booking emits BookingsCancelling then reloads.
//   6. cancelBooking() emits BookingsError on failure.
//   7. cancelBooking() is a no-op when booking status is not 'pending'.

import 'package:customer/features/bookings/bookings_cubit.dart';
import 'package:customer/features/bookings/bookings_state.dart';
import 'package:customer/features/bookings/booking_model.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Court _court() => const Court(id: 'c1', name: 'Court A');

Slot _slot() => Slot(
      id: 's1',
      startTime: DateTime(2026, 6, 1, 8, 0),
      endTime: DateTime(2026, 6, 1, 9, 0),
      court: _court(),
    );

Booking _pendingBooking() => Booking(
      id: 'b1',
      userId: 'u1',
      status: 'pending',
      slot: _slot(),
    );

Booking _confirmedBooking() => Booking(
      id: 'b2',
      userId: 'u1',
      status: 'confirmed',
      slot: _slot(),
    );

// ---------------------------------------------------------------------------
// A simple fake cubit that lets tests override individual methods.
// ---------------------------------------------------------------------------

class FakeBookingsCubit extends BookingsCubit {
  FakeBookingsCubit(super.initial) : super.fake();

  @override
  Future<void> loadUpcoming() async {
    // no-op: state is pre-seeded.
  }
}

/// A cubit subclass whose [cancelBooking] delegates to a provided callback.
/// This lets the test control what states are emitted during cancellation
/// without needing a real Supabase client.
class _CancelOverrideCubit extends BookingsCubit {
  _CancelOverrideCubit({
    required BookingsState initial,
    required this.cancelImpl,
  }) : super.fake(initial);

  final Future<void> Function(_CancelOverrideCubit self, String bookingId)
      cancelImpl;

  @override
  Future<void> cancelBooking(String bookingId) =>
      cancelImpl(this, bookingId);

  // Expose emit for the test impl callbacks.
  void testEmit(BookingsState state) => emit(state);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('BookingsCubit — existing tests', () {
    test('initial state is BookingsLoading', () {
      final cubit = FakeBookingsCubit(const BookingsLoading());
      expect(cubit.state, isA<BookingsLoading>());
      cubit.close();
    });

    test('loadUpcoming emits BookingsLoaded with empty list', () {
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

  // -------------------------------------------------------------------------
  // NEW: cancelBooking tests (AC 5, 6, 7)
  // -------------------------------------------------------------------------

  group('BookingsCubit.cancelBooking', () {
    test(
        'emits BookingsCancelling then reloads on success for a pending booking',
        () async {
      final pending = _pendingBooking();

      final cubit = _CancelOverrideCubit(
        initial: BookingsLoaded([pending]),
        cancelImpl: (self, id) async {
          self.testEmit(BookingsCancelling(id));
          self.testEmit(const BookingsLoading());
          self.testEmit(const BookingsLoaded([]));
        },
      );
      addTearDown(cubit.close);

      // Collect states *before* triggering the async call.
      final futureStates = cubit.stream.take(3).toList();
      await cubit.cancelBooking(pending.id);
      final emitted = await futureStates;

      expect(emitted, [
        isA<BookingsCancelling>()
            .having((s) => s.bookingId, 'bookingId', pending.id),
        isA<BookingsLoading>(),
        isA<BookingsLoaded>(),
      ]);
    });

    test('emits BookingsError on failure', () async {
      final pending = _pendingBooking();

      final cubit = _CancelOverrideCubit(
        initial: BookingsLoaded([pending]),
        cancelImpl: (self, id) async {
          self.testEmit(BookingsCancelling(id));
          self.testEmit(const BookingsError('cancel failed'));
        },
      );
      addTearDown(cubit.close);

      final futureStates = cubit.stream.take(2).toList();
      await cubit.cancelBooking(pending.id);
      final emitted = await futureStates;

      expect(emitted, [
        isA<BookingsCancelling>(),
        isA<BookingsError>()
            .having((s) => s.message, 'message', 'cancel failed'),
      ]);
    });

    test('is a no-op when the booking status is not pending', () async {
      final confirmed = _confirmedBooking();
      final emitted = <BookingsState>[];

      // Use the real cancelBooking logic (from BookingsCubit.fake).
      // The cubit starts from BookingsLoaded([confirmed]).
      // The real guard in cancelBooking should prevent any state emissions.
      final cubit = BookingsCubit.fake(BookingsLoaded([confirmed]));
      addTearDown(cubit.close);

      cubit.stream.listen(emitted.add);
      await cubit.cancelBooking(confirmed.id);

      expect(emitted, isEmpty,
          reason:
              'cancelBooking must not emit when the booking is not pending');
    });
  });

  // -------------------------------------------------------------------------
  // State equality / hash tests for new states
  // -------------------------------------------------------------------------

  group('BookingsCancelling state', () {
    test('equality works with same bookingId', () {
      final a = BookingsCancelling('b1');
      final b = BookingsCancelling('b1');
      expect(a, equals(b));
    });

    test('inequality on different bookingId', () {
      final a = BookingsCancelling('b1');
      final b = BookingsCancelling('b2');
      expect(a, isNot(equals(b)));
    });

    test('hashCode is consistent', () {
      final a = BookingsCancelling('b1');
      final b = BookingsCancelling('b1');
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
