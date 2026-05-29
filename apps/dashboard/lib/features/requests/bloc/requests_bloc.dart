import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/booking_request_repository.dart';
import '../requests_logic.dart';
import 'requests_event.dart';
import 'requests_state.dart';

export 'requests_event.dart';
export 'requests_state.dart';

/// Drives the incoming-requests queue (OWNER-27): loads a day's bookings,
/// navigates between days, and paginates within a day. [now] is injected so the
/// "default to today" behaviour is deterministic in tests.
class RequestsBloc extends Bloc<RequestsEvent, RequestsState> {
  RequestsBloc({
    required BookingRequestRepository repository,
    DateTime Function()? now,
  })  : _repository = repository,
        _now = now ?? DateTime.now,
        super(const RequestsInitial()) {
    on<RequestsStarted>(_onStarted);
    on<RequestsDateChanged>(_onDateChanged);
    on<RequestsPageChanged>(_onPageChanged);
    on<RequestsRefreshed>(_onRefreshed);
  }

  final BookingRequestRepository _repository;
  final DateTime Function() _now;

  /// Monotonic id of the most recently started load. Each [_load] captures its
  /// own id and drops its emit if a newer load has begun — so when the user
  /// navigates days quickly and the fetches resolve out of order, only the
  /// latest day's result is shown (the default `concurrent` event transformer
  /// otherwise lets a slow earlier fetch clobber a newer one).
  int _loadToken = 0;

  Future<void> _onStarted(
    RequestsStarted event,
    Emitter<RequestsState> emit,
  ) async {
    emit(const RequestsLoading());
    await _load(dayStartLocal(_now()), emit);
  }

  Future<void> _onDateChanged(
    RequestsDateChanged event,
    Emitter<RequestsState> emit,
  ) async {
    final day = dayStartLocal(event.day);
    final s = state;
    // No-op when the shown day is already loaded and settled — avoids a silent
    // page reset (e.g. tapping "Hôm nay" while already on today). A genuine
    // re-fetch of the current day goes through RequestsEvent.refreshed.
    if (s is RequestsLoaded && s.day == day && !s.busy) return;
    // Keep the current list visible with a busy spinner while the new day
    // loads, mirroring the schedule screen's reload UX.
    if (s is RequestsLoaded) {
      emit(s.copyWith(day: day, page: 0, busy: true));
    } else {
      emit(const RequestsLoading());
    }
    await _load(day, emit);
  }

  void _onPageChanged(
    RequestsPageChanged event,
    Emitter<RequestsState> emit,
  ) {
    final s = state;
    if (s is! RequestsLoaded) return;
    final clamped = clampPage(event.page, s.requests.length);
    if (clamped == s.page) return;
    emit(s.copyWith(page: clamped));
  }

  Future<void> _onRefreshed(
    RequestsRefreshed event,
    Emitter<RequestsState> emit,
  ) async {
    final s = state;
    final day = switch (s) {
      RequestsLoaded(:final day) => day,
      RequestsFailure(:final day?) => day,
      _ => dayStartLocal(_now()),
    };
    if (s is RequestsLoaded) {
      emit(s.copyWith(busy: true));
    } else {
      emit(const RequestsLoading());
    }
    await _load(day, emit);
  }

  Future<void> _load(DateTime day, Emitter<RequestsState> emit) async {
    final token = ++_loadToken;
    try {
      final raw = await _repository.fetchForDay(day: day);
      if (token != _loadToken) return; // superseded by a newer load
      emit(RequestsLoaded(
        day: day,
        requests: sortByStartAsc(raw),
        page: 0,
      ));
    } catch (e, st) {
      if (token != _loadToken) return; // superseded by a newer load
      emit(RequestsFailure(
        'Không thể tải danh sách đơn đặt sân.',
        day: day,
        stackTrace: st,
      ));
    }
  }
}
