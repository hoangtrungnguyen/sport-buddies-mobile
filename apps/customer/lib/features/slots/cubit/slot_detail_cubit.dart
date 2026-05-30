import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spb_core/spb_core.dart';

part 'slot_detail_state.dart';

class SlotDetailCubit extends Cubit<SlotDetailState> {
  SlotDetailCubit(this._repository) : super(const SlotDetailInitial());

  final SlotRepository _repository;

  Future<void> loadSlot(String slotId) async {
    emit(const SlotDetailLoading());
    final result = await _repository.fetchSlotById(slotId);
    result.when(
      success: (slot) => emit(SlotDetailLoaded(slot)),
      failure: (f) => emit(SlotDetailError(_message(f))),
    );
  }

  static String _message(AppFailure f) => switch (f) {
        NetworkFailure() => 'Không có kết nối mạng.',
        ServerFailure(code: final c) => 'Lỗi máy chủ ($c).',
        AuthFailure(message: final m) => 'Lỗi xác thực: $m',
      };
}
