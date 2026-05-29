import 'package:freezed_annotation/freezed_annotation.dart';

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
}
