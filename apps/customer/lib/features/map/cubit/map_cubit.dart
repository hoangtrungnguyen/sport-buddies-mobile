// MapCubit — grava-c9ca.2.1.
//
// Fetches courts enriched with slot-availability data from
// [CourtAvailabilityRepository] and emits the appropriate [MapState].
//
// The cubit is pure business logic with no Flutter SDK dependency; it is
// provided to the widget tree via BlocProvider in the router builder (§6.2).

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spb_core/spb_core.dart';

part 'map_state.dart';

/// Cubit that manages the map's court list enriched with availability data.
///
/// Typical lifecycle:
///   1. BlocProvider creates the cubit and calls [loadCourts].
///   2. Cubit emits [MapLoading] while the repository is fetching.
///   3. On success: emits [MapLoaded] with the court list.
///   4. On failure: emits [MapError] with a human-readable message.
///
/// When availability data changes (e.g. a slot is booked), the widget can
/// call [loadCourts] again to refresh the markers.
class MapCubit extends Cubit<MapState> {
  MapCubit({required CourtAvailabilityRepository repository})
      : _repository = repository,
        super(const MapInitial());

  final CourtAvailabilityRepository _repository;

  /// Fetches courts with availability and updates state.
  ///
  /// Safe to call multiple times — each call resets to [MapLoading] first.
  Future<void> loadCourts() async {
    emit(const MapLoading());

    final result = await _repository.fetchCourtsWithAvailability();
    result.when(
      success: (courts) => emit(MapLoaded(courts)),
      failure: (failure) => emit(
        MapError(_failureMessage(failure)),
      ),
    );
  }

  /// Maps domain failures to user-facing messages.
  static String _failureMessage(AppFailure failure) {
    return switch (failure) {
      NetworkFailure() => 'No internet connection.',
      ServerFailure(code: final c) => 'Server error ($c).',
      AuthFailure(message: final m) => 'Authentication error: $m',
    };
  }
}
