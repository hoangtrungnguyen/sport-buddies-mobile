// Widget tests for BookingTile.
//
// AC verified:
//   - BookingTile renders the court name.
//   - BookingTile renders a status badge.
//   - BookingTile renders formatted date/time.

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

  Widget buildSubject(Booking booking) {
    return MaterialApp(
      home: Scaffold(
        body: BookingTile(booking: booking),
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
}
