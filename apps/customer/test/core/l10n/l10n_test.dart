// Tests for l10n ARB scaffolding (grava-35d5.7).
//
// These tests verify:
//  1. The generated AppLocalizations class is accessible.
//  2. The `appTitle` key resolves to 'SportBuddies' in both Vietnamese and English.
//
// Run: fvm flutter test test/core/l10n/l10n_test.dart

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLocalizations', () {
    testWidgets('appTitle resolves to SportBuddies in Vietnamese (vi)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Text(l10n.appTitle);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('SportBuddies'), findsOneWidget);
    });

    testWidgets('appTitle resolves to SportBuddies in English (en)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Text(l10n.appTitle);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('SportBuddies'), findsOneWidget);
    });

    test('supportedLocales includes vi and en', () {
      final locales = AppLocalizations.supportedLocales.toList();
      expect(locales.any((l) => l.languageCode == 'vi'), isTrue,
          reason: 'Vietnamese must be a supported locale');
      expect(locales.any((l) => l.languageCode == 'en'), isTrue,
          reason: 'English must be a supported locale');
    });
  });
}
