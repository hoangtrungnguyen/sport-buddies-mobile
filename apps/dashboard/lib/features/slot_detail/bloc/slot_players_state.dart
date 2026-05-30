import 'package:dashboard/core/mixins/app_exception_mixin.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../model/slot_player.dart';

part 'slot_players_state.freezed.dart';

@freezed
sealed class SlotPlayersState with _$SlotPlayersState {
  const factory SlotPlayersState.initial() = SlotPlayersInitial;
  const factory SlotPlayersState.loading() = SlotPlayersLoading;

  /// Loaded roster — [players] may be empty (no one registered yet).
  const factory SlotPlayersState.loaded(List<SlotPlayer> players) =
      SlotPlayersLoaded;

  @With<AppExceptionMixin>()
  const factory SlotPlayersState.failure(
    String message, {
    StackTrace? stackTrace,
  }) = SlotPlayersFailure;
}
