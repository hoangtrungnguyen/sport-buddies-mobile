import 'package:dashboard/core/mixins/app_exception_mixin.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../model/booking_request.dart';
import '../model/requests_action.dart';

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

    /// Transient outcome of the most recent approve/reject/undo (OWNER-28/29).
    /// Set by the bloc when the action resolves, consumed once by the screen
    /// (undo snackbar / error), then cleared via
    /// [RequestsEvent.actionConsumed]. Null in the steady state.
    RequestsAction? lastAction,

    /// Bumped on every action emit. Without it, two value-equal [lastAction]s
    /// (e.g. two identical failures) would compare equal under freezed
    /// value-equality and Bloc would skip the second emit — silently dropping
    /// that one-shot signal. The nonce guarantees each action state is distinct.
    @Default(0) int actionNonce,
  }) = RequestsLoaded;

  @With<AppExceptionMixin>()
  const factory RequestsState.failure(
    String message, {
    DateTime? day,
    StackTrace? stackTrace,
  }) = RequestsFailure;
}
