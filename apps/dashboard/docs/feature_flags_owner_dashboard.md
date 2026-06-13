# Feature Flags — Owner Dashboard

> Stack: Flutter Web + Riverpod + Supabase | YAML defaults + remote overrides

---

## Table of Contents
1. [How It Works](#1-how-it-works)
2. [Project Structure](#2-project-structure)
3. [Dependencies](#3-dependencies)
4. [YAML Files](#4-yaml-files)
5. [Data Models](#5-data-models)
6. [Feature Flag Service](#6-feature-flag-service)
7. [Riverpod Providers](#7-riverpod-providers)
8. [UI Integration](#8-ui-integration)
9. [Role-Based Flag Evaluation](#9-role-based-flag-evaluation)
10. [Debug Panel](#10-debug-panel)
11. [Testing](#11-testing)
12. [Common Mistakes](#12-common-mistakes)

---

## 1. How It Works

The owner dashboard has a different flag profile from the customer app. Owners get access to operational tools — analytics, revenue reports, staff management, bulk actions — that are rolled out independently of customer-facing features.

```
Dashboard Startup
    │
    ├─► 1. Load local YAML (offline-safe defaults)
    │
    ├─► 2. Fetch Supabase overrides
    │         ├─► global scope   (all owners)
    │         └─► role scope     (plan-based: free / pro / enterprise)
    │               └─► role override wins over global
    │
    └─► 3. Cache in memory → serve isEnabled() from cache
```

Priority chain: `role remote → global remote → local YAML → false`

**Key difference from customer app:** flags here are often tied to subscription plan (free vs pro vs enterprise), not just rollout percentage.

---

## 2. Project Structure

```
lib/
├── config/
│   └── feature_flags/
│       ├── feature_flag.dart
│       ├── feature_flag_service.dart
│       ├── feature_flag_provider.dart
│       └── feature_names.dart
│
├── assets/
│   └── flags/
│       ├── feature_flags.dev.yaml
│       ├── feature_flags.staging.yaml
│       └── feature_flags.prod.yaml
│
└── screens/
    └── debug/
        └── feature_flags_debug_panel.dart

test/
└── config/
    └── feature_flag_service_test.dart

scripts/
└── check_expired_flags.sh
```

---

## 3. Dependencies

```yaml
# pubspec.yaml
dependencies:
  yaml: ^3.1.0
  flutter_riverpod: ^2.5.0
  supabase_flutter: ^2.3.0

flutter:
  assets:
    - lib/assets/flags/feature_flags.dev.yaml
    - lib/assets/flags/feature_flags.staging.yaml
    - lib/assets/flags/feature_flags.prod.yaml
```

---

## 4. YAML Files

### Rules
- Owner dashboard flags map to business capabilities, not UI experiments
- Plan-gated flags (`tier: plan_feature`) are always `false` in YAML — Supabase role override activates them
- Never put financial or revenue data behind an `experimental` flag in prod

---

### feature_flags.dev.yaml

```yaml
version: "1.0.0"
updated_at: "2024-06-01"

features:
  # ── Core (all owners) ────────────────────────────────────
  booking_management:
    enabled: true
    description: "View and manage all incoming bookings"
    owner: "product-team"
    tier: core
    since: "2024-01-15"

  basic_analytics:
    enabled: true
    description: "Daily booking count and revenue summary"
    owner: "product-team"
    tier: core
    since: "2024-01-15"

  venue_settings:
    enabled: true
    description: "Edit venue info, hours, and pricing"
    owner: "product-team"
    tier: core
    since: "2024-01-15"

  # ── Plan Features (pro+) ──────────────────────────────────
  advanced_analytics:
    enabled: true             # On in dev for testing
    description: "Revenue trends, heatmaps, customer retention"
    owner: "analytics-team"
    tier: plan_feature
    since: "2024-02-01"
    expires_at: "2025-01-01"

  staff_management:
    enabled: true
    description: "Invite and manage staff accounts"
    owner: "product-team"
    tier: plan_feature
    since: "2024-02-01"
    expires_at: "2025-01-01"

  bulk_booking_actions:
    enabled: true
    description: "Approve/reject multiple bookings at once"
    owner: "product-team"
    tier: plan_feature
    since: "2024-03-01"
    expires_at: "2025-01-01"

  # ── Beta ─────────────────────────────────────────────────
  ai_demand_forecast:
    enabled: false
    description: "AI forecast of peak booking hours"
    owner: "ml-team"
    tier: experimental
    since: "2024-05-01"
    expires_at: "2025-06-01"

  payout_dashboard:
    enabled: false
    description: "Revenue payout history and bank integration"
    owner: "finance-team"
    tier: beta
    since: "2024-04-01"
    expires_at: "2025-02-01"

  # ── Observability ─────────────────────────────────────────
  sentry_crash_reporting:
    enabled: true
    description: "Send errors to Sentry"
    owner: "devops-team"
    tier: observability

  performance_monitoring:
    enabled: true
    description: "Track dashboard load time and API latency"
    owner: "devops-team"
    tier: observability

  # ── Debug ─────────────────────────────────────────────────
  debug_panel:
    enabled: true
    description: "Feature flag debug panel in settings"
    owner: "dev-team"
    tier: debug

  verbose_logging:
    enabled: true
    description: "Verbose console output"
    owner: "dev-team"
    tier: debug
```

---

### feature_flags.staging.yaml

```yaml
version: "1.0.0"
updated_at: "2024-06-01"

features:
  booking_management:
    enabled: true
    description: "View and manage all incoming bookings"
    owner: "product-team"
    tier: core

  basic_analytics:
    enabled: true
    description: "Daily booking count and revenue summary"
    owner: "product-team"
    tier: core

  venue_settings:
    enabled: true
    description: "Edit venue info, hours, and pricing"
    owner: "product-team"
    tier: core

  advanced_analytics:
    enabled: true
    description: "Revenue trends, heatmaps, customer retention"
    owner: "analytics-team"
    tier: plan_feature
    expires_at: "2025-01-01"

  staff_management:
    enabled: true
    description: "Invite and manage staff accounts"
    owner: "product-team"
    tier: plan_feature
    expires_at: "2025-01-01"

  bulk_booking_actions:
    enabled: true
    description: "Approve/reject multiple bookings at once"
    owner: "product-team"
    tier: plan_feature
    expires_at: "2025-01-01"

  ai_demand_forecast:
    enabled: true             # Full test in staging
    description: "AI forecast of peak booking hours"
    owner: "ml-team"
    tier: experimental
    expires_at: "2025-06-01"

  payout_dashboard:
    enabled: true             # Test payment flows in staging
    description: "Revenue payout history and bank integration"
    owner: "finance-team"
    tier: beta
    expires_at: "2025-02-01"

  sentry_crash_reporting:
    enabled: true
    description: "Send errors to Sentry"
    owner: "devops-team"
    tier: observability

  performance_monitoring:
    enabled: true
    description: "Track dashboard load time and API latency"
    owner: "devops-team"
    tier: observability

  debug_panel:
    enabled: true
    description: "Feature flag debug panel in settings"
    owner: "dev-team"
    tier: debug

  verbose_logging:
    enabled: false
    description: "Verbose console output"
    owner: "dev-team"
    tier: debug
```

---

### feature_flags.prod.yaml

```yaml
version: "1.0.0"
updated_at: "2024-06-01"

features:
  booking_management:
    enabled: true
    description: "View and manage all incoming bookings"
    owner: "product-team"
    tier: core

  basic_analytics:
    enabled: true
    description: "Daily booking count and revenue summary"
    owner: "product-team"
    tier: core

  venue_settings:
    enabled: true
    description: "Edit venue info, hours, and pricing"
    owner: "product-team"
    tier: core

  advanced_analytics:
    enabled: false            # Enabled via Supabase role override for pro+ plans
    description: "Revenue trends, heatmaps, customer retention"
    owner: "analytics-team"
    tier: plan_feature
    expires_at: "2025-01-01"

  staff_management:
    enabled: false            # Pro+ only via role override
    description: "Invite and manage staff accounts"
    owner: "product-team"
    tier: plan_feature
    expires_at: "2025-01-01"

  bulk_booking_actions:
    enabled: false            # Pro+ only via role override
    description: "Approve/reject multiple bookings at once"
    owner: "product-team"
    tier: plan_feature
    expires_at: "2025-01-01"

  ai_demand_forecast:
    enabled: false
    description: "AI forecast of peak booking hours"
    owner: "ml-team"
    tier: experimental
    expires_at: "2025-06-01"

  payout_dashboard:
    enabled: false
    description: "Revenue payout history and bank integration"
    owner: "finance-team"
    tier: beta
    expires_at: "2025-02-01"

  sentry_crash_reporting:
    enabled: true
    description: "Send errors to Sentry"
    owner: "devops-team"
    tier: observability

  performance_monitoring:
    enabled: true
    description: "Track dashboard load time and API latency"
    owner: "devops-team"
    tier: observability

  debug_panel:
    enabled: false            # Never in prod
    description: "Feature flag debug panel in settings"
    owner: "dev-team"
    tier: debug

  verbose_logging:
    enabled: false
    description: "Verbose console output"
    owner: "dev-team"
    tier: debug
```

---

## 5. Data Models

### feature_names.dart

```dart
abstract class FeatureNames {
  // Core
  static const bookingManagement   = 'booking_management';
  static const basicAnalytics      = 'basic_analytics';
  static const venueSettings       = 'venue_settings';

  // Plan Features
  static const advancedAnalytics   = 'advanced_analytics';
  static const staffManagement     = 'staff_management';
  static const bulkBookingActions  = 'bulk_booking_actions';

  // Beta
  static const aiDemandForecast    = 'ai_demand_forecast';
  static const payoutDashboard     = 'payout_dashboard';

  // Observability
  static const sentryCrashReporting  = 'sentry_crash_reporting';
  static const performanceMonitoring = 'performance_monitoring';

  // Debug
  static const debugPanel            = 'debug_panel';
  static const verboseLogging        = 'verbose_logging';
}
```

### feature_flag.dart

```dart
// plan_feature tier = subscription-gated (free/pro/enterprise)
enum FeatureTier {
  core,
  plan_feature,
  beta,
  experimental,
  observability,
  debug,
}

class FeatureFlag {
  final String name;
  final bool enabled;
  final String description;
  final String? owner;
  final FeatureTier tier;
  final DateTime? since;
  final DateTime? expiresAt;

  const FeatureFlag({
    required this.name,
    required this.enabled,
    this.description = '',
    this.owner,
    this.tier = FeatureTier.core,
    this.since,
    this.expiresAt,
  });

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  factory FeatureFlag.fromYaml(String name, Map<dynamic, dynamic> data) {
    final tierStr = data['tier'] as String? ?? 'core';
    return FeatureFlag(
      name: name,
      enabled: data['enabled'] as bool? ?? false,
      description: data['description'] as String? ?? '',
      owner: data['owner'] as String?,
      tier: FeatureTier.values.firstWhere(
        (t) => t.name == tierStr,
        orElse: () => FeatureTier.core,
      ),
      since: data['since'] != null
          ? DateTime.tryParse(data['since'].toString()) : null,
      expiresAt: data['expires_at'] != null
          ? DateTime.tryParse(data['expires_at'].toString()) : null,
    );
  }

  FeatureFlag copyWith({bool? enabled}) => FeatureFlag(
    name: name,
    enabled: enabled ?? this.enabled,
    description: description,
    owner: owner,
    tier: tier,
    since: since,
    expiresAt: expiresAt,
  );
}
```

---

## 6. Feature Flag Service

```dart
// lib/config/feature_flags/feature_flag_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yaml/yaml.dart';

enum AppEnvironment { dev, staging, prod }
enum OwnerPlan { free, pro, enterprise }

class FeatureFlagService {
  static final FeatureFlagService _instance = FeatureFlagService._();
  factory FeatureFlagService() => _instance;
  FeatureFlagService._();

  final Map<String, FeatureFlag> _local  = {};
  final Map<String, FeatureFlag> _remote = {};
  late AppEnvironment _env;
  bool _ready = false;

  Future<void> initialize({
    AppEnvironment environment = AppEnvironment.dev,
    String? ownerId,
    OwnerPlan plan = OwnerPlan.free,
  }) async {
    _env = environment;
    await _loadYaml();
    await _loadRemote(ownerId: ownerId, plan: plan);
    _warnExpired();
    _ready = true;
    if (kDebugMode) _printSummary();
  }

  bool isEnabled(String name) {
    assert(_ready, 'Call initialize() before isEnabled()');
    return _remote[name]?.enabled ?? _local[name]?.enabled ?? false;
  }

  Map<String, FeatureFlag> get allFlags => {..._local, ..._remote};
  List<FeatureFlag> get expiredFlags =>
      allFlags.values.where((f) => f.isExpired).toList();
  AppEnvironment get environment => _env;

  void overrideForTesting(String name, {required bool enabled}) {
    assert(kDebugMode, 'overrideForTesting is debug-only');
    final base = _local[name] ?? FeatureFlag(name: name, enabled: enabled);
    _remote[name] = base.copyWith(enabled: enabled);
  }

  // ── Private ─────────────────────────────────────────────

  Future<void> _loadYaml() async {
    try {
      final path = switch (_env) {
        AppEnvironment.prod    => 'lib/assets/flags/feature_flags.prod.yaml',
        AppEnvironment.staging => 'lib/assets/flags/feature_flags.staging.yaml',
        AppEnvironment.dev     => 'lib/assets/flags/feature_flags.dev.yaml',
      };
      final raw  = await rootBundle.loadString(path);
      final yaml = loadYaml(raw) as Map;
      for (final e in (yaml['features'] as Map).entries) {
        _local[e.key as String] =
            FeatureFlag.fromYaml(e.key as String, e.value as Map);
      }
    } catch (e) {
      debugPrint('⚠️ FeatureFlags: YAML load failed — $e');
    }
  }

  Future<void> _loadRemote({String? ownerId, required OwnerPlan plan}) async {
    try {
      final db = Supabase.instance.client;

      // 1. Global overrides (apply to all owners)
      final global = await db
          .from('feature_flag_overrides')
          .select('flags')
          .eq('scope', 'global')
          .maybeSingle();
      if (global != null) _apply(global['flags'] as Map<String, dynamic>);

      // 2. Plan-based overrides (pro/enterprise unlocks plan_feature flags)
      final planRow = await db
          .from('feature_flag_overrides')
          .select('flags')
          .eq('scope', 'plan')
          .eq('plan', plan.name)
          .maybeSingle();
      if (planRow != null) _apply(planRow['flags'] as Map<String, dynamic>);

      // 3. Owner-specific overrides (highest priority)
      if (ownerId != null) {
        final ownerRow = await db
            .from('feature_flag_overrides')
            .select('flags')
            .eq('scope', 'owner')
            .eq('owner_id', ownerId)
            .maybeSingle();
        if (ownerRow != null) _apply(ownerRow['flags'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('⚠️ FeatureFlags: Remote unavailable, using YAML — $e');
    }
  }

  void _apply(Map<String, dynamic> overrides) {
    for (final e in overrides.entries) {
      final local = _local[e.key];
      if (local == null) continue;
      final val = (e.value as Map<String, dynamic>)['enabled'] as bool?;
      if (val != null) _remote[e.key] = local.copyWith(enabled: val);
    }
  }

  void _warnExpired() {
    if (!kDebugMode) return;
    for (final f in expiredFlags) {
      debugPrint('🔴 Expired flag "${f.name}" (${f.expiresAt}). Remove it.');
    }
  }

  void _printSummary() {
    debugPrint('=== Dashboard FeatureFlags [${_env.name}] ===');
    for (final e in allFlags.entries) {
      debugPrint('  ${e.value.enabled ? "✅" : "❌"} ${e.key}');
    }
  }
}
```

---

## 7. Riverpod Providers

```dart
final featureFlagServiceProvider = Provider<FeatureFlagService>(
  (_) => FeatureFlagService(),
);

final featureEnabledProvider = Provider.family<bool, String>((ref, name) {
  return ref.watch(featureFlagServiceProvider).isEnabled(name);
});

final allFlagsProvider = Provider<Map<String, FeatureFlag>>((ref) {
  return ref.watch(featureFlagServiceProvider).allFlags;
});

final expiredFlagsProvider = Provider<List<FeatureFlag>>((ref) {
  return ref.watch(featureFlagServiceProvider).expiredFlags;
});
```

---

## 8. UI Integration

### Initialize in main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseKey,
  );

  const envStr = String.fromEnvironment('ENV', defaultValue: 'dev');
  final env = switch (envStr) {
    'prod'    => AppEnvironment.prod,
    'staging' => AppEnvironment.staging,
    _         => AppEnvironment.dev,
  };

  // Fetch owner session and plan before flag init
  final session = Supabase.instance.client.auth.currentSession;
  final ownerId = session?.user.id;

  // Plan from JWT custom claim or Supabase profile table
  final planStr = session?.user.userMetadata?['plan'] as String? ?? 'free';
  final plan = OwnerPlan.values.firstWhere(
    (p) => p.name == planStr,
    orElse: () => OwnerPlan.free,
  );

  await FeatureFlagService().initialize(
    environment: env,
    ownerId: ownerId,
    plan: plan,
  );

  runApp(const ProviderScope(child: DashboardApp()));
}
```

### Conditional Widget

```dart
class DashboardSidebar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final advancedAnalytics = ref.watch(
      featureEnabledProvider(FeatureNames.advancedAnalytics),
    );
    final staffMgmt = ref.watch(
      featureEnabledProvider(FeatureNames.staffManagement),
    );
    final payouts = ref.watch(
      featureEnabledProvider(FeatureNames.payoutDashboard),
    );

    return Column(
      children: [
        const NavItem(label: 'Bookings', route: '/bookings'),
        const NavItem(label: 'Analytics', route: '/analytics/basic'),
        if (advancedAnalytics)
          const NavItem(label: 'Advanced Analytics', route: '/analytics/advanced'),
        if (staffMgmt)
          const NavItem(label: 'Staff', route: '/staff'),
        if (payouts)
          const NavItem(label: 'Payouts', route: '/payouts'),
      ],
    );
  }
}
```

### Plan Upgrade Gate

```dart
/// Shows an upgrade prompt instead of the feature when plan is insufficient
class PlanGate extends ConsumerWidget {
  const PlanGate({
    required this.feature,
    required this.child,
    this.requiredPlan = 'Pro',
    super.key,
  });

  final String feature;
  final Widget child;
  final String requiredPlan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(featureEnabledProvider(feature));
    if (enabled) return child;

    return UpgradePromptCard(
      message: 'Upgrade to $requiredPlan to unlock this feature.',
    );
  }
}

// Usage
PlanGate(
  feature: FeatureNames.advancedAnalytics,
  requiredPlan: 'Pro',
  child: const AdvancedAnalyticsDashboard(),
)
```

---

## 9. Role-Based Flag Evaluation

The Supabase schema includes a `plan` scope. Insert plan-level overrides once, and every owner on that plan inherits them automatically.

```sql
-- Enable advanced_analytics for all Pro owners
INSERT INTO feature_flag_overrides (scope, plan, flags, updated_by)
VALUES (
  'plan',
  'pro',
  '{"advanced_analytics": {"enabled": true},
    "staff_management": {"enabled": true},
    "bulk_booking_actions": {"enabled": true}}',
  'admin@yourapp.com'
);

-- Enable everything for enterprise
INSERT INTO feature_flag_overrides (scope, plan, flags, updated_by)
VALUES (
  'enterprise',
  'enterprise',
  '{"advanced_analytics": {"enabled": true},
    "staff_management": {"enabled": true},
    "bulk_booking_actions": {"enabled": true},
    "ai_demand_forecast": {"enabled": true},
    "payout_dashboard": {"enabled": true}}',
  'admin@yourapp.com'
);

-- Individual owner override (e.g. beta tester on free plan)
INSERT INTO feature_flag_overrides (scope, owner_id, flags, updated_by)
VALUES (
  'owner',
  'owner-uuid-here',
  '{"ai_demand_forecast": {"enabled": true}}',
  'admin@yourapp.com'
);
```

---

## 10. Debug Panel

```dart
// Only accessible when FeatureNames.debugPanel is enabled
class FeatureFlagsDebugPanel extends ConsumerWidget {
  const FeatureFlagsDebugPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allFlags = ref.watch(allFlagsProvider);
    final expired  = ref.watch(expiredFlagsProvider);
    final service  = ref.watch(featureFlagServiceProvider);

    final byTier = <FeatureTier, List<FeatureFlag>>{};
    for (final flag in allFlags.values) {
      byTier.putIfAbsent(flag.tier, () => []).add(flag);
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Feature Flags [${service.environment.name.toUpperCase()}]',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (expired.isNotEmpty)
            Container(
              color: Colors.red.shade50,
              padding: const EdgeInsets.all(12),
              child: Text(
                '⚠️ ${expired.length} expired flag(s) — needs cleanup',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          for (final tier in FeatureTier.values)
            if (byTier.containsKey(tier)) ...[
              Container(
                color: Colors.grey.shade100,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Text(
                  tier.name.toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
              for (final flag in byTier[tier]!)
                ListTile(
                  dense: true,
                  title: Text(flag.name,
                      style: const TextStyle(fontFamily: 'monospace')),
                  subtitle: Text(flag.description),
                  trailing: Switch(
                    value: flag.enabled,
                    onChanged: (v) =>
                        service.overrideForTesting(flag.name, enabled: v),
                  ),
                ),
            ],
        ],
      ),
    );
  }
}
```

---

## 11. Testing

```dart
void main() {
  group('FeatureFlagService — Owner Dashboard', () {
    late FeatureFlagService svc;

    setUp(() async {
      svc = FeatureFlagService();
      await svc.initialize(environment: AppEnvironment.dev);
    });

    test('core features are enabled', () {
      expect(svc.isEnabled(FeatureNames.bookingManagement), isTrue);
      expect(svc.isEnabled(FeatureNames.basicAnalytics), isTrue);
    });

    test('plan_feature flags are disabled in prod YAML', () async {
      final prodSvc = FeatureFlagService();
      await prodSvc.initialize(environment: AppEnvironment.prod);
      expect(prodSvc.isEnabled(FeatureNames.advancedAnalytics), isFalse);
      expect(prodSvc.isEnabled(FeatureNames.staffManagement), isFalse);
    });

    test('unknown flag returns false', () {
      expect(svc.isEnabled('ghost_flag'), isFalse);
    });

    test('overrideForTesting works for plan features', () {
      svc.overrideForTesting(FeatureNames.advancedAnalytics, enabled: true);
      expect(svc.isEnabled(FeatureNames.advancedAnalytics), isTrue);
    });

    test('no expired flags in YAML', () {
      expect(svc.expiredFlags, isEmpty);
    });
  });
}
```

---

## 12. Common Mistakes

| Mistake | Consequence | Fix |
|---------|------------|-----|
| Putting plan gate logic in the service layer | Business logic mixed with flag evaluation | Gate in UI only; service just returns bool |
| One global flag for all plan tiers | Can't differentiate free vs pro vs enterprise | Use `scope: plan` rows in Supabase |
| Enabling plan_feature flags in prod YAML | All owners get pro features for free | Always `false` in prod YAML; Supabase enables per plan |
| Not initializing plan before flags | Wrong flag state on first render | Resolve plan from session before `initialize()` |
| Raw strings in `isEnabled()` | Typo failures are silent | Use `FeatureNames` constants |

---

*v1.0 — Owner Dashboard | Flutter Web + Riverpod 2.x + Supabase*
