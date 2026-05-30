import 'package:freezed_annotation/freezed_annotation.dart';

part 'slot_players_event.freezed.dart';

@freezed
sealed class SlotPlayersEvent with _$SlotPlayersEvent {
  /// Load (or reload) the roster for the bloc's slot.
  const factory SlotPlayersEvent.started() = SlotPlayersStarted;
}
