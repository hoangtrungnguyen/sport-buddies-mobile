/// Environment configuration loaded from .env file via envied.
///
/// Requirements:
/// 1. Add envied dependencies to pubspec.yaml
/// 2. Create .env file in project root with required vars
/// 3. Run: fvm dart run build_runner build --delete-conflicting-outputs
///
/// Example .env:
/// ```
/// SUPABASE_URL=https://xxx.supabase.co
/// SUPABASE_KEY=eyJxxx...
/// VIETMAP_API_KEY=xxx...
/// ```

import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  Env._(); // Private constructor

  /// Supabase project URL.
  @EnviedField(varName: 'SUPABASE_URL')
  static const String supabaseUrl = _Env.supabaseUrl;

  /// Supabase anonymous/public key.
  @EnviedField(varName: 'SUPABASE_KEY')
  static const String supabaseAnonKey = _Env.supabaseAnonKey;

  /// VietMap / Goong tile + geocoding API key.
  @EnviedField(varName: 'VIETMAP_API_KEY', defaultValue: '')
  static const String vietmapApiKey = _Env.vietmapApiKey;

  /// Google Maps API key for map tiles.
  /// Leave empty in dev — the provider falls back to the keyless endpoint.
  @EnviedField(varName: 'GOOGLE_MAP_API_KEY', defaultValue: '')
  static const String googleMapApiKey = _Env.googleMapApiKey;

  /// Active map tile provider: 'google' (default) or 'vietmap'.
  /// Controls which [MapTileProvider] strategy [MapTileProvider.fromEnv] picks.
  @EnviedField(varName: 'MAP_PROVIDER', defaultValue: 'google')
  static const String mapProvider = _Env.mapProvider;

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
