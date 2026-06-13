/// Compile-time environment configuration supporting multiple environments.
///
/// Values are injected at build time via `--dart-define`. The run script
/// `scripts/run_env.sh <local|dev|prod>` loads the matching `.<env>.env`
/// file with `--dart-define-from-file`, so each key below maps directly to a
/// line in those files. Defaults mirror local development.
class Env {
  Env._();

  static const String environment =
      String.fromEnvironment('ENVIRONMENT', defaultValue: 'local');

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String supabaseClientKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static const bool bypassAuth =
      bool.fromEnvironment('BYPASS_AUTH', defaultValue: false);

  static const String bypassEmail =
      String.fromEnvironment('BYPASS_EMAIL', defaultValue: 'dev@snb.com');

  static const String bypassPassword =
      String.fromEnvironment('BYPASS_PASSWORD', defaultValue: '123456QWE');

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8010',
  );

  static const String geminiApiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  /// Throws [StateError] when required vars are missing.
  static void assertConfigured() {
    final missing = <String>[
      if (supabaseUrl.isEmpty) 'SUPABASE_URL',
      if (supabaseClientKey.isEmpty) 'SUPABASE_PUBLISHABLE_KEY',
    ];
    if (missing.isNotEmpty) {
      throw StateError(
        'Missing env vars: ${missing.join(', ')}',
      );
    }
  }
}
