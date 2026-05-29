import 'package:dashboard/core/mixins/app_exception_mixin.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../model/booking_request.dart';

part 'requests_state.freezed.dart';

@freezed
sealed class RequestsState with _$RequestsState {
  const factory RequestsState.initial() = RequestsInitial;
  const factory RequestsState.loading() = RequestsLoading;

  /// Loaded view for [day]. [requests] is the full day list, already sorted
  /// ascending by start time; [page] is the zero-based current page. [busy] is
  /// true while a date change is re-fetching but the previous list still shows.
  const factory RequestsState.loaded({
    required DateTime day,
    required List<BookingRequest> requests,
    @Default(0) int page,
    @Default(false) bool busy,
  }) = RequestsLoaded;

  @With<AppExceptionMixin>()
  const factory RequestsState.failure(
    String message, {
    DateTime? day,
    StackTrace? stackTrace,
  }) = RequestsFailure;
}
