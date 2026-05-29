// Widget tests for SportFilterBar — grava-c9ca.3.1
//
// AC verified:
//   1. Renders all 6 chips (All + 5 sports).
//   2. Chips are wrapped in a horizontally scrollable container.
//   3. The 'All' chip is selected by default (empty selectedSports).
//   4. Tapping a sport chip calls onSportsChanged with that sport.
//   5. Tapping the 'All' chip calls onSportsChanged with empty list.
//   6. Multi-select: tapping two chips both appear selected.

import 'package:customer/features/map/sport_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('SportFilterBar', () {
    testWidgets('renders 6 chips (All + 5 sports)', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SportFilterBar(
            selectedSports: const {},
            onSportsChanged: (_) {},
          ),
        ),
      );
      expect(find.byType(FilterChip), findsNWidgets(6));
    });

    testWidgets('labels include Tất cả, Bóng đá, Cầu lông, Pickleball, Tennis, Đa năng',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          SportFilterBar(
            selectedSports: const {},
            onSportsChanged: (_) {},
          ),
        ),
      );
      for (final label in [
        'Tất cả',
        'Bóng đá',
        'Cầu lông',
        'Pickleball',
        'Tennis',
        'Đa năng',
      ]) {
        expect(find.text(label), findsOneWidget,
            reason: 'Expected chip with label "$label"');
      }
    });

    testWidgets('All chip is selected when selectedSports is empty',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          SportFilterBar(
            selectedSports: const {},
            onSportsChanged: (_) {},
          ),
        ),
      );
      final allChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Tất cả'),
      );
      expect(allChip.selected, isTrue);
    });

    testWidgets('All chip is not selected when some sport is selected',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          SportFilterBar(
            selectedSports: const {'football'},
            onSportsChanged: (_) {},
          ),
        ),
      );
      final allChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Tất cả'),
      );
      expect(allChip.selected, isFalse);
    });

    testWidgets('tapping a sport chip calls onSportsChanged with that sport',
        (tester) async {
      final List<Set<String>> calls = [];
      await tester.pumpWidget(
        _wrap(
          SportFilterBar(
            selectedSports: const {},
            onSportsChanged: calls.add,
          ),
        ),
      );
      await tester.tap(find.widgetWithText(FilterChip, 'Bóng đá'));
      await tester.pump();
      expect(calls, hasLength(1));
      expect(calls.first, contains('football'));
    });

    testWidgets('tapping All chip calls onSportsChanged with empty set',
        (tester) async {
      final List<Set<String>> calls = [];
      await tester.pumpWidget(
        _wrap(
          SportFilterBar(
            selectedSports: const {'tennis'},
            onSportsChanged: calls.add,
          ),
        ),
      );
      await tester.tap(find.widgetWithText(FilterChip, 'Tất cả'));
      await tester.pump();
      expect(calls, hasLength(1));
      expect(calls.first, isEmpty);
    });

    testWidgets('selected sport chip has selected=true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SportFilterBar(
            selectedSports: const {'multi'},
            onSportsChanged: (_) {},
          ),
        ),
      );
      final chip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Đa năng'),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('multiple selected sports are all highlighted', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SportFilterBar(
            selectedSports: const {'football', 'badminton'},
            onSportsChanged: (_) {},
          ),
        ),
      );
      final footballChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Bóng đá'),
      );
      final badmintonChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Cầu lông'),
      );
      expect(footballChip.selected, isTrue);
      expect(badmintonChip.selected, isTrue);
    });

    testWidgets('wraps chips in a horizontally scrollable row', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SportFilterBar(
            selectedSports: const {},
            onSportsChanged: (_) {},
          ),
        ),
      );
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets(
        'tapping an already-selected sport chip removes it from selection',
        (tester) async {
      final List<Set<String>> calls = [];
      await tester.pumpWidget(
        _wrap(
          SportFilterBar(
            selectedSports: const {'football'},
            onSportsChanged: calls.add,
          ),
        ),
      );
      await tester.tap(find.widgetWithText(FilterChip, 'Bóng đá'));
      await tester.pump();
      expect(calls, hasLength(1));
      expect(calls.first, isNot(contains('football')));
    });
  });
}
