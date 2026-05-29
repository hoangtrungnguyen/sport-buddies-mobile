/// Compile-time environment configuration.
///
/// Pass values at build / run time via --dart-define:
///   fvm flutter run
///     --dart-define=SUPABASE_URL=http://localhost:54321
///     --dart-define=SUPABASE_ANON_KEY=[anon-key]
abstract final class Env {
  Env._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Base URL of the SportBuddies REST backend (Django) — used for endpoints
  /// that are not served directly by Supabase, e.g. `POST /auth/owner/signup`.
  /// Defaults to the conventional local Django dev server; override with
  /// `--dart-define=API_BASE_URL=https://api.example.com`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  /// Throws [StateError] when required vars are missing.
  static void assertConfigured() {
    final missing = <String>[
      if (supabaseUrl.isEmpty) 'SUPABASE_URL',
      if (supabaseAnonKey.isEmpty) 'SUPABASE_ANON_KEY',
    ];
    if (missing.isNotEmpty) {
      throw StateError(
        'Missing --dart-define vars: ${missing.join(', ')}',
      );
    }
  }
}
