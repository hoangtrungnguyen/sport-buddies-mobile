/// Environment configuration read from compile-time `--dart-define` variables.
///
/// Values are baked in at build/run time, e.g.:
/// ```
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xyz.supabase.co \
///   --dart-define=SUPABASE_PUBLISHABLE_KEY=... \
///   --dart-define=API_BASE_URL=...
/// ```
/// (Typically supplied via a launch config / `--dart-define-from-file`.)
abstract class Env {
  Env._(); // Private constructor — static access only.

  /// Target environment: 'local' (default), 'dev', or 'prod'.
  static const String environment =
      String.fromEnvironment('ENVIRONMENT', defaultValue: 'local');

  /// Supabase project URL.
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Supabase anonymous/publishable key.
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  /// Core-engine REST API base URL (writes: bookings, slot access, …).
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Dev/local convenience: credentials to pre-fill the login form (debug
  /// builds only). Empty in prod env files, so nothing is pre-filled there.
  static const String bypassEmail = String.fromEnvironment('BYPASS_EMAIL');
  static const String bypassPassword =
      String.fromEnvironment('BYPASS_PASSWORD');

  /// Throws [StateError] if any required env var is empty.
  static void assertConfigured() {
    final missing = <String>[
      if (supabaseUrl.isEmpty) 'SUPABASE_URL',
      if (supabaseAnonKey.isEmpty) 'SUPABASE_KEY',
    ];

    if (missing.isNotEmpty) {
      throw StateError(
        'Missing env vars: ${missing.join(', ')}. '
        'Pass them via --dart-define (or --dart-define-from-file).',
      );
    }
  }
}
