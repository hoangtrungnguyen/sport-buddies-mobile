import 'package:dashboard/config/feature_flags/feature_flag.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'feature_flag_state.freezed.dart';

/// Snapshot of resolved flags exposed to the UI. Re-emitted when a debug
/// override is applied so dependent widgets rebuild.
@freezed
sealed class FeatureFlagState with _$FeatureFlagState {
  const FeatureFlagState._();

  const factory FeatureFlagState({
    @Default(false) bool ready,
    @Default(<String, FeatureFlag>{}) Map<String, FeatureFlag> flags,
  }) = _FeatureFlagState;

  /// Whether [name] is enabled in this snapshot. Unknown flags are `false`.
  bool isEnabled(String name) => flags[name]?.enabled ?? false;
}
