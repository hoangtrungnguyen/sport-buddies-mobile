import 'package:customer/core/debug/app_logger.dart';
import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:customer/core/services/booking_api_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spb_core/spb_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'slot_detail_state.dart';

class SlotDetailCubit extends Cubit<SlotDetailState> {
  SlotDetailCubit(
    this._repository, {
    required SupabaseClient client,
    required BookingApiClient apiClient,
  })  : _client = client,
        _api = apiClient,
        super(const SlotDetailInitial());

  final SlotRepository _repository;
  final SupabaseClient _client;
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

  /// Reads this player's join status for [slotId] directly from Supabase
  /// (reads stay on Supabase; only the write goes through the REST API).
  Future<SlotJoinStatus> _fetchJoinStatus(String slotId) async {
    final userId = _client.auth.currentSession?.user.id;
    if (userId == null) return SlotJoinStatus.none;
    try {
      final row = await _client
          .from('slot_join_requests')
          .select('status')
          .eq('slot_id', slotId)
          .eq('user_id', userId)
          .maybeSingle();
      return _parseJoinStatus(row?['status'] as String?);
    } catch (e, st) {
      appLogger.w('SlotDetailCubit._fetchJoinStatus failed',
          error: e, stackTrace: st);
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
      emit(s.copyWith(
        joining: false,
        errorMessage: 'Không có kết nối mạng. Vui lòng thử lại.',
      ));
    } catch (e, st) {
      appLogger.e('SlotDetailCubit.requestToJoin', error: e, stackTrace: st);
      emit(s.copyWith(
        joining: false,
        errorMessage: 'Không gửi được yêu cầu, thử lại sau.',
      ));
    }
  }

  static SlotJoinStatus _parseJoinStatus(String? raw) => switch (raw) {
        'pending' => SlotJoinStatus.pending,
        'approved' => SlotJoinStatus.approved,
        'rejected' => SlotJoinStatus.rejected,
        _ => SlotJoinStatus.none,
      };

  static String _message(AppFailure f) => switch (f) {
        NetworkFailure() => 'Không có kết nối mạng.',
        ServerFailure(code: final c) => 'Lỗi máy chủ ($c).',
        AuthFailure(message: final m) => 'Lỗi xác thực: $m',
      };
}
