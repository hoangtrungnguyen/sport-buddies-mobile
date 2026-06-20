// SlotRow widget tests — grava-c9ca.5.2.
//
// TDD tests for the SlotRow widget.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/spb_core.dart';

import 'package:customer/features/slots/widgets/slot_row.dart';
import 'package:customer/l10n/app_localizations.dart';

void main() {
  group('SlotRow', () {
    late Slot testSlot;

    setUp(() {
      testSlot = Slot(
        id: 'slot-1',
        startTime: DateTime.utc(2026, 6, 15, 10, 0),
        endTime: DateTime.utc(2026, 6, 15, 11, 0),
        courtId: 'court-1',
        courtName: 'Sân A',
        sportType: 'badminton',
        accessPolicy: 'open',
        maxPlayers: 4,
        currentPlayers: 2,
      );
    });

    testWidgets('renders court name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SlotRow(slot: testSlot),
          ),
        ),
      );

      expect(find.text('Sân A'), findsOneWidget);
    });

    testWidgets('renders sport type badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SlotRow(slot: testSlot),
          ),
        ),
      );

      expect(find.text('Cầu lông'), findsOneWidget);
    });

    testWidgets('renders date', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SlotRow(slot: testSlot),
          ),
        ),
      );

      final expectedDate = DateFormat('EEE, d MMM yyyy').format(testSlot.startTime);
      expect(find.text(expectedDate), findsOneWidget);
    });

    testWidgets('renders time range', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SlotRow(slot: testSlot),
          ),
        ),
      );

      expect(find.text('10:00 – 11:00'), findsOneWidget);
    });

    testWidgets('renders player count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SlotRow(slot: testSlot),
          ),
        ),
      );

      expect(find.text('2/4'), findsOneWidget);
    });

    testWidgets('shows open lock icon for open access policy', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SlotRow(slot: testSlot),
          ),
        ),
      );

      expect(find.byIcon(Icons.lock_open), findsOneWidget);
    });

    testWidgets('shows closed lock icon for closed access policy', (tester) async {
      final closedSlot = Slot(
        id: 'slot-1',
        startTime: DateTime.utc(2026, 6, 15, 10, 0),
        endTime: DateTime.utc(2026, 6, 15, 11, 0),
        courtId: 'court-1',
        courtName: 'Sân A',
        sportType: 'badminton',
        accessPolicy: 'closed',
        maxPlayers: 4,
        currentPlayers: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SlotRow(slot: closedSlot),
          ),
        ),
      );

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('shows full player count in red when slot is full', (tester) async {
      final fullSlot = Slot(
        id: 'slot-1',
        startTime: DateTime.utc(2026, 6, 15, 10, 0),
        endTime: DateTime.utc(2026, 6, 15, 11, 0),
        courtId: 'court-1',
        courtName: 'Sân A',
        sportType: 'badminton',
        maxPlayers: 2,
        currentPlayers: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SlotRow(slot: fullSlot),
          ),
        ),
      );

      final playerText = find.text('2/2');
      expect(playerText, findsOneWidget);

      final textWidget = tester.widget<Text>(playerText);
      expect(textWidget.style?.color, Colors.red);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SlotRow(
              slot: testSlot,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SlotRow));
      expect(tapped, isTrue);
    });

    testWidgets('renders different sport type badges', (tester) async {
      final sports = {
        'badminton': 'Cầu lông',
        'football': 'Bóng đá',
        'tennis': 'Tennis',
        'basketball': 'Bóng rổ',
      };

      for (var entry in sports.entries) {
        final sportSlot = Slot(
          id: 'slot-1',
          startTime: DateTime.utc(2026, 6, 15, 10, 0),
          endTime: DateTime.utc(2026, 6, 15, 11, 0),
          courtId: 'court-1',
          courtName: 'Sân A',
          sportType: entry.key,
        );

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('vi'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SlotRow(slot: sportSlot),
            ),
          ),
        );

        expect(find.text(entry.value), findsOneWidget,
            reason: 'Expected label for ${entry.key}');
      }
    });
  });
}
