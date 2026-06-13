import 'package:dashboard/config/feature_flags/feature_flag_service.dart';
import 'package:dashboard/config/feature_flags/feature_flag_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Reactive façade over [FeatureFlagService]. The service resolves flags once
/// at startup; this cubit exposes that snapshot to the widget tree and re-emits
/// when a debug override changes a flag.
class FeatureFlagCubit extends Cubit<FeatureFlagState> {
  FeatureFlagCubit(this._service)
      : super(FeatureFlagState(
          ready: _service.isReady,
          flags: _service.allFlags,
        ));

  final FeatureFlagService _service;

  /// Direct (non-reactive) check — equivalent to the current state.
  bool isEnabled(String name) => _service.isEnabled(name);

  /// Re-reads the service and emits a fresh snapshot.
  void refresh() => emit(FeatureFlagState(
        ready: _service.isReady,
        flags: _service.allFlags,
      ));

  /// Debug-only: toggle a flag at runtime (used by the debug panel) and
  /// rebuild dependents.
  void setOverride(String name, {required bool enabled}) {
    _service.overrideForTesting(name, enabled: enabled);
    refresh();
  }
}
