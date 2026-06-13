import 'package:dashboard/config/feature_flags/feature_flag.dart';
import 'package:dashboard/config/feature_flags/feature_flag_api_client.dart';
import 'package:dashboard/core/debug/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';

/// Flag-profile environment. The app's `ENVIRONMENT` (`local|dev|prod`) maps
/// onto this via [FeatureFlagService.environmentFromName] — `local` shares the
/// `dev` profile.
enum AppEnvironment { dev, staging, prod }

/// Owner subscription plan — gates `plan_feature` flags via Supabase overrides.
enum OwnerPlan { free, pro, enterprise }

/// Resolves feature flags from local YAML defaults plus backend overrides
/// fetched over the REST API. Resolution priority (highest first):
///
///   owner override → subscription-tier (plan) → local YAML → false
///
/// Offline-safe: any remote failure falls back to YAML. Initialize once at
/// startup before calling [isEnabled].
class FeatureFlagService {
  FeatureFlagService._();
  static final FeatureFlagService _instance = FeatureFlagService._();
  factory FeatureFlagService() => _instance;

  final Map<String, FeatureFlag> _local = {};
  final Map<String, FeatureFlag> _remote = {};
  AppEnvironment _env = AppEnvironment.dev;
  bool _ready = false;

  AppEnvironment get environment => _env;
  bool get isReady => _ready;

  /// Maps the app's `ENVIRONMENT` define onto a flag profile.
  static AppEnvironment environmentFromName(String name) => switch (name) {
        'prod' => AppEnvironment.prod,
        'staging' => AppEnvironment.staging,
        _ => AppEnvironment.dev, // local + dev share the dev profile
      };

  /// Loads YAML defaults then layers backend overrides (plan tier, then
  /// per-owner) for the given [plan]. Safe to call again (re-resolves);
  /// subsequent calls clear prior overrides. [apiClient] is injectable for
  /// tests; defaults to a real client hitting [Env.apiBaseUrl].
  Future<void> initialize({
    AppEnvironment environment = AppEnvironment.dev,
    OwnerPlan plan = OwnerPlan.free,
    FeatureFlagApiClient? apiClient,
  }) async {
    _env = environment;
    _local.clear();
    _remote.clear();
    await _loadYaml();
    await _loadRemote(apiClient ?? FeatureFlagApiClient(), plan);
    _ready = true;
    if (kDebugMode) _logSummary();
  }

  /// Whether [name] is enabled. Unknown flags are `false`.
  bool isEnabled(String name) {
    assert(_ready, 'FeatureFlagService.initialize() must run before isEnabled()');
    return _remote[name]?.enabled ?? _local[name]?.enabled ?? false;
  }

  /// Whether the nav [route] is visible. A route governed by a flag (YAML
  /// `route:`) is visible only when that flag is enabled; a route no flag
  /// declares is always visible. Lets the YAML own the nav→flag mapping.
  bool isRouteEnabled(String route) {
    for (final flag in allFlags.values) {
      if (flag.route == route) return flag.enabled;
    }
    return true;
  }

  /// All flags with remote overrides layered over local defaults.
  Map<String, FeatureFlag> get allFlags => {..._local, ..._remote};

  /// Debug-only override used by the debug panel / tests.
  void overrideForTesting(String name, {required bool enabled}) {
    assert(kDebugMode, 'overrideForTesting is debug-only');
    final base = _local[name] ?? FeatureFlag(name: name, enabled: enabled);
    _remote[name] = base.copyWith(enabled: enabled);
  }

  // ── Internals ───────────────────────────────────────────────

  Future<void> _loadYaml() async {
    final path = switch (_env) {
      AppEnvironment.prod => 'lib/assets/flags/feature_flags.prod.yaml',
      AppEnvironment.staging => 'lib/assets/flags/feature_flags.staging.yaml',
      AppEnvironment.dev => 'lib/assets/flags/feature_flags.dev.yaml',
    };
    try {
      final raw = await rootBundle.loadString(path);
      final yaml = loadYaml(raw) as YamlMap;
      final features = yaml['features'] as YamlMap?;
      if (features == null) return;
      for (final entry in features.entries) {
        final name = entry.key as String;
        _local[name] = FeatureFlag.fromYaml(name, entry.value);
      }
    } catch (e, st) {
      appLogger.e('FeatureFlags: YAML load failed ($path)',
          error: e, stackTrace: st);
    }
  }

  Future<void> _loadRemote(FeatureFlagApiClient client, OwnerPlan plan) async {
    // Lower priority first: subscription-tier flags, then per-owner overrides
    // (owner wins). Each call is independently offline-safe (empty map on
    // failure), so a missing tier endpoint never blocks owner overrides.
    _apply(await client.fetchPlanFlags(plan.name));
    _apply(await client.fetchOwnerOverrides());
  }

  /// Merges a `{flag: enabled}` map onto local flags. Unknown flags are ignored
  /// (a remote override can't introduce a flag with no YAML default).
  void _apply(Map<String, bool> overrides) {
    overrides.forEach((name, enabled) {
      final local = _local[name];
      if (local != null) _remote[name] = local.copyWith(enabled: enabled);
    });
  }

  void _logSummary() {
    final lines = allFlags.entries
        .map((e) => '  ${e.value.enabled ? "✅" : "❌"} ${e.key}')
        .join('\n');
    appLogger.d('FeatureFlags [${_env.name}]\n$lines');
  }
}
