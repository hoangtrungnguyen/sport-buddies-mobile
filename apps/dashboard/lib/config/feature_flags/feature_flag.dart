/// A single feature flag: whether it is [enabled], and optionally the nav
/// [route] it gates. See `docs/feature_flags_owner_dashboard.md`.
///
/// YAML supports two forms per flag:
///   `booking_management: true`                 // enabled only
///   `advanced_analytics: {enabled: true, route: /analytics}`  // gates a route
class FeatureFlag {
  const FeatureFlag({
    required this.name,
    required this.enabled,
    this.route,
  });

  final String name;
  final bool enabled;

  /// Nav route this flag governs (YAML `route:`), e.g. `/analytics`. When set,
  /// the matching sidebar destination is hidden unless [enabled]. Null for
  /// flags that don't gate navigation.
  final String? route;

  /// Builds a flag from a YAML value — either a bare bool or a map with
  /// `enabled` (and optional `route`).
  factory FeatureFlag.fromYaml(String name, Object? data) {
    if (data is bool) return FeatureFlag(name: name, enabled: data);
    if (data is Map) {
      return FeatureFlag(
        name: name,
        enabled: data['enabled'] as bool? ?? false,
        route: data['route'] as String?,
      );
    }
    return FeatureFlag(name: name, enabled: false);
  }

  FeatureFlag copyWith({bool? enabled}) => FeatureFlag(
        name: name,
        enabled: enabled ?? this.enabled,
        route: route,
      );
}
