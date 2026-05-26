// Widget tests for BookingTile.
//
// AC verified:
//   - BookingTile renders the court name.
//   - BookingTile renders a status badge.
//   - BookingTile renders formatted date/time.
//   - Cancel CTA is shown only for pending bookings (grava-654b.3.3).
//   - Cancel CTA is absent from widget tree for confirmed/completed/cancelled.

import 'package:customer/features/bookings/booking_model.dart';
import 'package:customer/features/bookings/booking_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Booking testBooking;

  setUp(() {
    const court = Court(id: 'c1', name: 'Sân Cầu Lông ABC');
    final slot = Slot(
      id: 's1',
      startTime: DateTime(2026, 6, 15, 10, 0),
      endTime: DateTime(2026, 6, 15, 11, 0),
      court: court,
    );
    testBooking = Booking(
      id: 'b1',
      userId: 'u1',
      status: 'confirmed',
      slot: slot,
    );
  });

  Booking bookingWithStatus(String status) {
    const court = Court(id: 'c1', name: 'Sân Cầu Lông ABC');
    final slot = Slot(
      id: 's1',
      startTime: DateTime(2026, 6, 15, 10, 0),
      endTime: DateTime(2026, 6, 15, 11, 0),
      court: court,
    );
    return Booking(id: 'b1', userId: 'u1', status: status, slot: slot);
  }

  Widget buildSubject(Booking booking, {VoidCallback? onCancel}) {
    return MaterialApp(
      home: Scaffold(
        body: BookingTile(booking: booking, onCancel: onCancel),
      ),
    );
  }

  testWidgets('renders court name', (tester) async {
    await tester.pumpWidget(buildSubject(testBooking));
    expect(find.text('Sân Cầu Lông ABC'), findsOneWidget);
  });

  testWidgets('renders status badge text', (tester) async {
    await tester.pumpWidget(buildSubject(testBooking));
    expect(find.text('confirmed'), findsOneWidget);
  });

  testWidgets('renders date portion', (tester) async {
    await tester.pumpWidget(buildSubject(testBooking));
    // Date 15 Jun 2026
    expect(find.textContaining('2026'), findsWidgets);
  });

  testWidgets('renders time portion', (tester) async {
    await tester.pumpWidget(buildSubject(testBooking));
    // 10:00 start time
    expect(find.textContaining('10:00'), findsOneWidget);
  });

  // -----------------------------------------------------------------------
  // Cancel CTA visibility — grava-654b.3.3
  // -----------------------------------------------------------------------

  testWidgets('cancel CTA is present for pending booking', (tester) async {
    final pending = bookingWithStatus('pending');
    await tester.pumpWidget(buildSubject(pending, onCancel: () {}));
    expect(find.byKey(const Key('cancel_booking_button')), findsOneWidget);
  });

  testWidgets('cancel CTA is absent for confirmed booking', (tester) async {
    final confirmed = bookingWithStatus('confirmed');
    await tester.pumpWidget(buildSubject(confirmed, onCancel: () {}));
    expect(find.byKey(const Key('cancel_booking_button')), findsNothing);
  });

  testWidgets('cancel CTA is absent for completed booking', (tester) async {
    final completed = bookingWithStatus('completed');
    await tester.pumpWidget(buildSubject(completed, onCancel: () {}));
    expect(find.byKey(const Key('cancel_booking_button')), findsNothing);
  });

  testWidgets('cancel CTA is absent for cancelled booking', (tester) async {
    final cancelled = bookingWithStatus('cancelled');
    await tester.pumpWidget(buildSubject(cancelled, onCancel: () {}));
    expect(find.byKey(const Key('cancel_booking_button')), findsNothing);
  });

  testWidgets('cancel CTA is absent when onCancel callback is not provided',
      (tester) async {
    final pending = bookingWithStatus('pending');
    // No onCancel provided — button should not appear even for pending.
    await tester.pumpWidget(buildSubject(pending));
    expect(find.byKey(const Key('cancel_booking_button')), findsNothing);
  });

  testWidgets('cancel CTA invokes onCancel callback when tapped',
      (tester) async {
    var tapped = false;
    final pending = bookingWithStatus('pending');
    await tester.pumpWidget(
      buildSubject(pending, onCancel: () => tapped = true),
    );
    await tester.tap(find.byKey(const Key('cancel_booking_button')));
    expect(tapped, isTrue);
  });
}
