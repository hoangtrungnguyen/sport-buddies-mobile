import 'package:freezed_annotation/freezed_annotation.dart';

import '../model/profile_models.dart';

part 'profile_state.freezed.dart';

@freezed
sealed class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = ProfileInitial;
  const factory ProfileState.loading() = ProfileLoading;

  /// [saving] gates the edit dialog's Lưu button while a write is in flight.
  const factory ProfileState.loaded({
    required OwnerProfile profile,
    required ProfileStats stats,
    @Default(false) bool saving,
  }) = ProfileLoaded;

  const factory ProfileState.failure(String message) = ProfileFailure;
}
