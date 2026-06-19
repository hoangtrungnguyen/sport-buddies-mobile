part of 'slot_detail_cubit.dart';

/// Current player's join-request status for the slot.
enum SlotJoinStatus { none, pending, approved, rejected }

sealed class SlotDetailState {
  const SlotDetailState();
}

final class SlotDetailInitial extends SlotDetailState {
  const SlotDetailInitial();
}

final class SlotDetailLoading extends SlotDetailState {
  const SlotDetailLoading();
}

final class SlotDetailLoaded extends SlotDetailState {
  const SlotDetailLoaded(
    this.slot, {
    this.joinStatus = SlotJoinStatus.none,
    this.joining = false,
    this.signalingLastMinute = false,
    this.errorMessage,
  });

  final Slot slot;

  /// This player's join status for [slot].
  final SlotJoinStatus joinStatus;

  /// A join request is in-flight.
  final bool joining;

  /// Last-minute capacity signal is in-flight.
  final bool signalingLastMinute;

  /// Transient error surfaced via snackbar (cleared on the next action).
  final String? errorMessage;

  SlotDetailLoaded copyWith({
    SlotJoinStatus? joinStatus,
    bool? joining,
    bool? signalingLastMinute,
    String? errorMessage,
  }) => SlotDetailLoaded(
    slot,
    joinStatus: joinStatus ?? this.joinStatus,
    joining: joining ?? this.joining,
    signalingLastMinute: signalingLastMinute ?? this.signalingLastMinute,
    errorMessage: errorMessage,
  );
}

final class SlotDetailError extends SlotDetailState with AppExceptionMixin {
  const SlotDetailError(this.message, {this.stackTrace});

  @override
  final String message;
  @override
  final StackTrace? stackTrace;
}
