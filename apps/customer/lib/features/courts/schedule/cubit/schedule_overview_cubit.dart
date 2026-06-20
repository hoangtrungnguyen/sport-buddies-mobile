import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spb_core/spb_core.dart';

part 'schedule_overview_state.dart';

class ScheduleOverviewCubit extends Cubit<ScheduleOverviewState> {
  ScheduleOverviewCubit({
    required CourtRepository courtRepository,
    required SlotRepository slotRepository,
  }) : _courtRepo = courtRepository,
       _slotRepo = slotRepository,
       super(const ScheduleOverviewInitial());

  final CourtRepository _courtRepo;
  final SlotRepository _slotRepo;

  Future<void> load(String courtId) async {
    emit(const ScheduleOverviewLoading());

    // 1. Fetch the anchor court to get owner_id.
    final courtResult = await _courtRepo.fetchCourtById(courtId);
    switch (courtResult) {
      case Failure<Court>(:final failure):
        emit(ScheduleOverviewError(_message(failure)));
        return;
      case Success<Court>():
    }
    final anchorCourt = courtResult.value;
    final ownerId = anchorCourt.ownerId;
    if (ownerId == null) {
      emit(const ScheduleOverviewError('center_not_found'));
      return;
    }

    // 2. Fetch all courts in the same sports center.
    final courtsResult = await _courtRepo.fetchCourtsByOwner(ownerId);
    switch (courtsResult) {
      case Failure<List<Court>>(:final failure):
        emit(ScheduleOverviewError(_message(failure)));
        return;
      case Success<List<Court>>():
    }
    final courts = courtsResult.value;

    // 3. Emit loaded with today's date selected; fetch slots.
    final today = DateTime.now();
    emit(
      ScheduleOverviewLoaded(
        courts: courts,
        slotsByCourtId: const {},
        selectedDate: today,
      ),
    );
    await _loadSlots(courts, today);
  }

  Future<void> selectDate(DateTime date) async {
    final s = state;
    if (s is! ScheduleOverviewLoaded) return;
    emit(s.copyWith(selectedDate: date, slotsByCourtId: const {}));
    await _loadSlots(s.courts, date);
  }

  Future<void> _loadSlots(List<Court> courts, DateTime date) async {
    final s = state;
    if (s is! ScheduleOverviewLoaded) return;

    final courtIds = courts.map((c) => c.id).toList();
    final result = await _slotRepo.fetchScheduleSlots(courtIds, date);
    if (result is! Success<List<Slot>>) return;

    final byCourtId = <String, List<Slot>>{};
    for (final slot in result.value) {
      byCourtId.putIfAbsent(slot.courtId, () => []).add(slot);
    }

    if (!isClosed && state is ScheduleOverviewLoaded) {
      emit(
        (state as ScheduleOverviewLoaded).copyWith(slotsByCourtId: byCourtId),
      );
    }
  }

  static String _message(AppFailure f) => switch (f) {
    NetworkFailure() => 'network',
    ServerFailure() => 'server',
    AuthFailure() => 'auth',
  };
}
