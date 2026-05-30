import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spb_core/spb_core.dart';

part 'court_detail_state.dart';

class CourtDetailCubit extends Cubit<CourtDetailState> {
  CourtDetailCubit(this._repository) : super(const CourtDetailInitial());

  final CourtRepository _repository;

  Future<void> loadCourt(String courtId) async {
    emit(const CourtDetailLoading());
    final result = await _repository.fetchCourtById(courtId);
    result.when(
      success: (court) => emit(CourtDetailLoaded(court)),
      failure: (f) => emit(CourtDetailError(_message(f))),
    );
  }

  static String _message(AppFailure f) => switch (f) {
        NetworkFailure() => 'Không có kết nối mạng.',
        ServerFailure(code: final c) => 'Lỗi máy chủ ($c).',
        AuthFailure(message: final m) => 'Lỗi xác thực: $m',
      };
}
