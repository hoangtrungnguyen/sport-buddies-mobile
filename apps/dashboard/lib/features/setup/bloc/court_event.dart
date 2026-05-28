import 'package:freezed_annotation/freezed_annotation.dart';

part 'court_event.freezed.dart';

@freezed
sealed class CourtEvent with _$CourtEvent {
  const factory CourtEvent.loadRequested() = CourtLoadRequested;
  const factory CourtEvent.deactivateRequested(String id) = CourtDeactivateRequested;
  const factory CourtEvent.reactivateRequested(String id) = CourtReactivateRequested;
}
