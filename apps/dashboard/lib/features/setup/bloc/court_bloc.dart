import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/owner_court_repository.dart';
import 'court_event.dart';
import 'court_state.dart';

class CourtBloc extends Bloc<CourtEvent, CourtState> {
  CourtBloc(this._repo) : super(const CourtState.initial()) {
    on<CourtLoadRequested>(_onLoad);
    on<CourtDeactivateRequested>(_onDeactivate);
    on<CourtReactivateRequested>(_onReactivate);
  }

  final OwnerCourtRepository _repo;

  Future<void> _onLoad(
    CourtLoadRequested _,
    Emitter<CourtState> emit,
  ) async {
    emit(const CourtState.loading());
    try {
      final courts = await _repo.getCourts();
      emit(CourtState.loaded(courts));
    } catch (e, st) {
      emit(CourtState.failure('Không thể tải danh sách sân.', stackTrace: st));
    }
  }

  Future<void> _onDeactivate(
    CourtDeactivateRequested event,
    Emitter<CourtState> emit,
  ) async {
    final current = state;
    if (current is! CourtLoaded) return;
    emit(const CourtState.loading());
    try {
      await _repo.deactivateCourt(event.id);
      final updated = current.courts
          .map((c) => c.id == event.id ? c.copyWith(isActive: false) : c)
          .toList();
      emit(CourtState.loaded(updated));
    } catch (e, st) {
      emit(CourtState.failure('Không thể vô hiệu hoá sân.', stackTrace: st));
    }
  }

  Future<void> _onReactivate(
    CourtReactivateRequested event,
    Emitter<CourtState> emit,
  ) async {
    final current = state;
    if (current is! CourtLoaded) return;
    emit(const CourtState.loading());
    try {
      await _repo.reactivateCourt(event.id);
      final updated = current.courts
          .map((c) => c.id == event.id ? c.copyWith(isActive: true) : c)
          .toList();
      emit(CourtState.loaded(updated));
    } catch (e, st) {
      emit(CourtState.failure('Không thể kích hoạt sân.', stackTrace: st));
    }
  }
}
