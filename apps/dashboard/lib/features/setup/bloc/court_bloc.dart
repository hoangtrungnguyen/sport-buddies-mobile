import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/owner_court_repository.dart';
import 'court_event.dart';
import 'court_state.dart';

class CourtBloc extends Bloc<CourtEvent, CourtState> {
  CourtBloc(this._repo) : super(const CourtState.initial()) {
    on<CourtLoadRequested>(_onLoad);
    on<CourtDeactivateRequested>(_onDeactivate);
    on<CourtReactivateRequested>(_onReactivate);
    on<CourtAutoApproveToggled>(_onAutoApproveToggled);
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

  /// Optimistic-update: flip the toggle in the in-memory list immediately,
  /// then persist in the background. On failure restore the old value and emit
  /// a failure so the view can show a snackbar (OWNER-44).
  Future<void> _onAutoApproveToggled(
    CourtAutoApproveToggled event,
    Emitter<CourtState> emit,
  ) async {
    final current = state;
    if (current is! CourtLoaded) return;
    final optimistic = current.courts
        .map((c) => c.id == event.courtId
            ? c.copyWith(autoApproveSingle: event.value)
            : c)
        .toList();
    emit(CourtState.loaded(optimistic));
    try {
      await _repo.updateAutoApprove(event.courtId, value: event.value);
    } catch (e, st) {
      // Revert on failure.
      final reverted = optimistic
          .map((c) => c.id == event.courtId
              ? c.copyWith(autoApproveSingle: !event.value)
              : c)
          .toList();
      emit(CourtState.loaded(reverted));
      emit(CourtState.failure('Không thể lưu cài đặt.', stackTrace: st));
    }
  }
}
