/// Compile-time environment configuration.
///
/// Pass values at build / run time via --dart-define:
///   fvm flutter run
///     --dart-define=SUPABASE_URL=http://localhost:54321
///     --dart-define=SUPABASE_PUBLISHABLE_KEY=[sb_publishable_…]
abstract final class Env {
  Env._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Client API key passed to `Supabase.initialize`. Uses the current Supabase
  /// key scheme — `SUPABASE_PUBLISHABLE_KEY` (`sb_publishable_…`) — falling back
  /// to the legacy `SUPABASE_ANON_KEY` for older environments. The matching
  /// `SUPABASE_SECRET_KEY` is server-side only and is intentionally NOT read
  /// here: a secret key must never ship in a web client.
  static const String _publishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  /// The key to hand to the Supabase client (publishable preferred).
  static String get supabaseClientKey =>
      _publishableKey.isNotEmpty ? _publishableKey : supabaseAnonKey;

  /// DEV ONLY — when true the app auto-signs-in with a fixed dev account at
  /// startup (see `main.dart`) so the dashboard can be previewed without typing
  /// credentials. It establishes a **real** Supabase session, so the normal
  /// auth gate and RLS-backed data all behave as in production. Enable with
  /// `--dart-define=BYPASS_AUTH=true`. Defaults to false so it never leaks into
  /// a production build.
  static const bool bypassAuth =
      bool.fromEnvironment('BYPASS_AUTH', defaultValue: false);

  /// Dev account used by [bypassAuth] auto-login. Overridable via
  /// `--dart-define=BYPASS_EMAIL=… --dart-define=BYPASS_PASSWORD=…`.
  static const String bypassEmail =
      String.fromEnvironment('BYPASS_EMAIL', defaultValue: 'dev@snb.com');
  static const String bypassPassword = String.fromEnvironment(
    'BYPASS_PASSWORD',
    defaultValue: '123456&QWE',
  );

  /// Base URL of the SportBuddies REST backend (Django) — used for endpoints
  /// that are not served directly by Supabase, e.g. `POST /auth/owner/signup`.
  /// Defaults to the conventional local Django dev server; override with
  /// `--dart-define=API_BASE_URL=https://api.example.com`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8010',
  );

  /// Throws [StateError] when required vars are missing.
  static void assertConfigured() {
    final missing = <String>[
      if (supabaseUrl.isEmpty) 'SUPABASE_URL',
      if (supabaseClientKey.isEmpty) 'SUPABASE_PUBLISHABLE_KEY',
    ];
    if (missing.isNotEmpty) {
      throw StateError(
        'Missing --dart-define vars: ${missing.join(', ')}',
      );
    }
  }
}
