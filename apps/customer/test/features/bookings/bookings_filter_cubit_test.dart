// Unit tests for BookingsCubit filter-by-status functionality.
//
// AC verified:
//   - filterByStatus(null) shows all bookings (default 'All')
//   - filterByStatus('pending') shows only pending bookings
//   - filterByStatus('confirmed') shows only confirmed bookings
//   - filterByStatus('completed') shows only completed bookings
//   - filterByStatus('cancelled') shows only cancelled bookings
//   - selectedStatus is null by default (meaning 'All')
//   - filteredBookings on BookingsLoaded reflects selectedStatus

import 'package:customer/features/bookings/bookings_cubit.dart';
import 'package:customer/features/bookings/bookings_state.dart';
import 'package:customer/features/bookings/booking_model.dart';
import 'package:flutter_test/flutter_test.dart';

Booking _makeBooking(String id, String status) {
  const court = Court(id: 'c1', name: 'Court A');
  final slot = Slot(
    id: 's$id',
    startTime: DateTime(2026, 6, 1, 8, 0),
    endTime: DateTime(2026, 6, 1, 9, 0),
    court: court,
  );
  return Booking(id: id, userId: 'u1', status: status, slot: slot);
}

void main() {
  final allBookings = [
    _makeBooking('b1', 'pending'),
    _makeBooking('b2', 'confirmed'),
    _makeBooking('b3', 'completed'),
    _makeBooking('b4', 'cancelled'),
    _makeBooking('b5', 'pending'),
  ];

  group('BookingsCubit.filterByStatus', () {
    late BookingsCubit cubit;

    setUp(() {
      cubit = BookingsCubit.fake(BookingsLoaded(allBookings));
    });

    tearDown(() => cubit.close());

    test('selectedStatus is null by default (All)', () {
      final state = cubit.state as BookingsLoaded;
      expect(state.selectedStatus, isNull);
    });

    test('filteredBookings returns all bookings when selectedStatus is null', () {
      final state = cubit.state as BookingsLoaded;
      expect(state.filteredBookings, equals(allBookings));
    });

    test('filterByStatus(null) emits state with no filter, shows all bookings', () {
      cubit.filterByStatus('pending'); // set a filter first
      cubit.filterByStatus(null);      // then clear
      final state = cubit.state as BookingsLoaded;
      expect(state.selectedStatus, isNull);
      expect(state.filteredBookings, equals(allBookings));
    });

    test('filterByStatus("pending") shows only pending bookings', () {
      cubit.filterByStatus('pending');
      final state = cubit.state as BookingsLoaded;
      expect(state.selectedStatus, equals('pending'));
      expect(state.filteredBookings.map((b) => b.status).toSet(), equals({'pending'}));
      expect(state.filteredBookings.length, equals(2));
    });

    test('filterByStatus("confirmed") shows only confirmed bookings', () {
      cubit.filterByStatus('confirmed');
      final state = cubit.state as BookingsLoaded;
      expect(state.selectedStatus, equals('confirmed'));
      expect(state.filteredBookings.length, equals(1));
      expect(state.filteredBookings.first.id, equals('b2'));
    });

    test('filterByStatus("completed") shows only completed bookings', () {
      cubit.filterByStatus('completed');
      final state = cubit.state as BookingsLoaded;
      expect(state.selectedStatus, equals('completed'));
      expect(state.filteredBookings.length, equals(1));
      expect(state.filteredBookings.first.id, equals('b3'));
    });

    test('filterByStatus("cancelled") shows only cancelled bookings', () {
      cubit.filterByStatus('cancelled');
      final state = cubit.state as BookingsLoaded;
      expect(state.selectedStatus, equals('cancelled'));
      expect(state.filteredBookings.length, equals(1));
      expect(state.filteredBookings.first.id, equals('b4'));
    });

    test('filterByStatus on non-loaded state is a no-op', () {
      final cubit2 = BookingsCubit.fake(const BookingsLoading());
      addTearDown(cubit2.close);
      cubit2.filterByStatus('pending');
      expect(cubit2.state, isA<BookingsLoading>());
    });
  });

  group('BookingsLoaded.selectedStatus and filteredBookings', () {
    test('BookingsLoaded with selectedStatus=null has filteredBookings == bookings', () {
      final state = BookingsLoaded(allBookings);
      expect(state.selectedStatus, isNull);
      expect(state.filteredBookings, equals(allBookings));
    });

    test('BookingsLoaded with selectedStatus filters correctly', () {
      final state = BookingsLoaded(allBookings, selectedStatus: 'confirmed');
      expect(state.filteredBookings.length, equals(1));
      expect(state.filteredBookings.first.status, equals('confirmed'));
    });

    test('BookingsLoaded equality accounts for selectedStatus', () {
      final s1 = BookingsLoaded(allBookings, selectedStatus: 'pending');
      final s2 = BookingsLoaded(allBookings, selectedStatus: 'pending');
      final s3 = BookingsLoaded(allBookings, selectedStatus: 'confirmed');
      expect(s1, equals(s2));
      expect(s1, isNot(equals(s3)));
    });
  });
}
