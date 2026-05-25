/// Compile-time environment configuration.
///
/// All secrets are injected via `--dart-define=KEY=value` at build time. None
/// of these keys has a runtime fallback default — a missing key is treated as
/// a configuration error and surfaced via [assertConfigured].
///
/// Call [Env.assertConfigured] once during app bootstrap (in `main.dart`) so
/// the app fails fast at start-up rather than at the first feature use.
///
/// Example dev invocation:
/// ```bash
/// fvm flutter run \
///   --dart-define=SUPABASE_URL=http://localhost:54321 \
///   --dart-define=SUPABASE_ANON_KEY=<local-anon-key> \
///   --dart-define=VIETMAP_API_KEY=<vietmap-key>
/// ```
///
/// The class has only `static const` fields and a `static` method, so it is
/// never instantiated. The private constructor enforces that.
class Env {
  Env._();

  /// Supabase project URL (e.g. `http://localhost:54321` for local dev or the
  /// `https://<project>.supabase.co` URL in cloud environments).
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Supabase anonymous public key — safe to ship in the client bundle, but
  /// must still be injected per environment.
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  /// VietMap / Goong tile + geocoding API key, used by `flutter_map` and the
  /// VietMap plugin.
  static const String vietmapApiKey = String.fromEnvironment('VIETMAP_API_KEY');

  /// The complete list of required keys, in the order they appear in the
  /// project README and tech-plan §9.1. Iteration order is stable so the
  /// error message produced by [assertConfigured] is deterministic.
  static const List<({String key, String value})> _required = [
    (key: 'SUPABASE_URL', value: supabaseUrl),
    (key: 'SUPABASE_ANON_KEY', value: supabaseAnonKey),
    (key: 'VIETMAP_API_KEY', value: vietmapApiKey),
  ];

  /// Throws a [StateError] if any required compile-time env var is empty.
  ///
  /// All missing keys are reported in a single error so the operator does not
  /// have to fix-rebuild-fix-rebuild one key at a time.
  static void assertConfigured() {
    final missing = <String>[
      for (final entry in _required)
        if (entry.value.isEmpty) entry.key,
    ];
    if (missing.isNotEmpty) {
      throw StateError(
        'Missing env: ${missing.join(', ')}. '
        'Pass them via --dart-define=<KEY>=<value> at build/run time.',
      );
    }
  }
}
