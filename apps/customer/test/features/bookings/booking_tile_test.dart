// Widget tests for BookingTile.
//
// AC verified:
//   - BookingTile renders the court name.
//   - BookingTile renders a status badge.
//   - BookingTile renders formatted date/time.
//   - For recurring bookings, BookingTile shows a series subtitle e.g. 'Buổi 3 / 10'.
//   - For one-off bookings, the series subtitle line is NOT shown.
//   - If sessionNumber or totalSessions is null, series line is not rendered.

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

  // ─── Series context line tests ─────────────────────────────────────────────

  testWidgets('shows series line for recurring booking with both fields set',
      (tester) async {
    const court = Court(id: 'c2', name: 'Sân B');
    final slot = Slot(
      id: 's2',
      startTime: DateTime(2026, 6, 20, 8, 0),
      endTime: DateTime(2026, 6, 20, 9, 0),
      court: court,
    );
    final recurringBooking = Booking(
      id: 'b2',
      userId: 'u1',
      status: 'confirmed',
      slot: slot,
      sessionNumber: 3,
      totalSessions: 10,
    );
    await tester.pumpWidget(buildSubject(recurringBooking));
    expect(find.text('Buổi 3 / 10'), findsOneWidget);
  });

  testWidgets('does not show series line for one-off booking', (tester) async {
    await tester.pumpWidget(buildSubject(testBooking));
    // testBooking has no sessionNumber / totalSessions
    expect(find.textContaining('Buổi'), findsNothing);
  });

  testWidgets('does not show series line when sessionNumber is null',
      (tester) async {
    const court = Court(id: 'c3', name: 'Sân C');
    final slot = Slot(
      id: 's3',
      startTime: DateTime(2026, 6, 22, 9, 0),
      endTime: DateTime(2026, 6, 22, 10, 0),
      court: court,
    );
    final partialBooking = Booking(
      id: 'b3',
      userId: 'u1',
      status: 'confirmed',
      slot: slot,
      sessionNumber: null,
      totalSessions: 10,
    );
    await tester.pumpWidget(buildSubject(partialBooking));
    expect(find.textContaining('Buổi'), findsNothing);
  });

  testWidgets('does not show series line when totalSessions is null',
      (tester) async {
    const court = Court(id: 'c4', name: 'Sân D');
    final slot = Slot(
      id: 's4',
      startTime: DateTime(2026, 6, 23, 7, 0),
      endTime: DateTime(2026, 6, 23, 8, 0),
      court: court,
    );
    final partialBooking = Booking(
      id: 'b4',
      userId: 'u1',
      status: 'confirmed',
      slot: slot,
      sessionNumber: 2,
      totalSessions: null,
    );
    await tester.pumpWidget(buildSubject(partialBooking));
    expect(find.textContaining('Buổi'), findsNothing);
  });
}
