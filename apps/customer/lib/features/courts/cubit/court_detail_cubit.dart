import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spb_core/spb_core.dart';

part 'court_detail_state.dart';

class CourtDetailCubit extends Cubit<CourtDetailState> {
  CourtDetailCubit(this._repository, {required SlotRepository slotRepository})
      : _slotRepository = slotRepository,
        super(const CourtDetailInitial());

  final CourtRepository _repository;
  final SlotRepository _slotRepository;

  Future<void> loadCourt(String courtId) async {
    emit(const CourtDetailLoading());
    final (courtResult, slotsResult) = await (
      _repository.fetchCourtById(courtId),
      _slotRepository.fetchSlots(courtId),
    ).wait;

    courtResult.when(
      success: (court) {
        final openCount = switch (slotsResult) {
          Success(:final value) => value.length,
          Failure() => 0,
        };
        emit(CourtDetailLoaded(court, openSlotCount: openCount));
      },
      failure: (f) => emit(CourtDetailError(_message(f))),
    );
  }

  static String _message(AppFailure f) => switch (f) {
        NetworkFailure() => 'Không có kết nối mạng.',
        ServerFailure(code: final c) => 'Lỗi máy chủ ($c).',
        AuthFailure(message: final m) => 'Lỗi xác thực: $m',
      };
}
