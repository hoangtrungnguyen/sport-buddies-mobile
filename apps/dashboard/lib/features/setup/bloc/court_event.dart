import 'package:freezed_annotation/freezed_annotation.dart';

part 'court_event.freezed.dart';

@freezed
sealed class CourtEvent with _$CourtEvent {
  const factory CourtEvent.loadRequested() = CourtLoadRequested;
  const factory CourtEvent.deactivateRequested(String id) = CourtDeactivateRequested;
  const factory CourtEvent.reactivateRequested(String id) = CourtReactivateRequested;

  /// Toggle `courts.auto_approve_single` for [courtId] (OWNER-44/45).
  /// Persisted immediately; snackbar shown on success/failure in the view.
  const factory CourtEvent.autoApproveToggled(
    String courtId, {
    required bool value,
  }) = CourtAutoApproveToggled;
}
