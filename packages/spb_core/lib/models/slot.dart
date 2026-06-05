import 'package:freezed_annotation/freezed_annotation.dart';

part 'slot.freezed.dart';
part 'slot.g.dart';

/// A time slot available for booking at a court.
@freezed
abstract class Slot with _$Slot {
  const Slot._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Slot({
    required String id,
    required DateTime startTime,
    required DateTime endTime,
    required String courtId,
    required String courtName,
    required String sportType,
    @Default('open') String accessPolicy,
    @Default(4) int maxPlayers,
    @Default(0) int currentPlayers,
    String? hostId,
  }) = _Slot;

  bool get isFull => currentPlayers >= maxPlayers;

  factory Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);
}
