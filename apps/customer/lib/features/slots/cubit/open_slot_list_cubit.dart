// SlotListCubit — CAPP-034.
//
// Fetches open group slots for the "Slot trống" panel on the map screen.
// Two load paths:
//   loadAllGroupSlots() — all courts, status=booked & access_policy=open.
//   loadForCourt(id)    — single court, status=open (slot picker flow).

import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spb_core/spb_core.dart';

part 'open_slot_list_state.dart';

class SlotListCubit extends Cubit<SlotListState> {
  SlotListCubit(this._repository) : super(const SlotListInitial());

  final SlotRepository _repository;

  /// Loads all open group slots across every court (map panel).
  Future<void> loadAllGroupSlots() async {
    emit(const SlotListLoading());
    final result = await _repository.fetchAllGroupSlots();
    result.when(
      success: (slots) => emit(SlotListLoaded(slots)),
      failure: (f) => emit(SlotListError(_message(f))),
    );
  }

  /// Loads open slots for a single [courtId] (slot picker screen).
  Future<void> loadForCourt(String courtId) async {
    emit(const SlotListLoading());
    final result = await _repository.fetchSlots(courtId);
    result.when(
      success: (slots) => emit(SlotListLoaded(slots)),
      failure: (f) => emit(SlotListError(_message(f))),
    );
  }

  void clear() => emit(const SlotListInitial());

  static String _message(AppFailure f) => switch (f) {
        NetworkFailure() => 'Không có kết nối mạng.',
        ServerFailure(:final code) => 'Lỗi máy chủ ($code).',
        AuthFailure(:final message) => 'Lỗi xác thực: $message',
      };
}
