import 'package:freezed_annotation/freezed_annotation.dart';

part 'participant.freezed.dart';
part 'participant.g.dart';

/// A player on a slot roster — host or joined participant.
///
/// Unifies the customer `SlotParticipant` and the dashboard `SlotPlayer`.
@freezed
abstract class Participant with _$Participant {
  const Participant._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Participant({
    required String id,
    required String name,
    String? userId,
    String? avatarUrl,
    @Default(false) bool isHost,

    /// `pending` | `confirmed` | `cancelled`.
    @Default('confirmed') String bookingStatus,

    /// `paid` | `partial` | `unpaid` | `unknown`.
    @Default('unknown') String paymentStatus,
    String? paymentMethod,
    int? expectedPrice,
  }) = _Participant;

  bool get isPaid => paymentStatus == 'paid';

  factory Participant.fromJson(Map<String, dynamic> json) =>
      _$ParticipantFromJson(json);
}

/// A request from a player to join an open slot.
@freezed
abstract class JoinRequest with _$JoinRequest {
  const JoinRequest._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory JoinRequest({
    required String id,
    required String slotId,
    required String userId,
    String? userName,
    String? avatarUrl,

    /// `pending` | `approved` | `rejected`.
    @Default('pending') String status,
    String? note,
    DateTime? createdAt,
  }) = _JoinRequest;

  bool get isPending => status == 'pending';

  factory JoinRequest.fromJson(Map<String, dynamic> json) =>
      _$JoinRequestFromJson(json);
}
