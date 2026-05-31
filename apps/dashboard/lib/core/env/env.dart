import 'package:envied/envied.dart';

part 'env.g.dart';

/// Compile-time environment configuration supporting multiple environments.
///
/// Build for a specific environment using `--dart-define=ENVIRONMENT=prod` or `dev`.
/// Defaults to `local`.
@Envied(path: '.local.env', name: 'LocalEnv')
@Envied(path: '.dev.env', name: 'DevEnv')
@Envied(path: '.prod.env', name: 'ProdEnv')
abstract class Env {
  Env._();

  static const String environment =
      String.fromEnvironment('ENVIRONMENT', defaultValue: 'local');

  static final Env _instance = switch (environment) {
    'prod' => _ProdEnv(),
    'dev' => _DevEnv(),
    _ => _LocalEnv(),
  };

  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  final String _supabaseUrl = _instance._supabaseUrl;
  static String get supabaseUrl => _instance._supabaseUrl;

  @EnviedField(varName: 'SUPABASE_PUBLISHABLE_KEY', obfuscate: true)
  final String _supabasePublishableKey = _instance._supabasePublishableKey;
  static String get supabaseClientKey => _instance._supabasePublishableKey;

  @EnviedField(varName: 'BYPASS_AUTH', defaultValue: 'false')
  final String _bypassAuth = _instance._bypassAuth;
  static bool get bypassAuth => _instance._bypassAuth.toLowerCase() == 'true';

  @EnviedField(varName: 'BYPASS_EMAIL', defaultValue: 'dev@snb.com', obfuscate: true)
  final String _bypassEmail = _instance._bypassEmail;
  static String get bypassEmail => _instance._bypassEmail;

  @EnviedField(varName: 'BYPASS_PASSWORD', defaultValue: '123456&QWE', obfuscate: true)
  final String _bypassPassword = _instance._bypassPassword;
  static String get bypassPassword => _instance._bypassPassword;

  @EnviedField(varName: 'API_BASE_URL', defaultValue: 'http://localhost:8010', obfuscate: true)
  final String _apiBaseUrl = _instance._apiBaseUrl;
  static String get apiBaseUrl => _instance._apiBaseUrl;

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
