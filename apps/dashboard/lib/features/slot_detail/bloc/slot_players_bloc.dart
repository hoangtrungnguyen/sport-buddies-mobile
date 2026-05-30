import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/slot_players_repository.dart';
import 'slot_players_event.dart';
import 'slot_players_state.dart';

export 'slot_players_event.dart';
export 'slot_players_state.dart';

/// Loads the player roster for a single slot (OWNER-33). [slotId] is fixed for
/// the bloc's lifetime — one bloc per opened slot-detail dialog.
class SlotPlayersBloc extends Bloc<SlotPlayersEvent, SlotPlayersState> {
  SlotPlayersBloc({
    required SlotPlayersRepository repository,
    required this.slotId,
  })  : _repository = repository,
        super(const SlotPlayersInitial()) {
    on<SlotPlayersStarted>(_onStarted);
  }

  final SlotPlayersRepository _repository;
  final String slotId;

  Future<void> _onStarted(
    SlotPlayersStarted event,
    Emitter<SlotPlayersState> emit,
  ) async {
    emit(const SlotPlayersLoading());
    try {
      final players = await _repository.fetchPlayers(slotId: slotId);
      emit(SlotPlayersLoaded(players));
    } catch (e, st) {
      emit(SlotPlayersFailure(
        'Không thể tải danh sách người chơi.',
        stackTrace: st,
      ));
    }
  }
}
