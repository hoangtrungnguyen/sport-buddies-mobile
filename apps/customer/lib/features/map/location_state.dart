// Location feature — Cubit states.
//
// Three states drive the map center:
//   LocationInitial  — cubit just created; no fetch started yet.
//   LocationLoading  — permission request / GPS fetch in flight.
//   LocationLoaded   — resolved position (GPS or HCMC default).

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

/// Base class for all location states.
@immutable
sealed class LocationState {
  const LocationState();
}

/// Cubit just created; no position request has been made yet.
class LocationInitial extends LocationState {
  const LocationInitial();
}

/// Position request is in flight (permission dialog may be showing).
class LocationLoading extends LocationState {
  const LocationLoading();
}

/// Position resolved to a lat/lng coordinate.
///
/// [isDefault] is `true` when the position is the HCMC fallback
/// (permission denied or service unavailable) and `false` when it
/// comes from the device GPS.
class LocationLoaded extends LocationState {
  const LocationLoaded({
    required this.center,
    required this.isDefault,
  });

  /// The resolved map center.
  final LatLng center;

  /// Whether [center] is the HCMC fallback rather than a real GPS fix.
  final bool isDefault;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationLoaded &&
          runtimeType == other.runtimeType &&
          center.latitude == other.center.latitude &&
          center.longitude == other.center.longitude &&
          isDefault == other.isDefault;

  @override
  int get hashCode =>
      Object.hash(center.latitude, center.longitude, isDefault);

  @override
  String toString() =>
      'LocationLoaded(center: ${center.latitude}, ${center.longitude}, '
      'isDefault: $isDefault)';
}
