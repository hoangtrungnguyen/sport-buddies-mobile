import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/booking_request.dart';
import '../model/requests_action.dart';
import '../repository/booking_action_repository.dart';
import '../repository/booking_request_repository.dart';
import '../requests_logic.dart';
import 'requests_event.dart';
import 'requests_state.dart';

export 'requests_event.dart';
export 'requests_state.dart';

/// Drives the incoming-requests queue (OWNER-27/28/29): loads a day's bookings,
/// navigates between days, paginates, and approves/rejects/undoes requests.
/// [now] is injected so the "default to today" behaviour is deterministic in
/// tests.
class RequestsBloc extends Bloc<RequestsEvent, RequestsState> {
  RequestsBloc({
    required BookingRequestRepository repository,
    required BookingActionRepository actionRepository,
    DateTime Function()? now,
  })  : _repository = repository,
        _actions = actionRepository,
        _now = now ?? DateTime.now,
        super(const RequestsInitial()) {
    on<RequestsStarted>(_onStarted);
    on<RequestsDateChanged>(_onDateChanged);
    on<RequestsPageChanged>(_onPageChanged);
    on<RequestsRefreshed>(_onRefreshed);
    on<RequestsApproved>(_onApproved);
    on<RequestsRejected>(_onRejected);
    on<RequestsUndoRequested>(_onUndoRequested);
    on<RequestsActionConsumed>(_onActionConsumed);
  }

  final BookingRequestRepository _repository;
  final BookingActionRepository _actions;
  final DateTime Function() _now;

  /// Booking ids with an approve/reject/undo in flight — a second tap on the
  /// same card while the first is pending is ignored (no duplicate mutation).
  final Set<String> _inFlight = <String>{};

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

  Future<void> _onApproved(
    RequestsApproved event,
    Emitter<RequestsState> emit,
  ) =>
      _runAction(
        event.request,
        emit,
        run: () => _actions.approve(bookingId: event.request.id),
        toStatus: BookingStatus.confirmed,
        signal: (r) => RequestsAction.approved(r),
        failure: 'Không thể duyệt đơn. Vui lòng thử lại.',
      );

  Future<void> _onRejected(
    RequestsRejected event,
    Emitter<RequestsState> emit,
  ) =>
      _runAction(
        event.request,
        emit,
        run: () =>
            _actions.reject(bookingId: event.request.id, reason: event.reason),
        toStatus: BookingStatus.cancelled,
        signal: (r) => RequestsAction.rejected(r, reason: event.reason),
        failure: 'Không thể từ chối đơn. Vui lòng thử lại.',
      );

  Future<void> _onUndoRequested(
    RequestsUndoRequested event,
    Emitter<RequestsState> emit,
  ) =>
      _runAction(
        event.request,
        emit,
        run: () => _actions.restorePending(
          bookingId: event.request.id,
          slotId: event.request.slotId,
        ),
        toStatus: BookingStatus.pending,
        signal: (r) => RequestsAction.undone(r),
        failure: 'Không thể hoàn tác. Vui lòng thử lại.',
      );

  /// Shared approve/reject/undo flow: ignore a re-tap while in flight, run the
  /// repo write, then update the matching row + emit a one-shot signal — but
  /// only if we're still on the same loaded day (a mid-flight day change must
  /// not resurrect the old day's list).
  Future<void> _runAction(
    BookingRequest request,
    Emitter<RequestsState> emit, {
    required Future<void> Function() run,
    required BookingStatus toStatus,
    required RequestsAction Function(BookingRequest) signal,
    required String failure,
  }) async {
    final s = state;
    if (s is! RequestsLoaded) return;
    if (!_inFlight.add(request.id)) return; // re-tap while in flight → ignore
    try {
      await run();
      final cur = state;
      if (cur is! RequestsLoaded || !cur.day.isAtSameMomentAs(s.day)) return;
      final updated = request.copyWith(status: toStatus);
      emit(cur.copyWith(
        requests: _replace(cur.requests, updated),
        lastAction: signal(updated),
        actionNonce: cur.actionNonce + 1,
      ));
    } catch (e) {
      final cur = state;
      if (cur is! RequestsLoaded || !cur.day.isAtSameMomentAs(s.day)) return;
      emit(cur.copyWith(
        lastAction: RequestsAction.failed(failure),
        actionNonce: cur.actionNonce + 1,
      ));
    } finally {
      _inFlight.remove(request.id);
    }
  }

  void _onActionConsumed(
    RequestsActionConsumed event,
    Emitter<RequestsState> emit,
  ) {
    final s = state;
    if (s is RequestsLoaded && s.lastAction != null) {
      emit(s.copyWith(lastAction: null));
    }
  }

  /// Returns [list] with the entry matching [updated].id swapped for [updated]
  /// (identity by booking id); order preserved.
  static List<BookingRequest> _replace(
    List<BookingRequest> list,
    BookingRequest updated,
  ) =>
      [
        for (final r in list) r.id == updated.id ? updated : r,
      ];

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
