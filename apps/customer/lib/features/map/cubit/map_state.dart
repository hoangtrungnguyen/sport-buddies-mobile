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
  const MapLoaded(this.courts);

  /// Courts with their slot-availability-derived marker colours.
  final List<CourtAvailability> courts;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MapLoaded &&
          _listEquals(other.courts, courts));

  @override
  int get hashCode => Object.hashAll(courts);

  @override
  String toString() => 'MapLoaded(${courts.length} courts)';
}

/// Fetch failed; [message] is a human-readable reason for display / logging.
final class MapError extends MapState {
  const MapError(this.message);

  final String message;

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
