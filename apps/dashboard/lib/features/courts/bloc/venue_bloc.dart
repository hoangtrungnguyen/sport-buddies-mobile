import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/venue_repository.dart';
import 'venue_event.dart';
import 'venue_state.dart';

export 'venue_event.dart';
export 'venue_state.dart';

class VenueBloc extends Bloc<VenueEvent, VenueState> {
  VenueBloc(this._repo) : super(const VenueInitial()) {
    on<VenueLoadRequested>(_onLoad);
    on<VenueReloadRequested>(_onReload);
  }

  final VenueRepository _repo;

  Future<void> _onLoad(
    VenueLoadRequested event,
    Emitter<VenueState> emit,
  ) async {
    emit(const VenueState.loading());
    await _fetch(event.courtId, emit);
  }

  Future<void> _onReload(
    VenueReloadRequested _,
    Emitter<VenueState> emit,
  ) async {
    final current = state;
    final courtId = switch (current) {
      VenueLoaded(:final courtId) => courtId,
      VenueFailure(:final courtId?) => courtId,
      _ => null,
    };
    if (courtId == null) return;
    if (current is VenueLoaded) {
      emit(VenueLoaded(courtId: courtId, venues: current.venues));
    }
    await _fetch(courtId, emit);
  }

  Future<void> _fetch(String courtId, Emitter<VenueState> emit) async {
    try {
      final venues = await _repo.fetchForCourt(courtId);
      emit(VenueLoaded(courtId: courtId, venues: venues));
    } catch (e, st) {
      emit(VenueFailure(
        'Không thể tải danh sách khu sân.',
        courtId: courtId,
        stackTrace: st,
      ));
    }
  }
}
