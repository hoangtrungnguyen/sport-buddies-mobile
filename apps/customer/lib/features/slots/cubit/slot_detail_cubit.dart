import 'package:customer/core/debug/app_logger.dart';
import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:customer/core/services/booking_api_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spb_core/spb_core.dart';

part 'slot_detail_state.dart';

class SlotDetailCubit extends Cubit<SlotDetailState> {
  SlotDetailCubit(this._repository, {required BookingApiClient apiClient})
    : _api = apiClient,
      super(const SlotDetailInitial());

  final SlotRepository _repository;
  final BookingApiClient _api;

  Future<void> loadSlot(String slotId) async {
    emit(const SlotDetailLoading());

    final result = await _repository.fetchSlotById(slotId);
    await result.when(
      success: (slot) async {
        final joinStatus = await _fetchJoinStatus(slotId);
        emit(SlotDetailLoaded(slot, joinStatus: joinStatus));
      },
      failure: (f) async => emit(SlotDetailError(_message(f))),
    );
  }

  /// Fetches this player's join status for [slotId] via the REST API.
  Future<SlotJoinStatus> _fetchJoinStatus(String slotId) async {
    try {
      final status = await _api.getSlotJoinStatus(slotId);
      return _parseJoinStatus(status);
    } on NoConnectionException {
      appLogger.w('SlotDetailCubit._fetchJoinStatus: no connection');
      return SlotJoinStatus.none;
    } catch (e, st) {
      appLogger.w(
        'SlotDetailCubit._fetchJoinStatus failed',
        error: e,
        stackTrace: st,
      );
      return SlotJoinStatus.none;
    }
  }

  /// Sends a play-together join request for [slotId] via the REST API.
  Future<void> requestToJoin(String slotId) async {
    final s = state;
    if (s is! SlotDetailLoaded || s.joining) return;
    emit(s.copyWith(joining: true));
    try {
      await _api.requestToJoin(slotId);
      emit(s.copyWith(joining: false, joinStatus: SlotJoinStatus.pending));
    } on JoinConflictException {
      // Already requested (or slot just flipped) — reflect pending so the
      // player sees their request rather than a hard error.
      emit(s.copyWith(joining: false, joinStatus: SlotJoinStatus.pending));
    } on NoConnectionException {
      emit(s.copyWith(joining: false, errorMessage: 'network'));
    } catch (e, st) {
      appLogger.e('SlotDetailCubit.requestToJoin', error: e, stackTrace: st);
      emit(s.copyWith(joining: false, errorMessage: 'send_request'));
    }
  }

  /// Signals last-minute capacity for [slotId] via the REST API.
  /// Called by slot owner to indicate available spots for quick joining.
  Future<void> signalLastMinuteCapacity(String slotId) async {
    final s = state;
    if (s is! SlotDetailLoaded || s.signalingLastMinute) return;
    emit(s.copyWith(signalingLastMinute: true));
    try {
      await _api.signalLastMinuteCapacity(slotId);
      emit(
        s.copyWith(signalingLastMinute: false, errorMessage: 'last_call_sent'),
      );
    } on NoConnectionException {
      emit(s.copyWith(signalingLastMinute: false, errorMessage: 'network'));
    } catch (e, st) {
      appLogger.e(
        'SlotDetailCubit.signalLastMinuteCapacity',
        error: e,
        stackTrace: st,
      );
      emit(s.copyWith(signalingLastMinute: false, errorMessage: 'send_notify'));
    }
  }

  static SlotJoinStatus _parseJoinStatus(String? raw) => switch (raw) {
    'pending' => SlotJoinStatus.pending,
    'approved' => SlotJoinStatus.approved,
    'rejected' => SlotJoinStatus.rejected,
    _ => SlotJoinStatus.none,
  };

  static String _message(AppFailure f) => switch (f) {
    NetworkFailure() => 'network',
    ServerFailure() => 'server',
    AuthFailure() => 'auth',
  };
}
