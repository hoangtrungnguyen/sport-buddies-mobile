import 'package:freezed_annotation/freezed_annotation.dart';

part 'venue_event.freezed.dart';

@freezed
sealed class VenueEvent with _$VenueEvent {
  const factory VenueEvent.loadRequested(String courtId) = VenueLoadRequested;

  /// Re-fetch for the already-loaded courtId (called after create/update).
  const factory VenueEvent.reloadRequested() = VenueReloadRequested;
}
