// Tests for the [Env] class. Because [String.fromEnvironment] is a compile-time
// constant, we cannot inject values from a unit test — the fields will hold
// whatever was passed via `--dart-define` when the test process was launched
// (empty strings by default). This is therefore a sanity test of the
// unconfigured / default path: [Env.assertConfigured] MUST throw when any of
// the required keys is empty.
//
// To verify the configured path (where all three keys are set), run:
//   fvm flutter test test/env_test.dart \
//     --dart-define=SUPABASE_URL=https://x \
//     --dart-define=SUPABASE_ANON_KEY=y \
//     --dart-define=VIETMAP_API_KEY=z
// — but in the default test invocation (the one the pipeline uses) we only
// assert the throw path so the test is deterministic.

import 'package:customer/core/env/env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Env', () {
    test('exposes static const fields for the three required keys', () {
      // Reading the fields must not itself throw; they should be empty strings
      // in the unconfigured (test-default) state.
      expect(Env.supabaseUrl, isA<String>());
      expect(Env.supabaseAnonKey, isA<String>());
      expect(Env.vietmapApiKey, isA<String>());
    });

    test('assertConfigured() throws when any required key is empty', () {
      // In the default test invocation no --dart-define values are passed, so
      // every key is the empty string and assertConfigured must throw.
      expect(Env.assertConfigured, throwsStateError);
    });

    test('assertConfigured() error names the missing key', () {
      try {
        Env.assertConfigured();
        fail('expected StateError, got nothing');
      } on StateError catch (e) {
        // Message should mention "Missing env" and at least one of the keys
        // so operators have actionable diagnostics.
        expect(e.message, contains('Missing env'));
        final mentionsAKey = e.message.contains('SUPABASE_URL') ||
            e.message.contains('SUPABASE_ANON_KEY') ||
            e.message.contains('VIETMAP_API_KEY');
        expect(mentionsAKey, isTrue,
            reason: 'error should name the missing key(s) for diagnostics');
      }
    });
  });
}
