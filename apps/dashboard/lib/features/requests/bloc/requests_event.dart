import 'package:freezed_annotation/freezed_annotation.dart';

import '../model/booking_request.dart';

part 'requests_event.freezed.dart';

@freezed
sealed class RequestsEvent with _$RequestsEvent {
  /// Initial load — fetches requests for today.
  const factory RequestsEvent.started() = RequestsStarted;

  /// Navigate the queue to another calendar [day] (resets to the first page).
  const factory RequestsEvent.dateChanged(DateTime day) = RequestsDateChanged;

  /// Move to a (zero-based) [page] within the current day's results.
  const factory RequestsEvent.pageChanged(int page) = RequestsPageChanged;

  /// Re-fetch the currently shown day (e.g. retry after a failure).
  const factory RequestsEvent.refreshed() = RequestsRefreshed;

  /// Approve a pending [request] (OWNER-28): status → confirmed.
  const factory RequestsEvent.approved(BookingRequest request) =
      RequestsApproved;

  /// Reject a pending [request] (OWNER-29): status → cancelled, slot freed.
  const factory RequestsEvent.rejected(
    BookingRequest request, {
    String? reason,
  }) = RequestsRejected;

  /// Undo the last approve/reject for [request] within the grace period
  /// (status → pending).
  const factory RequestsEvent.undoRequested(BookingRequest request) =
      RequestsUndoRequested;

  /// Clear the transient [RequestsLoaded.lastAction] after the screen reacts.
  const factory RequestsEvent.actionConsumed() = RequestsActionConsumed;
}
