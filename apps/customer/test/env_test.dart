// Tests for the [Env] class. Values come from compile-time --dart-define
// variables; in the default test-runner context they are empty strings.

import 'package:customer/core/env/env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Env', () {
    test('exposes static const fields for the required keys', () {
      expect(Env.supabaseUrl, isA<String>());
      expect(Env.supabaseAnonKey, isA<String>());
      expect(Env.apiBaseUrl, isA<String>());
    });

    test('assertConfigured() does not throw when Supabase keys are baked', () {
      // The local .env populates SUPABASE_URL + SUPABASE_KEY at build time,
      // so the assertion should succeed. If this test ever throws in CI it
      // means the build_runner step was skipped or the .env keys went blank.
      expect(Env.assertConfigured, returnsNormally);
    });
  });
}
