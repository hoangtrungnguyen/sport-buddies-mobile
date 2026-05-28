import 'package:dashboard/core/mixins/app_exception_mixin.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../model/owner_court.dart';

part 'court_state.freezed.dart';

@freezed
sealed class CourtState with _$CourtState {
  const factory CourtState.initial() = CourtInitial;
  const factory CourtState.loading() = CourtLoading;
  const factory CourtState.loaded(List<OwnerCourt> courts) = CourtLoaded;

  @With<AppExceptionMixin>()
  const factory CourtState.failure(String message, {StackTrace? stackTrace}) =
      CourtFailure;
}
