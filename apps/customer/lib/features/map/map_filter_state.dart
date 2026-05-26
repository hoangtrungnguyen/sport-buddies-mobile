// Map filter state — grava-c9ca.3.1, grava-c9ca.4.2
//
// Holds the set of currently active sport filters for the map screen.
// An empty [selectedSports] means "show all" (no filter active).
//
// [maxDistanceKm] is the maximum distance from current location in km.
// When null, no distance filter is applied.

import 'package:flutter/foundation.dart';

/// State for [MapFilterCubit].
///
/// [selectedSports] is a set of sport identifiers (lower-case slugs, e.g.
/// `'football'`, `'basketball'`).  An empty set means "All" — no filter
/// is applied and every court marker is visible.
///
/// [maxDistanceKm] is the maximum distance from current location in km.
/// When null, no distance filter is applied. Values are rounded to 1
/// decimal place for display consistency.
@immutable
class MapFilterState {
  const MapFilterState({
    this.selectedSports = const {},
    this.maxDistanceKm,
  });

  final Set<String> selectedSports;
  final double? maxDistanceKm;

  MapFilterState copyWith({
    Set<String>? selectedSports,
    double? Function()? maxDistanceKm,
  }) {
    return MapFilterState(
      selectedSports: selectedSports ?? this.selectedSports,
      maxDistanceKm: maxDistanceKm != null
          ? maxDistanceKm()
          : this.maxDistanceKm,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapFilterState &&
          runtimeType == other.runtimeType &&
          _setsEqual(selectedSports, other.selectedSports) &&
          maxDistanceKm == other.maxDistanceKm;

  @override
  int get hashCode => Object.hashAll([...selectedSports.toList()..sort(), maxDistanceKm]);

  static bool _setsEqual(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }
}
