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
