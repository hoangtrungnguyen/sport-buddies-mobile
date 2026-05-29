import 'package:freezed_annotation/freezed_annotation.dart';

import 'booking_request.dart';

part 'requests_action.freezed.dart';

/// One-shot outcome of an approve/reject/undo on a booking request (OWNER-28/29).
///
/// Carried transiently on [RequestsLoaded.lastAction]: the bloc sets it when an
/// action resolves, the screen reacts once (shows the "Hoàn tác" undo snackbar
/// or an error), then dispatches `RequestsEvent.actionConsumed` so it never
/// re-fires. The screen's `listenWhen` uses `identical()` to react exactly once
/// per fresh instance — freezed value-equality does not interfere.
@freezed
sealed class RequestsAction with _$RequestsAction {
  /// A request was approved (status → confirmed). [request] is the post-change
  /// row; its id drives the undo.
  const factory RequestsAction.approved(BookingRequest request) =
      RequestApproved;

  /// A request was rejected (status → cancelled, slot freed). [reason] is the
  /// optional owner-supplied note.
  const factory RequestsAction.rejected(
    BookingRequest request, {
    String? reason,
  }) = RequestRejected;

  /// A prior approve/reject was undone within the grace period (→ pending).
  const factory RequestsAction.undone(BookingRequest request) = RequestUndone;

  /// An action failed; [message] is already localized for a red snackbar.
  const factory RequestsAction.failed(String message) = RequestActionFailed;
}
