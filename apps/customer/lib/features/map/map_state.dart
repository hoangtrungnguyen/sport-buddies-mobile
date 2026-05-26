// MapState — sealed state hierarchy for MapCubit (grava-c9ca.1.3)

import 'package:spb_core/models/court.dart';

sealed class MapState {
  const MapState();
}

/// No data loaded yet (initial / reset state).
final class MapInitial extends MapState {
  const MapInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MapInitial;

  @override
  int get hashCode => (MapInitial).hashCode;
}

/// Fetch in progress.
final class MapLoading extends MapState {
  const MapLoading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MapLoading;

  @override
  int get hashCode => (MapLoading).hashCode;
}

/// Courts successfully fetched.
final class MapLoaded extends MapState {
  const MapLoaded(this.courts);

  final List<Court> courts;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MapLoaded &&
          other.courts.length == courts.length &&
          _listsEqual(other.courts, courts));

  static bool _listsEqual(List<Court> a, List<Court> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(courts);

  @override
  String toString() => 'MapLoaded(${courts.length} courts)';
}

/// Fetch failed.
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
