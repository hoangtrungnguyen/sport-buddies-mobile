// Widget tests for BookingFilterBar.
//
// AC verified:
//   - All five chips are rendered (All, Pending, Confirmed, Completed, Cancelled)
//   - Tapping a chip calls the onFilterChanged callback with the appropriate status
//   - 'All' chip calls onFilterChanged(null)
//   - The selected chip is highlighted (selected: true on the FilterChip)

import 'package:customer/features/bookings/booking_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookingFilterBar', () {
    Widget buildSubject({String? selectedStatus, void Function(String?)? onFilterChanged}) {
      return MaterialApp(
        home: Scaffold(
          body: BookingFilterBar(
            selectedStatus: selectedStatus,
            onFilterChanged: onFilterChanged ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('renders all five filter chips', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
    });

    testWidgets('All chip is selected when selectedStatus is null', (tester) async {
      await tester.pumpWidget(buildSubject(selectedStatus: null));
      // Find the FilterChip with label 'All' and verify it is selected
      final allChipFinder = find.byWidgetPredicate(
        (w) => w is FilterChip && (w.label as Text).data == 'All',
      );
      expect(allChipFinder, findsOneWidget);
      final chip = tester.widget<FilterChip>(allChipFinder);
      expect(chip.selected, isTrue);
    });

    testWidgets('Pending chip is selected when selectedStatus is "pending"', (tester) async {
      await tester.pumpWidget(buildSubject(selectedStatus: 'pending'));
      final pendingChipFinder = find.byWidgetPredicate(
        (w) => w is FilterChip && (w.label as Text).data == 'Pending',
      );
      expect(pendingChipFinder, findsOneWidget);
      final chip = tester.widget<FilterChip>(pendingChipFinder);
      expect(chip.selected, isTrue);
    });

    testWidgets('tapping "Pending" chip calls onFilterChanged("pending")', (tester) async {
      String? captured;
      await tester.pumpWidget(buildSubject(
        onFilterChanged: (s) => captured = s,
      ));
      await tester.tap(find.text('Pending'));
      await tester.pump();
      expect(captured, equals('pending'));
    });

    testWidgets('tapping "All" chip calls onFilterChanged(null)', (tester) async {
      String? captured = 'pending'; // start with non-null
      await tester.pumpWidget(buildSubject(
        selectedStatus: 'pending',
        onFilterChanged: (s) => captured = s,
      ));
      await tester.tap(find.text('All'));
      await tester.pump();
      expect(captured, isNull);
    });

    testWidgets('tapping "Confirmed" chip calls onFilterChanged("confirmed")', (tester) async {
      String? captured;
      await tester.pumpWidget(buildSubject(
        onFilterChanged: (s) => captured = s,
      ));
      await tester.tap(find.text('Confirmed'));
      await tester.pump();
      expect(captured, equals('confirmed'));
    });

    testWidgets('tapping "Completed" chip calls onFilterChanged("completed")', (tester) async {
      String? captured;
      await tester.pumpWidget(buildSubject(
        onFilterChanged: (s) => captured = s,
      ));
      await tester.tap(find.text('Completed'));
      await tester.pump();
      expect(captured, equals('completed'));
    });

    testWidgets('tapping "Cancelled" chip calls onFilterChanged("cancelled")', (tester) async {
      String? captured;
      await tester.pumpWidget(buildSubject(
        onFilterChanged: (s) => captured = s,
      ));
      await tester.tap(find.text('Cancelled'));
      await tester.pump();
      expect(captured, equals('cancelled'));
    });
  });
}
