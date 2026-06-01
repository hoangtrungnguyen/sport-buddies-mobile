import 'package:dashboard/core/mixins/app_exception_mixin.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../model/venue.dart';

part 'venue_state.freezed.dart';

@freezed
sealed class VenueState with _$VenueState {
  const factory VenueState.initial() = VenueInitial;
  const factory VenueState.loading() = VenueLoading;

  const factory VenueState.loaded({
    required String courtId,
    required List<Venue> venues,
  }) = VenueLoaded;

  @With<AppExceptionMixin>()
  const factory VenueState.failure(
    String message, {
    String? courtId,
    StackTrace? stackTrace,
  }) = VenueFailure;
}
