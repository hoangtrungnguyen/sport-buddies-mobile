// Tests for the [Env] class. Values are baked into env.g.dart by envied at
// build time from the local .env file, so the fields here reflect whatever
// .env held at the last `dart run build_runner build`.

import 'package:customer/core/env/env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Env', () {
    test('exposes static const fields for the three required keys', () {
      expect(Env.supabaseUrl, isA<String>());
      expect(Env.supabaseAnonKey, isA<String>());
      expect(Env.vietmapApiKey, isA<String>());
    });

    test('assertConfigured() does not throw when Supabase keys are baked', () {
      // The local .env populates SUPABASE_URL + SUPABASE_KEY at build time,
      // so the assertion should succeed. If this test ever throws in CI it
      // means the build_runner step was skipped or the .env keys went blank.
      expect(Env.assertConfigured, returnsNormally);
    });
  });
}
