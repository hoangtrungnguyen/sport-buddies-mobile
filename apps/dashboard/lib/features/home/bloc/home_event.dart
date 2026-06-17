import 'package:freezed_annotation/freezed_annotation.dart';

import '../model/home_models.dart';

part 'home_event.freezed.dart';

@freezed
sealed class HomeEvent with _$HomeEvent {
  const factory HomeEvent.started() = HomeStarted;
  const factory HomeEvent.requestApproved(PendingRequest request) =
      HomeRequestApproved;
  const factory HomeEvent.requestDeclined(PendingRequest request) =
      HomeRequestDeclined;
}
