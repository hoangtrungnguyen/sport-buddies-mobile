import 'package:envied/envied.dart';

part 'env.g.dart';

/// Environment configuration loaded from .env files via envied.
/// Supports local, dev, and prod environments.
@Envied(path: '.local.env', name: 'LocalEnv')
@Envied(path: '.dev.env', name: 'DevEnv')
@Envied(path: '.prod.env', name: 'ProdEnv')
abstract class Env {
  Env._(); // Private constructor

  static const String environment =
      String.fromEnvironment('ENVIRONMENT', defaultValue: 'local');

  static final Env _instance = switch (environment) {
    'prod' => _ProdEnv(),
    'dev' => _DevEnv(),
    _ => _LocalEnv(),
  };

  /// Supabase project URL.
  @EnviedField(varName: 'SUPABASE_URL')
  final String _supabaseUrl = _instance._supabaseUrl;
  static String get supabaseUrl => _instance._supabaseUrl;

  /// Supabase anonymous/public key.
  @EnviedField(varName: 'SUPABASE_PUBLISHABLE_KEY')
  final String _supabaseAnonKey = _instance._supabaseAnonKey;
  static String get supabaseAnonKey => _instance._supabaseAnonKey;

  /// VietMap / Goong tile + geocoding API key.
  @EnviedField(varName: 'VIETMAP_API_KEY', defaultValue: '')
  final String _vietmapApiKey = _instance._vietmapApiKey;
  static String get vietmapApiKey => _instance._vietmapApiKey;

  /// Google Maps API key for map tiles.
  /// Leave empty in dev — the provider falls back to the keyless endpoint.
  @EnviedField(varName: 'GOOGLE_MAP_API_KEY', defaultValue: '')
  final String _googleMapApiKey = _instance._googleMapApiKey;
  static String get googleMapApiKey => _instance._googleMapApiKey;

  /// Active map tile provider: 'google' (default) or 'vietmap'.
  /// Controls which [MapTileProvider] strategy [MapTileProvider.fromEnv] picks.
  @EnviedField(varName: 'MAP_PROVIDER', defaultValue: 'google')
  final String _mapProvider = _instance._mapProvider;
  static String get mapProvider => _instance._mapProvider;

  /// Throws [StateError] if any required env var is empty.
  static void assertConfigured() {
    // VIETMAP_API_KEY temporarily relaxed — map tiles will fail until set.
    final missing = <String>[
      if (supabaseUrl.isEmpty) 'SUPABASE_URL',
      if (supabaseAnonKey.isEmpty) 'SUPABASE_KEY',
    ];

    if (missing.isNotEmpty) {
      throw StateError(
        'Missing env vars: ${missing.join(', ')}. '
        'Add them to .env file in project root.',
      );
    }
  }
}
