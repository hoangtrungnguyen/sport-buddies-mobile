// MapCubit — manages court list state for the map screen (grava-c9ca.1.3)
//
// State machine:
//   MapInitial → loadCourts() → MapLoading → MapLoaded | MapError

import 'package:flutter_bloc/flutter_bloc.dart';

import 'court_repository_impl.dart';
import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit({required SupabaseCourtRepository repository})
      : _repository = repository,
        super(const MapInitial());

  final SupabaseCourtRepository _repository;

  /// Fetch approved courts from Supabase and update state accordingly.
  Future<void> loadCourts() async {
    emit(const MapLoading());
    final result = await _repository.getApprovedCourts();
    result.when(
      success: (courts) => emit(MapLoaded(courts)),
      failure: (failure) => emit(MapError(failure.toString())),
    );
  }
}
