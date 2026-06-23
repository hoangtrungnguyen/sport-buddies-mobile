// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ProfileEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ProfileEvent()';
  }
}

/// @nodoc
class $ProfileEventCopyWith<$Res> {
  $ProfileEventCopyWith(ProfileEvent _, $Res Function(ProfileEvent) __);
}

/// Adds pattern-matching-related methods to [ProfileEvent].
extension ProfileEventPatterns on ProfileEvent {
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
    TResult Function(ProfileStarted value)? started,
    TResult Function(ProfileEditSubmitted value)? editSubmitted,
    TResult Function(ProfileTwoFactorToggled value)? twoFactorToggled,
    TResult Function(ProfileEmailNotifToggled value)? emailNotifToggled,
    TResult Function(ProfileAvatarChangeRequested value)? avatarChangeRequested,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ProfileStarted() when started != null:
        return started(_that);
      case ProfileEditSubmitted() when editSubmitted != null:
        return editSubmitted(_that);
      case ProfileTwoFactorToggled() when twoFactorToggled != null:
        return twoFactorToggled(_that);
      case ProfileEmailNotifToggled() when emailNotifToggled != null:
        return emailNotifToggled(_that);
      case ProfileAvatarChangeRequested() when avatarChangeRequested != null:
        return avatarChangeRequested(_that);
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
    required TResult Function(ProfileStarted value) started,
    required TResult Function(ProfileEditSubmitted value) editSubmitted,
    required TResult Function(ProfileTwoFactorToggled value) twoFactorToggled,
    required TResult Function(ProfileEmailNotifToggled value) emailNotifToggled,
    required TResult Function(ProfileAvatarChangeRequested value)
        avatarChangeRequested,
  }) {
    final _that = this;
    switch (_that) {
      case ProfileStarted():
        return started(_that);
      case ProfileEditSubmitted():
        return editSubmitted(_that);
      case ProfileTwoFactorToggled():
        return twoFactorToggled(_that);
      case ProfileEmailNotifToggled():
        return emailNotifToggled(_that);
      case ProfileAvatarChangeRequested():
        return avatarChangeRequested(_that);
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
    TResult? Function(ProfileStarted value)? started,
    TResult? Function(ProfileEditSubmitted value)? editSubmitted,
    TResult? Function(ProfileTwoFactorToggled value)? twoFactorToggled,
    TResult? Function(ProfileEmailNotifToggled value)? emailNotifToggled,
    TResult? Function(ProfileAvatarChangeRequested value)?
        avatarChangeRequested,
  }) {
    final _that = this;
    switch (_that) {
      case ProfileStarted() when started != null:
        return started(_that);
      case ProfileEditSubmitted() when editSubmitted != null:
        return editSubmitted(_that);
      case ProfileTwoFactorToggled() when twoFactorToggled != null:
        return twoFactorToggled(_that);
      case ProfileEmailNotifToggled() when emailNotifToggled != null:
        return emailNotifToggled(_that);
      case ProfileAvatarChangeRequested() when avatarChangeRequested != null:
        return avatarChangeRequested(_that);
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
    TResult Function()? started,
    TResult Function(OwnerProfile draft)? editSubmitted,
    TResult Function(bool enabled)? twoFactorToggled,
    TResult Function(bool enabled)? emailNotifToggled,
    TResult Function(Uint8List bytes, String filename)? avatarChangeRequested,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ProfileStarted() when started != null:
        return started();
      case ProfileEditSubmitted() when editSubmitted != null:
        return editSubmitted(_that.draft);
      case ProfileTwoFactorToggled() when twoFactorToggled != null:
        return twoFactorToggled(_that.enabled);
      case ProfileEmailNotifToggled() when emailNotifToggled != null:
        return emailNotifToggled(_that.enabled);
      case ProfileAvatarChangeRequested() when avatarChangeRequested != null:
        return avatarChangeRequested(_that.bytes, _that.filename);
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
    required TResult Function() started,
    required TResult Function(OwnerProfile draft) editSubmitted,
    required TResult Function(bool enabled) twoFactorToggled,
    required TResult Function(bool enabled) emailNotifToggled,
    required TResult Function(Uint8List bytes, String filename)
        avatarChangeRequested,
  }) {
    final _that = this;
    switch (_that) {
      case ProfileStarted():
        return started();
      case ProfileEditSubmitted():
        return editSubmitted(_that.draft);
      case ProfileTwoFactorToggled():
        return twoFactorToggled(_that.enabled);
      case ProfileEmailNotifToggled():
        return emailNotifToggled(_that.enabled);
      case ProfileAvatarChangeRequested():
        return avatarChangeRequested(_that.bytes, _that.filename);
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
    TResult? Function()? started,
    TResult? Function(OwnerProfile draft)? editSubmitted,
    TResult? Function(bool enabled)? twoFactorToggled,
    TResult? Function(bool enabled)? emailNotifToggled,
    TResult? Function(Uint8List bytes, String filename)? avatarChangeRequested,
  }) {
    final _that = this;
    switch (_that) {
      case ProfileStarted() when started != null:
        return started();
      case ProfileEditSubmitted() when editSubmitted != null:
        return editSubmitted(_that.draft);
      case ProfileTwoFactorToggled() when twoFactorToggled != null:
        return twoFactorToggled(_that.enabled);
      case ProfileEmailNotifToggled() when emailNotifToggled != null:
        return emailNotifToggled(_that.enabled);
      case ProfileAvatarChangeRequested() when avatarChangeRequested != null:
        return avatarChangeRequested(_that.bytes, _that.filename);
      case _:
        return null;
    }
  }
}

/// @nodoc

class ProfileStarted implements ProfileEvent {
  const ProfileStarted();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ProfileStarted);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ProfileEvent.started()';
  }
}

/// @nodoc

class ProfileEditSubmitted implements ProfileEvent {
  const ProfileEditSubmitted(this.draft);

  final OwnerProfile draft;

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProfileEditSubmittedCopyWith<ProfileEditSubmitted> get copyWith =>
      _$ProfileEditSubmittedCopyWithImpl<ProfileEditSubmitted>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProfileEditSubmitted &&
            (identical(other.draft, draft) || other.draft == draft));
  }

  @override
  int get hashCode => Object.hash(runtimeType, draft);

  @override
  String toString() {
    return 'ProfileEvent.editSubmitted(draft: $draft)';
  }
}

/// @nodoc
abstract mixin class $ProfileEditSubmittedCopyWith<$Res>
    implements $ProfileEventCopyWith<$Res> {
  factory $ProfileEditSubmittedCopyWith(ProfileEditSubmitted value,
          $Res Function(ProfileEditSubmitted) _then) =
      _$ProfileEditSubmittedCopyWithImpl;
  @useResult
  $Res call({OwnerProfile draft});

  $OwnerProfileCopyWith<$Res> get draft;
}

/// @nodoc
class _$ProfileEditSubmittedCopyWithImpl<$Res>
    implements $ProfileEditSubmittedCopyWith<$Res> {
  _$ProfileEditSubmittedCopyWithImpl(this._self, this._then);

  final ProfileEditSubmitted _self;
  final $Res Function(ProfileEditSubmitted) _then;

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? draft = null,
  }) {
    return _then(ProfileEditSubmitted(
      null == draft
          ? _self.draft
          : draft // ignore: cast_nullable_to_non_nullable
              as OwnerProfile,
    ));
  }

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OwnerProfileCopyWith<$Res> get draft {
    return $OwnerProfileCopyWith<$Res>(_self.draft, (value) {
      return _then(_self.copyWith(draft: value));
    });
  }
}

/// @nodoc

class ProfileTwoFactorToggled implements ProfileEvent {
  const ProfileTwoFactorToggled(this.enabled);

  final bool enabled;

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProfileTwoFactorToggledCopyWith<ProfileTwoFactorToggled> get copyWith =>
      _$ProfileTwoFactorToggledCopyWithImpl<ProfileTwoFactorToggled>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProfileTwoFactorToggled &&
            (identical(other.enabled, enabled) || other.enabled == enabled));
  }

  @override
  int get hashCode => Object.hash(runtimeType, enabled);

  @override
  String toString() {
    return 'ProfileEvent.twoFactorToggled(enabled: $enabled)';
  }
}

/// @nodoc
abstract mixin class $ProfileTwoFactorToggledCopyWith<$Res>
    implements $ProfileEventCopyWith<$Res> {
  factory $ProfileTwoFactorToggledCopyWith(ProfileTwoFactorToggled value,
          $Res Function(ProfileTwoFactorToggled) _then) =
      _$ProfileTwoFactorToggledCopyWithImpl;
  @useResult
  $Res call({bool enabled});
}

/// @nodoc
class _$ProfileTwoFactorToggledCopyWithImpl<$Res>
    implements $ProfileTwoFactorToggledCopyWith<$Res> {
  _$ProfileTwoFactorToggledCopyWithImpl(this._self, this._then);

  final ProfileTwoFactorToggled _self;
  final $Res Function(ProfileTwoFactorToggled) _then;

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? enabled = null,
  }) {
    return _then(ProfileTwoFactorToggled(
      null == enabled
          ? _self.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class ProfileEmailNotifToggled implements ProfileEvent {
  const ProfileEmailNotifToggled(this.enabled);

  final bool enabled;

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProfileEmailNotifToggledCopyWith<ProfileEmailNotifToggled> get copyWith =>
      _$ProfileEmailNotifToggledCopyWithImpl<ProfileEmailNotifToggled>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProfileEmailNotifToggled &&
            (identical(other.enabled, enabled) || other.enabled == enabled));
  }

  @override
  int get hashCode => Object.hash(runtimeType, enabled);

  @override
  String toString() {
    return 'ProfileEvent.emailNotifToggled(enabled: $enabled)';
  }
}

/// @nodoc
abstract mixin class $ProfileEmailNotifToggledCopyWith<$Res>
    implements $ProfileEventCopyWith<$Res> {
  factory $ProfileEmailNotifToggledCopyWith(ProfileEmailNotifToggled value,
          $Res Function(ProfileEmailNotifToggled) _then) =
      _$ProfileEmailNotifToggledCopyWithImpl;
  @useResult
  $Res call({bool enabled});
}

/// @nodoc
class _$ProfileEmailNotifToggledCopyWithImpl<$Res>
    implements $ProfileEmailNotifToggledCopyWith<$Res> {
  _$ProfileEmailNotifToggledCopyWithImpl(this._self, this._then);

  final ProfileEmailNotifToggled _self;
  final $Res Function(ProfileEmailNotifToggled) _then;

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? enabled = null,
  }) {
    return _then(ProfileEmailNotifToggled(
      null == enabled
          ? _self.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class ProfileAvatarChangeRequested implements ProfileEvent {
  const ProfileAvatarChangeRequested(this.bytes,
      {this.filename = 'avatar.jpg'});

  final Uint8List bytes;
  @JsonKey()
  final String filename;

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProfileAvatarChangeRequestedCopyWith<ProfileAvatarChangeRequested>
      get copyWith => _$ProfileAvatarChangeRequestedCopyWithImpl<
          ProfileAvatarChangeRequested>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProfileAvatarChangeRequested &&
            const DeepCollectionEquality().equals(other.bytes, bytes) &&
            (identical(other.filename, filename) ||
                other.filename == filename));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(bytes), filename);

  @override
  String toString() {
    return 'ProfileEvent.avatarChangeRequested(bytes: $bytes, filename: $filename)';
  }
}

/// @nodoc
abstract mixin class $ProfileAvatarChangeRequestedCopyWith<$Res>
    implements $ProfileEventCopyWith<$Res> {
  factory $ProfileAvatarChangeRequestedCopyWith(
          ProfileAvatarChangeRequested value,
          $Res Function(ProfileAvatarChangeRequested) _then) =
      _$ProfileAvatarChangeRequestedCopyWithImpl;
  @useResult
  $Res call({Uint8List bytes, String filename});
}

/// @nodoc
class _$ProfileAvatarChangeRequestedCopyWithImpl<$Res>
    implements $ProfileAvatarChangeRequestedCopyWith<$Res> {
  _$ProfileAvatarChangeRequestedCopyWithImpl(this._self, this._then);

  final ProfileAvatarChangeRequested _self;
  final $Res Function(ProfileAvatarChangeRequested) _then;

  /// Create a copy of ProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? bytes = null,
    Object? filename = null,
  }) {
    return _then(ProfileAvatarChangeRequested(
      null == bytes
          ? _self.bytes
          : bytes // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      filename: null == filename
          ? _self.filename
          : filename // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
