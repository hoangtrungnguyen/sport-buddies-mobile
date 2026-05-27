// OpenSlotListCubit — CAPP-034.
//
// Fetches open group slots for the "Slot trống" panel on the map screen.
// Two load paths:
//   loadAllGroupSlots() — all courts, status=booked & access_policy=open.
//   loadForCourt(id)    — single court, status=open (slot picker flow).

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spb_core/spb_core.dart';

part 'open_slot_list_state.dart';

class OpenSlotListCubit extends Cubit<OpenSlotListState> {
  OpenSlotListCubit(this._repository) : super(const OpenSlotListInitial());

  final OpenSlotRepository _repository;

  /// Loads all open group slots across every court (map panel).
  Future<void> loadAllGroupSlots() async {
    emit(const OpenSlotListLoading());
    final result = await _repository.fetchAllOpenGroupSlots();
    result.when(
      success: (slots) => emit(OpenSlotListLoaded(slots)),
      failure: (f) => emit(OpenSlotListError(_message(f))),
    );
  }

  /// Loads open slots for a single [courtId] (slot picker screen).
  Future<void> loadForCourt(String courtId) async {
    emit(const OpenSlotListLoading());
    final result = await _repository.fetchOpenSlots(courtId);
    result.when(
      success: (slots) => emit(OpenSlotListLoaded(slots)),
      failure: (f) => emit(OpenSlotListError(_message(f))),
    );
  }

  void clear() => emit(const OpenSlotListInitial());

  static String _message(AppFailure f) => switch (f) {
        NetworkFailure() => 'Không có kết nối mạng.',
        ServerFailure(:final code) => 'Lỗi máy chủ ($code).',
        AuthFailure(:final message) => 'Lỗi xác thực: $message',
      };
}
