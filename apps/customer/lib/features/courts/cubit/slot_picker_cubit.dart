import 'package:customer/core/debug/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spb_core/spb_core.dart';

part 'slot_picker_state.dart';

class SlotPickerCubit extends Cubit<SlotPickerState> {
  SlotPickerCubit({
    required SlotRepository slotRepository,
    required CourtRepository courtRepository,
  })  : _slotRepo = slotRepository,
        _courtRepo = courtRepository,
        super(const SlotPickerLoading());

  final SlotRepository _slotRepo;
  final CourtRepository _courtRepo;

  Future<void> load(String courtId) async {
    emit(const SlotPickerLoading());
    try {
      final slotsResult = await _slotRepo.fetchSlots(courtId);
      final courtResult = await _courtRepo.fetchCourtById(courtId);

      final slots =
          slotsResult is Success<List<Slot>> ? slotsResult.value : <Slot>[];
      final pricePerHour =
          courtResult is Success<Court> ? courtResult.value.pricePerHour : null;

      emit(SlotPickerLoaded(slots: slots, pricePerHour: pricePerHour));
    } catch (e, st) {
      appLogger.e('SlotPickerCubit.load', error: e, stackTrace: st);
      emit(SlotPickerError(e.toString()));
    }
  }
}
