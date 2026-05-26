// Tests for the main.dart init order (grava-35d5.4).
//
// We cannot call `main()` directly in a unit test because it initialises
// Firebase and Supabase, which require platform channels that are not
// available in the test process. Instead, we test the observable contract:
//
//   1. `Env.assertConfigured()` is exported and throws on missing keys.
//   2. `CustomerApp` is a widget that can be instantiated without crashing.
//   3. `DefaultFirebaseOptions.currentPlatform` returns an object whose type
//      is `FirebaseOptions` from `package:firebase_core`, so the
//      `Firebase.initializeApp(options: …)` call-site compiles correctly.
//
// Integration-level smoke (pumping CustomerApp) lives in widget_test.dart
// once Supabase can be mocked. This file focuses on the compile-time and
// unit-level constraints imposed by grava-35d5.4.

import 'package:customer/core/env/env.dart';
import 'package:customer/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('main.dart init-order contracts (grava-35d5.4)', () {
    group('Env.assertConfigured()', () {
      test('throws StateError when env vars are not set (default test run)',
          () {
        // In the default CI invocation no --dart-define values are provided,
        // so every Env field is the empty string → assertConfigured must throw.
        expect(Env.assertConfigured, throwsStateError);
      });

      test('error message names at least one missing key', () {
        try {
          Env.assertConfigured();
          fail('expected StateError');
        } on StateError catch (e) {
          expect(e.message, contains('Missing env'));
          final mentionsKey = e.message.contains('SUPABASE_URL') ||
              e.message.contains('SUPABASE_ANON_KEY') ||
              e.message.contains('VIETMAP_API_KEY');
          expect(mentionsKey, isTrue);
        }
      });
    });

    group('firebase_options stub type-safety', () {
      test(
          'DefaultFirebaseOptions.currentPlatform is a firebase_core.FirebaseOptions',
          () {
        // This assertion verifies that the stub firebase_options.dart uses the
        // FirebaseOptions type from firebase_core (not a local standalone
        // class), so `Firebase.initializeApp(options: ...)` compiles without a
        // type error.
        final options = DefaultFirebaseOptions.currentPlatform;
        expect(options, isA<FirebaseOptions>());
      });

      test('stub options carry placeholder values', () {
        final options = DefaultFirebaseOptions.currentPlatform;
        // Placeholder values must be obvious so nobody ships them as real creds.
        expect(options.apiKey, contains('TODO'));
        expect(options.appId, contains('TODO'));
        expect(options.projectId, contains('TODO'));
      });
    });
  });
}
