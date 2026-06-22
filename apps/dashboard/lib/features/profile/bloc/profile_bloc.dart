import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/profile_models.dart';
import '../repository/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required ProfileRepository repository})
      : _repository = repository,
        super(const ProfileState.initial()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileEditSubmitted>(_onEditSubmitted);
    on<ProfileTwoFactorToggled>(_onTwoFactorToggled);
    on<ProfileEmailNotifToggled>(_onEmailNotifToggled);
  }

  final ProfileRepository _repository;

  Future<void> _onStarted(
      ProfileStarted event, Emitter<ProfileState> emit) async {
    emit(const ProfileState.loading());
    try {
      final profile = await _repository.getProfile();
      final stats = await _repository.getStats();
      emit(ProfileState.loaded(profile: profile, stats: stats));
    } catch (e) {
      emit(ProfileState.failure(e.toString()));
    }
  }

  Future<void> _onEditSubmitted(
      ProfileEditSubmitted event, Emitter<ProfileState> emit) async {
    final current = state;
    if (current is! ProfileLoaded) return;
    emit(current.copyWith(saving: true));
    try {
      final saved = await _repository.updateProfile(event.draft);
      emit(current.copyWith(profile: saved, saving: false));
    } catch (e) {
      emit(current.copyWith(saving: false));
      emit(ProfileState.failure(e.toString()));
    }
  }

  Future<void> _onTwoFactorToggled(
      ProfileTwoFactorToggled event, Emitter<ProfileState> emit) {
    return _toggle(
      emit,
      next: (p) => p.copyWith(twoFactor: event.enabled),
      persist: () => _repository.setTwoFactor(event.enabled),
    );
  }

  Future<void> _onEmailNotifToggled(
      ProfileEmailNotifToggled event, Emitter<ProfileState> emit) {
    return _toggle(
      emit,
      next: (p) => p.copyWith(emailNotif: event.enabled),
      persist: () => _repository.setEmailNotif(event.enabled),
    );
  }

  /// Optimistically apply [next] to the loaded profile, then [persist]. On
  /// failure revert to the pre-toggle profile (design: "revert on fail").
  Future<void> _toggle(
    Emitter<ProfileState> emit, {
    required OwnerProfile Function(OwnerProfile) next,
    required Future<void> Function() persist,
  }) async {
    final current = state;
    if (current is! ProfileLoaded) return;
    final before = current.profile;
    emit(current.copyWith(profile: next(before)));
    try {
      await persist();
    } catch (_) {
      emit(current.copyWith(profile: before));
    }
  }
}
