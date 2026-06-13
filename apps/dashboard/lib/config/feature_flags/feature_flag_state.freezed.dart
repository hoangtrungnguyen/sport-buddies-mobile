// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feature_flag_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeatureFlagState {
  bool get ready;
  Map<String, FeatureFlag> get flags;

  /// Create a copy of FeatureFlagState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FeatureFlagStateCopyWith<FeatureFlagState> get copyWith =>
      _$FeatureFlagStateCopyWithImpl<FeatureFlagState>(
          this as FeatureFlagState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FeatureFlagState &&
            (identical(other.ready, ready) || other.ready == ready) &&
            const DeepCollectionEquality().equals(other.flags, flags));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, ready, const DeepCollectionEquality().hash(flags));

  @override
  String toString() {
    return 'FeatureFlagState(ready: $ready, flags: $flags)';
  }
}

/// @nodoc
abstract mixin class $FeatureFlagStateCopyWith<$Res> {
  factory $FeatureFlagStateCopyWith(
          FeatureFlagState value, $Res Function(FeatureFlagState) _then) =
      _$FeatureFlagStateCopyWithImpl;
  @useResult
  $Res call({bool ready, Map<String, FeatureFlag> flags});
}

/// @nodoc
class _$FeatureFlagStateCopyWithImpl<$Res>
    implements $FeatureFlagStateCopyWith<$Res> {
  _$FeatureFlagStateCopyWithImpl(this._self, this._then);

  final FeatureFlagState _self;
  final $Res Function(FeatureFlagState) _then;

  /// Create a copy of FeatureFlagState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ready = null,
    Object? flags = null,
  }) {
    return _then(_self.copyWith(
      ready: null == ready
          ? _self.ready
          : ready // ignore: cast_nullable_to_non_nullable
              as bool,
      flags: null == flags
          ? _self.flags
          : flags // ignore: cast_nullable_to_non_nullable
              as Map<String, FeatureFlag>,
    ));
  }
}

/// Adds pattern-matching-related methods to [FeatureFlagState].
extension FeatureFlagStatePatterns on FeatureFlagState {
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
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_FeatureFlagState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FeatureFlagState() when $default != null:
        return $default(_that);
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
  TResult map<TResult extends Object?>(
    TResult Function(_FeatureFlagState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FeatureFlagState():
        return $default(_that);
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
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_FeatureFlagState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FeatureFlagState() when $default != null:
        return $default(_that);
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
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(bool ready, Map<String, FeatureFlag> flags)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FeatureFlagState() when $default != null:
        return $default(_that.ready, _that.flags);
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
  TResult when<TResult extends Object?>(
    TResult Function(bool ready, Map<String, FeatureFlag> flags) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FeatureFlagState():
        return $default(_that.ready, _that.flags);
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
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(bool ready, Map<String, FeatureFlag> flags)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FeatureFlagState() when $default != null:
        return $default(_that.ready, _that.flags);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _FeatureFlagState extends FeatureFlagState {
  const _FeatureFlagState(
      {this.ready = false,
      final Map<String, FeatureFlag> flags = const <String, FeatureFlag>{}})
      : _flags = flags,
        super._();

  @override
  @JsonKey()
  final bool ready;
  final Map<String, FeatureFlag> _flags;
  @override
  @JsonKey()
  Map<String, FeatureFlag> get flags {
    if (_flags is EqualUnmodifiableMapView) return _flags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_flags);
  }

  /// Create a copy of FeatureFlagState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FeatureFlagStateCopyWith<_FeatureFlagState> get copyWith =>
      __$FeatureFlagStateCopyWithImpl<_FeatureFlagState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FeatureFlagState &&
            (identical(other.ready, ready) || other.ready == ready) &&
            const DeepCollectionEquality().equals(other._flags, _flags));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, ready, const DeepCollectionEquality().hash(_flags));

  @override
  String toString() {
    return 'FeatureFlagState(ready: $ready, flags: $flags)';
  }
}

/// @nodoc
abstract mixin class _$FeatureFlagStateCopyWith<$Res>
    implements $FeatureFlagStateCopyWith<$Res> {
  factory _$FeatureFlagStateCopyWith(
          _FeatureFlagState value, $Res Function(_FeatureFlagState) _then) =
      __$FeatureFlagStateCopyWithImpl;
  @override
  @useResult
  $Res call({bool ready, Map<String, FeatureFlag> flags});
}

/// @nodoc
class __$FeatureFlagStateCopyWithImpl<$Res>
    implements _$FeatureFlagStateCopyWith<$Res> {
  __$FeatureFlagStateCopyWithImpl(this._self, this._then);

  final _FeatureFlagState _self;
  final $Res Function(_FeatureFlagState) _then;

  /// Create a copy of FeatureFlagState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? ready = null,
    Object? flags = null,
  }) {
    return _then(_FeatureFlagState(
      ready: null == ready
          ? _self.ready
          : ready // ignore: cast_nullable_to_non_nullable
              as bool,
      flags: null == flags
          ? _self._flags
          : flags // ignore: cast_nullable_to_non_nullable
              as Map<String, FeatureFlag>,
    ));
  }
}

// dart format on
