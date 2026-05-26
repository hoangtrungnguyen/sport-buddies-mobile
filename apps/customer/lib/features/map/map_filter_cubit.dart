// MapFilterCubit — grava-c9ca.3.1, grava-c9ca.4.2
//
// Manages sport-type and distance filter state for the map screen.

import 'package:flutter_bloc/flutter_bloc.dart';

import 'map_filter_state.dart';

/// Cubit that tracks which sport types and distance range are currently
/// selected for filtering court markers on the map.
///
/// The initial state has an empty [MapFilterState.selectedSports] and null
/// [MapFilterState.maxDistanceKm], meaning all courts are visible (no filter
/// active).
class MapFilterCubit extends Cubit<MapFilterState> {
  MapFilterCubit() : super(const MapFilterState());

  /// Update the active sport filters.
  ///
  /// Passing an empty [sports] list resets the filter so all courts are shown.
  /// Passing one or more sport slugs restricts the visible markers to courts
  /// that support at least one of those sports.
  void filterBySports(List<String> sports) {
    emit(state.copyWith(selectedSports: Set<String>.from(sports)));
  }

  /// Update the active distance filter.
  ///
  /// Passing [distanceKm] restricts visible markers to courts within that
  /// radius (in km) from the user's current location. Passing null clears
  /// the distance filter.
  ///
  /// The value is rounded to 1 decimal place for display consistency.
  void filterByDistance(double? distanceKm) {
    final rounded = distanceKm != null
        ? double.parse(distanceKm.toStringAsFixed(1))
        : null;
    emit(state.copyWith(maxDistanceKm: () => rounded));
  }

  /// Clear all active filters (both sports and distance).
  void clearAll() {
    emit(const MapFilterState());
  }
}
