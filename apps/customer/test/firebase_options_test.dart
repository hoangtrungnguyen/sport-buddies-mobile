// Test for the stub firebase_options.dart shipped in grava-35d5.9.
//
// This stub exists so main.dart (grava-35d5.4) can call
// `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
// without a compile error before `firebase_core` is added to pubspec
// (grava-35d5.3) and before a real Firebase project is configured.
//
// Tests assert the public shape only — the placeholder values are
// intentionally non-functional and will be regenerated via
// `flutterfire configure` once the Firebase project exists.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:customer/firebase_options.dart';

void main() {
  group('DefaultFirebaseOptions (stub)', () {
    test('currentPlatform returns a FirebaseOptions instance', () {
      final options = DefaultFirebaseOptions.currentPlatform;
      expect(options, isA<FirebaseOptions>());
    });

    test('placeholder values are present and clearly marked TODO', () {
      final options = DefaultFirebaseOptions.currentPlatform;
      // We don't pin exact strings — only that placeholders are obvious so
      // nobody accidentally ships them as if they were real credentials.
      expect(options.apiKey, contains('TODO'));
      expect(options.appId, contains('TODO'));
      expect(options.messagingSenderId, contains('TODO'));
      expect(options.projectId, contains('TODO'));
    });
  });
}
