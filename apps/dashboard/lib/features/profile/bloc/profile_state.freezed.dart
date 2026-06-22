// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ProfileState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ProfileState()';
  }
}

/// @nodoc
class $ProfileStateCopyWith<$Res> {
  $ProfileStateCopyWith(ProfileState _, $Res Function(ProfileState) __);
}

/// Adds pattern-matching-related methods to [ProfileState].
extension ProfileStatePatterns on ProfileState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProfileInitial value)? initial,
    TResult Function(ProfileLoading value)? loading,
    TResult Function(ProfileLoaded value)? loaded,
    TResult Function(ProfileFailure value)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ProfileInitial() when initial != null:
        return initial(_that);
      case ProfileLoading() when loading != null:
        return loading(_that);
      case ProfileLoaded() when loaded != null:
        return loaded(_that);
      case ProfileFailure() when failure != null:
        return failure(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ProfileInitial value) initial,
    required TResult Function(ProfileLoading value) loading,
    required TResult Function(ProfileLoaded value) loaded,
    required TResult Function(ProfileFailure value) failure,
  }) {
    final _that = this;
    switch (_that) {
      case ProfileInitial():
        return initial(_that);
      case ProfileLoading():
        return loading(_that);
      case ProfileLoaded():
        return loaded(_that);
      case ProfileFailure():
        return failure(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ProfileInitial value)? initial,
    TResult? Function(ProfileLoading value)? loading,
    TResult? Function(ProfileLoaded value)? loaded,
    TResult? Function(ProfileFailure value)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case ProfileInitial() when initial != null:
        return initial(_that);
      case ProfileLoading() when loading != null:
        return loading(_that);
      case ProfileLoaded() when loaded != null:
        return loaded(_that);
      case ProfileFailure() when failure != null:
        return failure(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(OwnerProfile profile, ProfileStats stats, bool saving)?
        loaded,
    TResult Function(String message)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ProfileInitial() when initial != null:
        return initial();
      case ProfileLoading() when loading != null:
        return loading();
      case ProfileLoaded() when loaded != null:
        return loaded(_that.profile, _that.stats, _that.saving);
      case ProfileFailure() when failure != null:
        return failure(_that.message);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            OwnerProfile profile, ProfileStats stats, bool saving)
        loaded,
    required TResult Function(String message) failure,
  }) {
    final _that = this;
    switch (_that) {
      case ProfileInitial():
        return initial();
      case ProfileLoading():
        return loading();
      case ProfileLoaded():
        return loaded(_that.profile, _that.stats, _that.saving);
      case ProfileFailure():
        return failure(_that.message);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(OwnerProfile profile, ProfileStats stats, bool saving)?
        loaded,
    TResult? Function(String message)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case ProfileInitial() when initial != null:
        return initial();
      case ProfileLoading() when loading != null:
        return loading();
      case ProfileLoaded() when loaded != null:
        return loaded(_that.profile, _that.stats, _that.saving);
      case ProfileFailure() when failure != null:
        return failure(_that.message);
      case _:
        return null;
    }
  }
}

/// @nodoc

class ProfileInitial implements ProfileState {
  const ProfileInitial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ProfileInitial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ProfileState.initial()';
  }
}

/// @nodoc

class ProfileLoading implements ProfileState {
  const ProfileLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ProfileLoading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ProfileState.loading()';
  }
}

/// @nodoc

class ProfileLoaded implements ProfileState {
  const ProfileLoaded(
      {required this.profile, required this.stats, this.saving = false});

  final OwnerProfile profile;
  final ProfileStats stats;
  @JsonKey()
  final bool saving;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProfileLoadedCopyWith<ProfileLoaded> get copyWith =>
      _$ProfileLoadedCopyWithImpl<ProfileLoaded>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProfileLoaded &&
            (identical(other.profile, profile) || other.profile == profile) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            (identical(other.saving, saving) || other.saving == saving));
  }

  @override
  int get hashCode => Object.hash(runtimeType, profile, stats, saving);

  @override
  String toString() {
    return 'ProfileState.loaded(profile: $profile, stats: $stats, saving: $saving)';
  }
}

/// @nodoc
abstract mixin class $ProfileLoadedCopyWith<$Res>
    implements $ProfileStateCopyWith<$Res> {
  factory $ProfileLoadedCopyWith(
          ProfileLoaded value, $Res Function(ProfileLoaded) _then) =
      _$ProfileLoadedCopyWithImpl;
  @useResult
  $Res call({OwnerProfile profile, ProfileStats stats, bool saving});

  $OwnerProfileCopyWith<$Res> get profile;
  $ProfileStatsCopyWith<$Res> get stats;
}

/// @nodoc
class _$ProfileLoadedCopyWithImpl<$Res>
    implements $ProfileLoadedCopyWith<$Res> {
  _$ProfileLoadedCopyWithImpl(this._self, this._then);

  final ProfileLoaded _self;
  final $Res Function(ProfileLoaded) _then;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? profile = null,
    Object? stats = null,
    Object? saving = null,
  }) {
    return _then(ProfileLoaded(
      profile: null == profile
          ? _self.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as OwnerProfile,
      stats: null == stats
          ? _self.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as ProfileStats,
      saving: null == saving
          ? _self.saving
          : saving // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OwnerProfileCopyWith<$Res> get profile {
    return $OwnerProfileCopyWith<$Res>(_self.profile, (value) {
      return _then(_self.copyWith(profile: value));
    });
  }

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileStatsCopyWith<$Res> get stats {
    return $ProfileStatsCopyWith<$Res>(_self.stats, (value) {
      return _then(_self.copyWith(stats: value));
    });
  }
}

/// @nodoc

class ProfileFailure implements ProfileState {
  const ProfileFailure(this.message);

  final String message;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProfileFailureCopyWith<ProfileFailure> get copyWith =>
      _$ProfileFailureCopyWithImpl<ProfileFailure>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProfileFailure &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'ProfileState.failure(message: $message)';
  }
}

/// @nodoc
abstract mixin class $ProfileFailureCopyWith<$Res>
    implements $ProfileStateCopyWith<$Res> {
  factory $ProfileFailureCopyWith(
          ProfileFailure value, $Res Function(ProfileFailure) _then) =
      _$ProfileFailureCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$ProfileFailureCopyWithImpl<$Res>
    implements $ProfileFailureCopyWith<$Res> {
  _$ProfileFailureCopyWithImpl(this._self, this._then);

  final ProfileFailure _self;
  final $Res Function(ProfileFailure) _then;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(ProfileFailure(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
