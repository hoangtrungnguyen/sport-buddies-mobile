// MapState — grava-c9ca.2.1.
//
// Sealed state hierarchy for MapCubit.
// States drive MapScreen to show a loading indicator, the enriched court
// markers, or an error message.

part of 'map_cubit.dart';

/// Base class for all map states.
sealed class MapState {
  const MapState();
}

/// No data has been requested yet — the cubit has just been created.
final class MapInitial extends MapState {
  const MapInitial();
}

/// Data fetch is in progress.
final class MapLoading extends MapState {
  const MapLoading();
}

/// Fetch succeeded; [courts] is the enriched list ready for rendering.
final class MapLoaded extends MapState {
  const MapLoaded(this.courts, {this.selectedCourt});

  /// Courts with their slot-availability-derived marker colours.
  final List<CourtAvailability> courts;

  /// The court the user last tapped on the map (null if none selected).
  final CourtAvailability? selectedCourt;

  /// Returns a copy of this state with [court] as the selected court.
  MapLoaded withSelection(CourtAvailability? court) =>
      MapLoaded(courts, selectedCourt: court);

  /// Applies sport, distance, and open-slots filters, returning the
  /// subset of [courts] that should be rendered as map markers.
  ///
  /// [userPos] is the user's current location (spb_core LatLng) used for
  /// Haversine distance checks. Pass null to skip distance filtering.
  List<CourtAvailability> applyFilter({
    required Set<String> sports,
    required double? maxDistanceKm,
    required LatLng? userPos,
    required bool onlyWithOpenSlots,
  }) {
    return courts.where((court) {
      if (onlyWithOpenSlots && court.openSlotCount == 0) return false;
      if (sports.isNotEmpty && !sports.contains(court.sportType)) return false;
      if (maxDistanceKm != null && userPos != null) {
        final courtPos = LatLng(court.lat, court.lng);
        if (!userPos.isWithinRadius(courtPos, maxDistanceKm)) return false;
      }
      return true;
    }).toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MapLoaded &&
          _listEquals(other.courts, courts) &&
          other.selectedCourt == selectedCourt);

  @override
  int get hashCode => Object.hashAll([...courts, selectedCourt]);

  @override
  String toString() => 'MapLoaded(${courts.length} courts, '
      'selected: ${selectedCourt?.courtId})';
}

/// Fetch failed; [message] is a human-readable reason for display / logging.
final class MapError extends MapState with AppExceptionMixin {
  const MapError(this.message, {this.stackTrace});

  @override
  final String message;
  @override
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MapError && other.message == message);

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'MapError($message)';
}

// ---------------------------------------------------------------------------
// Helper — list equality without the `collection` package.
// ---------------------------------------------------------------------------

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
