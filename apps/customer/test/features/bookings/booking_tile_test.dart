// Widget tests for BookingTile.
//
// AC verified:
//   - BookingTile renders the court name.
//   - BookingTile renders a colour-coded localised status badge.
//   - BookingTile renders formatted date/time.
//   - Status → colour mapping: pending=amber, confirmed=green, completed=grey, cancelled=red
//   - Badge text is localised Vietnamese.

import 'package:customer/features/bookings/booking_model.dart';
import 'package:customer/features/bookings/booking_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Booking makeBooking({String status = 'confirmed'}) {
    const court = Court(id: 'c1', name: 'Sân Cầu Lông ABC');
    final slot = Slot(
      id: 's1',
      startTime: DateTime(2026, 6, 15, 10, 0),
      endTime: DateTime(2026, 6, 15, 11, 0),
      court: court,
    );
    return Booking(
      id: 'b1',
      userId: 'u1',
      status: status,
      slot: slot,
    );
  }

  Widget buildSubject(Booking booking) {
    return MaterialApp(
      home: Scaffold(
        body: BookingTile(booking: booking),
      ),
    );
  }

  testWidgets('renders court name', (tester) async {
    await tester.pumpWidget(buildSubject(makeBooking()));
    expect(find.text('Sân Cầu Lông ABC'), findsOneWidget);
  });

  testWidgets('renders date portion', (tester) async {
    await tester.pumpWidget(buildSubject(makeBooking()));
    expect(find.textContaining('2026'), findsWidgets);
  });

  testWidgets('renders time portion', (tester) async {
    await tester.pumpWidget(buildSubject(makeBooking()));
    expect(find.textContaining('10:00'), findsOneWidget);
  });

  // ---------- status badge text (Vietnamese localisation) ----------

  testWidgets('pending badge shows Vietnamese text', (tester) async {
    await tester.pumpWidget(buildSubject(makeBooking(status: 'pending')));
    expect(find.text('Chờ xác nhận'), findsOneWidget);
  });

  testWidgets('confirmed badge shows Vietnamese text', (tester) async {
    await tester.pumpWidget(buildSubject(makeBooking(status: 'confirmed')));
    expect(find.text('Đã xác nhận'), findsOneWidget);
  });

  testWidgets('completed badge shows Vietnamese text', (tester) async {
    await tester.pumpWidget(buildSubject(makeBooking(status: 'completed')));
    expect(find.text('Hoàn thành'), findsOneWidget);
  });

  testWidgets('cancelled badge shows Vietnamese text', (tester) async {
    await tester.pumpWidget(buildSubject(makeBooking(status: 'cancelled')));
    expect(find.text('Đã huỷ'), findsOneWidget);
  });

  // ---------- status badge colour ----------

  Chip findStatusChip(WidgetTester tester) {
    return tester.widget<Chip>(find.byType(Chip));
  }

  testWidgets('pending badge has amber background', (tester) async {
    await tester.pumpWidget(buildSubject(makeBooking(status: 'pending')));
    final chip = findStatusChip(tester);
    expect(chip.backgroundColor, Colors.amber);
  });

  testWidgets('confirmed badge has green background', (tester) async {
    await tester.pumpWidget(buildSubject(makeBooking(status: 'confirmed')));
    final chip = findStatusChip(tester);
    expect(chip.backgroundColor, Colors.green);
  });

  testWidgets('completed badge has grey background', (tester) async {
    await tester.pumpWidget(buildSubject(makeBooking(status: 'completed')));
    final chip = findStatusChip(tester);
    expect(chip.backgroundColor, Colors.grey);
  });

  testWidgets('cancelled badge has red background', (tester) async {
    await tester.pumpWidget(buildSubject(makeBooking(status: 'cancelled')));
    final chip = findStatusChip(tester);
    expect(chip.backgroundColor, Colors.red);
  });

  testWidgets('unknown status falls back to grey background', (tester) async {
    await tester.pumpWidget(buildSubject(makeBooking(status: 'unknown')));
    final chip = findStatusChip(tester);
    expect(chip.backgroundColor, Colors.grey);
  });
}
