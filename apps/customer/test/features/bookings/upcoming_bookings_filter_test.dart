// Widget tests verifying that UpcomingBookingsScreen integrates the filter bar.
//
// AC verified:
//   - Filter chips appear above the bookings list
//   - Tapping a chip changes the displayed bookings

import 'package:customer/features/bookings/booking_filter_bar.dart';
import 'package:customer/features/bookings/booking_model.dart';
import 'package:customer/features/bookings/bookings_cubit.dart';
import 'package:customer/features/bookings/bookings_state.dart';
import 'package:customer/features/bookings/upcoming_bookings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

Booking _makeBooking(String id, String status, String courtName) {
  final court = Court(id: 'c$id', name: courtName);
  final slot = Slot(
    id: 's$id',
    startTime: DateTime(2026, 6, 1, 8, 0),
    endTime: DateTime(2026, 6, 1, 9, 0),
    court: court,
  );
  return Booking(id: id, userId: 'u1', status: status, slot: slot);
}

void main() {
  final bookings = [
    _makeBooking('b1', 'pending', 'Court Pending'),
    _makeBooking('b2', 'confirmed', 'Court Confirmed'),
    _makeBooking('b3', 'cancelled', 'Court Cancelled'),
  ];

  Widget buildSubject(BookingsCubit cubit) {
    return MaterialApp(
      home: BlocProvider<BookingsCubit>.value(
        value: cubit,
        child: const UpcomingBookingsScreen(),
      ),
    );
  }

  group('UpcomingBookingsScreen with filter bar', () {
    late BookingsCubit cubit;

    setUp(() {
      cubit = BookingsCubit.fake(BookingsLoaded(bookings));
    });

    tearDown(() => cubit.close());

    testWidgets('shows BookingFilterBar when bookings are loaded', (tester) async {
      await tester.pumpWidget(buildSubject(cubit));
      expect(find.byType(BookingFilterBar), findsOneWidget);
    });

    testWidgets('filter bar is not shown during loading state', (tester) async {
      final loadingCubit = BookingsCubit.fake(const BookingsLoading());
      addTearDown(loadingCubit.close);
      await tester.pumpWidget(buildSubject(loadingCubit));
      expect(find.byType(BookingFilterBar), findsNothing);
    });

    testWidgets('all bookings are shown by default', (tester) async {
      await tester.pumpWidget(buildSubject(cubit));
      expect(find.text('Court Pending'), findsOneWidget);
      expect(find.text('Court Confirmed'), findsOneWidget);
      expect(find.text('Court Cancelled'), findsOneWidget);
    });

    testWidgets('tapping Pending chip shows only pending bookings', (tester) async {
      await tester.pumpWidget(buildSubject(cubit));
      await tester.tap(find.text('Pending'));
      await tester.pump();
      expect(find.text('Court Pending'), findsOneWidget);
      expect(find.text('Court Confirmed'), findsNothing);
      expect(find.text('Court Cancelled'), findsNothing);
    });

    testWidgets('tapping Confirmed chip shows only confirmed bookings', (tester) async {
      await tester.pumpWidget(buildSubject(cubit));
      await tester.tap(find.text('Confirmed'));
      await tester.pump();
      expect(find.text('Court Confirmed'), findsOneWidget);
      expect(find.text('Court Pending'), findsNothing);
      expect(find.text('Court Cancelled'), findsNothing);
    });

    testWidgets('tapping All chip after filter shows all bookings', (tester) async {
      await tester.pumpWidget(buildSubject(cubit));
      // First filter to pending
      await tester.tap(find.text('Pending'));
      await tester.pump();
      expect(find.text('Court Confirmed'), findsNothing);
      // Then reset to All
      await tester.tap(find.text('All'));
      await tester.pump();
      expect(find.text('Court Pending'), findsOneWidget);
      expect(find.text('Court Confirmed'), findsOneWidget);
      expect(find.text('Court Cancelled'), findsOneWidget);
    });
  });
}
