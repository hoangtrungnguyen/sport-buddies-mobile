// MapCubit — grava-c9ca.3.1
//
// Manages sport-type filter state for the map screen.

import 'package:flutter_bloc/flutter_bloc.dart';

import 'map_state.dart';

/// Cubit that tracks which sport types are currently selected for filtering
/// court markers on the map.
///
/// The initial state has an empty [MapState.selectedSports], meaning all
/// courts are visible (no filter active).
class MapCubit extends Cubit<MapState> {
  MapCubit() : super(const MapState());

  /// Update the active sport filters.
  ///
  /// Passing an empty [sports] list resets the filter so all courts are shown.
  /// Passing one or more sport slugs restricts the visible markers to courts
  /// that support at least one of those sports.
  ///
  /// Valid sport slugs: `'football'`, `'basketball'`, `'tennis'`,
  /// `'badminton'`, `'pickleball'`.
  void filterBySports(List<String> sports) {
    emit(state.copyWith(selectedSports: Set<String>.from(sports)));
  }
}
